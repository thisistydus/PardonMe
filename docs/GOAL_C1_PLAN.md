# Goal C1 — One More Run: plan and baseline

2026-09-27. Central question: does a complete, repeatable compressed day feel worth playing twice in a row?

## Audit before changes

Read README, the MVP Bible, Astra Kickoff Pack, Known Limitations, Assets Needed, the roadmap, and every `docs/` build log. Inspected the live implementations of Boost (`boost_manager.gd`, `boost_data.gd`, `first_boost.tres`), weapons (`weapon_data.gd`, `weapon_controller.gd`, `firearm_shot.gd`, `projectile.gd`, `thrown_weapon.gd`), NPC death and drops (`npc.gd`, `practice_target.gd`), score/Heat/HUD (`score_manager.gd`, `heat_manager.gd`, `district_hud.gd`, `hud.gd`), district time (`run_manager.gd` elapsed counter only — no fictional clock existed), vehicles (`compact.gd`, `vehicle_data.gd`) and police (`police_response.gd`, `cruiser_brain.gd`, `police_coordinator.gd`). The whole codebase was ~3,070 lines of GDScript; all of it was read.

Source checkpoint: `docs/checkpoints/2026-09-27_before_C1.zip` (142 files; SHA-256 `05745379…b48e2`). The PardonMe folder sits inside an accidental repository rooted at `~/Documents` with no commits, so no git operations were used.

## Baseline (Godot 4.7.stable.official.5b4e0cb0f, headless, untouched B.5 code)

Headless import: clean. Logs: `tests/c1_baseline_*.log`, `tests/c1_baseline_clean_*.log`.

| Suite | Result |
| --- | --- |
| acceptance | 36 / 36 |
| edge_cases | 14 / 14 |
| physics_revision | 33 / 33 |
| art_radio | 42 / 42 |
| district_layout | 21 / 21 |
| district_integration | 41 / 41 |
| district_combat | 22 / 22 |
| district_safety | 16 / 16 |
| district_drive | 3 / 3 |
| b5_weapons | 10 / 10 |
| b5_pressure | 10 / 10 |
| b5_response | 14 / 14 |
| b5_explosions | 12 / 12 |
| b5_delivery | 15 / 15 |
| **b5_escape** | **2 / 4 — fails on untouched B.5 code** |

**Pre-existing failure, not introduced by C1.** `b5_escape` fails "Maximum Heat clears…" and "Escaping removes the high-Heat roadblock" in three consecutive runs on the original files. Its scripted drive is bit-identical to the 2026-09-07 passing log (same end position, health 93, last-known position). Instrumentation showed the player parked only 19 units outside the 1,700-unit Heat-4 search circle; about 13 s into the 20 s cooldown a reinforcement officer walks into line of sight and legitimately re-identifies the player. Whether that happens depends on real-time-driven (`_process`) timing such as navigation occupancy refresh, so the test is environment-sensitive. It was left unmodified; weakening it would hide a real determinism issue (recorded as a C2 risk).

## Approach

Protect the brief's priority order: stability → timed run/results/restart → mission backbone + Rob/Destroy → cash → knife/shotgun → limited readability pass → extension points.

- **Clock:** a `RunClock` node owns fictional time (dawn 06:00 → next dawn), physics-stepped so pause, death and tests agree; `RunTuning` resource holds the 720 s default. `ToyRunManager.end_run(outcome)` becomes idempotent and emits `Events.run_ended`.
- **Missions:** smallest shared lifecycle (`DistrictMission`) plus a `MissionBoard` that owns offers, the single active job, counts, history and reward issue. Boost is ported onto it with every B.5 state name, method and message the retained tests use; `game.mission` still points at the Boost.
- **Rob/Destroy:** data resources + template nodes using existing geometry, hostile AI, blast and attribution systems. No interiors, no map changes.
- **Cash:** one authoritative `DistrictScore.add_cash()`; `CashDirector` rolls drops from an `Events.npc_killed` signal carrying last-attacker attribution.
- **Weapons:** knife and shotgun as `WeaponData` resources; shotgun pellets share a `ShotVolley` so a target is damaged once per trigger pull.
- **Visuals:** code-drawn treatments only (no image generation available in this session): Heat flames, payphone booth, vehicle paint/livery, objective card icons, world markers, results screen.

No phase approval was required by the brief. Stop after implementation and verification for human playtest.
