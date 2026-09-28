class_name DistrictDestroy
extends DistrictMission
## destroy (marked cars placed; one bolts when spooked) → leave → complete.
## Only destruction attributed to the player by the existing rules counts.
const DEFINITION: DestroyDefinition = preload("res://data/missions/warehouse_destroy.tres")
var targets: Array[ToyCompact] = []
var destroyed_count: int = 0
var first_kill: float = -1.0
var last_kill: float = -1.0
var chained: bool = false
var runner: ToyCompact
var running: bool = false
var hijacked: bool = false
var exit_point := Vector2.INF
var follower := RoadFollower.new()
var centroid := Vector2.ZERO

func _init() -> void:
	definition = DEFINITION

func _ready() -> void:
	Events.vehicle_destroyed.connect(on_vehicle_destroyed)

func begin() -> bool:
	var placements: Array[Transform2D] = []
	for i: int in DEFINITION.target_positions.size():
		var angle: float = DEFINITION.target_rotations[i] if i < DEFINITION.target_rotations.size() else 0.0
		var spot := clear_spot(DEFINITION.target_positions[i], angle)
		if spot == Vector2.INF:
			objective = "DESTROY / The marks' parking is blocked. Try the phone again shortly."
			return false
		placements.append(Transform2D(angle, spot))
	targets.clear()
	destroyed_count = 0
	first_kill = -1.0
	last_kill = -1.0
	chained = false
	running = false
	hijacked = false
	runner = null
	centroid = Vector2.ZERO
	for i: int in placements.size():
		var car := ToyCompact.new()
		car.data = DEFINITION.target_vehicle
		car.position = placements[i].origin
		car.rotation = placements[i].get_rotation()
		game.add_child(car)
		game.cars.append(car)
		targets.append(car)
		centroid += car.position / placements.size()
		if i == DEFINITION.runner_index:
			runner = car
	state = &"destroy"
	objective = "DESTROY / Wreck %d marked sedans near the Warehouse Cut. One of them will run." % targets.size()
	return true

func clear_spot(point: Vector2, angle: float) -> Vector2:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(96, 54)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.collision_mask = 1 | 2 | 4 | 8
	for offset: Vector2 in [Vector2.ZERO, Vector2(0, 120), Vector2(0, -120), Vector2(140, 0), Vector2(-140, 0)]:
		query.transform = Transform2D(angle, point + offset.rotated(angle))
		if game.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
			return point + offset.rotated(angle)
	return Vector2.INF

func tick(delta: float) -> void:
	if state == &"leave":
		if game.player.global_position.distance_to(centroid) > DEFINITION.leave_radius:
			complete()
		return
	if state != &"destroy" or not is_instance_valid(runner) or runner.disabled:
		return
	if runner.driver != null:
		hijacked = true
	if hijacked:
		return
	if runner.failure_timer >= 0:
		# A burning mark stops dead rather than fleeing on a lit fuse.
		runner.ai_throttle = 0
		runner.ai_brake = true
		return
	if not running and (runner.health < runner.data.durability or game.player.global_position.distance_to(runner.global_position) < DEFINITION.spook_radius):
		start_running()
	if running and runner.driver == null:
		runner.ai_controlled = true
		follower.drive(runner, delta)
		if runner.global_position.distance_to(exit_point) < DEFINITION.escape_distance:
			var escaped := runner
			targets.erase(escaped)
			runner = null
			game.cars.erase(escaped)
			escaped.queue_free()
			fail("DESTROY FAILED / A marked sedan escaped the district.")

func start_running() -> void:
	running = true
	var best := -INF
	for point: Vector2 in DEFINITION.exit_points:
		var margin := game.player.global_position.distance_to(point) - runner.global_position.distance_to(point)
		if margin > best:
			best = margin
			exit_point = point
	follower.plan(runner.global_position, exit_point)
	runner.ai_controlled = true
	runner.engine_voice.play()
	Events.message_requested.emit("THE MARK IS RUNNING / Stop it before it leaves the district.")
	Events.sound_requested.emit(&"police_alert")
	changed.emit()

func on_vehicle_destroyed(vehicle: Node2D) -> void:
	if state != &"destroy" or not vehicle in targets:
		return
	var car := vehicle as ToyCompact
	if not car.player_responsible:
		fail("DESTROY FAILED / Someone else wrecked a mark. No credit, no pay.")
		return
	if car == runner:
		runner.ai_controlled = false
		running = false
	destroyed_count += 1
	if car.chain_token != 0:
		chained = true
	last_kill = elapsed
	if first_kill < 0:
		first_kill = elapsed
	if destroyed_count < targets.size():
		objective = "DESTROY / %d of %d wrecked." % [destroyed_count, targets.size()]
		changed.emit()
		return
	if chained:
		add_bonus("CHAIN REACTION", DEFINITION.chain_bonus)
	if targets.size() > 1 and last_kill - first_kill <= DEFINITION.multi_window:
		add_bonus("MULTI-WRECK", DEFINITION.multi_bonus)
	if DEFINITION.leave_radius > 0:
		state = &"leave"
		objective = "DESTROY / All marks wrecked. Get clear of the scene."
		changed.emit()
	else:
		complete()

func cleanup() -> void:
	for car: ToyCompact in targets:
		if not is_instance_valid(car):
			continue
		car.ai_controlled = false
		car.ai_throttle = 0
		car.ai_brake = true
		if not car.disabled and car.failure_timer < 0:
			board.retire(car)
	running = false

func destination() -> Vector2:
	if state == &"leave":
		return Vector2.INF
	var nearest := Vector2.INF
	for car: ToyCompact in targets:
		if is_instance_valid(car) and not car.disabled and (nearest == Vector2.INF or car.global_position.distance_squared_to(game.player.global_position) < nearest.distance_squared_to(game.player.global_position)):
			nearest = car.global_position
	return nearest

func world_markers() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if state == &"leave":
		result.append({"p": centroid, "label": "GET CLEAR", "kind": &"escape", "radius": DEFINITION.leave_radius})
		return result
	for car: ToyCompact in targets:
		if is_instance_valid(car) and not car.disabled:
			result.append({"p": car.global_position, "label": "RUNNING" if car == runner and running else "DESTROY", "kind": &"destroy", "radius": 60.0})
	return result
