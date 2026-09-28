class_name DistrictMission
extends Node
## Smallest shared job lifecycle: offer → accept → template states → complete/fail → cleanup → retry.
## Templates override begin(), tick(), cleanup(), destination() and world_markers().
signal changed
var game: DistrictGame
var board: MissionBoard
var definition: MissionDefinition
var state: StringName = &"available"
var objective: String = ""
var elapsed: float = 0.0
var retry_timer: float = 0.0
var bonuses: Array[Dictionary] = []
const IDLE_STATES: Array[StringName] = [&"available", &"complete", &"failed", &"exhausted"]

func is_active() -> bool:
	return not state in IDLE_STATES

func can_offer() -> bool:
	return state == &"available" and board.clock_allows(definition)

## Called by the payphone route or directly. Returns true only when the job actually starts.
func accept(_phone: Node2D = null) -> bool:
	if state != &"available" or not board.can_start(self):
		return false
	elapsed = 0.0
	bonuses.clear()
	if not begin():
		board.refresh_phones()
		changed.emit()
		return false
	board.on_started(self)
	Events.sound_requested.emit(&"mission")
	changed.emit()
	return true

func _physics_process(delta: float) -> void:
	if state == &"failed" and retry_timer > 0:
		retry_timer -= delta
		if retry_timer <= 0 and not game.run.ended:
			state = &"available"
			objective = retry_message()
			board.refresh_phones()
			changed.emit()
		return
	if not is_active():
		return
	elapsed += delta
	if definition.time_limit > 0 and elapsed >= definition.time_limit and can_time_out():
		fail("%s FAILED / Out of time." % definition.kind_label)
		return
	tick(delta)

func time_left() -> float:
	return maxf(0.0, definition.time_limit - elapsed) if definition.time_limit > 0 else -1.0

func add_bonus(label: String, cash: int) -> void:
	bonuses.append({"label": label, "cash": cash})

func complete() -> void:
	if not is_active():
		return
	state = &"complete"
	cleanup()
	objective = "%s COMPLETE / Free play. Other payphones may still be ringing." % definition.kind_label
	board.on_finished(self, true, "")
	changed.emit()

func fail(reason: String, retry: bool = true) -> void:
	if not is_active():
		return
	state = &"failed"
	retry_timer = definition.retry_delay if retry else 0.0
	cleanup()
	objective = reason + (" Phone rings again in %.0f seconds." % definition.retry_delay if retry and definition.retry_delay > 0 else "")
	Events.sound_requested.emit(&"mission_fail")
	Events.message_requested.emit(objective)
	board.on_finished(self, false, reason)
	changed.emit()

## Run ended (death or dawn) mid-job: record the failure, tidy up, never retry.
func abort(reason: String) -> void:
	if not is_active():
		return
	state = &"failed"
	retry_timer = 0.0
	cleanup()
	objective = reason
	board.on_finished(self, false, reason)
	changed.emit()

func retry_message() -> String:
	return "%s offer is ringing again [E]." % definition.kind_label

# --- Template hooks -------------------------------------------------------
func begin() -> bool:
	return false

func tick(_delta: float) -> void:
	pass

## Templates may veto a timeout while a non-interruptible step (such as a handoff) runs.
func can_time_out() -> bool:
	return true

func cleanup() -> void:
	pass

func destination() -> Vector2:
	return Vector2.INF

## World and minimap presentation: [{"p": Vector2, "label": String, "kind": StringName, "radius": float}]
func world_markers() -> Array[Dictionary]:
	var point := destination()
	if point == Vector2.INF:
		return []
	return [{"p": point, "label": definition.kind_label, "kind": &"objective", "radius": 68.0}]
