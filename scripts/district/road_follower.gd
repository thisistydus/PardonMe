class_name RoadFollower
extends RefCounted
## Feeds throttle/steer/brake into an existing car along the district road graph.
## Same steering approach as PoliceCruiserBrain; intended as the C2 traffic building block.
var roads := DistrictRoadNetwork.new()
var route := PackedVector2Array()
var index: int = 0
var stuck: float = 0.0
var reverse_time: float = 0.0
var cruise_speed: float = 420.0
var corner_speed: float = 150.0

func plan(from: Vector2, to: Vector2) -> void:
	route = roads.route(from, to)
	index = 0

func arrived() -> bool:
	return index >= route.size()

## Returns true once the final route point is reached.
func drive(car: ToyCompact, delta: float) -> bool:
	while index < route.size() and car.global_position.distance_to(route[index]) < 90:
		index += 1
	if index >= route.size():
		car.ai_throttle = 0
		car.ai_steering = 0
		car.ai_brake = true
		return true
	var offset := route[index] - car.global_position
	var error := wrapf(offset.angle() - car.rotation, -PI, PI)
	var desired := corner_speed if absf(error) > 0.35 or offset.length() < 260 else cruise_speed
	car.ai_throttle = 1
	car.ai_steering = clampf(error * 2.5, -1, 1)
	car.ai_brake = car.speed > desired
	stuck = stuck + delta if absf(car.speed) < 20 else maxf(0, stuck - delta * 0.4)
	if stuck > 3:
		reverse_time = 1.0
		stuck = 0
	if reverse_time > 0:
		reverse_time -= delta
		car.ai_throttle = -0.6
		car.ai_steering = -signf(error)
		car.ai_brake = false
	return false
