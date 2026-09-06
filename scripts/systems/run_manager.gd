class_name ToyRunManager
extends Node

signal restarted
var quitting: bool = false
var elapsed: float = 0.0
var downs: int = 0
var ended: bool = false
var debug_visible: bool = false
var seed_value: int = 771104

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Events.player_died.connect(end_run)
	Events.target_downed.connect(func() -> void: downs += 1)

func _process(delta: float) -> void:
	if not ended and not get_tree().paused:
		elapsed += delta

func _unhandled_input(event: InputEvent) -> void:
	if quitting:
		return
	if event.is_action_pressed("restart") and not event.is_echo():
		restart()
	elif event.is_action_pressed("pause") and not event.is_echo() and not ended:
		get_tree().paused = not get_tree().paused
	elif event.is_action_pressed("debug_overlay") and not event.is_echo():
		debug_visible = not debug_visible

func end_run() -> void:
	ended = true
	get_tree().paused = true

func restart() -> void:
	if quitting:
		return
	get_tree().paused = false
	Engine.time_scale = 1.0
	restarted.emit()
	get_tree().reload_current_scene.call_deferred()

func prepare_shutdown() -> void:
	quitting = true
	get_tree().paused = true
	Events.shutdown_requested.emit()
	# Allow the audio mixer to release stopped stream playback references.
	await get_tree().create_timer(0.15, true, false, true).timeout

func quit_run() -> void:
	if quitting:
		return
	await prepare_shutdown()
	get_tree().quit()
