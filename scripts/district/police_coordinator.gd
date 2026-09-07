class_name PoliceCoordinator
extends Node2D
## Assign intent, not movement. Each officer owns sensing, reaction and staggered paths.
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
var game: DistrictGame
var timer: float = 0
var officers: Array[DistrictNPC] = []
var revision: int = 0
func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		timer = BALANCE.coordinator_interval
		coordinate()
	if game.run.debug_visible:
		queue_redraw()
	elif visible:
		queue_redraw()
func coordinate() -> void:
	revision += 1
	officers.clear()
	for npc: DistrictNPC in game.citizens:
		if is_instance_valid(npc) and not npc.downed and npc.role == "police":
			officers.append(npc)
	var roles := BALANCE.roles_by_heat[game.heat.level].split(",")
	var center := game.heat.search_position
	var radius := game.heat.search_radius
	for i: int in officers.size():
		var npc := officers[i]
		npc.police_role = StringName(roles[i % roles.size()])
		var angle := TAU * float(i) / maxi(1, officers.size())
		var desired := center
		match npc.police_role:
			&"pursuer":
				desired += Vector2.RIGHT.rotated(angle) * (55 + i * 3)
			&"interceptor":
				var prediction := game.heat.observed_velocity.limit_length(BALANCE.prediction_limit / BALANCE.prediction_seconds) * BALANCE.prediction_seconds if game.heat.unseen < 2 else Vector2.ZERO
				desired = road_point(center + prediction + Vector2.RIGHT.rotated(angle) * 160)
			&"containment":
				desired = road_point(center + Vector2.RIGHT.rotated(angle) * radius * 0.72)
			&"tactical":
				desired += Vector2.RIGHT.rotated(angle) * 260
			_:
				# Stable sector, slow depth changes; unseen live player is never consulted.
				desired += Vector2.RIGHT.rotated(angle) * radius * (0.32 + 0.09 * ((i + revision / 5) % 5))
		desired += Vector2.RIGHT.rotated(angle + PI / 2) * i * 7
		npc.assigned_target = game.navigation.grid.get_point_position(game.navigation.nearest(desired.clamp(Vector2(180, 180), DistrictLayout.SIZE - Vector2(180, 180))))
		if radius > 0 and npc.assigned_target.distance_to(center) > radius:
			npc.assigned_target = game.navigation.grid.get_point_position(game.navigation.nearest(center + (npc.assigned_target - center).normalized() * radius * 0.65))
		npc.debug_roles = game.run.debug_visible
func road_point(point: Vector2) -> Vector2:
	var best := Vector2(700, 600)
	for x: float in [700.0, 2400.0, 4100.0]:
		for y: float in [600.0, 1800.0, 3000.0]:
			var candidate := Vector2(x, y)
			if candidate.distance_squared_to(point) < best.distance_squared_to(point):
				best = candidate
	return best
func _draw() -> void:
	if not game.run.debug_visible:
		return
	for npc: DistrictNPC in officers:
		if not is_instance_valid(npc) or npc.downed:
			continue
		if npc.police_role in [&"interceptor", &"containment", &"search"]:
			draw_line(npc.global_position, npc.assigned_target, Color(0.7, 0.64, 0.37, 0.22), 1)
			draw_circle(npc.assigned_target, 10, Color("c2ae73"), false, 1)
