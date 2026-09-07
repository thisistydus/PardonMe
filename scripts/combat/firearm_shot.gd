class_name FirearmShot
extends RefCounted
## The same projectile, ballistics and report for both holders. AI chooses when/where to fire.
static func fire(parent: Node, weapon: WeaponData, at: Vector2, direction: Vector2, exclusions: Array[RID], player_caused: bool) -> ToyProjectile:
	var bullet := ToyProjectile.new()
	bullet.position = at
	bullet.direction = direction.normalized()
	bullet.damage = weapon.damage
	bullet.force = weapon.knockback
	bullet.speed = weapon.projectile_speed
	bullet.lifetime = weapon.projectile_range / weapon.projectile_speed
	bullet.mask = 1 | 8 | (4 if player_caused else 2)
	bullet.player_caused = player_caused
	bullet.exclusions = exclusions
	parent.add_child(bullet)
	Events.sound_requested.emit(weapon.shot_sound)
	Events.crime.emit(&"gunfire", at, 1.5, 700.0, player_caused)
	Events.impact.emit(at + direction * 26, direction, 0.15)
	return bullet
