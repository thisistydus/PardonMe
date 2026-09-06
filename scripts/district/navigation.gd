class_name DistrictNavigation
extends Node
## Static A* occupancy generated once; actor paths refreshed at bounded intervals.
var grid := AStarGrid2D.new()
var layout: DistrictLayout
var static_cells: Dictionary[Vector2i, bool] = {}
var car_cells: Array[Vector2i] = []
var refresh_timer: float = 0
const CELL: float = 40.0
func _ready() -> void:
	grid.region = Rect2i(0, 0, 120, 90)
	grid.cell_size = Vector2(CELL, CELL)
	grid.offset = Vector2(20, 20)
	grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	grid.update()
	for x: int in 120:
		for y: int in 90:
			var point := grid.get_point_position(Vector2i(x, y))
			for rect: Rect2 in layout.solids:
				if rect.grow(22).has_point(point):
					grid.set_point_solid(Vector2i(x, y))
					static_cells[Vector2i(x, y)] = true
					break
func cell(at: Vector2) -> Vector2i:
	return Vector2i(clampi(int(at.x / CELL), 0, 119), clampi(int(at.y / CELL), 0, 89))
func nearest(at: Vector2) -> Vector2i:
	var center := cell(at)
	if not grid.is_point_solid(center):
		return center
	for radius: int in range(1, 15):
		for x: int in range(-radius, radius + 1):
			for y: int in range(-radius, radius + 1):
				var candidate := center + Vector2i(x, y)
				if grid.is_in_boundsv(candidate) and not grid.is_point_solid(candidate):
					return candidate
	return Vector2i(17, 15)
func route(from: Vector2, to: Vector2) -> PackedVector2Array:
	return grid.get_point_path(nearest(from), nearest(to))
func clear_ray(owner: Node2D, from: Vector2, to: Vector2, excluded: Array[RID] = []) -> bool:
	return owner.get_world_2d().direct_space_state.intersect_ray(PhysicsRayQueryParameters2D.create(from, to, 1 | 8, excluded)).is_empty()

func _process(delta: float) -> void:
	refresh_timer -= delta
	if refresh_timer > 0:
		return
	refresh_timer = 1.0
	for occupied: Vector2i in car_cells:
		if not static_cells.has(occupied):
			grid.set_point_solid(occupied, false)
	car_cells.clear()
	for car: ToyCompact in get_tree().get_nodes_in_group("vehicles"):
		if absf(car.speed) > 20 or car.driver != null:
			continue
		var bounds := Rect2(car.global_position - Vector2(70, 70), Vector2(140, 140))
		for x: int in range(cell(bounds.position).x, cell(bounds.end).x + 1):
			for y: int in range(cell(bounds.position).y, cell(bounds.end).y + 1):
				var id := Vector2i(x, y)
				var local := car.to_local(grid.get_point_position(id))
				if absf(local.x) < 68 and absf(local.y) < 48:
					grid.set_point_solid(id)
					car_cells.append(id)
