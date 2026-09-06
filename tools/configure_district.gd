extends SceneTree
func _initialize() -> void:
	for action: String in ["district_map", "recover_vehicle"]:
		var event := InputEventKey.new()
		event.physical_keycode = KEY_M if action == "district_map" else KEY_F6
		ProjectSettings.set_setting("input/" + action, {"deadzone":0.2, "events":[event]})
	ProjectSettings.save()
	quit()
