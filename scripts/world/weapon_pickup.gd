class_name WeaponPickup
extends Node2D

@export var data: WeaponData
var ammo: int = -1
var age: float = 0.0

func _ready() -> void:
	add_to_group("pickups")
	if ammo < 0:
		ammo = data.ammunition

func _draw() -> void:
	draw_circle(Vector2.ZERO, 24, Color("1b201e"))
	draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color("bda263"), 2)
	match data.id:
		&"shotgun":
			draw_line(Vector2(-16, 9), Vector2(16, -9), Color("9d9a8c"), 6, true)
			draw_line(Vector2(-16, 9), Vector2(-7, 4), Color("6b4a2e"), 9, true)
		&"knife":
			draw_line(Vector2(-10, 8), Vector2(-3, 3), Color("5a4630"), 6, true)
			draw_line(Vector2(-3, 3), Vector2(12, -8), Color("e6e9e4"), 4, true)
		_:
			if data.firearm:
				draw_rect(Rect2(-12, -6, 27, 8), Color("dad2b9"))
				draw_rect(Rect2(-9, 0, 8, 11), Color("dad2b9"))
			else:
				draw_line(Vector2(-13, 12), Vector2(14, -13), Color("d4b67c"), 7, true)
	draw_string(ThemeDB.fallback_font, Vector2(-45, 42), data.title + (" %d" % ammo if data.firearm else ""), HORIZONTAL_ALIGNMENT_CENTER, 90, 12, Color("e4d5ae"))


func _process(delta: float) -> void:
	age += delta
