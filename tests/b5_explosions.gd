extends "res://tests/district_integration.gd"
func barrel(at: Vector2) -> ExplosiveBarrel:
	var prop := ExplosiveBarrel.new()
	prop.position = at
	city.add_child(prop)
	return prop
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	city.response.enabled = false
	player.position = Vector2(600, 600)
	var prop := barrel(Vector2(700, 600))
	await frames(3)
	player.aim_direction = Vector2.RIGHT
	player.weapons.equip(DistrictNPC.PISTOL)
	player.weapons.recovery = 0
	player.weapons.attack()
	await sim(0.2)
	verify(prop.health < 8, "Shared projectile damages environmental barrel")
	player.position = Vector2(655, 600)
	player.aim_direction = Vector2.RIGHT
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	player.weapons.recovery = 0
	player.weapons.attack()
	verify(prop.fuse > 0 and not prop.exploded, "Bat strike starts readable barrel fuse")
	player.position = Vector2(400, 600)
	await sim(1.0)
	verify(prop.exploded, "Barrel explodes once after warning")
	prop = barrel(Vector2(700, 600))
	player.position = Vector2(600, 600)
	player.aim_direction = Vector2.RIGHT
	player.weapons.equip(preload("res://data/weapons/bat.tres"))
	player.throw_weapon()
	await sim(0.2)
	verify(prop.health == 5, "Thrown weapon damages barrel and lands")
	player.position = Vector2(400, 1000)
	car.position = Vector2(600, 600)
	car.rotation = 0
	car.speed = 0
	await frames(3)
	car.speed = 420
	await sim(0.3)
	print("BARREL CAR TRACE position=%s speed=%.1f barrel_health=%.1f fuse=%.2f player=%s" % [car.position, car.speed, prop.health, prop.fuse, player.position])
	verify(prop.fuse > 0 or prop.exploded, "High-speed car impact triggers barrel warning")
	player.position = Vector2(700, 1000)
	car.position = Vector2(4100, 1800)
	car.speed = 0
	var a := barrel(Vector2(500, 1800))
	var b := barrel(Vector2(570, 1800))
	var c := barrel(Vector2(620, 1850))
	var victim := city.response.make_car(Vector2(680, 1850), 0)
	victim.health = 35
	var next_car := city.cars[2]
	next_car.position = Vector2(770, 1850)
	next_car.health = 25
	var last := barrel(Vector2(880, 1850))
	a.player_responsible = true
	var witness := city.citizens[0]
	witness.position = Vector2(500, 2250)
	await frames(3)
	a.take_hit(20, Vector2.ZERO)
	await sim(0.7)
	verify(a.exploded and not b.exploded and b.fuse > 0, "Chain starts on a later fuse rather than same-frame detonation")
	await sim(8.0)
	verify(b.exploded and c.exploded, "Barrel-to-barrel propagation works")
	verify(victim.disabled and next_car.disabled, "Barrel-to-police-cruiser and cruiser-to-vehicle chains work")
	verify(last.exploded, "Vehicle explosion ignites a downstream barrel")
	verify(city.explosion_tracker.feat_count > 0, "Attributed multi-object chain reports a debug feat")
	verify(city.heat.level > 0, "Witnessed attributed explosions generate Heat")
	await sim(2.0)
	verify(get_tree().get_nodes_in_group("explosions").is_empty(), "Chain terminates and transient blast nodes expire")
	print("B5 EXPLOSIONS COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
