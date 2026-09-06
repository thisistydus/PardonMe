extends "res://tests/acceptance.gd"

func press_number(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(3)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await frames(3)

func capture(name: String) -> void:
	if not "--visual" in OS.get_cmdline_user_args():
		return
	await RenderingServer.frame_post_draw
	var picture := get_viewport().get_texture().get_image()
	verify(picture.save_png("res://tests/" + name + ".png") == OK, "Saved visual check " + name)

func start() -> void:
	game = load("res://scenes/game.tscn").instantiate() as Node2D
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	var radio: ToyRadioManager = game.radio
	for texture: Texture2D in [SpriteArt.PLAYER, SpriteArt.COMPACT, SpriteArt.TARGET]:
		verify(texture.get_width() > 0 and texture.get_image().detect_alpha() != Image.ALPHA_NONE, "Generated sprite loads with actual alpha")
	verify(ToyRadioManager.LIBRARY.stations.size() == 4, "Four supplied stations are resource-driven")
	for i: int in 4:
		var station := ToyRadioManager.LIBRARY.stations[i]
		verify(station.audio.get_length() > 200 and station.logo != null, "Station %d has imported song and supplied logo" % (i + 1))
		verify(radio.offsets[i] >= 1 and radio.offsets[i] < station.audio.get_length(), "Station %d has random nonzero start offset" % (i + 1))
	verify(not radio.audio.playing and not game.hud.radio_card.visible, "On foot: no radio sound or logo")
	await press_number(KEY_3)
	verify(radio.selected == ToyRadioManager.OFF and not radio.audio.playing, "Station keys are ignored on foot")
	player.position = Vector2(490, 505)
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	await frames(3)
	await capture("art_on_foot")
	player.position = car.nearest_door(player.position)
	await tap(&"interact")
	verify(radio.vehicle == car and radio.audio.playing and radio.selected == 0, "Entering compact starts Anvil mid-song")
	verify(game.hud.radio_card.visible and game.hud.radio_logo.visible, "Station card appears at top only in vehicle")
	var rows: Array[Key] = [KEY_1, KEY_2, KEY_3, KEY_4]
	var bus := AudioServer.bus_count
	AudioServer.add_bus()
	AudioServer.set_bus_name(bus, "RadioTest")
	var audio_capture := AudioEffectCapture.new()
	audio_capture.buffer_length = 0.5
	AudioServer.add_bus_effect(bus, audio_capture)
	radio.audio.bus = "RadioTest"
	for i: int in 4:
		audio_capture.clear_buffer()
		await press_number(rows[i])
		await seconds(0.25)
		verify(radio.selected == i and car.radio_station == i, "Number %d selects correct station" % (i + 1))
		verify(game.hud.radio_logo.texture == ToyRadioManager.LIBRARY.stations[i].logo, "Station %d shows matching original logo" % (i + 1))
		verify(absf(radio.audio.get_playback_position() - radio.station_position(i)) < 0.35, "Station %d playback starts at broadcast position" % (i + 1))
		var samples := audio_capture.get_buffer(audio_capture.get_frames_available())
		var peak: float = 0.0
		for sample: Vector2 in samples:
			peak = maxf(peak, maxf(absf(sample.x), absf(sample.y)))
		verify(peak > 0.00001, "Station %d produces decoded audible samples" % (i + 1))
		await capture("radio_station_%d" % (i + 1))
	await press_number(KEY_KP_2)
	verify(radio.selected == 1, "Numeric keypad also selects station")
	await press_number(KEY_5)
	verify(not radio.audio.playing and not game.hud.radio_logo.visible and game.hud.radio_card.visible, "5 turns radio off and removes station logo")
	await tap(&"interact")
	verify(not game.hud.radio_card.visible and not radio.audio.playing, "Exiting hides card and stops audio")
	await tap(&"interact")
	verify(radio.selected == ToyRadioManager.OFF and not radio.audio.playing, "Vehicle remembers Off on re-entry")
	await press_number(KEY_4)
	var before := radio.station_position(3)
	await tap(&"interact")
	await seconds(0.3)
	await tap(&"interact")
	verify(radio.selected == 3 and radio.station_position(3) > before + 0.2, "Station timeline continues while on foot")
	await key(&"pause")
	before = radio.broadcast_time
	await seconds(0.2)
	verify(radio.audio.stream_paused and is_equal_approx(before, radio.broadcast_time), "Pause freezes radio audio and station timeline")
	await key(&"pause")
	verify(not radio.audio.stream_paused and radio.audio.playing, "Resume restores radio")
	radio.offsets[3] = ToyRadioManager.LIBRARY.stations[3].audio.get_length() - radio.broadcast_time - 0.15
	radio.select_station(3, true)
	await seconds(0.5)
	verify(radio.audio.playing and radio.audio.get_playback_position() < 1, "Track loops across end without going silent")
	var old_offsets := radio.offsets.duplicate()
	car.explode()
	verify(not radio.audio.playing and not game.hud.radio_card.visible, "Explosion/death stops audio and hides logo")
	await reset_game()
	radio = game.radio
	verify(not radio.audio.playing and not game.hud.radio_card.visible and radio.offsets != old_offsets, "Restart resets radio ownership and randomizes broadcast starts")
	AudioServer.remove_bus(bus)
	print("ART RADIO COMPLETE: %d checks passed" % checks)
	get_tree().quit(0)
