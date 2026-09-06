class_name DistrictLayout
extends Node2D
## Authored geometry shared by collision, navigation and the simplified street map.
const SIZE := Vector2(4800, 3600)
var roads: Array[Rect2] = []
var solids: Array[Rect2] = []
var gates: Array[Rect2] = [Rect2(1560, 880, 100, 12), Rect2(3060, 2580, 100, 12)]
var phones: Array[Vector2] = [Vector2(900, 760), Vector2(2690, 1550), Vector2(3820, 2760)]
var garage := Vector2(4400, 2600)
var storefront := Vector2(2800, 900)
var spawn_zones: Array[Vector2] = [Vector2(300, 600), Vector2(700, 320), Vector2(2400, 240), Vector2(4480, 600), Vector2(4500, 1800), Vector2(4100, 3280), Vector2(2400, 3320), Vector2(300, 3000)]
var labels: Array[Dictionary] = []

func _ready() -> void:
	for x: float in [700.0, 2400.0, 4100.0]:
		roads.append(Rect2(x - 130, 110, 260, 3380))
	for y: float in [600.0, 1800.0, 3000.0]:
		roads.append(Rect2(110, y - 130, 4580, 260))
	roads.append(Rect2(3280, 1930, 140, 940))
	# Two pedestrian passages bisect blocks; visible access gates stop cars only.
	roads.append(Rect2(1560, 780, 100, 890))
	roads.append(Rect2(3060, 1930, 100, 940))
	solids = [Rect2(0, 0, 4800, 100), Rect2(0, 3500, 4800, 100), Rect2(0, 100, 100, 3400), Rect2(4700, 100, 100, 3400),
		Rect2(1000, 920, 480, 320), Rect2(980, 1380, 500, 210), Rect2(1710, 860, 480, 650),
		Rect2(2650, 970, 1150, 580), Rect2(950, 2100, 580, 620), Rect2(1790, 2170, 380, 470),
		Rect2(2650, 2090, 330, 600), Rect2(3170, 2080, 70, 600), Rect2(3500, 2010, 350, 620),
		Rect2(200, 1000, 290, 480), Rect2(200, 2160, 280, 520), Rect2(4390, 900, 230, 650),
		Rect2(4310, 2090, 330, 320), Rect2(1060, 180, 1000, 220), Rect2(2710, 180, 1100, 220),
		Rect2(1000, 3220, 1140, 200), Rect2(2720, 3220, 1080, 200),
		Rect2(1100, 800, 130, 30), Rect2(2050, 1980, 90, 60)]
	for rect: Rect2 in solids:
		add_solid(rect, 1)
	for rect: Rect2 in gates:
		add_solid(rect, 16)
	labels = [{"p":Vector2(1000, 855), "t":"01 / MUNICIPAL TEST YARD"}, {"p":Vector2(2650, 850), "t":"02 / RECEIPT ROW"}, {"p":Vector2(1000, 2020), "t":"03 / CIVIC PLAZA"}, {"p":Vector2(3510, 1980), "t":"04 / WAREHOUSE CUT"}, {"p":Vector2(4310, 2530), "t":"DELIVERY GARAGE"}, {"p":Vector2(2600, 2930), "t":"SOUTHLINE AVENUE"}]

func add_solid(rect: Rect2, layer: int) -> void:
	var body := StaticBody2D.new()
	body.collision_layer = layer
	body.position = rect.get_center()
	var shape := RectangleShape2D.new()
	shape.size = rect.size
	var collider := CollisionShape2D.new()
	collider.shape = shape
	body.add_child(collider)
	add_child(body)

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("343c36"))
	for road: Rect2 in roads:
		draw_rect(road.grow(35), Color("626356"))
		draw_rect(road, Color("222a29"))
	for y: float in [600.0, 1800.0, 3000.0]:
		for x: int in range(140, 4650, 120):
			draw_line(Vector2(x, y), Vector2(x + 50, y), Color("ae965a"), 3)
	for x: float in [700.0, 2400.0, 4100.0]:
		for y: int in range(140, 3460, 120):
			draw_line(Vector2(x, y), Vector2(x, y + 50), Color("ae965a"), 3)
	var n: int = 0
	for rect: Rect2 in solids:
		draw_rect(Rect2(rect.position + Vector2(8, 10), rect.size), Color("151d1b"))
		draw_rect(rect, [Color("53584d"), Color("63574c"), Color("4d5c59")][n % 3])
		draw_rect(rect.grow(-9), Color("39433c"), false, 4)
		n += 1
	for gate: Rect2 in gates:
		draw_rect(gate, Color("bda367"))
		for x: int in range(0, 101, 20):
			draw_circle(gate.position + Vector2(x, 6), 6, Color("f2dfae"))
		draw_string(ThemeDB.fallback_font, gate.position + Vector2(-15, -12), "FOOT ACCESS", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("ddca99"))
	draw_rect(Rect2(garage - Vector2(90, 70), Vector2(180, 140)), Color("b89b5b"), false, 6)
	draw_rect(Rect2(storefront - Vector2(85, 40), Vector2(170, 80)), Color("9c584a"), false, 5)
	for i: int in 4:
		draw_rect(Rect2(2630 + i * 125, 750, 110, 125), Color("a6a28b"), false, 2)
	for entry: Dictionary in labels:
		draw_string(ThemeDB.fallback_font, entry.p, entry.t, HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("dac79c"))
