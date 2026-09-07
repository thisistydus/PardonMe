class_name VehicleExplosion
extends Node2D
## One radial damage event, then a short visual effect. Solid cover blocks the blast.
var source: CollisionObject2D
var object_damage_max: float = 100
var force_max: float = 1450
var chain_token: int = 0
var player_caused: bool = false
var radius: float = 190.0
var lethal_radius: float = 90.0
var age: float = 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 12
	add_to_group("explosions")
	Events.sound_requested.emit(&"explosion")
	Events.impact.emit(global_position, Vector2.UP, 2.0)
	chain_token = source.chain_token if source.chain_token != 0 else source.get_instance_id()
	player_caused = source.player_responsible
	Events.explosion_detonated.emit(chain_token, player_caused)
	apply_damage()

func apply_damage() -> void:
	var targets: Array[Node] = get_tree().get_nodes_in_group("damageable")
	targets.append_array(get_tree().get_nodes_in_group("player"))
	for node: Node in targets:
		var target := node as Node2D
		if target == source:
			continue
		var offset := target.global_position - global_position
		var distance := offset.length()
		if distance > radius:
			continue
		var ray := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1 | 8, [source.get_rid()])
		var cover := get_world_2d().direct_space_state.intersect_ray(ray)
		if not cover.is_empty() and cover.collider != target:
			continue
		var direction := offset.normalized() if distance > 0.1 else Vector2.UP
		var strength := 1.0 - distance / radius
		var push := direction * lerpf(450, force_max, strength)
		if target is ToyPlayer:
			target.take_blast(push, distance <= lethal_radius or target.vehicle == source)
		elif target is PracticeTarget:
			target.launch(ceili(lerpf(2, 6, strength)), push)
		elif target.has_method("receive_blast"):
			target.receive_blast(ceili(lerpf(20, object_damage_max, strength)), push, player_caused, chain_token)
		elif target.has_method("take_hit"):
			target.take_hit(ceili(lerpf(20, object_damage_max, strength)), push, false)

func _process(delta: float) -> void:
	# Let the blast finish visually even when the player's death pauses gameplay.
	age += delta / maxf(Engine.time_scale, 0.01)
	if age > 1.0:
		queue_free()
	queue_redraw()

func _draw() -> void:
	var burst := clampf(age / 0.22, 0, 1)
	var fade := clampf(1.0 - age / 0.65, 0, 1)
	draw_circle(Vector2.ZERO, radius * burst * 0.6, Color(0.8, 0.25, 0.09, fade * 0.8))
	draw_circle(Vector2.ZERO, radius * burst * 0.32, Color(1, 0.68, 0.24, fade))
	draw_arc(Vector2.ZERO, radius * minf(age / 0.35, 1), 0, TAU, 64, Color(1, 0.8, 0.4, fade), 6, true)
	for i: int in 12:
		var direction := Vector2.RIGHT.rotated(i * TAU / 12)
		var point := direction * radius * burst * (0.5 + 0.035 * (i % 5))
		draw_circle(point + Vector2(0, -age * 30), 10 + age * 28, Color(0.17, 0.16, 0.13, maxf(0, age - 0.12) * (1 - age)))
		draw_line(direction * radius * burst * 0.3, direction * radius * burst * 0.8, Color(1, 0.76, 0.35, fade), 4, true)
