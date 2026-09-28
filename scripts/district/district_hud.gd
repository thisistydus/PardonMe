class_name DistrictHUD
extends ToyHUD
var game: DistrictGame
var score_line: Label
var heat_line: Label
var heat_flames: HeatFlames
var objective_line: Label
var objective_card: Panel
var objective_title: Label
var objective_timer: Label
var clock_line: Label
var clock_detail: Label
var results: Panel
var results_title: Label
var results_subtitle: Label
var results_left: Label
var results_values: Label
var results_right_values: Label
var results_right: Label
var results_log: Label
var next_day: Button
var results_shown: bool = false
var popups: Array[Dictionary] = []

func _ready() -> void:
	custom_results = true
	super._ready()
	# Retain established radio/pause controls; replace the yard-only information.
	for child: Node in get_children():
		if child is Label and child.text == "MUNICIPAL TEST YARD  /  GOAL A":
			child.text = "FIRST DISTRICT / GOAL C1"
		elif child is Label and child.text.begins_with("R restart"):
			child.hide()
	status.position = Vector2(390, 22)
	status.size = Vector2(560, 60)
	clock_line = text_label(Vector2(1000, 18), Vector2(250, 36), 30)
	clock_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	clock_detail = text_label(Vector2(930, 56), Vector2(320, 22), 13)
	clock_detail.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_card = slab(Vector2(16, 98), Vector2(800, 74), Color(0.08, 0.1, 0.09, 0.82))
	objective_title = text_label(Vector2(60, 5), Vector2(560, 22), 14, objective_card)
	objective_title.add_theme_color_override("font_color", Color("e6bb63"))
	objective_timer = text_label(Vector2(620, 5), Vector2(166, 22), 14, objective_card)
	objective_timer.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	objective_line = text_label(Vector2(60, 26), Vector2(726, 46), 16, objective_card)
	objective_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_card.draw.connect(draw_objective_icon)
	heat_flames = HeatFlames.new()
	heat_flames.position = Vector2(24, 180)
	add_child(heat_flames)
	heat_line = text_label(Vector2(164, 184), Vector2(600, 28), 17)
	heat_line.add_theme_color_override("font_shadow_color", Color.BLACK)
	heat_line.add_theme_constant_override("shadow_offset_x", 2)
	heat_line.add_theme_constant_override("shadow_offset_y", 2)
	debug.position = Vector2(28, 225)
	debug.size = Vector2(750, 180)
	message.position = Vector2(40, 546)
	message.size = Vector2(935, 70)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	game.score.cash_added.connect(on_cash)
	build_results()

func build_results() -> void:
	results = slab(Vector2(200, 60), Vector2(880, 600), Color("141917"))
	results.mouse_filter = Control.MOUSE_FILTER_STOP
	var stamp := StyleBoxFlat.new()
	stamp.bg_color = Color("141917")
	stamp.border_color = Color("c9a55a")
	stamp.set_border_width_all(3)
	results.add_theme_stylebox_override("panel", stamp)
	results_title = text_label(Vector2(36, 22), Vector2(808, 44), 34, results)
	results_subtitle = text_label(Vector2(36, 70), Vector2(808, 26), 17, results)
	results_left = text_label(Vector2(36, 112), Vector2(220, 240), 20, results)
	results_values = text_label(Vector2(230, 112), Vector2(200, 240), 20, results)
	results_values.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	results_right = text_label(Vector2(480, 116), Vector2(200, 260), 17, results)
	results_right_values = text_label(Vector2(640, 116), Vector2(204, 260), 17, results)
	results_right_values.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	results_log = text_label(Vector2(36, 400), Vector2(808, 110), 15, results)
	results_log.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	next_day = Button.new()
	next_day.text = "NEXT DAY   [ R / ENTER ]"
	next_day.position = Vector2(150, 528)
	next_day.size = Vector2(360, 48)
	next_day.add_theme_font_size_override("font_size", 21)
	next_day.pressed.connect(run.restart)
	results.add_child(next_day)
	var quit := Button.new()
	quit.text = "QUIT"
	quit.position = Vector2(540, 528)
	quit.size = Vector2(190, 48)
	quit.add_theme_font_size_override("font_size", 21)
	quit.pressed.connect(run.quit_run)
	results.add_child(quit)
	results.hide()

func draw_objective_icon() -> void:
	var active := game.board.active
	var kind := String(active.definition.kind_label) if active != null else ""
	var c := Vector2(30, 37)
	var gold := Color("e6bb63")
	objective_card.draw_circle(c, 20, Color("1c2321"))
	objective_card.draw_arc(c, 20, 0, TAU, 28, gold, 2)
	match kind:
		"BOOST":
			objective_card.draw_rect(Rect2(c + Vector2(-13, -7), Vector2(26, 14)), gold)
			objective_card.draw_rect(Rect2(c + Vector2(-5, -5), Vector2(9, 10)), Color("1c2321"))
		"ROB":
			objective_card.draw_rect(Rect2(c + Vector2(-10, -6), Vector2(20, 15)), Color("6f9a5f"))
			objective_card.draw_string(ThemeDB.fallback_font, c + Vector2(-5, 7), "$", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("1c2321"))
		"DESTROY":
			objective_card.draw_arc(c, 10, 0, TAU, 20, Color("e0664e"), 3)
			objective_card.draw_line(c + Vector2(-15, 0), c + Vector2(15, 0), Color("e0664e"), 2)
			objective_card.draw_line(c + Vector2(0, -15), c + Vector2(0, 15), Color("e0664e"), 2)
		_:
			# Idle: a payphone handset.
			objective_card.draw_line(c + Vector2(-9, 8), c + Vector2(9, -8), gold, 5)
			objective_card.draw_circle(c + Vector2(-9, 8), 5, gold)
			objective_card.draw_circle(c + Vector2(9, -8), 5, gold)

func on_cash(amount: int, source: StringName) -> void:
	var label := text_label(Vector2(540, 300), Vector2(200, 26), 19)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.text = "+$%d %s" % [amount, String(source).to_upper()]
	label.add_theme_color_override("font_color", Color("b9e08f"))
	label.add_theme_color_override("font_shadow_color", Color.BLACK)
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	popups.append({"label": label, "age": 0.0, "offset": popups.size() * 24.0})

func _process(delta: float) -> void:
	super._process(delta)
	var clock := game.clock
	status.text = "CASH $%d   ×%d NOTORIETY   =   %d\n%s" % [game.score.money, game.score.notoriety, game.score.live_score(), "WOUNDED — 1 STRIKE LEFT" if player.wounded else "UNHURT — 2 STRIKES"]
	clock_line.text = clock.time_text()
	var urgent := clock.warned and not run.ended
	clock_line.add_theme_color_override("font_color", Color("ff6a52") if urgent and fmod(clock.elapsed, 1.0) < 0.5 else (Color("ffb59e") if urgent else Color("e8dabc")))
	clock_detail.text = "%s  ·  DAWN IN %d:%02d" % [clock.period, int(clock.remaining()) / 60, int(clock.remaining()) % 60]
	var active := game.board.active
	objective_title.text = (active.definition.kind_label + " / " + active.definition.title) if active != null else "PAYPHONES"
	objective_line.text = game.board.objective()
	var left := active.time_left() if active != null else -1.0
	objective_timer.text = "%d:%02d LEFT" % [int(left) / 60, int(left) % 60] if left >= 0 else ""
	objective_timer.add_theme_color_override("font_color", Color("ff6a52") if left >= 0 and left < 30 else Color("e8dabc"))
	objective_card.queue_redraw()
	heat_flames.level = game.heat.level
	heat_flames.searching = game.heat.searching
	heat_line.text = "HEAT %d  %s" % [game.heat.level, "SEARCHING — leave the red area unseen" if game.heat.searching else ("PURSUIT" if game.heat.identity_known else ("INVESTIGATING" if game.heat.level > 0 else "CLEAR"))]
	for popup: Dictionary in popups.duplicate():
		popup.age += delta
		var label: Label = popup.label
		# Rises from just above the player (camera-centred) so it never covers the score line.
		label.position = Vector2(540, 300 - float(popup.offset) - float(popup.age) * 40.0)
		label.modulate.a = clampf(1.6 - float(popup.age), 0, 1)
		if popup.age > 1.6:
			label.queue_free()
			popups.erase(popup)
	if player.vehicle:
		var vehicle := player.vehicle
		context.text = "%s / %s / %d%% / SPEED %d\nE exit · Space brake · 1–4 radio · 5 off · M map" % [vehicle.data.title, vehicle.damage_state(), int(vehicle.health / vehicle.data.durability * 100), int(absf(vehicle.speed))]
		if game.mission.delivery_ready(): context.text = "E — DELIVER VEHICLE\nConfirm transfer to surrender the car and collect your reward."
	else:
		context.text = "WASD move · Mouse aim · LMB use · E interact · M map\n" + interaction_hint()
	var states: String = ""
	for npc: DistrictNPC in game.citizens:
		if is_instance_valid(npc) and npc.role == "police" and not npc.downed:
			states += String(npc.police_role).left(1).to_upper() + " "
	debug.text = "STATE %s | HEAT %d (%.1f) | SEED %d\nSEARCH %s R%.0f | UNSEEN %.1fs | OUTSIDE %.1f/%.0fs\nIDENTIFIED %s | %s\nPOLICE %s\nMISSION %s | NPCs %d | FPS %d | F6 recovery (Heat 0)" % ["DRIVING" if player.vehicle else "ON FOOT", game.heat.level, game.heat.points, run.seed_value, str(game.heat.search_position.round()), game.heat.search_radius, game.heat.unseen, game.heat.outside_time, game.heat.search_duration, str(game.heat.identity_known), game.heat.report, states, String(active.state) if active != null else String(game.mission.state), game.citizens.size(), Engine.get_frames_per_second()]
	debug.text += "\n" + game.response.debug_status() + " | CHAINS %d" % game.explosion_tracker.feat_count
	debug.text += "\nCLOCK %s %.1f/%.0fs | JOBS %d/%d | CASH drops %d got %d gone %d" % [clock.time_text(), clock.elapsed, clock.tuning.run_seconds, game.board.completed, game.board.attempted, game.cash.dropped, game.cash.collected, game.cash.expired]
	if panel.visible:
		result.text = "DISTRICT PAUSED\n%s  ·  %s\n$%d × %d = %d\nJobs %d / %d  ·  Peak Heat %d\nSeed %d" % [clock.time_text(), clock.period, game.score.money, game.score.notoriety, game.score.live_score(), game.board.completed, game.board.attempted, game.heat.highest, run.seed_value]
	if run.ended:
		if not results_shown:
			results_shown = true
			game.minimap.hide()
			for popup: Dictionary in popups:
				(popup.label as Label).queue_free()
			popups.clear()
			fill_results()
			results.show()
			next_day.grab_focus()
	else:
		results.hide()

func fill_results() -> void:
	var survived := run.result == &"dawn"
	var numbers := game.score.breakdown(survived)
	var clock := game.clock
	results_title.text = "DAWN — THE PARDON HELD" if survived else "PERMISSION EXPIRED"
	results_title.add_theme_color_override("font_color", Color("e6c96c") if survived else Color("ff8a70"))
	results_subtitle.text = ("Survived until dawn. Everything is forgiven." if survived else "Died at %s — %s." % [clock.time_text(), player.death_cause if player.death_cause != "" else "cause unknown"])
	var street: int = game.score.cash_by_source.get(&"street", 0)
	var jobs: int = game.score.cash_by_source.get(&"mission", 0)
	var extra: int = game.score.cash_by_source.get(&"bonus", 0)
	results_left.text = "CASH EARNED\nNOTORIETY\nBASE  (CASH × NOT.)\nDAWN BONUS\n\nFINAL SCORE"
	results_values.text = "$%d\n×%d\n%d\n%s\n\n%d" % [numbers.cash, numbers.notoriety, numbers.base, ("+%d  (%d%%)" % [numbers.dawn_bonus, int(clock.tuning.dawn_bonus_fraction * 100)]) if survived else "—  (died)", numbers.final]
	var survival := clock.elapsed
	results_right.text = "Jobs attempted\nJobs completed\nPeak Heat\nSurvival time\nClock reached\nStreet cash\nJob cash\nBonus cash\nSeed"
	results_right_values.text = "%d\n%d\n%d\n%d:%02d\n%s\n$%d\n$%d\n$%d\n%d" % [game.board.attempted, game.board.completed, game.heat.highest, int(survival) / 60, int(survival) % 60, clock.time_text(), street, jobs, extra, run.seed_value]
	var lines: Array[String] = []
	for entry: Dictionary in game.board.history:
		var bonus_text := (" + " + ", ".join(entry.bonuses)) if not entry.bonuses.is_empty() else ""
		lines.append("%s  %s — %s" % [entry.kind, entry.title, ("DONE  $%d  +%d NOT.%s" % [entry.cash, entry.notoriety, bonus_text]) if entry.outcome == &"complete" else "FAILED  " + String(entry.reason)])
	if numbers.cash == 0:
		lines.append("No cash earned: the score is $0 × notoriety = 0. Notoriety multiplies cash; it cannot score alone.")
	results_log.text = "\n".join(lines) if not lines.is_empty() else "No jobs taken. Payphones ring from dawn."

func interaction_hint() -> String:
	for point: Node2D in get_tree().get_nodes_in_group("interactables"):
		if point.available and point.global_position.distance_to(player.global_position) < 65:
			var offer: DistrictMission = point.get("offer")
			return "E / ANSWER PAYPHONE" + (" — " + offer.definition.kind_label + " JOB" if offer != null else "")
	for vehicle: ToyCompact in game.cars:
		if not vehicle.disabled and not vehicle.unavailable and vehicle.nearest_door(player.global_position).distance_to(player.global_position) < 65:
			return "E / ENTER " + vehicle.data.title
	for pickup: WeaponPickup in get_tree().get_nodes_in_group("pickups"):
		if pickup.global_position.distance_to(player.global_position) < 65:
			return "E / PICK UP " + pickup.data.title + (" / %d rounds" % pickup.ammo if pickup.data.firearm else "")
	return "R restart · Esc pause · F3 debug · F4 shake"
