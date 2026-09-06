class_name ThrownWeapon
extends CharacterBody2D
## A swept physical weapon; transfers its exact resource/ammo to one pickup on landing.
var data: WeaponData
var ammo: int = 0
var direction: Vector2 = Vector2.RIGHT
var travel_speed: float
var age: float = 0.0
var settled: bool = false
var spin: float = 0.0

func _ready() -> void:
	add_to_group("thrown_weapons")
	collision_layer = 0
	collision_mask = 1 | 4 | 8
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	z_index = 7
	travel_speed = data.throw_speed
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	add_child(shape)

func _physics_process(delta: float) -> void:
	if settled:
		return
	age += delta
	spin += delta * (22.0 if data.firearm else 14.0)
	velocity = direction * travel_speed
	var contact := move_and_collide(velocity * delta)
	if contact:
		var body := contact.get_collider()
		if body.has_method("take_hit"):
			Events.crime.emit(&"harm", body.global_position, 1.0, 100.0, true)
			body.take_hit(data.throw_damage, direction * data.throw_knockback, false)
		else:
			Events.impact.emit(global_position, -direction, 0.4)
		Events.sound_requested.emit(&"throw_hit")
		land()
		return
	travel_speed = move_toward(travel_speed, 0, 1000.0 * delta)
	if travel_speed < 90.0 or age >= 1.0:
		land()
	queue_redraw()

func land() -> void:
	if settled:
		return
	settled = true
	var pickup := WeaponPickup.new()
	pickup.data = data
	pickup.ammo = ammo
	pickup.position = global_position
	get_tree().current_scene.add_child(pickup)
	remove_from_group("thrown_weapons")
	queue_free()

func _draw() -> void:
	draw_circle(Vector2(3, 7), 10, Color(0, 0, 0, 0.3))
	draw_line(-direction * 22, -direction * 7, Color(0.9, 0.8, 0.5, 0.45), 3, true)
	draw_set_transform(Vector2(0, -5), spin)
	if data.firearm:
		draw_rect(Rect2(-13, -4, 27, 8), Color("e6d9b9"))
		draw_rect(Rect2(-9, 0, 8, 12), Color("aaa28e"))
	else:
		draw_line(Vector2(-20, 0), Vector2(23, 0), Color("281f18"), 10, true)
		draw_line(Vector2(-20, 0), Vector2(23, 0), Color("d4b67c"), 6, true)
