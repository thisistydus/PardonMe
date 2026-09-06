class_name DistrictHUD
extends ToyHUD
var game: DistrictGame
var score_line: Label
var heat_line: Label
var objective_line: Label
func _ready() -> void:
	super._ready()
	# Retain established radio/pause controls; replace the yard-only information.
	for child: Node in get_children():
		if child is Label and child.text == "MUNICIPAL TEST YARD  /  GOAL A":
			child.text = "FIRST DISTRICT / GOAL B+"
	status.position = Vector2(390, 27)
	status.size = Vector2(580, 50)
	objective_line = text_label(Vector2(28, 110), Vector2(770, 62), 17)
	objective_line.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	objective_line.add_theme_color_override("font_shadow_color", Color.BLACK)
	objective_line.add_theme_constant_override("shadow_offset_x", 2)
	objective_line.add_theme_constant_override("shadow_offset_y", 2)
	heat_line = text_label(Vector2(28, 180), Vector2(740, 32), 18)
	debug.position = Vector2(28, 225)
	debug.size = Vector2(750, 160)
	message.position = Vector2(40, 546)
	message.size = Vector2(935, 70)
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
func _process(delta: float) -> void:
	super._process(delta)
	status.text = "$%d × %d = %d\n%s / DISTRICT TIME %02d:%02d" % [game.score.money, game.score.notoriety, game.score.live_score(), "WOUNDED" if player.wounded else "UNHURT", int(run.elapsed) / 60, int(run.elapsed) % 60]
	objective_line.text = game.mission.objective
	heat_line.text = "HEAT %d / %s" % [game.heat.level, "SEARCHING — leave gold/red radius" if game.heat.searching else ("PURSUIT" if game.heat.identity_known else ("INVESTIGATION" if game.heat.level > 0 else "CLEAR"))]
	if player.vehicle:
		var vehicle := player.vehicle
		context.text = "%s / %s / %d%% / SPEED %d\nE exit · Space brake · 1–4 radio · 5 off · M map" % [vehicle.data.title, vehicle.damage_state(), int(vehicle.health / vehicle.data.durability * 100), int(absf(vehicle.speed))]
	else:
		context.text = "WASD move · Mouse aim · LMB use · E interact · M map\n" + interaction_hint()
	var states: String = ""
	for npc: DistrictNPC in game.citizens:
		if is_instance_valid(npc) and npc.role == "police" and not npc.downed:
			states += String(npc.state) + " "
	debug.text = "STATE %s | HEAT %d (%.1f) | SEED %d\nSEARCH %s R%.0f | UNSEEN %.1fs | OUTSIDE %.1f/8s\nIDENTIFIED %s | %s\nPOLICE %s\nMISSION %s | NPCs %d | FPS %d | F6 recovery (Heat 0)" % ["DRIVING" if player.vehicle else "ON FOOT", game.heat.level, game.heat.points, run.seed_value, str(game.heat.search_position.round()), game.heat.search_radius, game.heat.unseen, game.heat.outside_time, str(game.heat.identity_known), game.heat.report, states, String(game.mission.state), game.citizens.size(), Engine.get_frames_per_second()]
	if panel.visible:
		result.text = "%s\n$%d × %d = %d\nMissions %d / Peak Heat %d\nSeed %d / District prototype" % ["PERMISSION EXPIRED" if run.ended else "DISTRICT PAUSED", game.score.money, game.score.notoriety, game.score.live_score(), game.score.missions, game.heat.highest, run.seed_value]
func interaction_hint() -> String:
	for point: Node2D in get_tree().get_nodes_in_group("interactables"):
		if point.available and point.global_position.distance_to(player.global_position) < 65:
			return "E / ANSWER PAYPHONE"
	for vehicle: ToyCompact in game.cars:
		if not vehicle.disabled and vehicle.nearest_door(player.global_position).distance_to(player.global_position) < 65:
			return "E / ENTER " + vehicle.data.title
	return "R restart · Esc pause · F3 debug · F4 shake"
