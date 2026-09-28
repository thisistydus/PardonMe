extends "res://tests/district_integration.gd"
## Goal C1: street cash drops, attribution, collection, caps, lifetime and restart cleanup.
var cash_events: int = 0

func boot() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.invulnerability = 1000
	city.score.cash_added.connect(func(_a: int, _s: StringName) -> void: cash_events += 1)

func civilian(index: int, at: Vector2) -> DistrictNPC:
	var npc := city.citizens[index]
	npc.ai_enabled = false
	npc.global_position = at
	npc.velocity = Vector2.ZERO
	return npc

func start() -> void:
	var config := CashDirector.CONFIG
	var saved := [config.civilian_chance, config.police_chance]
	config.civilian_chance = 1.0
	config.police_chance = 1.0
	await boot()
	verify(get_tree().get_nodes_in_group("cash_pickups").is_empty() and city.score.money == 0, "District starts with no cash and no pickups")
	# Player melee kill → drop on the ground, not instant cash.
	player.global_position = Vector2(2400, 1800)
	aim(Vector2.RIGHT)
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	var victim := civilian(0, player.global_position + Vector2(62, 0))
	await sim(0.2)
	player.weapons.attack()
	await frames(2)
	var drops := get_tree().get_nodes_in_group("cash_pickups")
	verify(victim.downed and city.cash.dropped == 1 and drops.size() == 1, "Player-killed civilian drops one cash pickup")
	var pickup := drops[0] as CashPickup
	var amount := pickup.amount
	verify(pickup.amount >= config.civilian_range.x and pickup.amount <= config.civilian_range.y, "Civilian drop value $%d is inside the configured range" % pickup.amount)
	verify(city.score.money == 0 and cash_events == 0, "Cash is not credited at the moment of death")
	player.global_position = pickup.global_position + Vector2(20, 0)
	await frames(3)
	verify(city.score.money == amount and city.score.cash_by_source.get(&"street", 0) == amount and cash_events == 1, "Walking over the pickup credits it once through the cash interface")
	verify(get_tree().get_nodes_in_group("cash_pickups").is_empty() and city.cash.collected == 1, "Collected pickup is removed")
	await frames(5)
	verify(cash_events == 1 and city.score.money == amount, "No duplicate collection on later frames")
	var street := city.score.money
	# A death the player did not cause drops nothing.
	var bystander := civilian(1, Vector2(2400, 2400))
	var barrel := ExplosiveBarrel.new()
	barrel.position = bystander.global_position + Vector2(50, 0)
	city.add_child(barrel)
	await frames(2)
	barrel.take_hit(8, Vector2.ZERO, false)
	await sim(1.0)
	verify(bystander.downed and not bystander.last_attacker_player, "Uncredited barrel blast kills a bystander")
	verify(city.cash.dropped == 1, "Non-player kill drops no cash (requires_player_kill)")
	# Player bullet kill of an officer uses the police table.
	var officer := city.citizens[17]
	officer.ai_enabled = false
	officer.global_position = Vector2(3000, 1800)
	player.global_position = Vector2(2850, 1800)
	aim(Vector2.RIGHT)
	player.weapons.equip(preload("res://data/weapons/pistol.tres"))
	await sim(0.2)
	player.weapons.attack()
	await sim(0.3)
	var police_drop := get_tree().get_nodes_in_group("cash_pickups").back() as CashPickup
	verify(officer.downed and officer.last_attacker_player and police_drop != null and police_drop.amount >= config.police_range.x and police_drop.amount <= config.police_range.y, "Player-shot officer drops police-table cash")
	# Thrown weapon kill of the armed hostile uses the hostile table.
	var hostile := city.citizens[16]
	hostile.ai_enabled = false
	hostile.global_position = Vector2(2400, 1300)
	player.global_position = Vector2(2250, 1300)
	aim(Vector2.RIGHT)
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	await frames(2)
	player.throw_weapon()
	await sim(0.5)
	var hostile_drop := get_tree().get_nodes_in_group("cash_pickups").back() as CashPickup
	verify(hostile.downed and hostile_drop.amount >= config.hostile_range.x and hostile_drop.amount <= config.hostile_range.y, "Thrown-weapon kill of a hostile drops hostile-table cash ($%d)" % hostile_drop.amount)
	# Driving over cash collects it with the larger vehicle radius.
	var car := city.car
	car.global_position = Vector2(700, 1800)
	car.rotation = 0
	player.global_position = car.door_positions()[0]
	await frames(3)
	car.enter(player)
	var roadside := city.cash.spawn(car.global_position + Vector2(55, 0), 25)
	await frames(3)
	verify(not is_instance_valid(roadside) or roadside.is_queued_for_deletion(), "Driving within the vehicle radius collects cash")
	verify(city.score.money == street + 25, "Vehicle collection credits exactly once")
	car.try_exit()
	await frames(2)
	# Invalid awards are refused, not silently applied.
	var before := city.score.money
	verify(not city.score.add_cash(0, &"street") and not city.score.add_cash(-50, &"street") and city.score.money == before and city.score.rejected_awards == 2, "Zero/negative cash awards are rejected and counted")
	# Soft cap and lifetime keep the world bounded.
	player.global_position = Vector2(200, 200)
	var existing := city.cash.pickups.size()
	for i: int in config.soft_cap + 5:
		city.cash.spawn(Vector2(4000 + (i % 10) * 30, 400 + (i / 10) * 30), 10)
	await frames(2)
	verify(city.cash.pickups.size() == config.soft_cap and get_tree().get_nodes_in_group("cash_pickups").size() <= config.soft_cap, "Pickups never exceed the soft cap of %d" % config.soft_cap)
	verify(city.cash.expired >= existing + 5, "Oldest pickups make room first")
	var old := city.cash.pickups[0]
	old.age = old.lifetime
	await frames(2)
	verify(not is_instance_valid(old) or old.is_queued_for_deletion(), "Pickups expire after their lifetime")
	# Mission payouts share the same authoritative interface.
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
	verify(city.score.cash_by_source.get(&"mission", 0) == 2500 and city.score.money == before + 2500, "Mission payout adds to the same cash total")
	# Restart clears abandoned pickups and cash.
	verify(not get_tree().get_nodes_in_group("cash_pickups").is_empty(), "Pickups are lying around before restart")
	await reset_game()
	quiet()
	await frames(3)
	verify(get_tree().get_nodes_in_group("cash_pickups").is_empty() and city.score.money == 0 and city.cash.dropped == 0, "Restart removes abandoned pickups and resets cash")
	config.civilian_chance = saved[0]
	config.police_chance = saved[1]
	print("C1 CASH COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
