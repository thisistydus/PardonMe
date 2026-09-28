class_name FirearmShot
extends RefCounted
## The same projectile, ballistics and report for both holders. AI chooses when/where to fire.
## Multi-pellet weapons spread their pellets evenly across spread_degrees and share one volley.
static func fire(parent: Node, weapon: WeaponData, at: Vector2, direction: Vector2, exclusions: Array[RID], player_caused: bool, source_label: String = "") -> ToyProjectile:
	var aim := direction.normalized()
	var count := maxi(1, weapon.pellets)
	var volley: ShotVolley = ShotVolley.new() if count > 1 else null
	var first: ToyProjectile
	for i: int in count:
		var offset := 0.0 if count == 1 else deg_to_rad(lerpf(-weapon.spread_degrees / 2.0, weapon.spread_degrees / 2.0, float(i) / (count - 1)))
		var bullet := ToyProjectile.new()
		bullet.position = at
		bullet.direction = aim.rotated(offset)
		bullet.damage = weapon.damage
		bullet.force = weapon.knockback
		bullet.speed = weapon.projectile_speed
		bullet.lifetime = weapon.projectile_range / weapon.projectile_speed
		bullet.mask = 1 | 8 | (4 if player_caused else 2)
		bullet.player_caused = player_caused
		bullet.exclusions = exclusions
		bullet.volley = volley
		bullet.source_label = source_label
		parent.add_child(bullet)
		if first == null:
			first = bullet
	Events.sound_requested.emit(weapon.shot_sound)
	Events.crime.emit(&"gunfire", at, weapon.noise_severity, weapon.noise_radius, player_caused)
	Events.impact.emit(at + aim * 26, aim, 0.15 if count == 1 else 0.45)
	return first
