extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	city.response.enabled = false
	player.position = Vector2(2400, 1800)
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	await frames(5)
	city.heat.points = 10
	city.heat.search_position = Vector2(2400, 600)
	city.heat.update_level()
	var brain := city.response.spawn_cruiser()
	verify(brain != null and city.director.offscreen(brain.car.position), "Cruiser spawns at authored road access outside camera")
	var start := brain.car.position
	await sim(5.0)
	verify(brain.car.position.distance_to(start) > 900 and brain.car.health == brain.car.data.durability, "Cruiser follows open road without hitting buildings")
	verify(absf(brain.roads.project(brain.car.position).distance_to(brain.car.position)) < 110, "Cruiser stays near road center")
	verify(city.response.spawn_roadblock(), "High-Heat authored roadblock spawns")
	verify(city.response.anchor in city.response.anchors and city.director.offscreen(city.response.anchor), "Roadblock anchor is authored and outside camera")
	verify(city.response.roadblock_cars.size() == 2, "Roadblock has two destructible stealable patrol vehicles")
	verify(not city.response.roadblock_visible(), "Undiscovered distant roadblock stays off minimap")
	car.position = city.response.anchor + Vector2(-180, 130)
	car.rotation = 0
	car.speed = 0
	await frames(3)
	car.speed = 500
	car.velocity = Vector2(500, 0)
	car.move_with_impacts(Vector2(360, 0))
	verify(car.position.x > city.response.anchor.x + 100 and car.health > 0, "Roadblock leaves a drivable side bypass")
	car.speed = 0
	brain.abandon()
	brain.car.speed = 0
	player.position = brain.car.door_positions()[0]
	await frames(3)
	city.heat.points = 0
	city.heat.update_level()
	verify(brain.car.enter(player), "Abandoned cruiser can be entered")
	verify(city.heat.level >= 2, "Stealing patrol cruiser raises significant Heat")
	brain.car.try_exit()
	player.position = Vector2(2400, 1800)
	brain.car.take_hit(200, Vector2.ZERO)
	verify(brain.car.failure_timer > 0, "Cruiser uses existing damage warning fuse")
	await sim(3.5)
	verify(brain.car.disabled, "Police cruiser explodes through shared vehicle behavior")
	var car_count := city.cars.size()
	var citizen_count := city.citizens.size()
	city.response.clear_roadblock()
	await frames(3)
	verify(city.response.anchor == Vector2.INF and city.cars.size() == car_count - 2 and city.citizens.size() == citizen_count - 2, "Roadblock cleanup removes owned cars/officers and marker")
	verify(city.response.roadblock_cars.is_empty(), "No roadblock collision references remain")
	print("B5 RESPONSE COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
