class_name DistrictMinimap
extends Control
var game: DistrictGame
var enlarged: bool = false
var markers: Array[DistrictMarker] = []
var refresh: float = 0.0
var view: Rect2
var map_rect: Rect2
func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("district_map") and not event.is_echo():
		enlarged = not enlarged
func _process(delta: float) -> void:
	position = Vector2(634, 234) if enlarged else Vector2(1020, 390)
	size = Vector2(630, 380) if enlarged else Vector2(244, 224)
	map_rect = Rect2(8, 29, size.x - 16, size.y - 37)
	var extent := DistrictLayout.SIZE if enlarged else Vector2(2100, 1750)
	var fit := minf(map_rect.size.x / extent.x, map_rect.size.y / extent.y)
	var fitted := extent * fit
	map_rect.position += (map_rect.size - fitted) / 2
	map_rect.size = fitted
	view = Rect2(Vector2.ZERO, extent) if enlarged else Rect2(game.player.global_position - extent / 2, extent)
	refresh -= delta
	if refresh <= 0:
		refresh = 0.5
		markers.clear()
		for node: Node in get_tree().get_nodes_in_group("map_markers"):
			markers.append(node as DistrictMarker)
	queue_redraw()
func map_point(point: Vector2) -> Vector2:
	return map_rect.position + (point - view.position) / view.size * map_rect.size
func map_box(rect: Rect2, color: Color) -> void:
	var overlap := rect.intersection(view)
	if overlap.has_area():
		draw_rect(Rect2(map_point(overlap.position), overlap.size / view.size * map_rect.size), color)
func _draw() -> void:
	if game == null or view.size.x == 0:
		return
	draw_rect(Rect2(Vector2.ZERO, size), Color("141e1c"))
	draw_rect(Rect2(Vector2.ZERO, size), Color("b19b65"), false, 1)
	draw_string(ThemeDB.fallback_font, Vector2(10, 19), ("N ↑ / H%d  R%.0f   [M]" % [game.heat.level, game.heat.search_radius] if game.heat.level > 0 else "N ↑ / DISTRICT   [M] MAP"), HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("e8dabc"))
	for road: Rect2 in game.layout.roads:
		map_box(road, Color("797b63"))
	for rect: Rect2 in game.layout.solids:
		map_box(rect, Color("39433b"))
	if game.heat.level > 0 and game.heat.searching:
		var circle := PackedVector2Array()
		for i: int in 64:
			circle.append(game.heat.search_position + Vector2.RIGHT.rotated(TAU * i / 64) * game.heat.search_radius)
		var bounds := PackedVector2Array([view.position, Vector2(view.end.x, view.position.y), view.end, Vector2(view.position.x, view.end.y)])
		for polygon: PackedVector2Array in Geometry2D.intersect_polygons(circle, bounds):
			var mapped := PackedVector2Array()
			for point: Vector2 in polygon: mapped.append(map_point(point))
			draw_colored_polygon(mapped, Color(0.75, 0.18, 0.1, 0.16))
	for marker: DistrictMarker in markers:
		if not is_instance_valid(marker) or not marker.active or not view.has_point(marker.point()):
			continue
		var point := map_point(marker.point())
		if marker.kind == &"phone":
			draw_circle(point, 3, Color("efd598"))
		elif marker.kind == &"garage":
			draw_rect(Rect2(point - Vector2(4, 4), Vector2(8, 8)), Color("ceae53"), false, 2)
		elif marker.kind == &"police" and marker.get_parent().map_visible():
			draw_circle(point, 3, Color("d46b60"))
	for brain: PoliceCruiserBrain in game.response.cruisers:
		if is_instance_valid(brain) and brain.map_visible() and view.has_point(brain.car.global_position):
			var point := map_point(brain.car.global_position)
			draw_rect(Rect2(point - Vector2(5, 3), Vector2(10, 6)), Color("d37057"))
	if game.response.roadblock_visible() and view.has_point(game.response.anchor):
		var point := map_point(game.response.anchor)
		draw_line(point - Vector2(6, 6), point + Vector2(6, 6), Color("ffac6b"), 3)
		draw_line(point - Vector2(6, -6), point + Vector2(6, -6), Color("ffac6b"), 3)
	if game.heat.level > 0 and game.heat.searching:
		var previous := Vector2.INF
		for i: int in 65:
			var world := game.heat.search_position + Vector2.RIGHT.rotated(TAU * i / 64) * game.heat.search_radius
			var mapped := map_point(world)
			if previous != Vector2.INF and map_rect.has_point(previous) and map_rect.has_point(mapped):
				draw_line(previous, mapped, Color("d37057"), 2)
			previous = mapped
	var objective := game.mission.destination()
	if objective != Vector2.INF:
		var mapped := map_point(objective).clamp(map_rect.position + Vector2(7, 7), map_rect.end - Vector2(7, 7))
		draw_circle(mapped, 7, Color("eec76b"), false, 2)
		draw_line(mapped - Vector2(9, 0), mapped + Vector2(9, 0), Color("eec76b"), 1)
	var facing := game.player.vehicle.rotation if game.player.vehicle else game.player.aim_direction.angle()
	var center := map_point(game.player.global_position)
	var arrow := PackedVector2Array()
	for offset: Vector2 in [Vector2(9, 0), Vector2(-6, -5), Vector2(-3, 0), Vector2(-6, 5)]:
		arrow.append(center + offset.rotated(facing))
	draw_colored_polygon(arrow, Color("ffffff"))
	if game.player.vehicle:
		draw_circle(center, 11, Color("dfc284"), false, 1)
