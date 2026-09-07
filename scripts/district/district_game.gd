class_name DistrictGame
extends Node2D
@onready var player: ToyPlayer = $Player
@onready var layout: DistrictLayout = $World
var car: ToyCompact
var cars: Array[ToyCompact] = []
var run: ToyRunManager
var feedback: ToyFeedback
var radio: ToyRadioManager
var hud: DistrictHUD
var minimap: DistrictMinimap
var mission: DistrictBoost
var score: DistrictScore
var heat: DistrictHeat
var explosion_tracker: ExplosionTracker
var response: PoliceResponse
var coordinator: PoliceCoordinator
var director: DistrictSpawnDirector
var recovery: DistrictRecovery
var citizens: Array[DistrictNPC] = []
var navigation: DistrictNavigation

func _ready() -> void:
	run = ToyRunManager.new()
	run.seed_value = (preload("res://data/run_config.tres") as RunConfig).seed_value
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			run.seed_value = int(arg.trim_prefix("--seed="))
	add_child(run)
	feedback = ToyFeedback.new()
	feedback.camera = $Player/Camera2D
	add_child(feedback)
	navigation = DistrictNavigation.new()
	navigation.layout = layout
	add_child(navigation)
	for at: Vector2 in [Vector2(1250, 740), Vector2(2680, 805), Vector2(2810, 805), Vector2(2940, 805), Vector2(720, 2250), Vector2(3990, 2500), Vector2(2190, 3110)]:
		var vehicle := ToyCompact.new()
		vehicle.position = at
		if cars.size() in [2, 5]:
			vehicle.data = preload("res://data/vehicles/sedan.tres")
		if cars.size() == 6:
			vehicle.data = preload("res://data/vehicles/patrol.tres")
		add_child(vehicle)
		cars.append(vehicle)
	car = cars[0]
	car.name = "Compact"
	explosion_tracker = ExplosionTracker.new()
	add_child(explosion_tracker)
	for point: Vector2 in [Vector2(1550, 2040), Vector2(1610, 2060), Vector2(1670, 2040), Vector2(1610, 2480), Vector2(3550, 3110), Vector2(3980, 2430)]:
		var barrel := ExplosiveBarrel.new()
		barrel.position = point
		add_child(barrel)
	radio = ToyRadioManager.new()
	add_child(radio)
	for i: int in 3:
		var target := PracticeTarget.new()
		target.position = Vector2(1280 + i * 75, 840)
		add_child(target)
	for i: int in 2:
		var pickup := WeaponPickup.new()
		pickup.data = load("res://data/weapons/bat.tres" if i == 0 else "res://data/weapons/pistol.tres")
		pickup.position = Vector2(980 + i * 75, 800)
		add_child(pickup)
	for point: Vector2 in layout.phones:
		var phone := DistrictPhone.new()
		phone.position = point
		add_child(phone)
	var garage_marker := Node2D.new()
	garage_marker.position = layout.garage
	add_child(garage_marker)
	var marker := DistrictMarker.new()
	marker.kind = &"garage"
	garage_marker.add_child(marker)
	for at: Vector2 in [Vector2(880, 830), Vector2(1550, 800), Vector2(2240, 1150), Vector2(2610, 860), Vector2(3000, 910), Vector2(3800, 860), Vector2(4300, 1700), Vector2(1000, 1950), Vector2(1550, 2060), Vector2(1640, 2400), Vector2(2240, 2650), Vector2(2650, 2800), Vector2(3090, 2750), Vector2(3890, 2750), Vector2(4400, 2780), Vector2(840, 2770)]:
		spawn_citizen(at, "civilian")
	citizens[4].seated_vehicle = cars[3]
	citizens[4].visible = false
	citizens[4].collision_layer = 0
	cars[3].occupied = true
	Events.vehicle_entered.connect(on_vehicle_entered)
	Events.vehicle_destroyed.connect(on_occupied_destroyed)
	spawn_citizen(Vector2(1800, 1990), "hostile")
	heat = DistrictHeat.new()
	heat.game = self
	add_child(heat)
	for at: Vector2 in [Vector2(2440, 1500), Vector2(3970, 2860)]:
		spawn_citizen(at, "police").heat = heat
	coordinator = PoliceCoordinator.new()
	coordinator.game = self
	add_child(coordinator)
	director = DistrictSpawnDirector.new()
	director.game = self
	add_child(director)
	response = PoliceResponse.new()
	response.game = self
	add_child(response)
	recovery = DistrictRecovery.new()
	recovery.game = self
	add_child(recovery)
	score = DistrictScore.new()
	add_child(score)
	mission = DistrictBoost.new()
	mission.game = self
	add_child(mission)
	var wayfinding := DistrictWayfinding.new()
	wayfinding.game = self
	add_child(wayfinding)
	hud = DistrictHUD.new()
	hud.game = self
	hud.player = player
	hud.car = car
	hud.run = run
	hud.feedback = feedback
	hud.radio = radio
	add_child(hud)
	minimap = DistrictMinimap.new()
	minimap.game = self
	hud.add_child(minimap)
	Events.message_requested.emit("FIRST DISTRICT / E at a ringing payphone. The test yard is behind you.")

func _process(delta: float) -> void:
	var camera := $Player/Camera2D as Camera2D
	var zoom_target := 0.82 if player.vehicle else 1.0
	camera.zoom = camera.zoom.lerp(Vector2.ONE * zoom_target, minf(1, delta * 2))
	if player.vehicle:
		hud.car = player.vehicle
	elif not is_instance_valid(hud.car):
		hud.car = car

func spawn_citizen(at: Vector2, role: String) -> DistrictNPC:
	var npc := DistrictNPC.new()
	npc.role = role
	npc.position = navigation.grid.get_point_position(navigation.nearest(at))
	npc.player = player
	npc.navigation = navigation
	npc.heat = heat
	add_child(npc)
	citizens.append(npc)
	return npc

func on_vehicle_entered(vehicle: Node2D) -> void:
	var taken := vehicle as ToyCompact
	for npc: DistrictNPC in citizens:
		if npc.seated_vehicle == taken:
			npc.seated_vehicle = null
			npc.global_position = taken.door_positions()[1]
			npc.visible = true
			npc.collision_layer = 4
			npc.danger = taken.global_position
			npc.change_state(&"alerted")
			taken.occupied = false
			Events.crime.emit(&"vehicle_theft", taken.global_position, 2.0, 180.0, true)
	if taken.data.police_vehicle:
		Events.crime.emit(&"police_theft", taken.global_position, 3.0, 650.0, true)

func on_occupied_destroyed(vehicle: Node2D) -> void:
	for npc: DistrictNPC in citizens:
		if npc.seated_vehicle == vehicle:
			npc.seated_vehicle = null
			npc.global_position = vehicle.global_position
			npc.visible = true
			npc.collision_layer = 4
	(vehicle as ToyCompact).occupied = false
