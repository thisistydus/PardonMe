class_name DistrictPhone
extends Node2D
## A street payphone. MissionBoard assigns one offer; it rings only while that job can start.
var available: bool = true
var offer: DistrictMission
var pulse: float = 0.0
var marker: DistrictMarker

func _ready() -> void:
	add_to_group("interactables")
	z_index = 3
	marker = DistrictMarker.new()
	marker.kind = &"phone"
	add_child(marker)

func set_available(value: bool) -> void:
	available = value
	marker.active = value

func interact(_player: ToyPlayer) -> bool:
	if not available:
		return false
	Events.phone_answered.emit(self)
	return true

func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()

func _draw() -> void:
	# Overhead booth: hood, cream housing, dark handset cradle, coin slot and a short post shadow.
	draw_rect(Rect2(-13, -12, 30, 30), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(-16, -18, 32, 34), Color("3b4a47"))
	draw_rect(Rect2(-16, -18, 32, 34), Color("141a18"), false, 2)
	draw_rect(Rect2(-12, -14, 24, 26), Color("dfcd9f"))
	var shake := sin(pulse * 40.0) * 1.5 if available and fmod(pulse, 1.2) < 0.5 else 0.0
	draw_rect(Rect2(-9 + shake, -11, 7, 20), Color("1c2321"))
	draw_circle(Vector2(-5.5 + shake, -11), 4, Color("1c2321"))
	draw_circle(Vector2(-5.5 + shake, 9), 4, Color("1c2321"))
	draw_rect(Rect2(3, -9, 6, 3), Color("8d7a4c"))
	draw_rect(Rect2(3, -2, 6, 8), Color("b8a476"))
	if available:
		for ring: int in 2:
			var radius := 24.0 + fmod(pulse * 26.0 + ring * 13.0, 26.0)
			draw_arc(Vector2.ZERO, radius, 0, TAU, 28, Color(0.9, 0.74, 0.39, 1.0 - (radius - 24.0) / 26.0), 2)
		var label := "E / " + (offer.definition.kind_label if offer != null else "ANSWER")
		draw_string(ThemeDB.fallback_font, Vector2(-70, -38), label, HORIZONTAL_ALIGNMENT_CENTER, 140, 15, Color("f1dfb3"))
