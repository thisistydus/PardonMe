extends "res://tests/district_integration.gd"
## Goal C1: mission backbone, Rob and Destroy success/failure, cleanup, counts and rewards.

func boot() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	player.invulnerability = 1000

func answer(index: int) -> void:
	player.position = city.layout.phones[index]
	await frames(2)
	await tap(&"interact")


func start() -> void:
	await boot()
	var rob := city.rob
	var destroy := city.destroy
	verify(city.phones.size() == 3 and city.phones[0].offer == city.mission and city.phones[1].offer == rob and city.phones[2].offer == destroy, "Each payphone carries one job: Boost, Rob, Destroy")
	verify(city.phones.all(func(p: DistrictPhone) -> bool: return p.available), "All three phones ring at dawn")
	verify(city.board.objective().contains("BOOST") and city.board.objective().contains("ROB") and city.board.objective().contains("DESTROY"), "Idle objective lists the ringing offers")
	# --- Rob: success with both bonuses -----------------------------------
	await answer(1)
	verify(city.board.active == rob and rob.state == &"travel" and city.board.attempted == 1, "Answering the Rob phone starts travel")
	verify(not city.phones.any(func(p: DistrictPhone) -> bool: return p.available), "Only one active job: every phone stops ringing")
	verify(not city.mission.accept(city.phones[0]) and city.mission.state == &"available", "Boost cannot start while Rob is active")
	verify(rob.destination() == rob.DEFINITION.store_position, "Rob marks the storefront")
	var civilians := city.citizens.size()
	player.position = rob.DEFINITION.store_position + Vector2(0, -150)
	await sim(0.2)
	verify(rob.state == &"robbing" and rob.guards.size() == 2 and city.citizens.size() == civilians + 2, "Arriving trips the alarm and spawns two guards")
	for guard: DistrictNPC in rob.guards: guard.ai_enabled = false
	verify(city.heat.level >= 1, "Robbery alarm is a witnessed crime that raises Heat")
	player.position = rob.DEFINITION.store_position
	await sim(1.5)
	player.position = rob.DEFINITION.store_position + Vector2(0, -300)
	await sim(1.0)
	var decayed := rob.hold
	verify(decayed > 0.4 and decayed < 1.5 and rob.state == &"robbing", "Leaving the counter pauses and decays the hold-up (%.2f)" % decayed)
	player.position = rob.DEFINITION.store_position
	var waited := 0
	while rob.state == &"robbing" and waited < 400:
		await frames(1)
		waited += 1
	verify(rob.state == &"grab" and is_instance_valid(rob.bag), "Completing the hold-up drops the cash bag")
	await frames(3)
	verify(rob.state == &"escape" and rob.carrying and not is_instance_valid(rob.bag), "Standing on the bag collects it")
	city.heat.points = 0
	city.heat.identity_known = false
	city.heat.update_level()
	player.position = rob.DEFINITION.store_position + Vector2(0, 1000)
	await sim(0.1)
	var rob_cash := rob.DEFINITION.cash_reward + rob.DEFINITION.low_heat_bonus + rob.DEFINITION.quick_bonus
	verify(rob.state == &"complete" and city.score.money == rob_cash and city.score.notoriety == 2, "Clean, quick escape pays $%d with both bonuses and +1 Notoriety" % rob_cash)
	verify(city.score.cash_by_source.get(&"mission", 0) == rob.DEFINITION.cash_reward and city.score.cash_by_source.get(&"bonus", 0) == rob.DEFINITION.low_heat_bonus + rob.DEFINITION.quick_bonus, "Mission and bonus cash go through the single cash interface")
	rob.complete()
	await frames(2)
	verify(city.score.money == rob_cash and city.board.completed == 1 and city.score.missions == 1, "Calling complete() again cannot re-award a finished job")
	verify(not rob.can_offer() and not city.phones[1].available and city.phones[0].available and city.phones[2].available, "Completed Rob retires its phone; the others ring again")
	player.position = Vector2(4400, 3300)
	await sim(1.2)
	verify(rob.guards.is_empty(), "Rob cleanup hands its guards over to the board")
	var remaining_guards := 0
	for npc: DistrictNPC in city.citizens:
		if is_instance_valid(npc) and npc.role == "hostile" and npc.global_position.distance_to(rob.DEFINITION.store_position) < 400 and not npc.downed:
			remaining_guards += 1
	verify(remaining_guards == 0 and city.board.retired.is_empty(), "Retired guards leave once off-screen")
	print("ROB SUCCESS SECTION OK")
	# --- Destroy: real barrel chain, both bonuses, leave the scene -----------
	await answer(2)
	verify(city.board.active == destroy and destroy.state == &"destroy" and destroy.targets.size() == 2, "Destroy places two marked sedans")
	verify(destroy.targets.all(func(c: ToyCompact) -> bool: return c.data.marked and c in city.cars), "Targets are marked and joined to the vehicle list")
	# Inside the leave radius, outside the runner's spook radius and every blast.
	player.position = Vector2(3700, 2700)
	var barrels: Array[ExplosiveBarrel] = []
	for car: ToyCompact in destroy.targets:
		var barrel := ExplosiveBarrel.new()
		barrel.position = car.global_position + Vector2.RIGHT.rotated(car.rotation).orthogonal() * 45
		city.add_child(barrel)
		barrels.append(barrel)
	await frames(3)
	for barrel: ExplosiveBarrel in barrels:
		Events.crime.emit(&"harm", barrel.global_position, 1.0, 70.0, true)
		barrel.take_hit(8, Vector2.ZERO, false)
	verify(barrels.all(func(b: ExplosiveBarrel) -> bool: return b.player_responsible), "Player damage makes the barrels player-attributed")
	await sim(5.0)
	verify(destroy.targets.all(func(c: ToyCompact) -> bool: return c.disabled), "Player barrel blasts chain into both targets")
	verify(destroy.state == &"leave" and destroy.chained, "All wrecked through a chain: leave the scene")
	player.position = destroy.centroid + Vector2(destroy.DEFINITION.leave_radius + 100, 0)
	await sim(0.1)
	var destroy_cash := destroy.DEFINITION.cash_reward + destroy.DEFINITION.chain_bonus + destroy.DEFINITION.multi_bonus
	verify(destroy.state == &"complete" and city.score.money == rob_cash + destroy_cash and city.score.notoriety == 4, "Destroy pays $%d with chain + multi-wreck bonuses and +2 Notoriety" % destroy_cash)
	verify(city.board.attempted == 2 and city.board.completed == 2 and city.board.failed == 0, "Board counts two attempts, two completions")
	print("DESTROY SUCCESS SECTION OK")
	# --- Fresh district for failure paths -------------------------------------
	await reset_game()
	quiet()
	player.invulnerability = 1000
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	rob = city.rob
	destroy = city.destroy
	# Rob failure: timer.
	await answer(1)
	rob.elapsed = rob.DEFINITION.time_limit - 0.05
	await sim(0.2)
	verify(rob.state == &"failed" and city.board.failed == 1 and city.board.active == null, "Rob fails when its timer expires")
	verify(city.score.money == 0 and city.score.notoriety == 1, "Failed job pays nothing")
	verify(city.phones[0].available and city.phones[2].available and not city.phones[1].available, "Other jobs ring immediately; failed Rob waits its retry delay")
	await sim(rob.DEFINITION.retry_delay + 0.2)
	verify(rob.state == &"available" and city.phones[1].available, "Failed Rob rings again after the retry delay")
	# Rob failure: bag destroyed before pickup.
	await answer(1)
	player.position = rob.DEFINITION.store_position
	await sim(0.1)
	for guard: DistrictNPC in rob.guards: guard.ai_enabled = false
	var holding := 0
	while rob.state == &"robbing" and holding < 400:
		await frames(1)
		holding += 1
	player.position = rob.DEFINITION.store_position + Vector2(0, -200)
	var bag := rob.bag
	verify(rob.state == &"grab" and is_instance_valid(bag), "Bag is on the ground before pickup")
	var blast_barrel := ExplosiveBarrel.new()
	blast_barrel.position = bag.global_position + Vector2(40, -30)
	city.add_child(blast_barrel)
	await frames(2)
	blast_barrel.take_hit(8, Vector2.ZERO, false)
	await sim(1.2)
	verify(rob.state == &"failed" and rob.objective.contains("burned"), "A blast that burns the bag fails the robbery")
	verify(not is_instance_valid(bag) or bag.is_queued_for_deletion(), "Burned bag is cleaned up")
	verify(city.board.attempted == 2 and city.board.failed == 2 and city.board.completed == 0, "Counts track two failed Rob attempts")
	# Destroy failure: someone else wrecks a target (no player attribution).
	await answer(2)
	player.position = Vector2(4400, 1300)
	var victim := destroy.targets[0]
	var survivor := destroy.targets[1]
	victim.receive_blast(200, Vector2.ZERO, false, 424242)
	var waiting := 0
	while destroy.state == &"destroy" and waiting < 400:
		await frames(1)
		waiting += 1
	verify(victim.disabled and not victim.player_responsible, "Uncredited blast wrecks the target")
	verify(destroy.state == &"failed" and destroy.objective.contains("No credit") and city.score.money == 0, "Uncredited destruction fails Destroy without reward")
	verify(is_instance_valid(survivor) and not survivor.disabled and survivor in city.board.retired, "Intact target is retired on failure")
	await sim(1.2)
	verify(not is_instance_valid(survivor) or survivor.is_queued_for_deletion(), "Retired target leaves once off-screen")
	# A failed job never blocks another: Boost starts at once.
	verify(city.mission.accept(city.phones[0]) and city.board.active == city.mission, "Boost can start straight after a failure")
	city.mission.target.receive_blast(500, Vector2.ZERO, true, 1)
	await sim(4.0)
	verify(city.mission.state == &"failed" and city.board.active == null, "Boost target destruction fails through the shared backbone")
	await sim(destroy.DEFINITION.retry_delay)
	# Destroy failure: the runner escapes the district after being spooked.
	await answer(2)
	var runner := destroy.runner
	player.position = runner.global_position + Vector2(-250, -150)
	await sim(0.3)
	verify(destroy.running and runner.ai_controlled, "Getting close spooks the runner")
	var runner_start := runner.global_position
	destroy.exit_point = runner.global_position + Vector2(480, 0)
	destroy.follower.plan(runner.global_position, destroy.exit_point)
	player.position = Vector2(700, 600)
	await sim(4.0)
	verify(runner_start.distance_to(Vector2(destroy.exit_point)) > 300 and destroy.state == &"failed" and destroy.objective.contains("escaped"), "Runner drives away on the road and escaping fails Destroy")
	verify(not is_instance_valid(runner) or runner.is_queued_for_deletion(), "Escaped runner is removed")
	# Destroy failure: timer.
	await sim(destroy.DEFINITION.retry_delay + 0.2)
	await answer(2)
	player.position = Vector2(700, 600)
	destroy.elapsed = destroy.DEFINITION.time_limit - 0.05
	await sim(0.2)
	verify(destroy.state == &"failed" and destroy.objective.contains("Out of time"), "Destroy fails when its timer expires")
	verify(city.board.attempted == 6 and city.board.failed == 6 and city.board.completed == 0 and city.board.history.size() == 6, "Six attempts, six failures recorded in order")
	verify(city.score.money == 0 and city.score.missions == 0, "No reward leaked from any failure")
	print("C1 MISSIONS COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
