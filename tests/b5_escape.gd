extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	car.position = Vector2(2400, 600)
	car.rotation = PI / 2
	player.position = car.door_positions()[0]
	await frames(3)
	car.enter(player)
	city.heat.points = 10
	city.heat.identity_known = true
	city.heat.search_position = car.position
	city.heat.update_level()
	var officer := city.spawn_citizen(Vector2(2180, 600), "police")
	verify(officer.can_see(player.position), "Escape begins with real police sight at Heat 4")
	city.heat.confirm_sighting(player.position)
	var waypoints: Array[Vector2] = [Vector2(2400, 2700), Vector2(2300, 3000), Vector2(850, 3000), Vector2(700, 3300)]
	var index: int = 0
	var began := Time.get_ticks_msec()
	while index < waypoints.size() and Time.get_ticks_msec() - began < 90000 and player.alive:
		var offset := waypoints[index] - car.position
		if offset.length() < 110:
			index += 1
			continue
		var error := wrapf(offset.angle() - car.rotation, -PI, PI)
		Input.action_press("move_up")
		if error > 0.05: Input.action_press("move_right")
		else: Input.action_release("move_right")
		if error < -0.05: Input.action_press("move_left")
		else: Input.action_release("move_left")
		var desired: float = 170 if absf(error) > 0.35 or offset.length() < 280 else 500
		if car.speed > desired: Input.action_press("handbrake")
		else: Input.action_release("handbrake")
		await frames(1)
	for action: String in ["move_up", "move_right", "move_left"]: Input.action_release(action)
	Input.action_press("handbrake")
	await sim(0.6)
	Input.action_release("handbrake")
	print("ESCAPE DRIVE position=%s health=%.0f player_alive=%s waypoints=%d last_known=%s heat=%d" % [car.position, car.health, player.alive, index, city.heat.search_position, city.heat.level])
	verify(index == waypoints.size() and player.alive, "Player drives an actual escape route with police and responses enabled")
	await sim(22)
	verify(city.heat.level == 0, "Maximum Heat clears after real driving, LOS loss and sustained time outside search area")
	verify(city.response.anchor == Vector2.INF, "Escaping removes the high-Heat roadblock")
	print("B5 ESCAPE COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
