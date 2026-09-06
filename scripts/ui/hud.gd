class_name ToyHUD
extends CanvasLayer

var player: ToyPlayer
var car: ToyCompact
var run: ToyRunManager
var feedback: ToyFeedback
var radio: ToyRadioManager
var radio_card: Panel
var radio_logo: TextureRect
var station_name: Label
var track_name: Label
var status: Label
var equipment: Label
var context: Label
var message: Label
var debug: Label
var panel: Panel
var result: Label
var resume: Button
var restart_button: Button
var message_time: float = 8.0

func text_label(at: Vector2, size: Vector2, font_size: int, parent: Node = self) -> Label:
	var label := Label.new()
	label.position = at
	label.size = size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color("e8dabc"))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func slab(at: Vector2, size: Vector2, color: Color) -> Panel:
	var node := Panel.new()
	node.position = at
	node.size = size
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color("a48b55")
	style.set_border_width_all(1)
	node.add_theme_stylebox_override("panel", style)
	node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(node)
	return node

func button(title: String, at: Vector2, callback: Callable) -> Button:
	var node := Button.new()
	node.text = title
	node.position = at
	node.size = Vector2(300, 42)
	node.add_theme_font_size_override("font_size", 20)
	panel.add_child(node)
	node.pressed.connect(callback)
	return node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 30
	slab(Vector2(16, 14), Vector2(1248, 76), Color("151b19"))
	var brand := text_label(Vector2(34, 24), Vector2(300, 30), 25)
	brand.text = "PARDON ME"
	var subtitle := text_label(Vector2(34, 56), Vector2(350, 22), 13)
	subtitle.text = "MUNICIPAL TEST YARD  /  GOAL A"
	status = text_label(Vector2(415, 27), Vector2(520, 50), 19)
	var help := text_label(Vector2(1000, 29), Vector2(260, 50), 14)
	help.text = "R restart   ·   Esc pause\nF3 debug   ·   F4 camera shake"
	slab(Vector2(16, 631), Vector2(1248, 73), Color("151b19"))
	equipment = text_label(Vector2(34, 640), Vector2(420, 54), 19)
	context = text_label(Vector2(466, 640), Vector2(780, 54), 16)
	message = text_label(Vector2(170, 575), Vector2(940, 44), 17)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_color_override("font_shadow_color", Color.BLACK)
	message.add_theme_constant_override("shadow_offset_x", 2)
	message.add_theme_constant_override("shadow_offset_y", 2)
	message.text = "E picks up the nearby bat. Targets are north-east; the compact is on the road."
	debug = text_label(Vector2(28, 107), Vector2(620, 100), 15)
	debug.add_theme_color_override("font_shadow_color", Color.BLACK)
	debug.add_theme_constant_override("shadow_offset_x", 2)
	debug.add_theme_constant_override("shadow_offset_y", 2)
	Events.message_requested.connect(show_message)
	build_radio_card()
	panel = slab(Vector2(365, 175), Vector2(550, 390), Color("171c19"))
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	result = text_label(Vector2(36, 24), Vector2(480, 172), 23, panel)
	resume = button("CONTINUE TEST", Vector2(125, 202), func() -> void: get_tree().paused = false)
	restart_button = button("R  /  RESTART TEST", Vector2(125, 258), run.restart)
	button("QUIT", Vector2(125, 314), run.quit_run)
	panel.hide()

func build_radio_card() -> void:
	radio_card = slab(Vector2(846, 104), Vector2(418, 112), Color("151b19"))
	radio_logo = TextureRect.new()
	radio_logo.position = Vector2(8, 8)
	radio_logo.size = Vector2(138, 92)
	radio_logo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	radio_logo.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	radio_logo.mouse_filter = Control.MOUSE_FILTER_IGNORE
	radio_card.add_child(radio_logo)
	station_name = text_label(Vector2(158, 11), Vector2(250, 25), 18, radio_card)
	track_name = text_label(Vector2(158, 38), Vector2(248, 43), 15, radio_card)
	track_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	var keys := text_label(Vector2(158, 87), Vector2(244, 18), 12, radio_card)
	keys.text = "1–4 STATIONS   /   5 OFF   /   C CYCLE"
	radio.availability_changed.connect(func(in_vehicle: bool) -> void: radio_card.visible = in_vehicle)
	radio.station_changed.connect(show_station)
	radio_card.hide()

func show_station(station: RadioStationData) -> void:
	radio_logo.visible = station != null
	radio_logo.texture = station.logo if station != null else null
	station_name.text = station.title if station != null else "RADIO OFF"
	track_name.text = station.track_title if station != null else "Just you and the engine."

func show_message(text: String) -> void:
	message.text = text
	message_time = 4.5

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_shake") and not event.is_echo():
		feedback.shake_enabled = not feedback.shake_enabled
		show_message("CAMERA SHAKE " + ("ON" if feedback.shake_enabled else "OFF"))

func _process(delta: float) -> void:
	var health := "WOUNDED / 1 STRIKE LEFT" if player.wounded else "UNHURT / 2 STRIKES"
	status.text = "%s\nTEST TIME  %02d:%02d     TARGETS DOWN  %d" % [health, int(run.elapsed) / 60, int(run.elapsed) % 60, run.downs]
	equipment.text = "%s\n%s" % [player.weapons.data.title, "%d / 8 ROUNDS · RMB throw · Q drop" % player.weapons.ammo if player.weapons.data.firearm else "LMB use · RMB throw · Q drop"]
	if player.vehicle:
		context.text = "COMPACT  %s  %d%%  |  SPEED %d\nW gas · S brake/reverse · A D steer · Space brake · E exit" % [car.damage_state(), int(car.health), int(absf(car.speed))]
	else:
		context.text = "WASD move  ·  Mouse aim  ·  LMB use  ·  E pickup / enter\n" + interaction_hint()
	debug.visible = run.debug_visible
	debug.text = "STATE %s | HEAT — NOT IMPLEMENTED (GOAL B)\nMISSION — NOT IMPLEMENTED (GOAL C) | SEED %d\nCAR %s %.1f%% | FPS %d | POSITION %s" % ["DEAD" if not player.alive else ("DRIVING" if player.vehicle else ("WOUNDED" if player.wounded else "ON FOOT")), run.seed_value, car.damage_state(), car.health, Engine.get_frames_per_second(), str(player.global_position.round())]
	if not get_tree().paused:
		message_time -= delta
	message.visible = message_time > 0
	var was_visible := panel.visible
	panel.visible = get_tree().paused
	if panel.visible:
		resume.visible = not run.ended
		result.text = "%s\n\nTargets down: %d  /  Time: %02d:%02d\nSeed: %d\nGoal A test — scoring comes later." % ["PERMISSION EXPIRED" if run.ended else "TEST SUSPENDED", run.downs, int(run.elapsed) / 60, int(run.elapsed) % 60, run.seed_value]
		if not was_visible:
			if run.ended:
				restart_button.grab_focus()
			else:
				resume.grab_focus()

func interaction_hint() -> String:
	if player.global_position.distance_to(car.nearest_door(player.global_position)) < 65 and not car.disabled:
		return "E  /  ENTER COMPACT"
	for node: Node in get_tree().get_nodes_in_group("pickups"):
		var pickup := node as WeaponPickup
		if player.global_position.distance_to(pickup.global_position) < 65:
			return "E  /  PICK UP " + pickup.data.title
	return "Targets respawn after 5s. Live-fire target waits in the south-east."
