extends "res://tests/district_integration.gd"
## Two consecutive full-length default days (2 × 720 s real time) with live AI. Stability evidence,
## not a feel test: day 1 idles out of sight; day 2 robs the store with live guards, then hides.
var outcomes: Array[StringName] = []

func run_day(active: bool) -> void:
	refresh_refs()
	await frames(5)
	(player.get_node("Camera2D") as Camera2D).position_smoothing_enabled = false
	var nodes_start := get_tree().get_node_count()
	var began := Time.get_ticks_msec()
	if active:
		player.invulnerability = 1000
		player.position = city.layout.phones[1]
		await frames(2)
		await tap(&"interact")
		player.position = city.rob.DEFINITION.store_position
		while city.rob.state in [&"travel", &"robbing", &"grab"] and not city.run.ended:
			await frames(1)
		# Hide in the far south-west corner and let the city search, then give up.
		player.position = Vector2(250, 3380)
		player.invulnerability = 0
	else:
		player.position = Vector2(250, 3380)
	var peak_nodes := 0
	while not city.run.ended:
		await seconds(5.0)
		peak_nodes = maxi(peak_nodes, get_tree().get_node_count())
		# Heat clears; if the rob escape radius is satisfied the job completes on its own.
	var real := (Time.get_ticks_msec() - began) / 1000.0
	outcomes.append(city.run.result)
	print("SOAK DAY result=%s clock=%.1f real=%.1f nodes_start=%d peak=%d cash=%d jobs=%d/%d heat_peak=%d cause=%s" % [city.run.result, city.clock.elapsed, real, nodes_start, peak_nodes, city.score.money, city.board.completed, city.board.attempted, city.heat.highest, player.death_cause])
	verify(city.run.ended and city.clock.elapsed <= city.clock.tuning.run_seconds, "Full-length day %d ended (%s)" % [outcomes.size(), city.run.result])
	verify(peak_nodes < nodes_start + 400, "Node count stays bounded through a full day (%d → peak %d)" % [nodes_start, peak_nodes])
	await frames(10)
	verify(city.hud.results.visible, "Results screen opened after full day %d" % outcomes.size())

func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	await run_day(false)
	verify(outcomes[0] == &"dawn" and absf(city.clock.elapsed - 720.0) < 0.01, "Idle day 1 lasted the full default 720 s to dawn")
	await reset_game()
	await run_day(true)
	verify(city.board.attempted == 1, "Day 2 took a live job")
	print("C1 SOAK COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
