class_name DistrictWayfinding
extends Node2D
## World-space objective presentation for whichever job is active.
var game: DistrictGame
var age: float = 0

func _ready() -> void:
	z_index = 9

func _process(delta: float) -> void:
	age += delta
	queue_redraw()

func _draw() -> void:
	var gold := Color("e6bb63")
	for marker: Dictionary in game.board.markers():
		var point: Vector2 = marker.p
		var radius: float = marker.radius
		match marker.kind:
			&"escape":
				# Large "get clear" boundary: dashed so it never reads as a wall.
				for i: int in 48:
					var a := TAU * i / 48.0 + age * 0.05
					draw_arc(point, radius, a, a + TAU / 96.0, 3, Color(0.9, 0.73, 0.39, 0.55), 4)
			&"hold":
				draw_arc(point, radius, 0, TAU, 40, Color(0.9, 0.73, 0.39, 0.35), 3)
				draw_arc(point, radius, -PI / 2, -PI / 2 + TAU * float(marker.progress), 40, gold, 7)
			&"destroy":
				var r := radius + sin(age * 5) * 4
				draw_arc(point, r, 0, TAU, 32, Color("e0664e"), 3)
				for angle: float in [0.0, PI / 2, PI, PI * 1.5]:
					var direction := Vector2.RIGHT.rotated(angle)
					draw_line(point + direction * (r - 14), point + direction * (r + 12), Color("e0664e"), 4)
			_:
				draw_arc(point, radius + sin(age * 4) * 4, 0, TAU, 36, gold, 3, true)
		var label: String = marker.label
		draw_string(ThemeDB.fallback_font, point + Vector2(-70, -minf(radius, 90.0) - 18), label, HORIZONTAL_ALIGNMENT_CENTER, 140, 17, Color("f5d690"))
	# Carried robbery bag rides on the player so the escape phase stays readable.
	if game.rob.carrying and game.player.alive:
		var at := game.player.global_position + Vector2(0, -38)
		draw_rect(Rect2(at - Vector2(9, 6), Vector2(18, 13)), Color("2c3a2c"))
		draw_string(ThemeDB.fallback_font, at + Vector2(-4, 6), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("e6c96c"))
