extends "res://tests/district_integration.gd"
## Goal C1: compressed day, final warning, dawn/death endings, results accuracy and clean restarts.
var warnings: int = 0
var dawns: int = 0
var ended_events: Array[StringName] = []
var hours: Array[int] = []

func boot() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(10)
	quiet()
	player.invulnerability = 0

func watch_clock() -> void:
	warnings = 0
	dawns = 0
	hours.clear()
	city.clock.final_warning.connect(func() -> void: warnings += 1)
	city.clock.dawn.connect(func() -> void: dawns += 1)
	city.clock.hour_reached.connect(func(hour: int) -> void: hours.append(hour))

func restart_clean() -> void:
	await reset_game()
	quiet()

func start() -> void:
	Events.run_ended.connect(func(outcome: StringName) -> void: ended_events.append(outcome))
	await boot()
	var tuning := load("res://data/run_tuning.tres") as RunTuning
	verify(city.clock.tuning.run_seconds == tuning.run_seconds and tuning.run_seconds == 720.0, "Run length comes from data/run_tuning.tres (default 720 s = 12 min)")
	verify(city.clock.tuning != tuning, "Run duplicates tuning so command-line/test overrides never edit the shared resource")
	verify(city.clock.time_text().begins_with("06:0") and city.clock.period == "MORNING", "Run opens at dawn, 06:00, MORNING")
	var before := city.clock.minute_of_day()
	await sim(3.0)
	var advanced := city.clock.minute_of_day() - before
	verify(advanced >= 5 and advanced <= 7, "12-minute day advances two fictional minutes per real second (%d in 3 s)" % advanced)
	verify(absf(city.clock.elapsed - 3.0 - 10.0 / 60.0) < 0.2, "Clock counts simulated physics time")
	# Midnight-wrapping availability windows are data-ready.
	city.clock.elapsed = city.clock.tuning.run_seconds * (17.0 / 24.0)
	city.clock.publish()
	verify(city.clock.time_text() == "23:00" and city.clock.period == "NIGHT", "Seventeen fictional hours after dawn reads 23:00 NIGHT")
	verify(city.clock.is_within(22, 2) and not city.clock.is_within(6, 12) and city.clock.is_within(0, 24), "Availability windows handle wrap-around and whole-day offers")
	city.clock.elapsed = 3.0
	city.clock.publish()
	# Configurable short day: warning and dawn fire exactly once.
	watch_clock()
	city.clock.tuning.run_seconds = 8.0
	city.clock.tuning.final_warning_seconds = 3.0
	city.clock.elapsed = 1.0
	city.clock.last_hour = -1
	city.clock.publish()
	verify(hours.is_empty(), "Re-basing the clock does not report a crossed hour threshold")
	city.score.add_cash(1000, &"street")
	city.score.add_notoriety(2)
	await sim(3.2)
	verify(warnings == 0 and not city.run.ended, "No final warning before the last configured seconds")
	await sim(1.2)
	verify(warnings == 1, "Final warning fires when the configured final window opens")
	verify(hours.size() >= 10, "Hour thresholds are reported as the day compresses (%d)" % hours.size())
	await sim(1.0)
	verify(warnings == 1, "Final warning fires only once")
	await sim(3.0)
	verify(dawns == 1 and city.run.ended and city.run.result == &"dawn", "Configured 8-second day ends at dawn once")
	verify(get_tree().paused and ended_events == [&"dawn"], "Dawn pauses play and reports one run_ended(dawn)")
	var stopped := city.clock.elapsed
	await seconds(0.3)
	verify(city.clock.elapsed == stopped and stopped == 8.0, "Clock stops at dawn")
	city.run.end_run(&"died")
	player.die("TEST")
	verify(city.run.result == &"dawn" and ended_events.size() == 1, "A later death cannot end the run a second time")
	await frames(2)
	var numbers := city.score.breakdown(true)
	verify(numbers.base == 3000 and numbers.dawn_bonus == 750 and numbers.final == 3750, "Score: $1000 × 3 = 3000, +25% dawn bonus = 3750")
	verify(city.hud.results.visible and city.hud.results_title.text.begins_with("DAWN"), "Results screen opens on dawn")
	verify(city.hud.results_values.text.contains("3750") and city.hud.results_values.text.contains("$1000") and city.hud.results_values.text.contains("×3"), "Results show cash, notoriety and final score")
	verify(city.hud.results_right_values.text.contains("0:08") and city.hud.results_right_values.text.contains("06:00"), "Results show survival time and the dawn clock")
	verify(not city.hud.panel.visible and city.hud.next_day.has_focus(), "Pause panel stays hidden; NEXT DAY has focus for one-input restart")
	var connections := Events.run_ended.get_connections().size()
	var kill_connections := Events.npc_killed.get_connections().size()
	var nodes_first := get_tree().get_node_count()
	# Restart with R from the results screen.
	await restart_clean()
	await frames(4)
	verify(not get_tree().paused and not city.run.ended and city.clock.elapsed < 0.3, "R from results starts a fresh, unpaused day")
	verify(city.score.money == 0 and city.score.notoriety == 1 and city.heat.level == 0 and city.board.attempted == 0, "Restart clears cash, notoriety, Heat and job counts")
	verify(get_tree().get_nodes_in_group("cash_pickups").is_empty() and not city.hud.results.visible, "Restart clears pickups and hides results")
	verify(Events.run_ended.get_connections().size() == connections and Events.npc_killed.get_connections().size() == kill_connections, "Restart does not accumulate autoload signal connections")
	verify(absi(get_tree().get_node_count() - nodes_first) < 40, "Scene node count is stable across restart (%d → %d)" % [nodes_first, get_tree().get_node_count()])
	# Second run: die mid-job, results name the cause.
	ended_events.clear()
	player.position = city.layout.phones[0]
	await tap(&"interact")
	verify(city.board.active == city.mission and city.board.attempted == 1, "Second run can accept a job")
	player.invulnerability = 0
	player.take_hit(1, Vector2.RIGHT * 100, true, "SHOT BY POLICE")
	player.invulnerability = 0
	player.take_hit(1, Vector2.RIGHT * 100, true, "SHOT BY POLICE")
	await frames(3)
	verify(not player.alive and city.run.ended and city.run.result == &"died" and ended_events == [&"died"], "Second strike kills and ends the run once")
	verify(city.board.history.back().outcome == &"failed" and city.board.completed == 0 and city.mission.state == &"failed", "Job active at death is recorded as failed")
	verify(city.hud.results.visible and city.hud.results_title.text == "PERMISSION EXPIRED" and city.hud.results_subtitle.text.contains("SHOT BY POLICE"), "Death results show the cause")
	verify(city.hud.results_values.text.contains("(died)") and city.score.breakdown(false).dawn_bonus == 0, "Death gets no dawn bonus")
	verify(city.hud.results_log.text.contains("No cash earned"), "Zero-cash run explains the zero score instead of hiding it")
	var dead_clock := city.clock.elapsed
	await seconds(0.3)
	verify(city.clock.elapsed == dead_clock, "Clock stops after death")
	# One-input restart through the focused button (ui_accept) as well as R.
	city.hud.next_day.emit_signal("pressed")
	await frames(6)
	refresh_refs()
	quiet()
	await frames(3)
	verify(player.alive and not city.run.ended and city.mission.state == &"available" and city.clock.elapsed < 0.3, "NEXT DAY button restarts cleanly")
	# Third consecutive run completes a job and reaches dawn with the correct result.
	city.clock.tuning.run_seconds = 30.0
	player.position = city.layout.phones[0]
	await tap(&"interact")
	var boost := city.mission.target
	player.position = boost.nearest_door(boost.position + Vector2(0, 80))
	await frames(3)
	await tap(&"interact")
	boost.global_position = city.layout.garage
	boost.speed = 0
	await frames(5)
	await tap(&"interact")
	await sim(0.8)
	verify(city.board.completed == 1 and city.score.money == 2500 and city.score.notoriety == 2, "Boost completes through the mission board in a later run")
	city.clock.elapsed = 29.5
	await sim(0.8)
	verify(city.run.result == &"dawn" and city.score.breakdown(true).final == 6250, "Dawn after a Boost: 2500 × 2 = 5000 + 1250 = 6250")
	verify(city.hud.results_log.text.contains("BOOST") and city.hud.results_log.text.contains("DONE"), "Results log lists the completed job")
	print("C1 RUN LOOP COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
