extends Node
## Real engine integration checks. The harness survives game-scene restarts.
var checks: int = 0
var failures: int = 0
var game: Node2D
var player: ToyPlayer
var car: ToyCompact
var target: PracticeTarget
var started: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	start.call_deferred()

func verify(condition: bool, description: String) -> void:
	if not condition:
		push_error("FAIL: " + description)
		failures += 1
		# Exit deferred with the failure code after the calling coroutine yields.
		finish_failure.call_deferred()
		return
	checks += 1
	print("PASS: " + description)

func finish_failure() -> void:
	get_tree().quit(1)

func frames(count: int) -> void:
	for i: int in count:
		await get_tree().physics_frame

func seconds(duration: float) -> void:
	await get_tree().create_timer(duration, true, false, true).timeout

func tap(action: StringName) -> void:
	Input.action_press(action)
	await frames(2)
	Input.action_release(action)
	await frames(2)

func key(action: StringName) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = InputEventAction.new()
	event.action = action
	event.pressed = false
	Input.parse_input_event(event)
	await frames(3)

func refresh_refs() -> void:
	game = get_tree().current_scene
	player = game.get_node("Player") as ToyPlayer
	car = game.get_node("Compact") as ToyCompact
	target = get_tree().get_nodes_in_group("targets")[0] as PracticeTarget

func reset_game() -> void:
	await key(&"restart")
	refresh_refs()
	await frames(4)

func aim(direction: Vector2) -> void:
	player.controller_aim = true
	player.aim_direction = direction

func stage_target(at: Vector2) -> void:
	target.position = at
	target.velocity = Vector2.ZERO
	target.health = 3
	target.downed = false
	target.collision_layer = 4
	target.air_time = 0.0
	player.global_position = at - Vector2(38, 0)
	player.impulse = Vector2.ZERO
	aim(Vector2.RIGHT)

func start() -> void:
	game = load("res://scenes/game.tscn").instantiate() as Node2D
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	if "--soak" in OS.get_cmdline_user_args():
		await soak()
		return
	var at := player.position
	Input.action_press("move_right")
	await frames(30)
	Input.action_release("move_right")
	verify(player.position.x > at.x + 100, "WASD moves player")
	player.position = Vector2(200, 650)
	Input.action_press("move_right")
	Input.action_press("move_up")
	at = player.position
	await frames(30)
	Input.action_release("move_right")
	Input.action_release("move_up")
	verify(player.position.distance_to(at) < 150, "Diagonal movement normalized")
	aim(Vector2.UP)
	Input.action_press("move_right")
	await frames(5)
	Input.action_release("move_right")
	verify(player.aim_direction.dot(Vector2.UP) > 0.99, "Aim independent of movement")
	player.position = Vector2(480, 250)
	Input.action_press("move_right")
	await frames(30)
	Input.action_release("move_right")
	verify(player.position.x < 490, "Player blocked by cover")
	player.position = Vector2(220, 660)
	await tap(&"interact")
	verify(player.weapons.data.id == &"bat", "E picks up bat")
	await tap(&"drop_weapon")
	verify(player.weapons.data.id == &"fists", "Drop restores permanent fists")
	for i: int in 3:
		if i == 0:
			stage_target(Vector2(850, 260))
		else:
			player.position = target.position - Vector2(38, 0)
			target.velocity = Vector2.ZERO
		await seconds(0.4)
		await tap(&"attack")
		verify(target.downed == (i == 2), "Fists strike %d / three strikes down target" % (i + 1))
	stage_target(Vector2(850, 260))
	player.weapons.equip(load("res://data/weapons/bat.tres"))
	await seconds(0.2)
	await tap(&"attack")
	verify(target.downed and target.velocity.length() > 300, "Bat incapacitates with strong knockback")
	await seconds(0.4)
	verify(is_equal_approx(Engine.time_scale, 1.0), "Hit pause always restores simulation")
	stage_target(Vector2(950, 350))
	player.position = target.position - Vector2(150, 0)
	player.weapons.equip(load("res://data/weapons/pistol.tres"))
	await seconds(0.2)
	Input.action_press("attack")
	await seconds(0.7)
	Input.action_release("attack")
	verify(target.downed and player.weapons.ammo == 7, "Pistol one-hit kill; held input does not autofire")
	await tap(&"drop_weapon")
	await tap(&"interact")
	verify(player.weapons.ammo == 7, "Dropped pistol preserves ammo")
	stage_target(Vector2(770, 250))
	player.position = Vector2(465, 250)
	await seconds(0.3)
	await tap(&"attack")
	await seconds(0.5)
	verify(not target.downed and target.health == 3, "Swept bullet stops at cover")
	player.weapons.ammo = 1
	player.position = Vector2(200, 660)
	aim(Vector2.DOWN)
	await tap(&"attack")
	await seconds(0.3)
	await tap(&"attack")
	verify(player.weapons.ammo == 0, "Empty pistol cannot fire or underflow ammo")
	player.position = car.nearest_door(player.position)
	await tap(&"interact")
	verify(player.vehicle == car and not player.visible, "E enters compact immediately")
	at = car.position
	Input.action_press("move_up")
	await seconds(0.6)
	Input.action_release("move_up")
	verify(car.position.distance_to(at) > 60 and car.speed > 150, "Compact accelerates and moves")
	var angle := car.rotation
	Input.action_press("move_right")
	await seconds(0.3)
	Input.action_release("move_right")
	verify(absf(car.rotation - angle) > 0.1, "Compact steers through rotation")
	Input.action_press("handbrake")
	await seconds(0.4)
	Input.action_release("handbrake")
	verify(absf(car.speed) < 30, "Handbrake stops compact")
	await tap(&"interact")
	verify(player.vehicle == null and player.visible and player.collision_layer == 2, "Exit restores on-foot collision and visibility")
	car.position = Vector2(600, 100)
	car.rotation = 0
	car.speed = 0
	player.position = Vector2(600, 148)
	verify(car.enter(player), "Entry beside wall succeeds at clear door")
	verify(car.try_exit() and player.position.y > 120, "Exit selects unblocked side beside wall")
	car.position = Vector2(500, 450)
	car.rotation = 0
	car.speed = 0
	stage_target(Vector2(730, 450))
	player.position = Vector2(500, 498)
	verify(car.enter(player), "Re-entry works")
	Input.action_press("move_up")
	await seconds(1.2)
	Input.action_release("move_up")
	verify(target.downed, "High-speed vehicle impact incapacitates target")
	verify(car.health < 100, "Collision damages compact")
	car.take_hit(100, Vector2.LEFT)
	verify(not car.disabled and car.failure_timer > 2.5, "Critical vehicle gives readable failure delay")
	verify(car.try_exit(), "Player can exit during explosion countdown")
	player.position = Vector2(150, 1000)
	await seconds(3.5)
	verify(car.disabled and car.damage_state() == "WRECKED", "Vehicle explodes after warning")
	verify(player.alive, "Player survives after leaving blast radius")
	await reset_game()
	verify(player.alive and not player.wounded and car.health == 100 and game.run.downs == 0, "Restart resets actors, damage and counters")
	await key(&"pause")
	verify(get_tree().paused, "Pause action pauses simulation")
	at = player.position
	Input.action_press("move_right")
	await seconds(0.2)
	Input.action_release("move_right")
	verify(player.position == at, "Paused player does not move")
	await key(&"pause")
	verify(not get_tree().paused, "Pause action resumes")
	player.position = Vector2(1220, 930)
	await seconds(2.5)
	verify(player.wounded and player.alive, "Live-fire projectile causes first-strike wound")
	await seconds(2.0)
	verify(not player.alive and game.run.ended and get_tree().paused, "Second projectile ends run and shows results")
	await reset_game()
	verify(player.alive and not get_tree().paused and game.run.seed_value == 771104, "Restart from death retains seed and resumes input")
	print("ACCEPTANCE COMPLETE: %d checks passed" % checks)
	get_tree().quit(0)

func soak() -> void:
	started = Time.get_ticks_msec()
	var cycle: int = 0
	while Time.get_ticks_msec() - started < 600000:
		cycle += 1
		await reset_game()
		await tap(&"interact")
		verify(player.weapons.data.id == &"bat", "Soak %d pickup" % cycle)
		stage_target(Vector2(850, 260))
		await seconds(0.2)
		await tap(&"attack")
		verify(target.downed, "Soak %d bat hit" % cycle)
		await seconds(0.2)
		player.position = car.nearest_door(player.position)
		await tap(&"interact")
		verify(player.vehicle == car, "Soak %d enter" % cycle)
		Input.action_press("move_up")
		await seconds(0.65)
		Input.action_press("move_right")
		await seconds(0.25)
		Input.action_release("move_right")
		Input.action_release("move_up")
		Input.action_press("handbrake")
		await seconds(0.4)
		Input.action_release("handbrake")
		await tap(&"interact")
		verify(player.vehicle == null and player.visible, "Soak %d exit" % cycle)
		player.position = Vector2(1220, 930)
		await seconds(4.8)
		verify(game.run.ended, "Soak %d death" % cycle)
		print("SOAK elapsed %.1fs | cycle %d | nodes %d" % [(Time.get_ticks_msec() - started) / 1000.0, cycle, get_tree().get_node_count()])
	print("SOAK COMPLETE: %.1f real seconds, %d cycles, %d assertions" % [(Time.get_ticks_msec() - started) / 1000.0, cycle, checks])
	get_tree().quit(0)
