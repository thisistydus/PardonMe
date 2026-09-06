extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	var owner := city.citizens[4]
	var occupied := city.cars[3]
	verify(owner.seated_vehicle == occupied and occupied.occupied, "Occupied parked car has a seated civilian owner")
	player.position = occupied.nearest_door(occupied.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	verify(player.vehicle == occupied and owner.seated_vehicle == null and owner.visible, "Stealing occupied car ejects owner")
	verify(owner.state == &"alerted" and city.heat.level > 0, "Owner reacts and reports vehicle theft")
	occupied.try_exit()
	await reset_game()
	quiet()
	var patrol := city.cars[6]
	player.position = patrol.nearest_door(patrol.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	verify(player.vehicle == patrol and city.heat.level >= 2, "Patrol vehicle theft alarm raises Heat")
	verify(not city.heat.identity_known, "Remote theft alarm reports vehicle location without visual suspect identification")
	patrol.try_exit()
	var officer := city.citizens[17]
	officer.position = Vector2(700, 600)
	player.position = Vector2(4300, 3200)
	city.heat.search_position = Vector2(900, 600)
	city.heat.report_age = 1
	officer.ai_enabled = true
	await sim(0.5)
	verify(officer.state == &"investigating" and officer.destination == city.heat.search_position, "Unknown-suspect officer investigates reported location")
	verify(not officer.map_visible(), "Unseen inactive/investigating police are hidden on map")
	officer.change_state(&"searching")
	verify(officer.map_visible(), "Participating search officer is eligible for map marker")
	quiet()
	city.heat.points = 0
	city.heat.update_level()
	Events.crime.emit(&"gunfire", officer.position, 5, 700, false)
	verify(city.heat.level == 0, "NPC gunfire does not falsely attribute player crime")
	for point: float in [1.0, 3.0, 6.0, 10.0]:
		city.heat.points = point
		city.heat.update_level()
		verify(city.heat.level == [1.0, 3.0, 6.0, 10.0].find(point) + 1, "All five Heat levels have defined escalation thresholds")
	# Actual traversal around the NW building, using actor navigation.
	city.heat.points = 0
	city.heat.update_level()
	var walker := city.citizens[0]
	walker.position = Vector2(920, 1100)
	walker.destination = Vector2(1540, 1100)
	walker.state = &"flee"
	walker.state_time = -20
	walker.path_timer = 0
	walker.ai_enabled = true
	var initial_distance := walker.position.distance_to(walker.destination)
	await sim(7.5)
	verify(walker.position.distance_to(walker.destination) < 90 and initial_distance > 500, "NPC walks around building corners to destination")
	# Restart twice to catch duplicated listeners/ownership and scene cleanup.
	for i: int in 2:
		await reset_game()
		quiet()
		verify(city.citizens.size() == 19 and city.cars.size() == 7 and city.score.money == 0, "Repeated restart restores original district composition")
	print("DISTRICT SAFETY COMPLETE: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures > 0 else 0)
