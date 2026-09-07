extends "res://tests/district_integration.gd"
func prepare_target() -> ToyCompact:
	quiet()
	city.mission.accept(null)
	var vehicle := city.mission.target
	vehicle.position = city.layout.garage
	player.position = vehicle.door_positions()[0]
	await frames(3)
	vehicle.enter(player)
	await frames(3)
	return vehicle
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	var target: ToyCompact = await prepare_target()
	verify(city.mission.delivery_ready() and city.score.money == 0, "Correct stopped car shows delivery prompt without auto reward")
	target.position += Vector2(250, 0)
	await frames(3)
	verify(not city.mission.delivery_ready() and city.score.money == 0, "Leaving zone before confirming gives no reward")
	target.position = city.layout.garage
	target.try_exit()
	await frames(3)
	verify(city.score.money == 0 and city.mission.state == &"deliver", "Manual exit in delivery area does not complete mission")
	car.position = city.layout.garage + Vector2(100, 100)
	player.position = car.door_positions()[0]
	await frames(3)
	car.enter(player)
	verify(not city.mission.delivery_ready() and not city.mission.try_interact(player), "Wrong vehicle cannot confirm delivery")
	car.try_exit()
	car.position = Vector2(1250, 740)
	player.position = target.door_positions()[0]
	await frames(3)
	target.enter(player)
	var police := city.spawn_citizen(city.layout.garage + Vector2(-250, 0), "police")
	police.ai_enabled = true
	city.heat.points = 3
	city.heat.identity_known = true
	city.heat.update_level()
	await tap(&"interact")
	verify(city.mission.state == &"transferring" and player.vehicle == null and player.control_locked, "E commits a short locked exterior handoff")
	verify(target.unavailable and not target.enter(player) and not city.recovery.recover(target), "Transferred target rejects entry and recovery")
	verify(city.mission.destination() == Vector2.INF, "Mission map target clears at transfer")
	city.mission.try_interact(player)
	await sim(0.8)
	verify(not is_instance_valid(target) and city.mission.target == null, "Delivered car and its collision body are removed")
	verify(player.vehicle == null and not player.control_locked and player.position.distance_to(city.layout.garage) > 85, "Player returns to free play on foot outside garage")
	verify(city.score.money == 2500 and city.score.missions == 1 and city.score.notoriety == 2, "Nearby police do not duplicate or interrupt single reward")
	city.mission.finish_delivery()
	verify(city.score.missions == 1, "Repeated completion callback cannot duplicate reward")
	await reset_game()
	target = await prepare_target()
	target.try_exit()
	player.position = Vector2(4100, 3000)
	target.explode()
	verify(city.score.money == 0 and city.mission.state == &"failed", "Target destroyed in garage before confirmation gives no reward")
	await sim(4.3)
	city.mission.accept(null)
	verify(city.mission.target != target and city.mission.state == &"steal", "Destroyed target replacement remains functional")
	await reset_game()
	target = await prepare_target()
	await tap(&"interact")
	verify(city.mission.state == &"transferring", "Restart fixture is mid-transfer")
	await reset_game()
	verify(city.mission.state == &"available" and city.score.money == 0 and city.cars.size() == 7 and not player.control_locked, "Restart during handoff clears all transient state")
	print("B5 DELIVERY COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
