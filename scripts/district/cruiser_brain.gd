class_name PoliceCruiserBrain
extends Node
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
var game: DistrictGame
var car: ToyCompact
var roads := DistrictRoadNetwork.new()
var state: StringName = &"responding"
var route := PackedVector2Array()
var index: int = 0
var timer: float = 0
var stuck: float = 0
var reverse_time: float = 0
var destination := Vector2.ZERO
var discovered: bool = false
var sight_timer: float = 0
func _ready() -> void:
	car.ai_controlled = true
	car.engine_voice.play()
func abandon() -> void:
	state = &"abandoned"
	car.ai_controlled = false
	car.ai_throttle = 0
	car.ai_steering = 0
	car.ai_brake = true
	car.engine_voice.stop()
func _physics_process(delta: float) -> void:
	if car.disabled:
		state = &"wrecked"
		car.ai_controlled = false
		return
	if car.driver != null or state == &"abandoned":
		car.ai_controlled = false
		return
	if car.failure_timer >= 0 or game.heat.level < BALANCE.vehicle_heat:
		abandon()
		return
	sight_timer -= delta
	if sight_timer <= 0:
		sight_timer = 0.3
		var exclude: Array[RID] = [car.get_rid()]
		if game.player.vehicle: exclude.append(game.player.vehicle.get_rid())
		if car.global_position.distance_to(game.player.global_position) < 650 and game.navigation.clear_ray(car, car.global_position, game.player.global_position, exclude):
			if game.heat.identity_known or (game.heat.report_age < 8 and game.player.global_position.distance_to(game.heat.search_position) < 160):
				game.heat.confirm_sighting(game.player.global_position)
	timer -= delta
	# The vehicle receives dispatch knowledge only; no hidden-player homing.
	if timer <= 0:
		timer = 2.3
		destination = roads.project(game.heat.search_position)
		if route.is_empty() or destination.distance_to(route[-1]) > 250:
			route = roads.route(car.global_position, destination)
			index = 0
		state = &"searching" if game.heat.searching else &"pursuing"
	while index < route.size() and car.global_position.distance_to(route[index]) < 90:
		index += 1
	if index >= route.size():
		car.ai_throttle = 0
		car.ai_brake = true
		return
	var offset := route[index] - car.global_position
	var error := wrapf(offset.angle() - car.rotation, -PI, PI)
	var desired_speed: float = 155 if absf(error) > 0.35 or offset.length() < 260 else 450
	car.ai_throttle = 1
	car.ai_steering = clampf(error * 2.5, -1, 1)
	car.ai_brake = car.speed > desired_speed
	stuck = stuck + delta if absf(car.speed) < 20 else maxf(0, stuck - delta * 0.4)
	if stuck > 3:
		reverse_time = 1.0
		stuck = 0
	if reverse_time > 0:
		reverse_time -= delta
		car.ai_throttle = -0.6
		car.ai_steering = -signf(error)
		car.ai_brake = false
		state = &"reversing"
	car.ai_state = String(state)
func map_visible() -> bool:
	var distance := car.global_position.distance_to(game.player.global_position)
	if distance < 650:
		discovered = true
	return distance < 1000 and (discovered or state == &"pursuing")
