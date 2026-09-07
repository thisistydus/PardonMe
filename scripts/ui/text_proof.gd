extends Control
## Isolated native proof. No dependency on the essential game HUD.
var label: RichTextLabel
var elapsed: float = 0
func _ready() -> void:
	var background := ColorRect.new()
	background.color = Color("151b19")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	label = RichTextLabel.new()
	label.position = Vector2(120, 240)
	label.size = Vector2(1040, 250)
	label.bbcode_enabled = true
	label.scroll_active = false
	label.add_theme_font_size_override("normal_font_size", 28)
	label.add_theme_color_override("default_color", Color("e8dabc"))
	label.text = "[font_size=36]MUNICIPAL TRANSMISSION[/font_size]\n[color=#d2ad61]Vehicle received.[/color] Your permission remains in force.\n[img=72x48]res://Art/Logos/TheAnvil.png[/img] 96.9 THE ANVIL — native inline image / color / reveal"
	label.visible_characters = 0
	add_child(label)
func _process(delta: float) -> void:
	elapsed += delta
	label.visible_characters = mini(label.get_total_character_count(), int(elapsed * 38))
	if "--verify" in OS.get_cmdline_user_args() and elapsed > 6:
		assert(label.visible_characters == label.get_total_character_count())
		assert("[color" not in label.get_parsed_text())
		set_process(false)
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://screenshots/2026-09-07_PardonMe_B5_native_text.png")
		print("B5 TEXT COMPLETE: native reveal, BBCode color and inline texture loaded")
		get_tree().quit()
