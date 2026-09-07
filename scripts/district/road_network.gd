class_name DistrictRoadNetwork
extends RefCounted
var graph := AStar2D.new()
func _init() -> void:
	for row: int in 3:
		for col: int in 3:
			var id := row * 3 + col
			graph.add_point(id, Vector2(700 + col * 1700, 600 + row * 1200))
	for row: int in 3:
		for col: int in 3:
			var id := row * 3 + col
			if col < 2: graph.connect_points(id, id + 1)
			if row < 2: graph.connect_points(id, id + 3)
func project(point: Vector2) -> Vector2:
	var best := Vector2.INF
	var distance: float = INF
	for row: int in 3:
		var candidate := Vector2(clampf(point.x, 250, 4550), 600 + row * 1200)
		if candidate.distance_squared_to(point) < distance:
			best = candidate
			distance = candidate.distance_squared_to(point)
	for col: int in 3:
		var candidate := Vector2(700 + col * 1700, clampf(point.y, 250, 3350))
		if candidate.distance_squared_to(point) < distance:
			best = candidate
			distance = candidate.distance_squared_to(point)
	return best
func route(from: Vector2, to: Vector2) -> PackedVector2Array:
	var a := project(from)
	var b := project(to)
	var result := PackedVector2Array()
	if from.distance_to(a) > 60: result.append(a)
	if is_equal_approx(a.x, b.x) or is_equal_approx(a.y, b.y):
		result.append(b)
		return result
	var start := graph.get_closest_point(a)
	var finish := graph.get_closest_point(b)
	result.append_array(graph.get_point_path(start, finish))
	result.append(b)
	return result
