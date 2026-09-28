extends "res://tests/district_integration.gd"
## Windowed capture of the C1 build using real runtime systems (staged positions, no painted substitutes).
var date_prefix: String = "2026-09-27_PardonMe_C1_"

func shot(feature: String) -> void:
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	verify(picture.save_png("res://screenshots/" + date_prefix + feature + ".png") == OK, "Saved running-build screenshot " + feature)

func fresh() -> void:
	await reset_game()
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.invulnerability = 1000

func dummy(index: int, at: Vector2) -> PracticeTarget:
	var d := get_tree().get_nodes_in_group("targets")[index] as PracticeTarget
	d.position = at
	d.health = 3
	d.downed = false
	d.collision_layer = 4
	d.velocity = Vector2.ZERO
	return d

func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.invulnerability = 1000
	# 1. Payphones + idle HUD at dawn.
	player.position = city.layout.phones[0] + Vector2(60, 40)
	get_viewport().warp_mouse(Vector2(1100, 360))
	aim(Vector2.LEFT)
	await sim(1.0)
	await shot("payphone_idle_hud")
	# 2. Heat flames during a pursuit, with a job active.
	player.position = city.layout.phones[1]
	await tap(&"interact")
	player.position = Vector2(2400, 1800)
	city.heat.points = 7
	city.heat.identity_known = true
	city.heat.search_position = player.position
	city.heat.update_level()
	for i: int in 4:
		var officer := city.spawn_citizen(Vector2(2150 + i * 60, 1640), "police")
		officer.ai_enabled = false
		officer.change_state(&"pursuing")
	city.score.add_cash(640, &"street")
	await sim(1.2)
	await shot("hud_heat_flames")
	# 3. Knife stab.
	await fresh()
	player.position = Vector2(2400, 1800)
	aim(Vector2.RIGHT)
	player.weapons.equip(preload("res://data/weapons/knife.tres"))
	var knife_target := dummy(0, Vector2(2445, 1800))
	await sim(0.3)
	aim(Vector2.RIGHT)
	player.weapons.attack()
	await frames(2)
	await shot("knife_stab")
	verify(knife_target.downed, "Knife capture shows a real hit")
	# 4. Shotgun spread.
	await sim(0.5)
	player.weapons.equip(preload("res://data/weapons/shotgun.tres"))
	player.position = Vector2(2250, 1800)
	for i: int in 3:
		dummy(i, Vector2(2420, 1800 + (i - 1) * 45))
	await sim(0.3)
	aim(Vector2.RIGHT)
	player.weapons.attack()
	await frames(6)
	await shot("shotgun_blast")
	# 5. Rob: alarm, guards and the hold-up ring.
	await fresh()
	player.position = city.layout.phones[1]
	await tap(&"interact")
	player.position = city.rob.DEFINITION.store_position
	await sim(0.2)
	for guard: DistrictNPC in city.rob.guards:
		guard.ai_enabled = true
	await sim(1.6)
	await shot("rob_holdup")
	while city.rob.state == &"robbing":
		await frames(1)
	player.position = city.rob.DEFINITION.store_position + Vector2(0, -160)
	await frames(2)
	await shot("rob_bag")
	# 6. Destroy: marked sedans, one running.
	await fresh()
	player.position = city.layout.phones[2]
	await tap(&"interact")
	player.position = city.destroy.runner.global_position + Vector2(-60, -220)
	await sim(0.8)
	await shot("destroy_runner")
	# 7. Vehicle palettes side by side.
	await fresh()
	var lineup: Array[ToyCompact] = [city.cars[0], city.cars[2], city.cars[6]]
	player.position = Vector2(2400, 1720)
	for i: int in lineup.size():
		lineup[i].global_position = Vector2(2250 + i * 140, 1830)
		lineup[i].rotation = -PI / 2
	player.position = city.layout.phones[2]
	await tap(&"interact")
	var mark := city.destroy.targets[0]
	mark.global_position = Vector2(2670, 1830)
	mark.rotation = -PI / 2
	player.position = Vector2(2460, 1700)
	await sim(0.5)
	await shot("vehicle_palettes")
	# 8. Street cash from a player kill, collected with a popup.
	await fresh()
	var config := CashDirector.CONFIG
	var saved := config.civilian_chance
	config.civilian_chance = 1.0
	player.position = Vector2(2400, 1800)
	aim(Vector2.RIGHT)
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	for i: int in 3:
		var npc := city.citizens[i]
		npc.global_position = Vector2(2470, 1760 + i * 40)
	await sim(0.3)
	aim(Vector2.RIGHT)
	player.weapons.attack()
	await sim(0.8)
	city.cash.spawn(Vector2(2330, 1860), 42)
	player.position = get_tree().get_nodes_in_group("cash_pickups")[0].global_position
	await frames(8)
	player.position = Vector2(2380, 1800)
	await frames(2)
	await shot("cash_pickups")
	config.civilian_chance = saved
	# 9. Results: death, then dawn.
	player.invulnerability = 0
	player.take_hit(1, Vector2.LEFT * 50, true, "SHOT BY POLICE")
	player.invulnerability = 0
	player.take_hit(1, Vector2.LEFT * 50, true, "SHOT BY POLICE")
	await frames(6)
	await shot("results_died")
	await fresh()
	player.position = city.layout.phones[0]
	await tap(&"interact")
	var boost := city.mission.target
	player.position = boost.nearest_door(boost.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	boost.global_position = city.layout.garage
	boost.speed = 0
	await frames(5)
	await tap(&"interact")
	await sim(0.8)
	city.score.add_cash(310, &"street")
	city.heat.highest = 3
	city.clock.elapsed = city.clock.tuning.run_seconds - 61.0
	await sim(1.5)
	await shot("final_minute_warning")
	city.clock.elapsed = city.clock.tuning.run_seconds - 0.1
	await sim(0.4)
	await frames(6)
	await shot("results_dawn")
	print("C1 VISUAL COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
