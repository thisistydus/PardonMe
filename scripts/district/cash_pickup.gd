class_name CashPickup
extends Node2D
## Dropped street cash. Collected by walking or driving over it; CashDirector owns lifetime.
var amount: int = 0
var age: float = 0.0
var lifetime: float = 90.0
var collected: bool = false

func _ready() -> void:
	add_to_group("cash_pickups")
	z_index = 4

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func _draw() -> void:
	var fading := lifetime - age < 10.0
	if fading and fmod(age, 0.5) < 0.18:
		return
	var bob := sin(age * 4.0) * 1.5
	draw_circle(Vector2(2, 5), 11, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, bob), -0.18)
	draw_rect(Rect2(-12, -7, 24, 14), Color("4f7a45"))
	draw_rect(Rect2(-10, -5, 24, 14), Color("78a86a"))
	draw_rect(Rect2(-10, -5, 24, 14), Color("1e2a1b"), false, 1.5)
	draw_string(ThemeDB.fallback_font, Vector2(-2, 6), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("1e2a1b"))
	draw_set_transform(Vector2.ZERO)
	draw_string(ThemeDB.fallback_font, Vector2(-14, -14), "$%d" % amount, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("cfe6a8"))
