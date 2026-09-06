extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	player.position = city.layout.phones[0]
	await tap(&"interact")
	car = city.mission.target
	player.position = car.nearest_door(car.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	verify(player.vehicle == car, "Driven Boost starts in actual parked mission target")
	var waypoints: Array[Vector2] = [Vector2(car.position.x + 130, 600), Vector2(3800, 600), Vector2(4100, 850), Vector2(4100, 2350), Vector2(4350, 2600), city.layout.garage]
	var start_position := car.position
	var index: int = 0
	var began := Time.get_ticks_msec()
	var traveled: float = 0
	var previous := car.position
	while index < waypoints.size() and Time.get_ticks_msec() - began < 90000 and player.alive:
		var offset := waypoints[index] - car.position
		var final := index == waypoints.size() - 1
		if offset.length() < (55 if final else 120):
			index += 1
			continue
		var error := wrapf(offset.angle() - car.rotation, -PI, PI)
		var desired_speed: float = 180 if absf(error) > 0.35 or offset.length() < 260 else 480
		if final:
			desired_speed = clampf(offset.length() * 0.8, 65, 200)
		Input.action_press("move_up")
		if error > 0.05: Input.action_press("move_right")
		else: Input.action_release("move_right")
		if error < -0.05: Input.action_press("move_left")
		else: Input.action_release("move_left")
		if car.speed > desired_speed: Input.action_press("handbrake")
		else: Input.action_release("handbrake")
		await frames(1)
		traveled += car.position.distance_to(previous)
		previous = car.position
	for action: String in ["move_up", "move_right", "move_left"]:
		Input.action_release(action)
	Input.action_press("handbrake")
	await sim(0.6)
	Input.action_release("handbrake")
	print("DRIVE TRACE start=%s end=%s waypoints=%d distance=%.0f health=%.1f mission=%s" % [start_position, car.position, index, traveled, car.health, city.mission.state])
	verify(index == waypoints.size() and traveled > 2000 and car.health > 0, "Actual driving navigates roads and turns across district to garage")
	verify(city.mission.state == &"complete" and city.score.live_score() == 5000, "Driven delivery completes Boost without teleporting the car")
	print("DISTRICT DRIVE COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures > 0 else 0)
