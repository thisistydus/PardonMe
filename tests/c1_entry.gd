extends "res://tests/district_integration.gd"
## Run with `-- --run-seconds=5`: the real entry scene honours the command-line day length.
func start() -> void:
	game = load("res://scenes/district.tscn").instantiate()
	get_tree().root.add_child(game)
	get_tree().current_scene = game
	refresh_refs()
	await frames(5)
	verify("--run-seconds=5" in OS.get_cmdline_user_args() and city.clock.tuning.run_seconds == 5.0, "--run-seconds=5 shortens the day to 5 s")
	verify((load("res://data/run_tuning.tres") as RunTuning).run_seconds == 720.0, "Override leaves data/run_tuning.tres at 720 s")
	await sim(5.3)
	verify(city.run.ended and city.run.result == &"dawn", "Unattended default district reaches dawn")
	await frames(5)
	verify(city.hud.results.visible, "Results screen shown")
	await reset_game()
	verify(city.clock.tuning.run_seconds == 5.0 and not city.run.ended, "Restarted day keeps the command-line length")
	print("C1 ENTRY COMPLETE: %d checks, %d failures" % [checks, failures])
	await city.run.prepare_shutdown()
	get_tree().quit(1 if failures else 0)
