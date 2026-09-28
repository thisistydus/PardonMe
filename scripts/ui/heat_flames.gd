class_name HeatFlames
extends Control
## Four flame icons for Heat 1–4. Count, fill and the adjacent word carry the state, not colour alone.
var level: int = 0
var searching: bool = false
var age: float = 0.0
const LIT: Array[Color] = [Color("e9c46a"), Color("f0a04b"), Color("e56b3c"), Color("d63a2f")]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	custom_minimum_size = Vector2(132, 34)
	size = custom_minimum_size

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func flame(center: Vector2, scale: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for p: Vector2 in [Vector2(0, -15), Vector2(4, -8), Vector2(9, -4), Vector2(10, 3), Vector2(7, 10), Vector2(0, 13), Vector2(-7, 10), Vector2(-10, 3), Vector2(-8, -5), Vector2(-3, -3), Vector2(-4, -10)]:
		points.append(center + p * scale)
	return points

func _draw() -> void:
	for i: int in 4:
		var center := Vector2(16 + i * 32, 17)
		var shape := flame(center, 1.0)
		if i < level:
			var flicker := 1.0 + (sin(age * 14.0 + i) * 0.06 if not searching else sin(age * 6.0) * 0.12)
			draw_colored_polygon(flame(center + Vector2(0, 1), flicker), LIT[i])
			draw_colored_polygon(flame(center + Vector2(0, 5), 0.45 * flicker), Color("fff0c2"))
		var outline := shape.duplicate()
		outline.append(shape[0])
		draw_polyline(outline, Color("e8dabc") if i < level else Color(0.55, 0.52, 0.45, 0.7), 1.5, true)
