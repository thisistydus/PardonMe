class_name ToyPlayer
extends CharacterBody2D

var aim_direction: Vector2 = Vector2.RIGHT
var controller_aim: bool = false
var alive: bool = true
var wounded: bool = false
var invulnerability: float = 0.0
var impulse: Vector2 = Vector2.ZERO
var weapons: WeaponController
var vehicle: ToyCompact
var stride: float = 0.0

func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 14.0
	shape.shape = circle
	add_child(shape)
	weapons = WeaponController.new()
	weapons.name = "WeaponController"
	add_child(weapons)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		controller_aim = false
	elif event is InputEventJoypadMotion and event.axis in [JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y] and absf(event.axis_value) > 0.25:
		controller_aim = true

func _physics_process(delta: float) -> void:
	if not alive:
		return
	invulnerability = maxf(0.0, invulnerability - delta)
	if vehicle != null:
		global_position = vehicle.global_position
		if Input.is_action_just_pressed("interact"):
			vehicle.try_exit()
		return
	var stick := Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if controller_aim:
		if stick.length() > 0.2:
			aim_direction = stick.normalized()
	else:
		var direction := get_global_mouse_position() - global_position
		if direction.length() > 4.0:
			aim_direction = direction.normalized()
	var movement := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	stride += movement.length() * delta * 16.0
	velocity = movement * (245.0 if wounded else 280.0) + impulse
	impulse = impulse.move_toward(Vector2.ZERO, 1400.0 * delta)
	move_and_slide()
	if Input.is_action_just_pressed("interact"):
		interact()
	if Input.is_action_just_pressed("drop_weapon"):
		drop_weapon()
	if Input.is_action_just_pressed("throw_weapon"):
		throw_weapon()
	queue_redraw()

func interact() -> void:
	for point: Node2D in get_tree().get_nodes_in_group("interactables"):
		if global_position.distance_to(point.global_position) < 65 and point.interact(self):
			return
	var cars := get_tree().get_nodes_in_group("vehicles")
	cars.sort_custom(func(a: ToyCompact, b: ToyCompact) -> bool: return a.nearest_door(global_position).distance_squared_to(global_position) < b.nearest_door(global_position).distance_squared_to(global_position))
	for node: Node in cars:
		var car := node as ToyCompact
		if car.enter(self):
			return
	var nearest: WeaponPickup
	var distance: float = 65.0
	for node: Node in get_tree().get_nodes_in_group("pickups"):
		var pickup := node as WeaponPickup
		var d := global_position.distance_to(pickup.global_position)
		if d < distance:
			distance = d
			nearest = pickup
	if nearest:
		drop_weapon()
		weapons.equip(nearest.data, nearest.ammo)
		nearest.remove_from_group("pickups")
		nearest.queue_free()
		Events.sound_requested.emit(&"enter")

func drop_weapon() -> void:
	if weapons.data == WeaponController.FISTS:
		return
	var pickup := WeaponPickup.new()
	pickup.data = weapons.data
	pickup.ammo = weapons.ammo
	pickup.position = global_position
	get_tree().current_scene.add_child(pickup)
	weapons.equip(WeaponController.FISTS)

func throw_weapon() -> void:
	if not alive or vehicle != null or weapons.data == WeaponController.FISTS:
		return
	var thrown := ThrownWeapon.new()
	thrown.data = weapons.data
	thrown.ammo = weapons.ammo
	thrown.direction = aim_direction
	# Sweep from the player's center, so a nearby wall cannot be skipped at release.
	thrown.position = global_position
	get_tree().current_scene.add_child(thrown)
	weapons.equip(WeaponController.FISTS)
	Events.sound_requested.emit(&"swing")

func take_hit(_amount: int, push: Vector2, _bullet: bool = true) -> void:
	if not alive or invulnerability > 0.0:
		return
	impulse = push
	invulnerability = 0.9
	Events.impact.emit(global_position, push.normalized(), 1.2)
	if wounded:
		die()
	else:
		wounded = true
		Events.sound_requested.emit(&"wounded")
		Events.message_requested.emit("WOUNDED. The next bullet ends your permission slip.")

func take_blast(push: Vector2, lethal: bool) -> void:
	if not alive:
		return
	if lethal:
		# A point-blank blast (including the occupant) cannot be tanked with bullet grace.
		die()
	else:
		take_hit(1, push, false)
		if alive:
			Events.message_requested.emit("BLAST INJURY. Keep clear of wrecks!")

func die() -> void:
	if not alive:
		return
	alive = false
	visible = false
	collision_layer = 0
	collision_mask = 0
	if vehicle != null:
		vehicle.driver = null
		vehicle.engine_voice.stop()
		vehicle = null
	Events.sound_requested.emit(&"death")
	Events.player_died.emit()


func _draw() -> void:
	draw_circle(Vector2(3, 5), 17, Color(0, 0, 0, 0.35))
	var moving := velocity.length() > 20.0
	var sway := sin(stride) * 0.035 if moving else 0.0
	draw_set_transform(Vector2(0, absf(sin(stride)) * -1.3 if moving else 0.0), aim_direction.angle() + sway)
	var color := Color.WHITE if not wounded else Color(1, 0.55, 0.48)
	if invulnerability > 0 and fmod(invulnerability, 0.15) > 0.075:
		color = Color(1.6, 1.6, 1.6)
	draw_texture_rect_region(SpriteArt.PLAYER, Rect2(-24, -22, 48, 44), SpriteArt.PLAYER_REGION, color)
	draw_line(Vector2(28, 0), Vector2(42, 0), Color("d4b567"), 2, true)
	draw_set_transform(Vector2.ZERO)
