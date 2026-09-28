class_name DistrictRob
extends DistrictMission
## travel → robbing (alarm, guards, hold-up) → grab (bag on the ground) → escape → complete.
const DEFINITION: RobDefinition = preload("res://data/missions/receipt_row_rob.tres")
var guards: Array[DistrictNPC] = []
var bag: MissionPackage
var carrying: bool = false
var hold: float = 0.0

func _init() -> void:
	definition = DEFINITION

func begin() -> bool:
	hold = 0.0
	carrying = false
	state = &"travel"
	objective = "ROB / Hit the Receipt Row storefront. Guards will be waiting."
	return true

func tick(delta: float) -> void:
	var player := game.player
	var store := DEFINITION.store_position
	match state:
		&"travel":
			if player.global_position.distance_to(store) < DEFINITION.alarm_radius:
				trip_alarm()
		&"robbing":
			var inside := player.vehicle == null and player.alive and player.global_position.distance_to(store) < DEFINITION.zone_radius
			hold = clampf(hold + (delta if inside else -delta * DEFINITION.hold_decay), 0.0, DEFINITION.hold_seconds)
			if hold >= DEFINITION.hold_seconds:
				drop_bag()
		&"grab":
			if not is_instance_valid(bag) or bag.burned:
				fail("ROB FAILED / The cash bag burned before you grabbed it.")
			elif player.vehicle == null and player.global_position.distance_to(bag.global_position) < DEFINITION.pickup_radius + 14.0:
				take_bag()
		&"escape":
			if player.global_position.distance_to(store) > DEFINITION.escape_radius and not game.heat.identity_known:
				if game.heat.level <= DEFINITION.low_heat_threshold:
					add_bonus("LOW HEAT", DEFINITION.low_heat_bonus)
				if elapsed <= DEFINITION.quick_seconds:
					add_bonus("QUICK", DEFINITION.quick_bonus)
				complete()

func trip_alarm() -> void:
	state = &"robbing"
	objective = "ROB / Alarm tripped. Stand at the counter on foot to empty the register."
	for point: Vector2 in DEFINITION.guard_positions:
		var guard := game.spawn_citizen(point, "hostile")
		guards.append(guard)
	Events.crime.emit(&"robbery", DEFINITION.store_position, DEFINITION.alarm_severity, DEFINITION.alarm_audible_radius, true)
	Events.sound_requested.emit(&"police_alert")
	Events.message_requested.emit("ROBBERY IN PROGRESS / Guards on the door.")
	changed.emit()

func drop_bag() -> void:
	state = &"grab"
	bag = MissionPackage.new()
	bag.position = DEFINITION.store_position
	game.add_child(bag)
	objective = "ROB / The clerk threw the bag. Grab it."
	Events.sound_requested.emit(&"mission")
	changed.emit()

func take_bag() -> void:
	bag.queue_free()
	bag = null
	carrying = true
	state = &"escape"
	objective = "ROB / Bag secured. Get outside the gold ring on your map and shake any pursuit."
	Events.sound_requested.emit(&"cash")
	Events.message_requested.emit("BAG SECURED / Get clear.")
	changed.emit()

func cleanup() -> void:
	carrying = false
	hold = 0.0
	if is_instance_valid(bag):
		bag.queue_free()
	bag = null
	for guard: DistrictNPC in guards:
		if is_instance_valid(guard) and not guard.downed:
			board.retire(guard)
	guards.clear()

func destination() -> Vector2:
	if state == &"grab" and is_instance_valid(bag):
		return bag.global_position
	if state in [&"travel", &"robbing"]:
		return DEFINITION.store_position
	return Vector2.INF

func world_markers() -> Array[Dictionary]:
	match state:
		&"travel":
			return [{"p": DEFINITION.store_position, "label": "ROB HERE", "kind": &"rob", "radius": DEFINITION.zone_radius}]
		&"robbing":
			return [{"p": DEFINITION.store_position, "label": "HOLD %d%%" % int(hold / DEFINITION.hold_seconds * 100), "kind": &"hold", "radius": DEFINITION.zone_radius, "progress": hold / DEFINITION.hold_seconds}]
		&"grab":
			return [{"p": destination(), "label": "GRAB", "kind": &"bag", "radius": 40.0}] if destination() != Vector2.INF else []
		&"escape":
			return [{"p": DEFINITION.store_position, "label": "GET CLEAR", "kind": &"escape", "radius": DEFINITION.escape_radius}]
	return []
