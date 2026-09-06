class_name DistrictPhone
extends Node2D
var available: bool = true
var pulse: float = 0.0
func _ready() -> void:
	add_to_group("interactables")
	var marker := DistrictMarker.new()
	marker.kind = &"phone"
	add_child(marker)
func interact(_player: ToyPlayer) -> bool:
	if not available:
		return false
	Events.phone_answered.emit(self)
	return true
func _process(delta: float) -> void:
	pulse += delta
	queue_redraw()
func _draw() -> void:
	draw_rect(Rect2(-12, -16, 24, 32), Color("dfcd9f"))
	draw_rect(Rect2(-7, -11, 14, 18), Color("24312f"))
	if available:
		draw_arc(Vector2.ZERO, 25 + sin(pulse * 4) * 3, 0, TAU, 24, Color("e4bc64"), 2)
		draw_string(ThemeDB.fallback_font, Vector2(-40, -32), "E / BOOST", HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("e6d7b4"))
