class_name DistrictRecovery
extends Node
var game: DistrictGame
func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("recover_vehicle") or event.is_echo() or get_tree().paused:
		return
	var car: ToyCompact = game.player.vehicle
	if car == null:
		for candidate: ToyCompact in game.cars:
			if candidate.global_position.distance_to(game.player.global_position) < 110:
				car = candidate
				break
	if car == null:
		Events.message_requested.emit("RECOVERY / Stand beside a stopped vehicle.")
		return
	recover(car)
func recover(car: ToyCompact) -> bool:
	if car.unavailable or car.ai_controlled or game.heat.level > 0 or absf(car.speed) > 30 or car.failure_timer >= 0 or car.disabled:
		Events.message_requested.emit("RECOVERY / Stop first. Unavailable during Heat or explosion warning.")
		return false
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = car.footprint
	query.collision_mask = 1 | 8 | 16
	query.exclude = [car.get_rid()]
	for radius: float in [90.0, 150.0, 220.0, 300.0]:
		for i: int in 16:
			var point := car.global_position + Vector2.RIGHT.rotated(TAU * i / 16) * radius
			var on_road: bool = false
			for road: Rect2 in game.layout.roads:
				if minf(road.size.x, road.size.y) >= 140 and road.grow(-48).has_point(point):
					on_road = true
			query.transform = Transform2D(0, point)
			if on_road and car.get_world_2d().direct_space_state.intersect_shape(query).is_empty():
				car.global_position = point
				car.rotation = 0
				car.speed = 0
				car.velocity = Vector2.ZERO
				Events.message_requested.emit("VEHICLE RECOVERED / Damage and ammunition unchanged.")
				return true
	Events.message_requested.emit("NO CLEAR ROAD NEARBY / Try another vehicle or R to restart.")
	return false
