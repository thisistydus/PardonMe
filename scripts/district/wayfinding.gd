class_name DistrictWayfinding
extends Node2D
var game: DistrictGame
var age: float = 0
func _process(delta: float) -> void:
	age += delta
	queue_redraw()
func _draw() -> void:
	var destination := game.mission.destination()
	if destination == Vector2.INF:
		return
	draw_arc(destination, 68 + sin(age * 4) * 4, 0, TAU, 36, Color("e6bb63"), 3, true)
	draw_string(ThemeDB.fallback_font, destination + Vector2(-55, -84), "BOOST TARGET" if game.mission.state == &"steal" or game.player.vehicle != game.mission.target else "DELIVER HERE", HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("f5d690"))
