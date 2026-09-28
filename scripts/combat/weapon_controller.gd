class_name WeaponController
extends Node2D

const FISTS: WeaponData = preload("res://data/weapons/fists.tres")
var data: WeaponData = FISTS
var ammo: int = 0
var recovery: float = 0.0
var swing_time: float = 0.0
var swing_direction: Vector2 = Vector2.RIGHT
var player: ToyPlayer

func _ready() -> void:
	player = get_parent() as ToyPlayer
	z_index = 5

func _physics_process(delta: float) -> void:
	recovery = maxf(0.0, recovery - delta)
	swing_time = maxf(0.0, swing_time - delta)
	if player.alive and player.visible and Input.is_action_just_pressed("attack"):
		attack()
	queue_redraw()

func equip(weapon: WeaponData, remaining: int = -1) -> void:
	data = weapon
	ammo = weapon.ammunition if remaining < 0 else remaining
	swing_time = 0.0
	recovery = 0.15

func attack() -> void:
	if recovery > 0.0 or not player.alive or not player.visible or player.control_locked:
		return
	recovery = data.cooldown
	swing_direction = player.aim_direction
	if data.firearm:
		if ammo <= 0:
			Events.sound_requested.emit(&"empty")
			Events.message_requested.emit("EMPTY. Drop it, find another, or use your fists.")
			return
		ammo -= 1
		FirearmShot.fire(get_tree().current_scene, data, global_position, swing_direction, [player.get_rid()], true)
		player.impulse -= swing_direction * data.recoil
		swing_time = 0.09
		return
	swing_time = 0.16
	Events.sound_requested.emit(&"stab" if data.id == &"knife" else &"swing")
	Events.crime.emit(&"melee", global_position, 0.0, 70.0, true)
	for node: Node in get_tree().get_nodes_in_group("damageable"):
		var target := node as Node2D
		var offset := target.global_position - global_position
		if offset.length() > data.reach + 14.0:
			continue
		if absf(swing_direction.angle_to(offset)) > deg_to_rad(data.arc_degrees / 2.0):
			continue
		var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1 | 8, [player.get_rid()])
		var wall := get_world_2d().direct_space_state.intersect_ray(query)
		if not wall.is_empty() and wall.collider != target:
			continue
		Events.crime.emit(&"harm", target.global_position, 1.0, 70.0, true)
		if target.has_method("note_attacker"):
			target.note_attacker(true)
		target.take_hit(data.damage, offset.normalized() * data.knockback, false)

func _draw() -> void:
	var direction := swing_direction if swing_time > 0 else player.aim_direction
	draw_set_transform(Vector2.ZERO, direction.angle())
	if data.id == &"bat":
		var angle := lerpf(1.2, -1.2, swing_time / 0.16) if swing_time > 0.0 else -0.65
		var tip := Vector2(64, 0).rotated(angle)
		draw_line(Vector2(13, 12), tip, Color("1a1a16"), 11, true)
		draw_line(Vector2(13, 12), tip, Color("d5b878"), 7, true)
	elif data.id == &"knife":
		# A short forward jab rather than a sweep.
		var reach := 14.0 + (18.0 * sin(PI * swing_time / 0.16) if swing_time > 0.0 else 0.0)
		draw_line(Vector2(reach, 9), Vector2(reach + 10, 9), Color("2a211a"), 6, true)
		draw_line(Vector2(reach + 10, 9), Vector2(reach + 30, 9), Color("dfe3e0"), 4, true)
	elif data.id == &"shotgun":
		draw_rect(Rect2(8, -6, 16, 12), Color("6b4a2e"))
		draw_rect(Rect2(20, -4, 30, 8), Color("9d9a8c"))
		if swing_time > 0.0:
			draw_circle(Vector2(54, 0), 13 * swing_time / 0.09, Color("ffd07a"))
	elif data.firearm:
		draw_rect(Rect2(12, -5, 23, 9), Color("afa996"))
		if swing_time > 0.0:
			draw_circle(Vector2(37, 0), 8 * swing_time / 0.09, Color("ffe0a1"))
	elif swing_time > 0.0:
		draw_circle(Vector2(35, 0), 8, Color("e5d7b3"))
	if swing_time > 0.0 and not data.firearm:
		draw_arc(Vector2.ZERO, data.reach, -deg_to_rad(data.arc_degrees / 2), deg_to_rad(data.arc_degrees / 2), 24, Color(0.94, 0.82, 0.56, swing_time / 0.16), 3 if data.id == &"knife" else 6, true)

