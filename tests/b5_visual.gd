extends "res://tests/district_integration.gd"
var date_prefix: String = "2026-09-07_PardonMe_B5_"
func shot(feature: String) -> void:
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	verify(picture.save_png("res://screenshots/" + date_prefix + feature + ".png") == OK, "Saved running-build screenshot " + feature)
func fresh() -> void:
	await reset_game()
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.invulnerability = 1000
func set_heat(at: Vector2) -> void:
	city.heat.points = 10
	city.heat.identity_known = true
	city.heat.search_position = at
	city.heat.update_level()
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.position = Vector2(2400, 1800)
	player.invulnerability = 1000
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	set_heat(player.position)
	for i: int in 8:
		city.spawn_citizen(Vector2(2060 + i * 45, 1740), "police")
	city.coordinator.coordinate()
	await sim(1.1)
	await shot("on_foot_pursuit")
	city.run.debug_visible = true
	city.coordinator.coordinate()
	await frames(3)
	await shot("police_roles")
	quiet()
	city.heat.searching = true
	city.heat.unseen = 3
	city.minimap.enlarged = true
	await frames(4)
	await shot("expanded_search")
	city.minimap.enlarged = false
	await frames(3)
	await shot("maximum_heat_minimap")
	await fresh()
	player.position = Vector2(2400, 1800)
	set_heat(player.position)
	await frames(3)
	var brain := city.response.spawn_cruiser()
	verify(brain != null, "Visual cruiser is spawned by actual response system")
	car.position = Vector2(1000, 600)
	player.position = car.door_positions()[0]
	await frames(3)
	car.enter(player)
	city.radio.select_station(2)
	city.heat.search_position = Vector2(1500, 600)
	await sim(2.3)
	await shot("cruiser_pursuit")
	await fresh()
	player.position = Vector2(2400, 1800)
	set_heat(player.position)
	await frames(3)
	verify(city.response.spawn_roadblock(), "Visual roadblock uses authored off-screen spawn")
	player.position = city.response.anchor + Vector2(-280, 100)
	await sim(0.4)
	await shot("roadblock")
	await fresh()
	player.position = Vector2(2400, 1800)
	var officer := city.spawn_citizen(Vector2(2450, 1800), "police")
	officer.ai_enabled = false
	officer.ammo = 3
	officer.take_hit(3, Vector2(100, 0))
	await sim(0.2)
	await shot("police_weapon_drop")
	var pickup := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	player.position = pickup.position
	player.interact()
	await frames(4)
	verify(player.weapons.ammo == 3, "Rendered pickup displays the retained police magazine")
	await shot("police_weapon_pickup")
	await fresh()
	player.position = city.layout.phones[0]
	await tap(&"interact")
	var delivered := city.mission.target
	delivered.position = city.layout.garage
	player.position = delivered.door_positions()[0]
	await frames(3)
	delivered.enter(player)
	await frames(4)
	await shot("boost_confirm")
	await tap(&"interact")
	await sim(0.85)
	await shot("boost_removal")
	verify(not is_instance_valid(delivered) and player.vehicle == null, "Rendered delivery leaves player on foot with car removed")
	await fresh()
	# Deliberately staged performance fixture: ordinary NPCs, protected observer car.
	car.position = Vector2(2400, 1800)
	player.position = car.door_positions()[0]
	await frames(3)
	car.enter(player)
	car.health = 10000
	city.radio.select_station(1)
	set_heat(car.position)
	city.run.debug_visible = true
	city.director.enabled = true
	city.response.enabled = true
	for npc: DistrictNPC in city.citizens: npc.ai_enabled = true
	for i: int in 18:
		var angle := TAU * i / 18
		city.spawn_citizen(car.position + Vector2.RIGHT.rotated(angle) * (240 + (i % 3) * 35), "police")
	city.coordinator.coordinate()
	verify(city.coordinator.officers.size() >= 20, "Stress begins with at least twenty active mixed-role police")
	city.response.spawn_cruiser()
	city.response.spawn_roadblock()
	for i: int in 8:
		var npc := city.spawn_citizen(Vector2(2800 + i * 35, 1900), "hostile")
		npc.take_hit(3, Vector2.ZERO)
	var a := ExplosiveBarrel.new()
	a.position = Vector2(2800, 1800)
	a.player_responsible = true
	city.add_child(a)
	var b := ExplosiveBarrel.new()
	b.position = Vector2(2860, 1800)
	city.add_child(b)
	var vehicle := city.cars[1]
	vehicle.position = Vector2(2930, 1800)
	vehicle.health = 30
	var next_vehicle := city.cars[2]
	next_vehicle.position = Vector2(3020, 1800)
	next_vehicle.health = 20
	await frames(3)
	a.take_hit(20, Vector2.ZERO)
	await sim(0.8)
	await shot("barrel_vehicle_chain")
	var samples: Array[float] = []
	var began := Time.get_ticks_msec()
	var last_tick := Time.get_ticks_usec()
	var max_projectiles: int = 0
	var peak_police: int = 0
	var fleeing: bool = false
	while Time.get_ticks_msec() - began < 20000:
		await get_tree().process_frame
		var tick := Time.get_ticks_usec()
		samples.append((tick - last_tick) / 1000.0)
		last_tick = tick
		var bullets: int = 0
		for child: Node in city.get_children():
			if child is ToyProjectile: bullets += 1
		max_projectiles = maxi(max_projectiles, bullets)
		var count: int = 0
		for npc: DistrictNPC in city.citizens:
			if npc.role == "police" and not npc.downed: count += 1
			if npc.state == &"flee": fleeing = true
		peak_police = maxi(peak_police, count)
	samples.sort()
	verify(player.alive and a.exploded and b.exploded and vehicle.disabled and next_vehicle.disabled, "Stress includes barrel/vehicle/vehicle chains with surviving observer")
	verify(peak_police >= 20 and peak_police <= 22 and max_projectiles >= 2 and fleeing, "Stress includes capped mixed police, concurrent projectiles and fleeing civilians")
	verify(city.radio.audio.playing and city.response.anchor != Vector2.INF and not city.response.cruisers.is_empty(), "Radio, roadblock and cruiser remain active during stress")
	await shot("stress_debug")
	var report := {"duration_seconds":20, "samples":samples.size(), "median_frame_ms":samples[samples.size()/2], "p95_frame_ms":samples[int(samples.size()*0.95)], "peak_police":peak_police, "fleeing_civilians_observed":fleeing, "peak_projectiles":max_projectiles, "nodes":get_tree().get_node_count(), "drops":get_tree().get_nodes_in_group("pickups").size(), "fixture":"Protected observer car; actual AI, physics, audio, renderer. No export claim."}
	var file := FileAccess.open("res://docs/b5_performance.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(report, "\t"))
	print("B5 PERFORMANCE " + JSON.stringify(report))
	print("B5 VISUAL COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
