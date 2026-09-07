class_name DistrictNPC
extends PracticeTarget
## Reuses verified damage/launch feedback; navigation and decisions are separate.
@export_enum("civilian", "hostile", "police") var role: String = "civilian"
var navigation: DistrictNavigation
var player: ToyPlayer
var heat: Node
var state: StringName = &"idle"
var home: Vector2
var destination: Vector2
var last_seen: Vector2
var path := PackedVector2Array()
var path_index: int = 0
var path_timer: float = 0.0
var state_time: float = 0.0
var think_time: float = 0.0
var memory: float = 0.0
var danger: Vector2
var ai_enabled: bool = true
var rng := RandomNumberGenerator.new()
var shots_fired: int = 0
var seated_vehicle: ToyCompact
var identified: bool = false
var police_role: StringName = &"search"
var assigned_target := Vector2.ZERO
var debug_roles: bool = false
var move_speed: float = 215
var reaction: float = 0.6
var engagement: float = 330
var discipline: float = 1.8
var held_weapon: WeaponData
var ammo: int = 0
var weapon_dropped: bool = false
const BALANCE: PressureConfig = preload("res://data/pressure_config.tres")
const PISTOL: WeaponData = preload("res://data/weapons/pistol.tres")

func _ready() -> void:
	super._ready()
	remove_from_group("targets")
	add_to_group("citizens")
	if role == "police":
		add_to_group("police")
		var marker := DistrictMarker.new()
		marker.kind = &"police"
		add_child(marker)
	if role != "civilian":
		held_weapon = PISTOL
		ammo = clampi(int(held_weapon.ammunition * BALANCE.npc_magazine_fraction), 0, held_weapon.ammunition)
	home = global_position
	destination = home
	rng.seed = int(home.x * 17 + home.y * 7)
	think_time = rng.randf_range(0, 0.2)
	path_timer = rng.randf_range(0, 0.9)
	move_speed = rng.randf_range(BALANCE.speed_range.x, BALANCE.speed_range.y)
	reaction = rng.randf_range(BALANCE.reaction_range.x, BALANCE.reaction_range.y)
	engagement = rng.randf_range(BALANCE.engagement_range.x, BALANCE.engagement_range.y)
	discipline = rng.randf_range(BALANCE.shot_discipline_range.x, BALANCE.shot_discipline_range.y) if role == "police" else 1.8
	assigned_target = home
	Events.crime.connect(hear_danger)

func can_see(point: Vector2, distance: float = 520.0) -> bool:
	if downed or global_position.distance_to(point) > distance:
		return false
	var exclude: Array[RID] = [get_rid()]
	if player.vehicle and point.distance_to(player.global_position) < 5:
		exclude.append(player.vehicle.get_rid())
	return navigation.clear_ray(self, global_position, point, exclude)

func map_visible() -> bool:
	return not downed and (state in [&"pursuing", &"searching", &"alerted"] or (global_position.distance_to(player.global_position) < 550 and can_see(player.global_position, 550)))

func change_state(next: StringName) -> void:
	if state != next:
		state = next
		state_time = 0
		if role == "police" and next == &"alerted":
			Events.sound_requested.emit(&"police_alert")

func _physics_process(delta: float) -> void:
	if seated_vehicle != null:
		global_position = seated_vehicle.global_position
		return
	state_time += delta
	memory = maxf(0, memory - delta)
	path_timer -= delta
	think_time -= delta
	if not downed and ai_enabled and player.alive and stun <= 0 and air_time <= 0:
		if think_time <= 0:
			think_time = 0.18
			decide()
		if role != "civilian" and state in [&"pursuing", &"attack"]:
			fire_if_ready(delta)
		else:
			telegraph = 0
		if state in [&"wander", &"flee", &"pursuing", &"investigating", &"searching", &"returning"]:
			walk_path()
		else:
			velocity = Vector2.ZERO
	super._physics_process(delta)

func decide() -> void:
	if role == "civilian":
		if state == &"alerted" and state_time > 0.35:
			change_state(&"panic")
		elif state == &"panic" and state_time > 0.5:
			destination = navigation.grid.get_point_position(navigation.nearest(global_position + (global_position - danger).normalized() * 580))
			path_timer = 0
			change_state(&"flee")
		elif state == &"flee" and state_time > 7:
			change_state(&"idle")
		elif state == &"idle" and state_time > 1.5:
			destination = navigation.grid.get_point_position(navigation.nearest(home + Vector2(rng.randf_range(-180, 180), rng.randf_range(-140, 140))))
			change_state(&"wander")
		elif state == &"wander" and global_position.distance_to(destination) < 35:
			change_state(&"idle")
		return
	if role == "police":
		police_decision()
		return
	if can_see(player.global_position, 430):
		last_seen = player.global_position
		memory = 3.0
		if state == &"idle":
			change_state(&"suspicious")
		elif state == &"suspicious" and state_time > 0.65:
			change_state(&"pursuing")
		elif state in [&"pursuing", &"attack"]:
			change_state(&"attack" if global_position.distance_to(player.global_position) < 280 else &"pursuing")
		destination = last_seen
	elif memory > 0:
		destination = last_seen
		change_state(&"pursuing")
	else:
		change_state(&"idle")

func police_decision() -> void:
	if heat == null or heat.level == 0:
		identified = false
		if global_position.distance_to(home) > 60:
			destination = home
			change_state(&"returning")
		else:
			change_state(&"unaware")
		return
	if not heat.identity_known and heat.can_identify(self):
		heat.confirm_sighting(player.global_position)
	if heat.identity_known and can_see(player.global_position):
		if not identified:
			identified = true
			change_state(&"alerted")
		elif state != &"alerted" or state_time > reaction:
			change_state(&"pursuing")
		heat.confirm_sighting(player.global_position)
		last_seen = player.global_position
		if police_role == &"pursuer" or (police_role == &"containment" and global_position.distance_to(last_seen) < 250):
			destination = last_seen
		elif police_role == &"tactical":
			destination = last_seen + (global_position - last_seen).normalized() * engagement
		else:
			destination = assigned_target
	elif not heat.identity_known:
		identified = false
		destination = heat.search_position
		change_state(&"investigating")
	else:
		identified = false
		change_state(&"searching")
		destination = assigned_target

func walk_path() -> void:
	if path_timer <= 0:
		path_timer = 0.8 + rng.randf_range(0, 0.25)
		path = navigation.route(global_position, destination)
		path_index = 0
	while path_index < path.size() and global_position.distance_to(path[path_index]) < 22:
		path_index += 1
	if path_index >= path.size():
		velocity = Vector2.ZERO
		return
	var heading := (path[path_index] - global_position).normalized()
	# Local steering around parked vehicles, in addition to static grid routes.
	var ray := PhysicsRayQueryParameters2D.create(global_position, global_position + heading * 70, 8)
	if not get_world_2d().direct_space_state.intersect_ray(ray).is_empty():
		var side := heading.orthogonal()
		if not navigation.clear_ray(self, global_position, global_position + side * 65):
			side = -side
		heading = side
	var pace: float = 65 if state in [&"wander", &"returning"] else (move_speed if role == "police" else 175)
	var separation := Vector2.ZERO
	if role == "police":
		for other: Node in get_tree().get_nodes_in_group("police"):
			if other == self or other.downed:
				continue
			var offset: Vector2 = global_position - other.global_position
			if offset.length_squared() < 70 * 70 and offset.length_squared() > 1:
				separation += offset.normalized() * (1 - offset.length() / 70)
	velocity = (heading + separation.limit_length(1.2)).normalized() * pace
	if telegraph <= 0:
		shot_direction = heading

func fire_if_ready(delta: float) -> void:
	if held_weapon == null or ammo <= 0:
		telegraph = 0
		return
	if role == "police" and (heat == null or heat.level < 2):
		return
	if not can_see(player.global_position, engagement + (90 if police_role == &"tactical" else 40)):
		telegraph = 0
		shot_timer = 1.8
		return
	shot_timer -= delta
	if shot_timer <= 0.7 and telegraph <= 0:
		shot_direction = (player.global_position - global_position).normalized()
		telegraph = 0.7
	if shot_timer <= 0:
		ammo -= 1
		FirearmShot.fire(get_tree().current_scene, held_weapon, global_position, shot_direction, [get_rid()], false)
		shots_fired += 1
		# Deliberate aim/reset interval; never faster than the shared weapon cadence.
		shot_timer = maxf(held_weapon.cooldown, discipline)
		telegraph = 0

func hear_danger(_kind: StringName, at: Vector2, _severity: float, audible: float, _player_caused: bool) -> void:
	if downed or role != "civilian":
		return
	var distance := global_position.distance_to(at)
	if distance < audible or (distance < 260 and can_see(at, 260)):
		danger = at
		if not state in [&"alerted", &"panic"]:
			change_state(&"alerted")

func take_hit(amount: int, push: Vector2, bullet: bool = false) -> void:
	if downed:
		return
	super.take_hit(amount, push, bullet)
	if downed:
		drop_held_weapon()
		respawn_time = INF
		change_state(&"killed")
	else:
		danger = global_position - push.normalized() * 100
		change_state(&"alerted" if role == "civilian" else &"pursuing")
		if role != "civilian":
			if can_see(player.global_position):
				last_seen = player.global_position
				memory = 3

func _draw() -> void:
	var color := Color("d0ba8f") if role == "civilian" else (Color("739eaf") if role == "police" else Color("b75a48"))
	draw_circle(Vector2(2, 5), 17, Color(0, 0, 0, 0.3))
	draw_set_transform(Vector2(0, -visual_lift()), tumble_angle if air_time > 0 else (PI / 2 if downed else shot_direction.angle()))
	draw_rect(Rect2(-12, -14, 24, 28), color.darkened(0.5) if downed else color)
	draw_circle(Vector2(5, 0), 9, Color("ebd4ad"))
	if held_weapon != null:
		draw_line(Vector2(8, 9), Vector2(31, 9), Color("212623"), 6)
	draw_set_transform(Vector2.ZERO)
	if downed:
		return
	if telegraph > 0:
		draw_line(shot_direction * 28, shot_direction * 330, Color(0.95, 0.32, 0.2, 0.6), 2)
	if state in [&"alerted", &"panic", &"suspicious"]:
		draw_string(ThemeDB.fallback_font, Vector2(-3, -28), "!", HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Color("ffd889"))
	if role == "police":
		draw_string(ThemeDB.fallback_font, Vector2(-38, -27), (String(police_role) + "/" + String(state) + " %d" % ammo if debug_roles else String(state)).to_upper(), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("d5e0c5"))

func drop_held_weapon() -> void:
	if weapon_dropped or held_weapon == null:
		return
	weapon_dropped = true
	var pickup := WeaponPickup.new()
	pickup.data = held_weapon
	pickup.ammo = ammo
	pickup.position = global_position
	get_tree().current_scene.add_child(pickup)
	held_weapon = null
	ammo = 0
