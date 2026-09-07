class_name ExplosiveBarrel
extends StaticBody2D
## Small prop using the same receive_blast / VehicleExplosion interface as vehicles.
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
var health: float = 0
var fuse: float = -1
var exploded: bool = false
var player_responsible: bool = false
var chain_token: int = 0
var age: float = 0
var warning_timer: float = 0
var rng := RandomNumberGenerator.new()
func _ready() -> void:
	add_to_group("damageable")
	add_to_group("barrels")
	collision_layer = 8
	collision_mask = 0
	health = BALANCE.barrel_health
	rng.seed = int(position.x * 31 + position.y)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 16
	shape.shape = circle
	add_child(shape)
	Events.crime.connect(record_source)
func record_source(kind: StringName, at: Vector2, _severity: float, _noise: float, caused: bool) -> void:
	if kind == &"harm" and caused and at.distance_to(global_position) < 10:
		player_responsible = true
func take_hit(amount: int, push: Vector2, bullet: bool = false) -> void:
	if exploded: return
	health = maxf(0, health - amount * (2 if bullet else 1))
	Events.impact.emit(global_position, push.normalized(), 0.35)
	Events.sound_requested.emit(&"crash")
	if health <= 0 and fuse < 0:
		fuse = BALANCE.barrel_fuse + (rng.randf_range(BALANCE.chain_delay_range.x, BALANCE.chain_delay_range.y) if chain_token != 0 else 0.0)
	queue_redraw()
func receive_blast(amount: int, push: Vector2, caused: bool, token: int) -> void:
	player_responsible = player_responsible or caused
	if chain_token == 0: chain_token = token
	take_hit(amount, push)
func _physics_process(delta: float) -> void:
	if fuse < 0 or exploded: return
	age += delta
	fuse -= delta
	warning_timer -= delta
	if warning_timer <= 0:
		warning_timer = 0.2
		Events.sound_requested.emit(&"warning")
	if fuse <= 0: explode()
	queue_redraw()
func explode() -> void:
	if exploded: return
	exploded = true
	collision_layer = 0
	remove_from_group("damageable")
	var blast := VehicleExplosion.new()
	blast.source = self
	blast.radius = BALANCE.barrel_radius
	blast.lethal_radius = BALANCE.barrel_lethal_radius
	blast.object_damage_max = BALANCE.barrel_damage
	blast.force_max = BALANCE.barrel_force
	blast.position = global_position
	Events.crime.emit(&"explosion", global_position, 2.0, 1000.0, player_responsible)
	get_tree().current_scene.add_child(blast)
	queue_redraw()
func _draw() -> void:
	if exploded:
		draw_circle(Vector2.ZERO, 19, Color("211e17"))
		draw_arc(Vector2.ZERO, 14, 0.2, 4.9, 12, Color("534938"), 4)
		return
	draw_circle(Vector2(3, 4), 19, Color(0, 0, 0, 0.4))
	draw_circle(Vector2.ZERO, 16, Color("943f31"))
	draw_arc(Vector2.ZERO, 14, 0, TAU, 24, Color("d0ac60"), 3)
	draw_line(Vector2(-9, -8), Vector2(9, 8), Color("211e17"), 5)
	draw_circle(Vector2(6, -5), 3, Color("d4c18a"))
	if fuse >= 0:
		draw_arc(Vector2.ZERO, BALANCE.barrel_radius, 0, TAU, 40, Color(0.9, 0.4, 0.1, 0.35), 2)
		draw_circle(Vector2(0, -23), 4 + sin(age * 30) * 2, Color("ffe3a0"))
