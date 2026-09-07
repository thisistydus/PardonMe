class_name DistrictBoost
extends Node
signal changed
const DEFINITION: BoostDefinition = preload("res://data/missions/first_boost.tres")
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
var eligible: Array[ToyCompact] = []
var transfer_time: float = 0
var game: DistrictGame
var target: ToyCompact
var state: StringName = &"available"
var used: Array[int] = []
var objective: String = "Answer a ringing payphone [E] for a Boost job."
var retry_timer: float = 0
var rng := RandomNumberGenerator.new()
func _ready() -> void:
	add_to_group("vehicle_interactions")
	for i: int in DEFINITION.eligible_vehicle_indices:
		if i < game.cars.size(): eligible.append(game.cars[i])
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
	var candidates: Array[ToyCompact] = []
	for vehicle: ToyCompact in eligible:
		if is_instance_valid(vehicle) and not vehicle.get_instance_id() in used and not vehicle.disabled and vehicle.failure_timer < 0 and vehicle.driver == null:
			candidates.append(vehicle)
	if candidates.is_empty():
		objective = "NO VIABLE BOOST TARGETS / R starts a fresh district."
		state = &"exhausted"
		set_phones(false)
		changed.emit()
		return
	var selected := candidates[rng.randi_range(0, candidates.size() - 1)]
	used.append(selected.get_instance_id())
	target = selected
	state = &"steal"
	objective = "BOOST / Steal the marked " + target.data.title + " [E]"
	set_phones(false)
	Events.sound_requested.emit(&"mission")
	Events.message_requested.emit(DEFINITION.title + " / $%d + one Notoriety tier" % BALANCE.boost_reward)
	changed.emit()
func acquired(vehicle: Node2D) -> void:
	if vehicle != target or not state in [&"steal", &"deliver"]:
		return
	state = &"deliver"
	objective = "BOOST / Deliver this vehicle to the east garage. Stop inside the gold box, then press E to deliver."
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
	if state == &"transferring":
		transfer_time -= delta
		target.modulate.a = clampf(transfer_time / 0.65, 0, 1)
		if transfer_time <= 0:
			finish_delivery()

func delivery_ready() -> bool:
	return state == &"deliver" and is_instance_valid(target) and target.driver == game.player and not target.disabled and not target.unavailable and target.failure_timer < 0 and target.global_position.distance_to(game.layout.garage) < DEFINITION.delivery_radius and absf(target.speed) < DEFINITION.delivery_speed

func try_interact(actor: ToyPlayer) -> bool:
	if actor != game.player or not delivery_ready(): return false
	# Authored exterior handoff points; validate before locking or rewarding.
	var exit_point := Vector2.INF
	for offset: Vector2 in [Vector2(-125, 0), Vector2(0, 125), Vector2(125, 0)]:
		var query := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 17
		query.shape = circle
		query.transform = Transform2D(0, game.layout.garage + offset)
		query.collision_mask = 1 | 4 | 8
		if actor.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
			exit_point = game.layout.garage + offset
			break
	if exit_point == Vector2.INF:
		Events.message_requested.emit("GARAGE EXIT BLOCKED / Clear the apron before delivery.")
		return true
	if not target.try_exit(): return true
	actor.global_position = exit_point
	state = &"transferring"
	transfer_time = 0.65
	target.unavailable = true
	target.remove_from_group("vehicles")
	target.remove_from_group("damageable")
	target.speed = 0
	target.velocity = Vector2.ZERO
	actor.control_locked = true
	actor.invulnerability = maxf(actor.invulnerability, 1.5)
	objective = "GARAGE RECEIPT / Transferring vehicle…"
	changed.emit()
	return true

func finish_delivery() -> void:
	if state != &"transferring": return
	state = &"complete"
	game.hud.car = game.car
	game.cars.erase(target)
	eligible.erase(target)
	target.queue_free()
	target = null
	game.player.control_locked = false
	objective = "BOOST COMPLETE / Vehicle surrendered. Free play; R restarts the district."
	set_phones(false)
	Events.mission_completed.emit(BALANCE.boost_reward)
	changed.emit()
