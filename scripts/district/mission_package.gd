class_name MissionPackage
extends Node2D
## A marked mission object lying in the world. Blasts destroy it; bullets and melee ignore it.
signal destroyed
var label: String = "CASH BAG"
var burned: bool = false
var age: float = 0.0

func _ready() -> void:
	add_to_group("damageable")
	z_index = 6

func take_hit(_amount: int, _push: Vector2, _bullet: bool = false) -> void:
	pass

func receive_blast(_amount: int, _push: Vector2, _caused: bool, _token: int) -> void:
	if burned:
		return
	burned = true
	remove_from_group("damageable")
	Events.impact.emit(global_position, Vector2.UP, 0.5)
	destroyed.emit()
	queue_redraw()

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func _draw() -> void:
	if burned:
		draw_circle(Vector2.ZERO, 14, Color("211e17"))
		draw_arc(Vector2.ZERO, 11, 0.4, 5.2, 10, Color("6a5a3d"), 3)
		return
	var bob := sin(age * 5.0) * 2.0
	draw_circle(Vector2(3, 6), 15, Color(0, 0, 0, 0.35))
	draw_set_transform(Vector2(0, bob))
	draw_rect(Rect2(-13, -9, 26, 20), Color("2c3a2c"))
	draw_rect(Rect2(-13, -9, 26, 20), Color("16140f"), false, 2)
	draw_arc(Vector2(0, -9), 7, PI, TAU, 10, Color("16140f"), 3)
	draw_string(ThemeDB.fallback_font, Vector2(-6, 7), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("e6c96c"))
	draw_set_transform(Vector2.ZERO)
	draw_arc(Vector2.ZERO, 24 + sin(age * 4.0) * 3, 0, TAU, 24, Color("e6bb63"), 2)
	draw_string(ThemeDB.fallback_font, Vector2(-34, -30), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("f5d690"))
