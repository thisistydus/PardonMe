class_name WeaponPickup
extends Node2D

@export var data: WeaponData
var ammo: int = -1

func _ready() -> void:
	add_to_group("pickups")
	if ammo < 0:
		ammo = data.ammunition

func _draw() -> void:
	draw_circle(Vector2.ZERO, 24, Color("1b201e"))
	draw_arc(Vector2.ZERO, 25, 0, TAU, 32, Color("bda263"), 2)
	if data.firearm:
		draw_rect(Rect2(-12, -6, 27, 8), Color("dad2b9"))
		draw_rect(Rect2(-9, 0, 8, 11), Color("dad2b9"))
	else:
		draw_line(Vector2(-13, 12), Vector2(14, -13), Color("d4b67c"), 7, true)
	draw_string(ThemeDB.fallback_font, Vector2(-30, 44), "E  " + ("PISTOL" if data.firearm else "BAT"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("e4d5ae"))

