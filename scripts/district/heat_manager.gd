class_name DistrictHeat
extends Node
signal changed(level: int)
signal escaped
var game: DistrictGame
var points: float = 0
var level: int = 0
var highest: int = 0
var identity_known: bool = false
var search_position := Vector2.ZERO
var search_radius: float = 440
var unseen: float = 0
var outside_time: float = 0
var report_age: float = 999
var searching: bool = false
var report: String = "NO REPORT"
var crime_cooldown: float = 0
var last_crime: StringName = &""

func _ready() -> void:
	Events.crime.connect(on_crime)
func on_crime(kind: StringName, at: Vector2, severity: float, audible: float, player_caused: bool) -> void:
	if severity <= 0 or not player_caused:
		return
	var witnessed: bool = kind == &"police_theft" # The patrol car reports its own theft alarm.
	var direct: bool = false
	var police_victim: bool = false
	for npc: DistrictNPC in game.citizens:
		if not is_instance_valid(npc) or npc.downed:
			continue
		var distance := npc.global_position.distance_to(at)
		if kind == &"harm" and distance < 25 and npc.role != "police":
			continue # An isolated victim is not an additional witness to their own death.
		if kind == &"harm" and distance < 25 and npc.role == "police":
			police_victim = true
		if npc.can_see(at, 470) or distance < audible:
			witnessed = true
			if npc.role == "police" and npc.can_see(at, 520) and npc.can_see(game.player.global_position, 520) and player_caused:
				direct = true
	if not witnessed:
		return
	# No remote knowledge of the player: unheard/unseen crimes do nothing.
	if crime_cooldown > 0 and kind == last_crime and not police_victim:
		return
	crime_cooldown = 0.65
	last_crime = kind
	search_position = at
	report_age = 0
	unseen = 0
	outside_time = 0
	report = "WITNESSED " + String(kind).to_upper() if direct else "REPORTED " + String(kind).to_upper()
	points = minf(14, points + (3.0 if police_victim else severity))
	if direct:
		identity_known = true
		points = maxf(points, 3)
	update_level()
	Events.message_requested.emit(report + " / HEAT %d" % level)
	Events.sound_requested.emit(&"heat")
func confirm_sighting(at: Vector2) -> void:
	identity_known = true
	search_position = at
	unseen = 0
	outside_time = 0
	points = maxf(points, 3)
	update_level()
func can_identify(npc: DistrictNPC) -> bool:
	return report_age < 8 and game.player.global_position.distance_to(search_position) < 160 and npc.can_see(game.player.global_position)
func update_level() -> void:
	var next: int = 0
	for threshold: float in [1.0, 3.0, 6.0, 10.0]:
		if points >= threshold:
			next += 1
	if next != level:
		level = next
		highest = maxi(highest, level)
		search_radius = 400 + level * 50
		changed.emit(level)
func _physics_process(delta: float) -> void:
	report_age += delta
	crime_cooldown = maxf(0, crime_cooldown - delta)
	if level == 0:
		return
	unseen += delta
	var next_search := unseen > 1.2
	if next_search and not searching:
		Events.message_requested.emit("POLICE SEARCHING / Leave the marked area and stay unseen.")
		Events.sound_requested.emit(&"search")
	searching = next_search
	if unseen > 2 and game.player.global_position.distance_to(search_position) > search_radius:
		outside_time += delta
		if outside_time > 8:
			points = 0
			identity_known = false
			searching = false
			update_level()
			escaped.emit()
			Events.message_requested.emit("PURSUIT ESCAPED / HEAT CLEAR")
			Events.sound_requested.emit(&"escaped")
	else:
		outside_time = 0
