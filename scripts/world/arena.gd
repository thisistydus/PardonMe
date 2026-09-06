class_name ToyArena
extends Node2D

var blocks: Array[Rect2] = [Rect2(50, 50, 1500, 22), Rect2(50, 1128, 1500, 22), Rect2(50, 50, 22, 1100), Rect2(1528, 50, 22, 1100), Rect2(500, 210, 240, 85), Rect2(780, 570, 230, 70), Rect2(310, 740, 95, 200)]

func _ready() -> void:
	for rect: Rect2 in blocks:
		var body := StaticBody2D.new()
		body.position = rect.get_center()
		var collision := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = rect.size
		collision.shape = shape
		body.add_child(collision)
		add_child(body)

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1600, 1200), Color("292e2c"))
	draw_rect(Rect2(75, 340, 1450, 205), Color("1d2222"))
	draw_rect(Rect2(1060, 75, 210, 1050), Color("1d2222"))
	for x: int in range(110, 1500, 100):
		draw_line(Vector2(x, 442), Vector2(x + 44, 442), Color("ad9559"), 3)
	for y: int in range(90, 1100, 100):
		draw_line(Vector2(1165, y), Vector2(1165, y + 44), Color("ad9559"), 3)
	for x: int in range(75, 1520, 80):
		for y: int in range(75, 1130, 80):
			draw_circle(Vector2(x, y), 1, Color("3c403a"))
	for rect: Rect2 in blocks:
		draw_rect(Rect2(rect.position + Vector2(6, 7), rect.size), Color("131817"))
		draw_rect(rect, Color("5a6055"))
		draw_rect(rect.grow(-5), Color("454d45"))
		draw_line(rect.position, rect.position + Vector2(rect.size.x, 0), Color("aaa17d"), 3)
	label_at(Vector2(120, 130), "MUNICIPAL MOTOR & IMPACT TESTING", 25)
	label_at(Vector2(120, 165), "FORM A-01 / TEMPORARY PERMISSION TO MAKE A MESS", 14)
	label_at(Vector2(120, 610), "01  /  EQUIPMENT", 21)
	label_at(Vector2(790, 170), "02  /  IMPACT PRACTICE", 21)
	label_at(Vector2(1050, 800), "03 / LIVE FIRE", 20)
	label_at(Vector2(110, 1090), "SAME YARD. DIFFERENT MISTAKES.", 18)

func label_at(at: Vector2, text: String, font_size: int) -> void:
	draw_string(ThemeDB.fallback_font, at, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color("c3b58f"))

