extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	var last_radius: float = 0
	var last_duration: float = 0
	for value: float in [1.0, 3.0, 6.0, 10.0]:
		city.heat.points = value
		city.heat.update_level()
		verify(city.heat.search_radius > last_radius and city.heat.search_duration > last_duration, "Radius and duration increase at Heat %d" % city.heat.level)
		last_radius = city.heat.search_radius
		last_duration = city.heat.search_duration
	city.heat.search_position = Vector2(2400, 1800)
	city.heat.identity_known = true
	city.heat.unseen = 3
	for i: int in 18:
		var npc := city.spawn_citizen(Vector2(700 + i * 40, 600), "police")
		npc.ai_enabled = false
	city.coordinator.coordinate()
	var roles: Dictionary = {}
	var destinations: Dictionary = {}
	for npc: DistrictNPC in city.coordinator.officers:
		roles[npc.police_role] = true
		destinations[npc.assigned_target] = true
	verify(roles.size() == 5 and city.coordinator.officers.size() == 20, "Twenty officers receive all five roles at Heat 4")
	verify(destinations.size() >= 15, "Role coordinator distributes distinct destinations")
	var reported := city.heat.search_position
	player.position = Vector2(4400, 3200)
	await sim(1.0)
	verify(city.heat.search_position == reported, "Coordinator does not follow an unseen live player")
	verify(city.minimap.game.heat.search_radius == last_radius, "Minimap reads the authoritative world search radius")
	city.heat.points = 6
	city.heat.update_level()
	city.coordinator.coordinate()
	var tactical: int = 0
	for npc: DistrictNPC in city.coordinator.officers:
		if npc.police_role == &"tactical": tactical += 1
	verify(tactical == 0, "Tactical assignment retires below Heat 4")
	var walker := city.coordinator.officers[0]
	walker.position = Vector2(2390, 1600)
	walker.velocity = Vector2(220, 0)
	walker.stun = 0
	walker.air_time = 0
	var wall := StaticBody2D.new()
	wall.position = Vector2(2420, 1600)
	wall.collision_layer = 1
	var collision := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size = Vector2(10, 100)
	collision.shape = box
	wall.add_child(collision)
	city.add_child(wall)
	await frames(3)
	walker.velocity = Vector2(220, 0)
	await sim(0.3)
	verify(not walker.downed, "Normal police walking collision does not trigger knockback-only wall kill")
	print("B5 PRESSURE COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
