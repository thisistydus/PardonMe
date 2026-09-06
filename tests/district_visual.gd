extends "res://tests/district_integration.gd"
func shot(filename: String) -> void:
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	verify(picture.save_png("res://screenshots/" + filename) == OK, "Saved " + filename)
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	var camera := player.get_node("Camera2D") as Camera2D
	camera.position_smoothing_enabled = false
	await frames(5)
	await shot("2026-09-06_PardonMe_Bplus_on_foot.png")
	player.position = city.layout.phones[0]
	await tap(&"interact")
	car = city.mission.target
	player.position = car.nearest_door(car.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	city.radio.select_station(1)
	car.position = Vector2(2400, 1800)
	await sim(1.0)
	await shot("2026-09-06_PardonMe_Bplus_driving.png")
	await key(&"district_map")
	await frames(3)
	await shot("2026-09-06_PardonMe_Bplus_map.png")
	await key(&"district_map")
	city.heat.points = 10
	city.heat.identity_known = true
	city.heat.search_position = Vector2(2500, 1800)
	city.heat.searching = true
	city.heat.unseen = 2
	city.heat.update_level()
	await key(&"debug_overlay")
	await frames(3)
	await shot("2026-09-06_PardonMe_Bplus_debug.png")
	# Observe renderer performance with a representative active population and radio.
	city.director.enabled = true
	city.heat.unseen = 0
	city.heat.outside_time = 0
	player.invulnerability = 1000
	car.health = 10000
	var blast_car: ToyCompact = city.cars[0]
	blast_car.position = player.position + Vector2(450, 190)
	blast_car.take_hit(150, Vector2.ZERO)
	for npc: DistrictNPC in city.citizens:
		npc.ai_enabled = true
	for i: int in 6:
		var officer := city.spawn_citizen(Vector2(2150 + i * 50, 1800), "police")
		officer.heat = city.heat
	var samples: Array[float] = []
	var began := Time.get_ticks_msec()
	var last_tick := Time.get_ticks_usec()
	while Time.get_ticks_msec() - began < 10000:
		await get_tree().process_frame
		var tick := Time.get_ticks_usec()
		samples.append((tick - last_tick) / 1000000.0)
		last_tick = tick
	verify(player.alive and car.health < 10000 and blast_car.disabled, "Performance load includes active police bullets, radio and a vehicle explosion")
	samples.sort()
	print("PERFORMANCE: samples=%d median_frame_ms=%.2f p95_frame_ms=%.2f fps=%d nodes=%d NPCs=%d" % [samples.size(), samples[samples.size()/2] * 1000, samples[int(samples.size()*0.95)] * 1000, Engine.get_frames_per_second(), get_tree().get_node_count(), city.citizens.size()])
	get_tree().quit(1 if failures > 0 else 0)
