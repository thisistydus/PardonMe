class_name ToyProjectile
extends Node2D
## Swept ray per physics tick prevents tunneling, including through thin cover.
var player_caused: bool = true
var direction: Vector2 = Vector2.RIGHT
var speed: float = 1050.0
var damage: int = 3
var force: float = 270.0
var lifetime: float = 1.6
var exclusions: Array[RID] = []
var mask: int = 1 | 4 | 8

func _ready() -> void:
	z_index = 8

func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	var next := global_position + direction * speed * delta
	var query := PhysicsRayQueryParameters2D.create(global_position, next, mask, exclusions)
	var hit := get_world_2d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		global_position = hit.position
		var body: Object = hit.collider
		if body.has_method("take_hit"):
			if player_caused and body is Node2D:
				Events.crime.emit(&"harm", body.global_position, 1.5, 100.0, true)
			body.take_hit(damage, direction * force, true)
		else:
			Events.impact.emit(global_position, direction, 0.25)
		queue_free()
		return
	global_position = next
	queue_redraw()

func _draw() -> void:
	draw_line(-direction * 24.0, direction * 3.0, Color("f5dca0"), 3, true)
	draw_circle(Vector2.ZERO, 2, Color.WHITE)

