class_name DistrictSpawnDirector
extends Node
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
var game: DistrictGame
var cooldown: float = 3.0
var spawned_positions: Array[Vector2] = []
var enabled: bool = true
func offscreen(point: Vector2) -> bool:
	var camera := game.player.get_node("Camera2D") as Camera2D
	var visible_size := Vector2(1280, 720) / camera.zoom
	return not Rect2(camera.get_screen_center_position() - visible_size / 2, visible_size).grow(180).has_point(point) and game.player.global_position.distance_to(point) > 800
func eligible_zone() -> Vector2:
	var best := Vector2.INF
	var distance: float = INF
	for zone: Vector2 in game.layout.spawn_zones:
		var point := game.navigation.grid.get_point_position(game.navigation.nearest(zone))
		if not offscreen(point):
			continue
		var d := point.distance_to(game.heat.search_position)
		if d < distance:
			best = point
			distance = d
	return best
func _physics_process(delta: float) -> void:
	if not enabled:
		return
	cooldown -= delta
	if cooldown > 0:
		return
	clean_drops()
	cooldown = BALANCE.reinforcement_delays[game.heat.level]
	for npc: DistrictNPC in game.citizens.duplicate():
		if is_instance_valid(npc) and npc.downed and npc.state_time > 25 and offscreen(npc.global_position):
			game.citizens.erase(npc)
			npc.queue_free()
	var count: int = 0
	for npc: DistrictNPC in game.citizens:
		if is_instance_valid(npc) and npc.role == "police" and not npc.downed:
			count += 1
	var desired: int = BALANCE.police_budgets[game.heat.level]
	if game.heat.level > 0 and count < desired:
		var point := eligible_zone()
		if point != Vector2.INF:
			var officer := game.spawn_citizen(point, "police")
			officer.heat = game.heat
			spawned_positions.append(officer.global_position)
	# Retire excess units only out of view after Heat clears; bodies are retained.
	if game.heat.level == 0 and count > 2:
		for npc: DistrictNPC in game.citizens.duplicate():
			if count <= 2:
				break
			if is_instance_valid(npc) and npc.role == "police" and not npc.downed and offscreen(npc.global_position):
				game.citizens.erase(npc)
				npc.queue_free()
				count -= 1

func clean_drops() -> void:
	var drops := get_tree().get_nodes_in_group("pickups")
	if drops.size() <= BALANCE.drop_soft_cap:
		return
	drops.sort_custom(func(a: WeaponPickup, b: WeaponPickup) -> bool: return a.age > b.age)
	var excess := drops.size() - BALANCE.drop_soft_cap
	for pickup: WeaponPickup in drops:
		if excess <= 0:
			break
		if pickup.age > BALANCE.drop_min_age and pickup.global_position.distance_to(game.player.global_position) > BALANCE.drop_safe_distance and offscreen(pickup.global_position):
			pickup.remove_from_group("pickups")
			pickup.queue_free()
			excess -= 1
