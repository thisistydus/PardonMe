extends "res://tests/district_integration.gd"
## Goal C1: knife and shotgun through the shared weapon, projectile, throw and pickup paths.
const KNIFE: WeaponData = preload("res://data/weapons/knife.tres")
const SHOTGUN: WeaponData = preload("res://data/weapons/shotgun.tres")
const BAT: WeaponData = preload("res://data/weapons/bat.tres")
const PISTOL: WeaponData = preload("res://data/weapons/pistol.tres")
var dummies: Array[PracticeTarget] = []
var gunfire: Array[float] = []
var kills: Array[bool] = []

func boot() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	player.invulnerability = 1000
	dummies.clear()
	for node: Node in get_tree().get_nodes_in_group("targets"):
		dummies.append(node as PracticeTarget)
	target = dummies[0]

func place(dummy: PracticeTarget, at: Vector2) -> void:
	dummy.position = at
	dummy.velocity = Vector2.ZERO
	dummy.health = 3
	dummy.downed = false
	dummy.stun = 0
	dummy.air_time = 0
	dummy.collision_layer = 4
	dummy.respawn_time = 0

func projectiles() -> int:
	var count := 0
	for child: Node in city.get_children():
		if child is ToyProjectile and not child.is_queued_for_deletion():
			count += 1
	return count

func start() -> void:
	Events.crime.connect(func(kind: StringName, _at: Vector2, severity: float, _r: float, caused: bool) -> void:
		if kind == &"gunfire" and caused: gunfire.append(severity))
	Events.npc_killed.connect(func(_npc: Node2D, by_player: bool) -> void: kills.append(by_player))
	await boot()
	var at := Vector2(2400, 1800)
	# --- Knife --------------------------------------------------------------
	player.weapons.equip(KNIFE)
	stage_target(at)
	await sim(0.2)
	stage_target(at)
	player.weapons.attack()
	verify(target.downed, "Knife kills an ordinary target in one clean hit")
	verify(absf(target.velocity.length() - KNIFE.knockback) < 1.0, "Knife knockback is light (%.0f)" % target.velocity.length())
	await sim(0.2)
	player.weapons.equip(BAT)
	stage_target(at)
	await sim(0.2)
	player.weapons.attack()
	verify(target.downed and target.velocity.length() > KNIFE.knockback * 4, "Bat knockback stays far heavier than the knife")
	stage_target(at)
	player.global_position = at - Vector2(72, 0)
	player.weapons.equip(KNIFE)
	await sim(0.2)
	player.weapons.attack()
	verify(not target.downed and target.health == 3, "Knife misses at 72 units where its reach ends")
	player.weapons.equip(BAT)
	await sim(0.2)
	player.weapons.attack()
	verify(target.downed, "Bat still connects at 72 units")
	player.weapons.equip(KNIFE)
	stage_target(at)
	await sim(0.2)
	player.weapons.attack()
	await sim(0.19)
	stage_target(at)
	player.weapons.attack()
	verify(target.downed, "Knife recovers in under 0.2 s for a second stab")
	player.weapons.equip(BAT)
	stage_target(at)
	await sim(0.2)
	player.weapons.attack()
	await sim(0.19)
	stage_target(at)
	player.weapons.attack()
	verify(not target.downed, "Bat is still recovering at 0.19 s")
	# Throw, land, recover, drop.
	player.weapons.equip(KNIFE)
	stage_target(at)
	player.global_position = at - Vector2(220, 0)
	await sim(0.45)
	player.throw_weapon()
	verify(player.weapons.data == WeaponController.FISTS, "Throwing leaves fists")
	await sim(0.6)
	var landed := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	verify(target.downed and landed.data == KNIFE, "Thrown knife downs the target and lands as a knife pickup")
	player.global_position = landed.global_position
	await frames(2)
	player.interact()
	verify(player.weapons.data == KNIFE, "Landed knife can be picked up again")
	player.drop_weapon()
	var dropped := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	verify(dropped.data == KNIFE and player.weapons.data == WeaponController.FISTS, "Knife drops gently as a pickup")
	player.interact()
	# --- Shotgun ------------------------------------------------------------
	player.weapons.equip(SHOTGUN)
	player.global_position = Vector2(2400, 1000)
	aim(Vector2.LEFT)
	verify(player.weapons.ammo == 4, "Shotgun starts with four shells in the weapon")
	await sim(0.3)
	gunfire.clear()
	player.weapons.attack()
	verify(player.weapons.ammo == 3 and projectiles() == SHOTGUN.pellets, "One trigger pull spends one shell and fires %d pellets" % SHOTGUN.pellets)
	verify(gunfire == [SHOTGUN.noise_severity] and SHOTGUN.noise_severity > PISTOL.noise_severity, "One gunfire report per pull, louder than the pistol")
	await sim(0.3)
	player.weapons.attack()
	verify(player.weapons.ammo == 3, "Shotgun cadence is slow: no second shot at 0.3 s")
	await sim(0.6)
	player.weapons.attack()
	verify(player.weapons.ammo == 2, "Second shot after the 0.8 s pump")
	# Several targets in the spread, each hit once.
	await sim(1.0)
	player.weapons.ammo = 4
	player.global_position = at - Vector2(150, 0)
	aim(Vector2.RIGHT)
	for i: int in 3:
		place(dummies[i], at + Vector2(0, (i - 1) * 35))
	await frames(2)
	player.weapons.attack()
	await sim(0.3)
	verify(dummies.all(func(d: PracticeTarget) -> bool: return d.downed), "One pull at 150 units downs three spread targets")
	# One trigger pull damages one vehicle once.
	await sim(0.6)
	var car := city.cars[4]
	car.global_position = Vector2(2400, 1300)
	car.rotation = PI / 2
	car.health = car.data.durability
	player.global_position = Vector2(2320, 1300)
	aim(Vector2.RIGHT)
	await frames(3)
	var health := car.health
	player.weapons.attack()
	await sim(0.2)
	verify(is_equal_approx(health - car.health, SHOTGUN.damage * 4.0), "Seven pellets into a car deal one volley of damage (%.0f)" % (health - car.health))
	verify(car.player_responsible, "Shotgun damage attributes the car to the player")
	# Out of range.
	await sim(0.8)
	place(dummies[0], at + Vector2(590, 0))
	player.global_position = at
	aim(Vector2.RIGHT)
	await frames(2)
	player.weapons.attack()
	await sim(0.8)
	verify(not dummies[0].downed, "Pellets expire before 590 units (range %.0f)" % SHOTGUN.projectile_range)
	# Explosive barrel.
	await sim(0.2)
	player.weapons.ammo = 4
	var barrel := ExplosiveBarrel.new()
	barrel.position = Vector2(2500, 2300)
	city.add_child(barrel)
	player.global_position = Vector2(2380, 2300)
	aim(Vector2.RIGHT)
	await frames(3)
	player.weapons.attack()
	await sim(0.15)
	verify(barrel.fuse >= 0 and barrel.player_responsible, "One shotgun volley lights a barrel with player attribution")
	await sim(1.0)
	verify(barrel.exploded, "Shotgun-lit barrel explodes")
	# Pellet kill attribution on a district NPC.
	await sim(0.3)
	kills.clear()
	var civilian := city.citizens[2]
	civilian.ai_enabled = false
	civilian.global_position = Vector2(3000, 1800)
	player.global_position = Vector2(2900, 1800)
	aim(Vector2.RIGHT)
	await frames(3)
	player.weapons.attack()
	await sim(0.2)
	verify(civilian.downed and kills == [true], "Pellet kill is reported once and attributed to the player")
	# Exhaust, then throw empty.
	await sim(0.9)
	player.weapons.ammo = 1
	player.global_position = Vector2(2400, 1000)
	aim(Vector2.LEFT)
	player.weapons.attack()
	await sim(0.9)
	var before := projectiles()
	player.weapons.attack()
	verify(player.weapons.ammo == 0 and projectiles() == before, "Empty shotgun clicks without firing")
	stage_target(at)
	player.global_position = at - Vector2(160, 0)
	await frames(2)
	player.throw_weapon()
	await sim(0.6)
	var empty := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	verify(target.downed and empty.data == SHOTGUN and empty.ammo == 0, "Empty shotgun is thrown, hits and lands with zero shells")
	# Hostile shotgun volley on the player: one strike, not seven.
	player.invulnerability = 0
	player.wounded = false
	FirearmShot.fire(city, SHOTGUN, player.global_position + Vector2(90, 0), Vector2.LEFT, [], false, "TEST SHOTGUN")
	await sim(0.2)
	verify(player.alive and player.wounded, "An enemy volley wounds the player once instead of killing outright")
	# Death while holding a shotgun, then a clean restart.
	player.weapons.equip(SHOTGUN)
	player.invulnerability = 0
	FirearmShot.fire(city, SHOTGUN, player.global_position + Vector2(90, 0), Vector2.LEFT, [], false, "TEST SHOTGUN")
	await sim(0.2)
	verify(not player.alive and city.run.ended and player.death_cause == "SHOT BY TEST SHOTGUN", "Death while holding the shotgun ends the run with the shooter named")
	await reset_game()
	quiet()
	verify(player.alive and player.weapons.data == WeaponController.FISTS and not city.run.ended, "Restart after a shotgun death starts on fists")
	print("C1 WEAPONS COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
