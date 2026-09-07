class_name PoliceResponse
extends Node2D
## Owns response lifetimes. One roadblock per escalation, cleared only at low Heat.
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
const PATROL: VehicleData = preload("res://data/vehicles/patrol.tres")
var game: DistrictGame
var cruisers: Array[PoliceCruiserBrain] = []
var roadblock_cars: Array[ToyCompact] = []
var roadblock_officers: Array[DistrictNPC] = []
var anchor := Vector2.INF
var anchors: Array[Vector2] = [Vector2(3500, 600), Vector2(1600, 1800), Vector2(3500, 3000)]
var road_spawns: Array[Vector2] = [Vector2(300, 600), Vector2(700, 300), Vector2(4500, 600), Vector2(4500, 1800), Vector2(4100, 3300), Vector2(300, 3000)]
var timer: float = 2
var vehicle_timer: float = 4
var roadblock_used: bool = false
var discovered: bool = false
var enabled: bool = true
func _physics_process(delta: float) -> void:
	if not enabled: return
	timer -= delta
	vehicle_timer -= delta
	if timer > 0: return
	timer = 1
	if game.heat.level <= BALANCE.roadblock_clear_heat:
		clear_roadblock()
		roadblock_used = false
	if game.heat.level >= BALANCE.roadblock_heat and not roadblock_used:
		spawn_roadblock()
	if game.heat.level >= BALANCE.vehicle_heat and vehicle_timer <= 0:
		vehicle_timer = BALANCE.vehicle_delay
		if cruisers.size() < BALANCE.vehicle_cap:
			spawn_cruiser()
	for brain: PoliceCruiserBrain in cruisers.duplicate():
		if not is_instance_valid(brain):
			cruisers.erase(brain)
		elif game.heat.level == 0 and brain.car.driver == null and game.director.offscreen(brain.car.global_position):
			game.cars.erase(brain.car)
			brain.car.queue_free()
			cruisers.erase(brain)
func make_car(at: Vector2, angle: float) -> ToyCompact:
	var car := ToyCompact.new()
	car.data = PATROL
	car.position = at
	car.rotation = angle
	game.add_child(car)
	game.cars.append(car)
	return car
func spawn_cruiser() -> PoliceCruiserBrain:
	for point: Vector2 in road_spawns:
		if not game.director.offscreen(point) or not clear_spawn(point): continue
		var car := make_car(point, 0 if point.x < 2400 else PI)
		var brain := PoliceCruiserBrain.new()
		brain.game = game
		brain.car = car
		car.add_child(brain)
		cruisers.append(brain)
		Events.message_requested.emit("HEAT RESPONSE / Cruiser dispatched to the reported area.")
		return brain
	return null
func clear_spawn(at: Vector2) -> bool:
	var shape := RectangleShape2D.new()
	shape.size = Vector2(120, 120)
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, at)
	query.collision_mask = 1 | 2 | 4 | 8
	return get_world_2d().direct_space_state.intersect_shape(query).is_empty()
func spawn_roadblock() -> bool:
	for point: Vector2 in anchors:
		if not game.director.offscreen(point) or not clear_spawn(point + Vector2(0, 55)) or not clear_spawn(point - Vector2(0, 55)): continue
		anchor = point
		roadblock_used = true
		for y: float in [-55.0, 55.0]:
			roadblock_cars.append(make_car(point + Vector2(0, y), PI / 2))
		var police_count := get_tree().get_nodes_in_group("police").filter(func(n: Node) -> bool: return not n.downed).size()
		for i: int in mini(2, maxi(0, BALANCE.police_budgets[game.heat.level] - police_count)):
			var npc := game.spawn_citizen(point + Vector2(110, -80 + i * 160), "police")
			roadblock_officers.append(npc)
		Events.message_requested.emit("HEAT 4 / Road containment authorized. Watch the intersections.")
		return true
	return false
func clear_roadblock() -> void:
	for car: ToyCompact in roadblock_cars:
		if not is_instance_valid(car): continue
		if car.driver != null: continue # A stolen car belongs to the player now.
		game.cars.erase(car)
		car.queue_free()
	for npc: DistrictNPC in roadblock_officers:
		if not is_instance_valid(npc): continue
		game.citizens.erase(npc)
		npc.queue_free()
	roadblock_cars.clear()
	roadblock_officers.clear()
	anchor = Vector2.INF
	discovered = false
func roadblock_visible() -> bool:
	if anchor == Vector2.INF: return false
	if anchor.distance_to(game.player.global_position) < 800: discovered = true
	return discovered
func debug_status() -> String:
	var states: String = ""
	for brain: PoliceCruiserBrain in cruisers:
		if is_instance_valid(brain): states += String(brain.state) + " "
	return "CRUISERS %s | ROADBLOCK %s" % [states, str(anchor.round()) if anchor != Vector2.INF else "none"]
