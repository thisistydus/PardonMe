class_name MissionBoard
extends Node
## Owns offers, the single active job, run-level mission counts and reward issue.
## Jobs own their objectives and objects; rewards reach the score only through here.
signal changed
var game: DistrictGame
var missions: Array[DistrictMission] = []
var active: DistrictMission
var attempted: int = 0
var completed: int = 0
var failed: int = 0
## One entry per attempt: {"title", "kind", "outcome", "cash", "notoriety", "bonuses", "reason"}
var history: Array[Dictionary] = []
var retired: Array[Node2D] = []
var retire_timer: float = 1.0
const IDLE_TEXT: String = "Answer a ringing payphone [E] for work."

func _ready() -> void:
	Events.phone_answered.connect(on_phone)
	Events.run_ended.connect(on_run_ended)
	game.clock.hour_reached.connect(on_hour)

func register(mission: DistrictMission) -> void:
	mission.game = game
	mission.board = self
	missions.append(mission)
	mission.changed.connect(changed.emit)

func clock_allows(definition: MissionDefinition) -> bool:
	return game.clock.is_within(definition.available_from_hour, definition.available_until_hour)

func can_start(mission: DistrictMission) -> bool:
	return not game.run.ended and (active == null or active == mission)

func on_phone(phone: Node2D) -> void:
	var offer: DistrictMission = phone.get("offer")
	if offer != null:
		offer.accept(phone)

func on_started(mission: DistrictMission) -> void:
	active = mission
	attempted += 1
	history.append({"title": mission.definition.title, "kind": mission.definition.kind_label, "outcome": &"active", "cash": 0, "notoriety": 0, "bonuses": [], "reason": ""})
	Events.message_requested.emit("%s / %s / $%d + %d Notoriety%s" % [mission.definition.kind_label, mission.definition.title, mission.definition.cash_reward, mission.definition.notoriety_reward, (" / %.0fs" % mission.definition.time_limit) if mission.definition.time_limit > 0 else ""])
	refresh_phones()
	changed.emit()

func on_finished(mission: DistrictMission, success: bool, reason: String) -> void:
	if active == mission:
		active = null
	var entry: Dictionary = history.back() if not history.is_empty() else {}
	if success:
		completed += 1
		var bonus_cash: int = 0
		var labels: Array[String] = []
		for bonus: Dictionary in mission.bonuses:
			bonus_cash += int(bonus.cash)
			labels.append(bonus.label)
		game.score.award_mission(mission.definition, bonus_cash, labels)
		entry.outcome = &"complete"
		entry.cash = mission.definition.cash_reward + bonus_cash
		entry.notoriety = mission.definition.notoriety_reward
		entry.bonuses = labels
		Events.mission_completed.emit(mission.definition.cash_reward + bonus_cash)
	else:
		failed += 1
		entry.outcome = &"failed"
		entry.reason = reason
	refresh_phones()
	changed.emit()

func on_run_ended(outcome: StringName) -> void:
	if active != null:
		active.abort("RUN ENDED / " + ("Died on the job." if outcome == &"died" else "Dawn arrived mid-job."))
	for phone: DistrictPhone in game.phones:
		phone.set_available(false)

func on_hour(_hour: int) -> void:
	# Availability windows are data-ready; all C1 jobs are open all day.
	refresh_phones()

func refresh_phones() -> void:
	for phone: DistrictPhone in game.phones:
		phone.set_available(not game.run.ended and active == null and phone.offer != null and phone.offer.can_offer())

## Mission-owned actors or vehicles that should leave once nobody can see them.
func retire(node: Node2D) -> void:
	if is_instance_valid(node) and not node in retired:
		retired.append(node)

func _physics_process(delta: float) -> void:
	retire_timer -= delta
	if retire_timer > 0:
		return
	retire_timer = 1.0
	for node: Node2D in retired.duplicate():
		if not is_instance_valid(node):
			retired.erase(node)
			continue
		var in_use := node is ToyCompact and (node as ToyCompact).driver != null
		if not in_use and game.director.offscreen(node.global_position):
			retired.erase(node)
			if node is DistrictNPC:
				game.citizens.erase(node)
			if node is ToyCompact:
				game.cars.erase(node)
			node.queue_free()

func objective() -> String:
	if active != null:
		return active.objective
	for mission: DistrictMission in missions:
		if mission.state == &"failed" and mission.retry_timer > 0:
			return mission.objective
	var offers: Array[String] = []
	for phone: DistrictPhone in game.phones:
		if phone.available:
			offers.append(phone.offer.definition.kind_label)
	if offers.is_empty():
		return "No phones ringing. Free play until dawn — street cash still counts."
	return "Answer a ringing payphone [E]: " + " · ".join(offers)

func destination() -> Vector2:
	return active.destination() if active != null else Vector2.INF

func markers() -> Array[Dictionary]:
	return active.world_markers() if active != null else []
