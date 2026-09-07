class_name ToyCompact
extends CharacterBody2D

@export var data: VehicleData = preload("res://data/vehicles/compact.tres")
var chain_token: int = 0
var occupied: bool = false
var ai_controlled: bool = false
var ai_throttle: float = 0
var ai_steering: float = 0
var ai_brake: bool = false
var ai_state: String = ""
var unavailable: bool = false
var driver: ToyPlayer
var health: float
var speed: float = 0.0
var crash_cooldown: float = 0.0
var failure_timer: float = -1.0
var disabled: bool = false
var age: float = 0.0
var footprint := RectangleShape2D.new()
var engine_voice: AudioStreamPlayer2D
var warning_timer: float = 0.0
var player_responsible: bool = false
var radio_station: int = 0

func _ready() -> void:
	Events.shutdown_requested.connect(stop_engine)
	Events.crime.connect(record_damage_source)
	add_to_group("vehicles")
	add_to_group("damageable")
	collision_layer = 8
	collision_mask = 1 | 2 | 4 | 8 | 16
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	health = data.durability
	footprint.size = Vector2(86, 44)
	var shape := CollisionShape2D.new()
	shape.shape = footprint
	add_child(shape)
	engine_voice = AudioStreamPlayer2D.new()
	engine_voice.volume_db = -25
	engine_voice.max_distance = 1200
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = 2205
	var bytes := PackedByteArray()
	bytes.resize(4410)
	for i: int in 2205:
		var phase := TAU * 80 * i / 22050.0
		bytes.encode_s16(i * 2, int((sin(phase) * 0.65 + sin(phase * 2) * 0.25 + sin(phase * 4) * 0.1) * 18000))
	stream.data = bytes
	engine_voice.stream = stream
	add_child(engine_voice)

func record_damage_source(kind: StringName, at: Vector2, _severity: float, _noise: float, caused: bool) -> void:
	if kind == &"harm" and caused and at.distance_to(global_position) < 10:
		player_responsible = true

func door_positions() -> Array[Vector2]:
	return [to_global(Vector2(-4, 48)), to_global(Vector2(-4, -48))]

func nearest_door(from: Vector2) -> Vector2:
	var doors := door_positions()
	return doors[0] if from.distance_squared_to(doors[0]) < from.distance_squared_to(doors[1]) else doors[1]

func enter(player: ToyPlayer) -> bool:
	if driver != null or disabled or unavailable or not player.alive or (ai_controlled and absf(speed) > 45):
		return false
	var door := nearest_door(player.global_position)
	if player.global_position.distance_to(door) > 65:
		return false
	var query := PhysicsRayQueryParameters2D.create(player.global_position, door, 1 | 8, [get_rid()])
	if not get_world_2d().direct_space_state.intersect_ray(query).is_empty():
		return false
	ai_controlled = false
	driver = player
	player.vehicle = self
	player.visible = false
	player.collision_layer = 0
	player.collision_mask = 0
	player.impulse = Vector2.ZERO
	player.global_position = global_position
	engine_voice.play()
	Events.sound_requested.emit(&"enter")
	Events.message_requested.emit(data.title + " / W accelerate · S brake/reverse · A D steer · Space handbrake · E exit")
	Events.vehicle_entered.emit(self)
	return true

func try_exit() -> bool:
	if driver == null:
		return false
	var candidates := door_positions()
	candidates.append(to_global(Vector2(-66, 0)))
	candidates.append(to_global(Vector2(66, 0)))
	for point: Vector2 in candidates:
		var query := PhysicsShapeQueryParameters2D.new()
		var circle := CircleShape2D.new()
		circle.radius = 16
		query.shape = circle
		query.transform = Transform2D(0, point)
		query.collision_mask = 1 | 4 | 8
		# Include this vehicle to guarantee no overlapping exit.
		if not get_world_2d().direct_space_state.intersect_shape(query).is_empty():
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position, point, 1 | 8, [get_rid()])
		if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
			continue
		driver.global_position = point
		driver.visible = true
		driver.collision_layer = 2
		driver.collision_mask = 1 | 4 | 8
		driver.velocity = Vector2.ZERO
		driver.vehicle = null
		driver = null
		Events.vehicle_exited.emit(self)
		engine_voice.stop()
		Events.sound_requested.emit(&"enter")
		return true
	Events.message_requested.emit("DOORS BLOCKED. Move the compact to make room.")
	return false

func _physics_process(delta: float) -> void:
	age += delta
	crash_cooldown = maxf(0, crash_cooldown - delta)
	if failure_timer >= 0 and not disabled:
		failure_timer -= delta
		warning_timer -= delta
		if warning_timer <= 0:
			Events.sound_requested.emit(&"warning")
			warning_timer = 0.18 if failure_timer < 1.0 else 0.5
		if failure_timer <= 0:
			explode()
	var throttle: float = 0.0
	var steering: float = 0.0
	var handbrake: bool = false
	if driver and driver.alive and not disabled and not unavailable:
		throttle = Input.get_axis("move_down", "move_up")
		steering = Input.get_axis("move_left", "move_right")
		handbrake = Input.is_action_pressed("handbrake")
	elif ai_controlled and not disabled and not unavailable:
		throttle = ai_throttle
		steering = ai_steering
		handbrake = ai_brake
	var degradation := 0.8 if health < 60 else 1.0
	if absf(throttle) > 0.05:
		var target_speed := throttle * (data.max_speed if throttle > 0 else data.reverse_speed) * degradation
		var rate := data.braking if speed * throttle < 0 else data.acceleration
		speed = move_toward(speed, target_speed, rate * delta)
	else:
		speed = move_toward(speed, 0, (900.0 if disabled else 125.0) * delta)
	if handbrake:
		speed = move_toward(speed, 0, data.braking * delta)
	if absf(speed) > 2:
		var angle := rotation + steering * signf(speed) * data.steering * clampf(absf(speed) / 190.0, 0.28, 1.0) * delta
		var query := PhysicsShapeQueryParameters2D.new()
		query.shape = footprint
		query.transform = Transform2D(angle, global_position)
		query.collision_mask = 1 | 8 | 16
		query.exclude = [get_rid()]
		if get_world_2d().direct_space_state.intersect_shape(query).is_empty():
			rotation = angle
	velocity = Vector2.RIGHT.rotated(rotation) * speed
	move_with_impacts(velocity * delta)
	if driver:
		driver.global_position = global_position
		engine_voice.pitch_scale = 0.7 + absf(speed) / 300.0
	queue_redraw()

func move_with_impacts(motion: Vector2) -> void:
	# Resolve the remaining motion after launching a body. A wall behind it still stops us.
	for i: int in 6:
		var collision := move_and_collide(motion)
		if collision == null:
			return
		var body := collision.get_collider()
		var impact_speed := absf(speed)
		if driver and impact_speed > 100:
			player_responsible = true
		if body is PracticeTarget and impact_speed > 90:
			Events.crime.emit(&"harm", body.global_position, 1.5, 180.0, driver != null)
			body.launch(3 if impact_speed > 230 else 1, velocity.normalized() * clampf(impact_speed * 2.4 + 200, 420, 1650))
			take_hit(maxi(1, int(impact_speed / 120)), Vector2.ZERO, false)
			speed *= data.target_speed_retention
			velocity = Vector2.RIGHT.rotated(rotation) * speed
			motion = collision.get_remainder() * data.target_speed_retention
			continue
		if body is ExplosiveBarrel and impact_speed > 70:
			body.player_responsible = body.player_responsible or driver != null
			body.take_hit(maxi(1, int(impact_speed / 12)), velocity, false)
		if body is ToyPlayer and impact_speed > 90:
			body.take_hit(1, velocity.normalized() * impact_speed, false)
		if crash_cooldown <= 0 and impact_speed > 100:
			if body is ToyCompact:
				body.player_responsible = body.player_responsible or driver != null
				body.take_hit(int(impact_speed / 12), velocity.normalized() * impact_speed, false)
			take_hit(int(impact_speed / 15), collision.get_normal() * impact_speed, false)
			crash_cooldown = 0.3
			speed *= -0.3
		else:
			speed = 0
		return

func explode() -> void:
	if disabled or unavailable:
		return
	disabled = true
	Events.crime.emit(&"explosion", global_position, 2.0, 1000.0, player_responsible)
	Events.vehicle_destroyed.emit(self)
	health = 0
	failure_timer = 0
	speed = 0
	velocity = Vector2.ZERO
	engine_voice.stop()
	Events.message_requested.emit("COMPACT EXPLODED. Stay clear of the blast!")
	var blast := VehicleExplosion.new()
	blast.source = self
	blast.radius = data.blast_radius
	blast.lethal_radius = data.lethal_blast_radius
	blast.position = global_position
	get_tree().current_scene.add_child(blast)
	queue_redraw()

func take_hit(amount: int, push: Vector2, bullet: bool = false) -> void:
	if disabled or unavailable:
		return
	health = maxf(0, health - float(amount) * (4.0 if bullet else 1.0))
	Events.impact.emit(global_position, push.normalized(), 0.7)
	Events.sound_requested.emit(&"crash")
	if health <= 0 and failure_timer < 0:
		failure_timer = data.explosion_delay
		warning_timer = 0
		Events.message_requested.emit("EXPLOSION IN %.0f SECONDS — EXIT AND RUN!" % data.explosion_delay)
	elif health <= 30:
		if failure_timer < 0:
			Events.message_requested.emit("CRITICAL DAMAGE. Further damage risks an explosion.")

func damage_state() -> String:
	if disabled:
		return "WRECKED"
	if failure_timer >= 0:
		return "EXPLODES IN %.1fs" % maxf(0, failure_timer)
	if health <= 30:
		return "CRITICAL"
	if health <= 60:
		return "SMOKING"
	return "HEALTHY"

func _draw() -> void:
	if failure_timer >= 0 and not disabled:
		draw_arc(Vector2.ZERO, data.blast_radius, 0, TAU, 64, Color(0.9, 0.39, 0.17, 0.35 + sin(age * 18) * 0.15), 3, true)
	draw_rect(Rect2(-46, -21, 94, 49), Color(0, 0, 0, 0.4))
	var tint := Color(0.37, 0.31, 0.26) if disabled else (Color(0.65, 0.78, 1.0) if data.title == "SEDAN" else Color.WHITE)
	draw_texture_rect_region(SpriteArt.COMPACT, Rect2(-46, -24, 92, 48), SpriteArt.COMPACT_REGION, tint)
	if occupied and driver == null:
		draw_circle(Vector2(-4, 5), 6, Color("e1b984"))
		draw_string(ThemeDB.fallback_font, Vector2(-38, -35), "OCCUPIED", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("e1c184"))
	if data.police_vehicle:
		draw_rect(Rect2(-10, -20, 20, 40), Color("d8ddd5"))
		draw_rect(Rect2(-5, -19, 10, 13), Color("b83e38"))
		draw_rect(Rect2(-5, 6, 10, 13), Color("3d78a1"))
	if disabled:
		draw_line(Vector2(-35, -15), Vector2(27, 10), Color("8e4d31"), 4)
		draw_line(Vector2(-15, 20), Vector2(32, -20), Color("0f1513"), 7)
	if health <= 60:
		for i: int in 5:
			var t := fmod(age * 0.6 + i * 0.2, 1.0)
			draw_circle(Vector2(30 - t * 32, -t * 35), 5 + t * (20 if health <= 30 else 10), Color(0.15, 0.15, 0.13, (1 - t) * 0.6))
	if health <= 30 and not disabled and fmod(age, 0.6) < 0.3:
		draw_arc(Vector2.ZERO, 55, 0, TAU, 32, Color("d37451"), 3)


func stop_engine() -> void:
	engine_voice.stop()
	engine_voice.stream = null

func receive_blast(amount: int, push: Vector2, caused: bool, token: int) -> void:
	player_responsible = player_responsible or caused
	if chain_token == 0: chain_token = token
	var was_pending := failure_timer >= 0
	take_hit(amount, push)
	if not was_pending and failure_timer >= 0:
		var balance: PressureConfig = preload("res://data/pressure_config.tres")
		failure_timer += randf_range(balance.chain_delay_range.x, balance.chain_delay_range.y)
