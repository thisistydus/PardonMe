extends "res://tests/acceptance.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	player = game.player
	car = game.car
	await frames(10)
	game.director.enabled = false
	for npc: DistrictNPC in game.citizens:
		npc.ai_enabled = false
	verify(game.cars.size() == 7, "Seven enterable vehicles placed")
	verify(game.cars[2].data.title == "SEDAN", "Sedan uses distinct vehicle data")
	verify(game.layout.phones.size() == 3, "Three authored mission phones")
	verify(game.navigation.route(Vector2(900, 800), Vector2(4400, 2600)).size() > 40, "Navigation connects yard to garage around blocks")
	for vehicle: ToyCompact in game.cars:
		player.position = vehicle.nearest_door(vehicle.position + Vector2(0, 80))
		await frames(3)
		verify(vehicle.enter(player), "Enter parked " + vehicle.data.title)
		verify(vehicle.try_exit(), "Exit parked vehicle")
	car.position = Vector2(700, 600)
	car.rotation = 0
	player.position = Vector2(696, 648)
	await frames(3)
	car.enter(player)
	Input.action_press("move_up")
	await seconds(3.0)
	Input.action_release("move_up")
	verify(car.position.x > 2000 and car.speed > 600, "Long road supports full-speed driving across blocks")
	car.try_exit()
	car.position = Vector2(1610, 820)
	car.rotation = PI / 2
	car.speed = 300
	car.velocity = Vector2.DOWN * 300
	await frames(3)
	car.move_with_impacts(Vector2.DOWN * 110)
	verify(car.position.y < 880, "Pedestrian gate blocks a car")
	player.position = Vector2(1580, 850)
	Input.action_press("move_down")
	await frames(30)
	Input.action_release("move_down")
	verify(player.position.y > 900, "Pedestrian gate allows on-foot passage")
	print("DISTRICT LAYOUT COMPLETE: %d checks" % checks)
	get_tree().quit(1 if failures > 0 else 0)
