class_name PracticeTarget
extends CharacterBody2D

@export var armed: bool = false
var health: int = 3
var downed: bool = false
var stun: float = 0.0
var respawn_time: float = 0.0
var origin: Vector2
var shot_timer: float = 1.7
var telegraph: float = 0.0
var shot_direction: Vector2 = Vector2.LEFT
var air_time: float = 0.0
var tumble_angle: float = 0.0
const FLIGHT_DURATION: float = 0.8

func _ready() -> void:
	add_to_group("damageable")
	add_to_group("targets")
	origin = position
	collision_layer = 4
	collision_mask = 1 | 8
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16.0
	collision.shape = circle
	add_child(collision)

func _physics_process(delta: float) -> void:
	stun = maxf(0, stun - delta)
	if air_time > 0:
		air_time = maxf(0, air_time - delta)
		tumble_angle += delta * 13.0
		if air_time <= 0:
			collision_layer = 0 if downed else 4
			collision_mask = 1 | 8
	if velocity.length() > 2.0:
		var before := velocity.length()
		move_and_slide()
		if not downed and (stun > 0 or air_time > 0) and get_slide_collision_count() > 0 and before > 160:
			take_hit(3, Vector2.ZERO, false)
		velocity = velocity.move_toward(Vector2.ZERO, delta * (260.0 if air_time > 0 else 850.0))
	if downed:
		respawn_time -= delta
		if respawn_time <= 0:
			var space := PhysicsShapeQueryParameters2D.new()
			var circle := CircleShape2D.new()
			circle.radius = 40.0
			space.shape = circle
			space.transform = Transform2D(0, origin)
			space.collision_mask = 2 | 8
			if get_world_2d().direct_space_state.intersect_shape(space).is_empty():
				position = origin
				health = 3
				downed = false
				collision_layer = 4
				shot_timer = 1.7
				tumble_angle = 0.0
		queue_redraw()
		return
	if armed and stun <= 0 and air_time <= 0:
		update_shooter(delta)
	queue_redraw()

func update_shooter(delta: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as ToyPlayer
	if player == null or not player.alive:
		return
	var offset := player.global_position - global_position
	var query := PhysicsRayQueryParameters2D.create(global_position, player.global_position, 1 | 8)
	var can_see := offset.length() < 420.0 and get_world_2d().direct_space_state.intersect_ray(query).is_empty()
	if not can_see:
		telegraph = 0.0
		shot_timer = 1.7
		return
	shot_timer -= delta
	if shot_timer <= 0.65 and telegraph <= 0:
		shot_direction = offset.normalized()
		telegraph = 0.65
	if shot_timer <= 0:
		var bullet := ToyProjectile.new()
		bullet.position = global_position
		bullet.direction = shot_direction
		bullet.player_caused = false
		bullet.mask = 1 | 2 | 8
		bullet.speed = 510.0
		bullet.exclusions = [get_rid()]
		get_tree().current_scene.add_child(bullet)
		Events.sound_requested.emit(&"enemy_shot")
		shot_timer = 1.7
		telegraph = 0.0

func take_hit(amount: int, push: Vector2, _bullet: bool = false) -> void:
	if downed:
		return
	health -= amount
	velocity = push
	stun = 0.55
	telegraph = 0
	shot_timer = 1.7
	Events.impact.emit(global_position, push.normalized(), 1.0 if amount >= 3 else 0.6)
	Events.sound_requested.emit(&"bat_hit" if amount >= 3 else &"punch")
	if health <= 0:
		downed = true
		collision_layer = 0
		respawn_time = 5.0
		Events.target_downed.emit()
	queue_redraw()

func launch(amount: int, push: Vector2) -> void:
	if downed:
		return
	take_hit(amount, push)
	air_time = FLIGHT_DURATION
	tumble_angle = 0.0
	# Airborne bodies don't stop cars or collide with their launching vehicle.
	collision_layer = 0
	collision_mask = 1

func visual_lift() -> float:
	return sin(PI * air_time / FLIGHT_DURATION) * 55.0

func _draw() -> void:
	draw_circle(Vector2(3, 5), 19, Color(0, 0, 0, 0.3))
	var facing := shot_direction.angle() if armed else 0.0
	var scale_factor := Vector2(1.0, 0.65) if downed and air_time <= 0 else Vector2.ONE
	var turn := tumble_angle if air_time > 0 else (PI * 0.5 if downed else facing)
	draw_set_transform(Vector2(0, -visual_lift()), turn, scale_factor)
	var tint := Color(0.6, 0.48, 0.38) if downed else (Color(1.0, 0.6, 0.5) if armed else Color.WHITE)
	draw_texture_rect_region(SpriteArt.TARGET, Rect2(-22, -21, 44, 42), SpriteArt.TARGET_REGION, tint)
	draw_set_transform(Vector2.ZERO)
	if downed:
		return
	if stun > 0:
		draw_arc(Vector2.ZERO, 25, 0, TAU, 24, Color("efd191"), 2)
	if armed:
		draw_line(Vector2.ZERO, shot_direction * 28, Color("d6c8a9"), 6)
		if telegraph > 0:
			draw_line(shot_direction * 30, shot_direction * 380, Color(0.85, 0.3, 0.2, 0.45), 2)
	else:
		for i: int in health:
			draw_rect(Rect2(-13 + i * 10, -29, 7, 4), Color("d1c093"))
