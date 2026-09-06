class_name DistrictBoost
extends Node
signal changed
const DEFINITION: BoostDefinition = preload("res://data/missions/first_boost.tres")
var game: DistrictGame
var target: ToyCompact
var state: StringName = &"available"
var used: Array[int] = []
var objective: String = "Answer a ringing payphone [E] for a Boost job."
var retry_timer: float = 0
var rng := RandomNumberGenerator.new()
func _ready() -> void:
	rng.seed = game.run.seed_value
	Events.phone_answered.connect(accept)
	Events.vehicle_entered.connect(acquired)
	Events.vehicle_destroyed.connect(destroyed)
func set_phones(available: bool) -> void:
	for phone: Node in get_tree().get_nodes_in_group("interactables"):
		phone.available = available
		for child: Node in phone.get_children():
			if child is DistrictMarker:
				child.active = available
func accept(_phone: Node2D) -> void:
	if state != &"available":
		return
	var candidates: Array[int] = []
	for i: int in DEFINITION.eligible_vehicle_indices:
		if i < game.cars.size() and not i in used and not game.cars[i].disabled and game.cars[i].failure_timer < 0 and game.cars[i].driver == null:
			candidates.append(i)
	if candidates.is_empty():
		objective = "NO VIABLE BOOST TARGETS / R starts a fresh district."
		state = &"exhausted"
		set_phones(false)
		changed.emit()
		return
	var selected := candidates[rng.randi_range(0, candidates.size() - 1)]
	used.append(selected)
	target = game.cars[selected]
	state = &"steal"
	objective = "BOOST / Steal the marked " + target.data.title + " [E]"
	set_phones(false)
	Events.sound_requested.emit(&"mission")
	Events.message_requested.emit(DEFINITION.title + " / $%d + one Notoriety tier" % DEFINITION.reward)
	changed.emit()
func acquired(vehicle: Node2D) -> void:
	if vehicle != target or not state in [&"steal", &"deliver"]:
		return
	state = &"deliver"
	objective = "BOOST / Deliver this vehicle to the east garage. Stop inside the gold box."
	Events.sound_requested.emit(&"mission")
	Events.message_requested.emit("TARGET ACQUIRED / Garage marked on your map.")
	changed.emit()
func destroyed(vehicle: Node2D) -> void:
	if vehicle != target or not state in [&"steal", &"deliver"]:
		return
	state = &"failed"
	target = null
	retry_timer = 4
	objective = "BOOST FAILED / Target destroyed. Another phone offer in four seconds."
	Events.message_requested.emit(objective)
	changed.emit()
func destination() -> Vector2:
	if state == &"steal" and is_instance_valid(target):
		return target.global_position
	if state == &"deliver" and is_instance_valid(target):
		return game.layout.garage if game.player.vehicle == target else target.global_position
	return Vector2.INF
func _process(delta: float) -> void:
	if state == &"failed":
		retry_timer -= delta
		if retry_timer <= 0:
			state = &"available"
			objective = "Answer another payphone [E]. The destroyed target is retired."
			set_phones(true)
			changed.emit()
	if state == &"deliver" and target != null and target.driver == game.player and target.failure_timer < 0 and target.global_position.distance_to(game.layout.garage) < DEFINITION.delivery_radius and absf(target.speed) < DEFINITION.delivery_speed:
		state = &"complete"
		target = null
		objective = "BOOST COMPLETE / +$%d and +1 Notoriety. Free play; R repeats the district." % DEFINITION.reward
		# This pass offers one completed job per run, never the same target twice.
		set_phones(false)
		Events.mission_completed.emit(DEFINITION.reward)
		changed.emit()
