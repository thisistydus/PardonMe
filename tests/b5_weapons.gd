extends "res://tests/district_integration.gd"
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	var officer := city.spawn_citizen(Vector2(600, 600), "police")
	officer.heat = city.heat
	officer.ai_enabled = false
	player.position = Vector2(850, 600)
	await frames(3)
	city.heat.points = 3
	city.heat.update_level()
	officer.shot_timer = 0
	officer.shot_direction = Vector2.RIGHT
	officer.fire_if_ready(0.1)
	verify(officer.ammo == 7 and officer.shots_fired == 1, "Police firing consumes the actual pistol magazine")
	var bullet: ToyProjectile
	for node: Node in city.get_children():
		if node is ToyProjectile: bullet = node
	verify(bullet != null and bullet.speed == officer.held_weapon.projectile_speed and bullet.damage == officer.held_weapon.damage and is_equal_approx(bullet.lifetime * bullet.speed, officer.held_weapon.projectile_range), "Police bullet uses shared damage, speed and range")
	bullet.queue_free()
	var before := get_tree().get_nodes_in_group("pickups").size()
	officer.take_hit(3, Vector2.ZERO, true)
	officer.take_hit(3, Vector2.ZERO, true)
	verify(get_tree().get_nodes_in_group("pickups").size() == before + 1, "Repeated lethal hits produce exactly one police pistol")
	var drop := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	verify(drop.ammo == 7 and drop.data == DistrictNPC.PISTOL, "Dropped magazine preserves remaining seven rounds")
	player.position = drop.position
	player.interact()
	verify(player.weapons.ammo == 7, "Player picks up the officer's remaining magazine")
	player.aim_direction = Vector2.LEFT
	for i: int in 7:
		player.weapons.recovery = 0
		player.weapons.attack()
	verify(player.weapons.ammo == 0, "Player can fire and empty that same police pistol")
	player.throw_weapon()
	verify(player.weapons.data == WeaponController.FISTS, "Empty police pistol uses existing throw ownership transition")
	var empty := city.spawn_citizen(Vector2(1200, 600), "police")
	empty.ai_enabled = false
	empty.ammo = 0
	empty.take_hit(3, Vector2.ZERO)
	var empty_drop := get_tree().get_nodes_in_group("pickups").back() as WeaponPickup
	verify(empty_drop.ammo == 0, "Empty officer drops zero ammo, never a fresh magazine")
	for i: int in 70:
		var pickup := WeaponPickup.new()
		pickup.data = DistrictNPC.PISTOL
		pickup.ammo = 0
		pickup.position = player.position if i < 4 else Vector2(4400, 3200)
		pickup.age = 200
		city.add_child(pickup)
	city.director.clean_drops()
	verify(is_instance_valid(empty_drop) and not empty_drop.is_queued_for_deletion(), "Young combat drop survives cleanup")
	await frames(3)
	verify(get_tree().get_nodes_in_group("pickups").size() <= 64, "Only old distant excess pickups are cleaned to the soft cap")
	print("B5 WEAPONS COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
