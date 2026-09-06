extends Node2D
## Composition root only; simulation and presentation live in separate components.
const CONFIG: RunConfig = preload("res://data/run_config.tres")
@onready var player: ToyPlayer = $Player
var car: ToyCompact
var run: ToyRunManager
var feedback: ToyFeedback
var hud: ToyHUD
var radio: ToyRadioManager

func _ready() -> void:
	player.position = CONFIG.player_start
	run = ToyRunManager.new()
	run.name = "RunManager"
	run.seed_value = CONFIG.seed_value
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--seed="):
			run.seed_value = int(arg.trim_prefix("--seed="))
	add_child(run)
	feedback = ToyFeedback.new()
	feedback.name = "Feedback"
	feedback.camera = $Player/Camera2D
	add_child(feedback)
	car = ToyCompact.new()
	car.name = "Compact"
	car.position = CONFIG.compact_start
	add_child(car)
	radio = ToyRadioManager.new()
	radio.name = "RadioManager"
	add_child(radio)
	var rng := RandomNumberGenerator.new()
	rng.seed = run.seed_value
	for at: Vector2 in [Vector2(840, 245), Vector2(915, 280), Vector2(960, 230), Vector2(900, 440)]:
		var target := PracticeTarget.new()
		target.position = at + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6))
		add_child(target)
	var shooter := PracticeTarget.new()
	shooter.position = Vector2(1360, 930)
	shooter.armed = true
	add_child(shooter)
	for i: int in 2:
		var pickup := WeaponPickup.new()
		pickup.data = load("res://data/weapons/bat.tres" if i == 0 else "res://data/weapons/pistol.tres") as WeaponData
		pickup.position = Vector2(270 + i * 90, 660)
		add_child(pickup)
	hud = ToyHUD.new()
	hud.name = "HUD"
	hud.player = player
	hud.car = car
	hud.run = run
	hud.feedback = feedback
	hud.radio = radio
	add_child(hud)
