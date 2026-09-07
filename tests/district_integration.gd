extends "res://tests/acceptance.gd"
var city: DistrictGame
func refresh_refs() -> void:
	game = get_tree().current_scene
	city = game as DistrictGame
	player = city.player
	car = city.car
func sim(duration: float) -> void:
	var elapsed: float = 0
	while elapsed < duration:
		await get_tree().physics_frame
		elapsed += get_physics_process_delta_time()
func quiet() -> void:
	city.director.enabled = false
	city.response.enabled = false
	for npc: DistrictNPC in city.citizens:
		npc.ai_enabled = false
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(20)
	quiet()
	verify(city.citizens.size() == 19, "Sixteen civilians, one hostile and two ambient police")
	verify(city.score.money == 0 and city.score.notoriety == 1, "District starts with zero Money and ×1")
	# No nearby witness or audible observer at the west waterfront.
	player.position = Vector2(180, 180)
	Events.crime.emit(&"harm", player.position, 2.0, 0.0, true)
	verify(city.heat.level == 0, "Unseen and unheard crime causes no Heat")
	var civilian := city.citizens[0]
	civilian.position = player.position
	Events.crime.emit(&"harm", civilian.position, 2.0, 0.0, true)
	verify(city.heat.level == 0, "Isolated civilian victim does not create an imaginary extra witness")
	civilian.position = Vector2(400, 180)
	civilian.ai_enabled = true
	Events.crime.emit(&"gunfire", Vector2(480, 180), 1.5, 700.0, true)
	verify(civilian.state == &"alerted", "Civilian becomes alerted to gunfire")
	verify(city.heat.level == 1 and not city.heat.identity_known, "Reported gunfire creates investigation without identity")
	var reported := city.heat.search_position
	player.position = Vector2(180, 700)
	await sim(0.5)
	verify(city.heat.search_position == reported, "Unseen player movement does not move reported search position")
	await sim(0.7)
	verify(civilian.state == &"flee", "Civilian progresses through panic to flee")
	var flee_start := civilian.position
	await sim(1.0)
	verify(civilian.position.distance_to(flee_start) > 60, "Panicked civilian navigates away from danger")
	civilian.ai_enabled = false
	var police := city.citizens[17]
	police.position = Vector2(700, 600)
	player.position = Vector2(900, 600)
	await frames(3)
	city.heat.crime_cooldown = 0
	Events.crime.emit(&"gunfire", player.position, 1.5, 700, true)
	verify(city.heat.level >= 2 and city.heat.identity_known, "Direct police witness identifies suspect and creates Heat 2")
	police.ai_enabled = true
	await sim(0.9)
	verify(police.state == &"pursuing", "Officer alerts then pursues on foot")
	var pursuit_start := police.position
	player.position = Vector2(1350, 600)
	await sim(0.8)
	verify(police.position.distance_to(pursuit_start) > 50, "Officer moves toward last observed player position")
	# Leave sight behind the NW building and travel beyond the search radius.
	player.position = Vector2(1300, 1600)
	await sim(1.5)
	verify(city.heat.searching and police.state == &"searching", "Breaking LOS starts a visible police search")
	var frozen_search := city.heat.search_position
	player.position = Vector2(4400, 3200)
	await sim(city.heat.search_duration + 0.5)
	verify(city.heat.level == 0 and not city.heat.identity_known, "Leaving search area unseen clears pursuit after cooldown")
	verify(frozen_search != player.position, "Escape search never follows hidden player")
	quiet()
	player.position = Vector2(2400, 1800)
	var camera := player.get_node("Camera2D") as Camera2D
	camera.position_smoothing_enabled = false
	await frames(3)
	for point: Vector2 in city.layout.spawn_zones:
		if city.director.offscreen(point):
			verify(point.distance_to(player.position) > 800, "Eligible police spawn is outside immediate player view")
	city.heat.points = 10
	city.heat.search_position = player.position
	city.heat.update_level()
	verify(city.heat.level == 4, "Heat has level 4 escalation")
	city.director.enabled = true
	city.director.cooldown = 0
	await frames(3)
	verify(city.director.spawned_positions.size() == 1, "Heat 4 adds an authored off-screen reinforcement")
	verify(city.director.offscreen(city.director.spawned_positions[0]), "Actual reinforcement spawned beyond expanded camera view")
	quiet()
	city.heat.points = 0
	city.heat.update_level()
	# Real phone interaction and vehicle entry flow.
	player.position = city.layout.phones[0]
	await tap(&"interact")
	verify(city.mission.state == &"steal" and city.mission.target != null, "E at payphone accepts a Boost job")
	var boost := city.mission.target
	verify(city.mission.destination() == boost.position, "Boost marks correct target on minimap")
	player.position = boost.nearest_door(boost.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	verify(player.vehicle == boost and city.mission.state == &"deliver", "Entering marked vehicle advances Boost")
	verify(city.mission.destination() == city.layout.garage, "Garage becomes active mission destination")
	verify(city.radio.audio.playing and city.hud.radio_card.visible, "Radio preserved in mission vehicle")
	boost.global_position = city.layout.garage
	boost.speed = 0
	await frames(5)
	await tap(&"interact")
	await sim(0.8)
	verify(city.mission.state == &"complete", "Correct stopped vehicle delivered to garage")
	verify(city.score.money == 2500 and city.score.notoriety == 2 and city.score.live_score() == 5000, "Boost grants $2500 and tier ×2 for live score 5000")
	city.mission.accept(get_tree().get_nodes_in_group("interactables")[0])
	await frames(3)
	verify(city.score.money == 2500 and city.mission.state == &"complete", "Completed mission cannot repeat or double-award")
	await reset_game()
	quiet()
	verify(city.score.money == 0 and city.heat.level == 0 and city.mission.state == &"available", "Restart resets district score, Heat, mission and population")
	player.position = city.layout.phones[0]
	await tap(&"interact")
	boost = city.mission.target
	var used := city.mission.used[0]
	boost.explode()
	verify(city.mission.state == &"failed" and city.score.money == 0, "Destroyed mission target fails gracefully without reward")
	await sim(4.3)
	player.position = city.layout.phones[0]
	await tap(&"interact")
	verify(city.mission.state == &"steal" and city.mission.used.back() != used, "Retry selects a different target after delay")
	city.heat.points = 0
	city.heat.update_level()
	car.position = Vector2(720, 2300)
	car.health = 64
	car.speed = 0
	await frames(3)
	verify(city.recovery.recover(car) and car.health == 64, "Local car recovery keeps damage")
	city.heat.points = 3
	city.heat.update_level()
	verify(not city.recovery.recover(car), "Recovery cannot bypass an active pursuit")
	await key(&"district_map")
	verify(city.minimap.enlarged, "M enlarges north-up map")
	await key(&"debug_overlay")
	await frames(3)
	verify(city.hud.debug.visible and "SEARCH" in city.hud.debug.text, "Debug exposes search position/radius and police states")
	print("DISTRICT INTEGRATION COMPLETE: %d checks, %d failures" % [checks, failures])
	get_tree().quit(1 if failures > 0 else 0)
