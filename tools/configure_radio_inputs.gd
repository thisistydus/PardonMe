extends SceneTree
func _initialize() -> void:
	var row: Array[int] = [KEY_1, KEY_2, KEY_3, KEY_4, KEY_5]
	var pad: Array[int] = [KEY_KP_1, KEY_KP_2, KEY_KP_3, KEY_KP_4, KEY_KP_5]
	for i: int in 5:
		var events: Array[InputEvent] = []
		for code: int in [row[i], pad[i]]:
			var event := InputEventKey.new()
			event.physical_keycode = code
			events.append(event)
		ProjectSettings.set_setting("input/radio_%d" % (i + 1), {"deadzone": 0.2, "events": events})
	assert(ProjectSettings.save() == OK)
	quit()
