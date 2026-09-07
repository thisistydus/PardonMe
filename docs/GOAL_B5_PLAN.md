# Goal B.5 — Pressure and Payoff

2026-09-07. Human B+ feedback: approximately 40 minutes of successful joint stress testing. Before changes, audited source/resources/docs and reviewed B+ debug benchmark. Godot 4.7 baseline startup passed. Pre-refactor source checkpoint: checkpoints/2026-09-07_before_B5.zip and SHA-256 manifest. Original media stays untouched.

Preserve Player/WeaponController, ToyCompact handling and VehicleExplosion radial semantics. Add shared firearm emission using WeaponData; finite NPC magazines/drop-once ownership. Add a PressureConfig resource, a lightweight officer coordinator, a road graph and cruiser input adapter, and an owned roadblock response. Compose barrels with the existing blast path. Make Boost an explicit, short, restart-safe handoff. Use an isolated native RichTextLabel proof after researching the real add-on.

Sequence: existing regression suites → shared weapons → search/roles → cruisers/roadblock → barrels/chains → Boost handoff → text evaluation → rendered stress/acceptance/screenshots/documentation. No phase approval required.

Protected controls: WASD move/drive, mouse aim, LMB attack, RMB throw, Q drop, E interact/enter/exit, Space handbrake, R restart, Esc pause, F3 debug, F4 shake, M map, F6 safe recovery; 1–4 station, 5 Off, C cycle. Controller actions remain defined. E gains delivery confirmation when valid.
