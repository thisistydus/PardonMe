# Goal C1 — One More Run

2026-09-27. Godot **4.7.stable.official.5b4e0cb0f**, Compatibility renderer. Open `project.godot`, press F5. Default scene is still `scenes/district.tscn`; the Goal A yard (`scenes/game.tscn`) is unchanged.

**Question for the human playtest:** does a complete, repeatable compressed day feel worth playing twice in a row? Nothing below claims it does. Automated checks prove the loop *works*; only play can tell whether it's *worth repeating*.

## What is actually playable

1. **A full compressed day.** The run opens at 06:00 and ends at the following 06:00 after 12 real minutes. The HUD clock (top right) shows fictional time, the period (MORNING / AFTERNOON / EVENING / NIGHT) and real time left until dawn. In the final real minute the clock turns red and pulses, a two-tone cue plays and the message bar reads "FINAL MINUTE".
2. **Three ringing payphones, three jobs.** The yard phone offers **BOOST**, the phone south of Receipt Row offers **ROB**, and the Warehouse Cut phone offers **DESTROY**. Only one job can be active; while it runs, every phone goes quiet. A failed job rings again after a short delay, and a completed job is retired for that day. Other phones keep ringing after a completion (in B.5, completing the Boost silenced everything).
3. **Street cash.** Pedestrians, officers and armed hostiles *you* kill can drop green cash bundles. Walk or drive over one to collect it; a "+$NN STREET" popup rises above you. Uncollected cash blinks and disappears after 90 s.
4. **Knife and shotgun.** Both sit in the yard pickup row beside the bat and pistol, and one of each is out in the district (civic plaza sidewalk; Warehouse Cut service road).
5. **Endings.** Death or dawn freezes play and opens the results screen. **R**, **Enter** (on the focused NEXT DAY button) or a click starts a clean next day in the same process.

## Controls

Unchanged from B.5: WASD move/drive · mouse aim · LMB attack · RMB throw · Q drop · E pick up / answer phone / enter / exit / confirm Boost delivery · Space handbrake · 1–4 radio, 5 off, C cycle · M map · F3 debug · F4 shake · F6 recovery · Esc pause · R restart. On the results screen, R or Enter starts the next day. Controller actions are defined in the Input Map; physical controllers remain untested.

## The run loop

`RunClock` (`scripts/district/run_clock.gd`) is the single source of fictional time. It is physics-stepped, so pause, hit-pause, death and tests all agree. Real elapsed seconds map linearly onto 1,440 fictional minutes starting at `dawn_hour`.

Interfaces for later systems (all on `game.clock`):

| Signal / method | Fires / returns |
| --- | --- |
| `run_started` | First physics tick of a run |
| `minute_changed(minute_of_day)` | Each new fictional minute |
| `hour_reached(hour)` | Each fictional hour crossed (not the opening hour) |
| `period_changed(period)` | Label change (MORNING → …) |
| `final_warning` | Once, when `final_warning_seconds` remain |
| `dawn` | Once, at `run_seconds` |
| `is_within(from_hour, until_hour)` | Offer-window test, wraps midnight; 0→24 = always |
| `time_text()`, `hour()`, `minute_of_day()`, `remaining()`, `progress()` | Queries |

`ToyRunManager.end_run(outcome)` is now idempotent. Only the first death or dawn ends a run; it emits `Events.run_ended(&"dawn" | &"died")`. `MissionBoard` records any active job as failed ("Died on the job" / "Dawn arrived mid-job").

**Results screen** (`district_hud.gd`) shows: outcome, cause of death, cash earned, notoriety, base score, dawn bonus, final score, jobs attempted/completed, peak Heat, survival time, clock reached, the street/job/bonus cash split, seed, and a per-job log with bonuses or failure reasons.

**Score formula (unchanged in principle, now shown line by line):**
`BASE = cash × notoriety` (notoriety is never below ×1); `FINAL = BASE + dawn bonus`, where the dawn bonus is `floor(BASE × 0.25)` if the player survived to dawn and 0 if they died. The 25% bonus comes from the Kickoff Pack §2, which the brief defers to; it is configurable, and setting it to 0 reproduces a plain cash × notoriety score. **Zero-value handling:** a run with $0 scores 0 regardless of notoriety, and the results screen explains this rather than hiding it. Zero or negative cash awards are refused by `add_cash()` and counted in `rejected_awards`. Notoriety is clamped to 1…`notoriety_cap` (6).

**Cause of death** is recorded only where the damage path identifies it reliably: "SHOT BY POLICE", "SHOT BY AN ARMED HOSTILE", "SHOT" (the yard's training shooter), "EXPLOSION", "EXPLOSION WHILE DRIVING", "STRUCK BY A <vehicle>". Only the shooter's *role* is known, not which individual fired.

**Restart** reloads the district scene, which discards time, cash, notoriety, Heat, jobs, guards, targets, cash pickups, weapon drops and HUD state. Autoload signal connections and node counts were checked to be stable across restarts (see tests).

Excluded as instructed: no lighting, `CanvasModulate`, time-of-day activity, time-specific jobs, shops or meta-progression.

## Mission backbone

| File | Role |
| --- | --- |
| `scripts/district/mission_definition.gd` | Shared data: id, title, kind label, phone, cash/notoriety reward, optional time limit, retry delay, offer window, reserved `faction_id` |
| `scripts/district/district_mission.gd` | Lifecycle: `accept → begin() → tick() → complete()/fail() → cleanup() → retry`; `abort()` at run end; bonuses; `destination()` / `world_markers()` for map and world presentation |
| `scripts/district/mission_board.gd` | Phone routing, the single active job, attempt/complete/fail counts, per-attempt history, reward issue into `DistrictScore`, and retiring mission actors once they are off-screen |

A job's reward is issued only by `MissionBoard.on_finished`, which is reached only through `complete()`, and `complete()` refuses a finished job. That is why double rewards can't happen, and the tests check it. `faction_id` is empty and unused: no faction names, UI, standing or behaviour exist.

**Adding a job** means writing a `MissionDefinition` subclass resource plus a `DistrictMission` subclass implementing `begin/tick/cleanup/destination/world_markers`, then registering it in `district_game.gd` with a phone index.

### Boost (preserved)

Behaviour, state names, delivery handoff, retry and messages are the same as in B.5. The reward now comes from `data/missions/first_boost.tres` (`cash_reward` 2500, `notoriety_reward` 1). Duplicate `boost_reward`/`boost_notoriety` fields were removed from `PressureConfig`, so there is one source of truth. `game.mission` still points at the Boost for the retained suites.

### Rob — "No Receipt Necessary" (`receipt_row_rob.tres`)

**Flow:**
1. **travel:** reach the Receipt Row storefront.
2. **robbing:** arriving within 230 units, on foot or driving, trips the alarm (a witnessed "robbery" crime) and spawns two armed guards, which reuse the existing hostile AI.
3. Stand on foot inside the counter zone for 3 s. Progress decays at half speed when you step out.
4. **grab:** the cash bag drops; walk over it.
5. **escape:** get outside the gold ring (950 units) *and* lose any positive police identification.
6. **complete.**

- **Reward:** $3,200 and +1 Notoriety. Bonuses: +$750 for escaping at Heat ≤ 1, and +$500 for finishing within 100 s of accepting.
- **Failure:** death, the 300 s timer, or a blast burning the bag before pickup. The bag-burn condition is real and tested, but it's situational: the bag is only on the ground briefly unless you walk away from it.
- **Cleanup:** the bag is removed, and living guards are retired and removed once off-screen.

### Destroy — "Paperwork Fire" (`warehouse_destroy.tres`)

On acceptance, two **marked sedans** (red paint, gold roof stripe) are parked near the Warehouse Cut, next to existing barrels. The spawn points shift to a nearby clear spot if blocked.

**Flow:**
1. **destroy:** wreck both marked sedans.
2. **The runner:** one of them bolts for the nearest district edge away from you when you get within 380 units or damage it. It drives the road graph via the new `RoadFollower`.
3. **leave:** once both are wrecked, get clear of the scene (650 units).
4. **complete.**

- **Reward:** $1,800 and +2 Notoriety. Bonuses: CHAIN REACTION (+$600) if any target was set off by another blast; MULTI-WRECK (+$400) if both die within 5 s.
- **Attribution:** existing rules only. Guns, rams, thrown weapons, player-lit barrels and chains all count. A target wrecked without player attribution (police crossfire, AI cruisers, an explosion nobody attributed to you) **fails** the job ("No credit, no pay").
- **Failure:** death, the 240 s timer, an uncredited wreck, or the runner reaching the district edge.
- **Runner edge cases:** a burning runner stops instead of fleeing on a lit fuse, and stealing the runner ends its escape attempt.
- **Cleanup:** intact targets are retired off-screen; wrecks remain as scenery.

### Future job extension points (not implemented; no placeholder jobs, phones or menu entries exist)

| Future job | Hook it would use |
| --- | --- |
| Hold the Block | `tick()` timer inside a zone, with `DistrictHeat.level` as pressure; `world_markers` "hold" ring already exists |
| Getaway | Rob's escape phase generalised: pickup NPCs, then `escape` ring + identity loss |
| Contract target | `spawn_citizen(..., "hostile")` + `Events.npc_killed(npc, by_player)` attribution |
| Repo | Boost with a different vehicle source/destination (`BoostDefinition` fields) |
| Method-specific elimination | `note_attacker` plus the killing source. Currently only *player vs non-player* is recorded, so a weapon/method id would need adding to the kill signal |
| Maintain a Heat level | `tick()` reading `game.heat.level` for a duration; `time_left()` drives the HUD timer |
| Time-windowed jobs | Set `available_from_hour/until_hour`. The board already re-checks on `hour_reached` |

## Cash

One authoritative interface: `DistrictScore.add_cash(amount, source)`. Street pickups (`&"street"`), job payouts (`&"mission"`) and bonuses (`&"bonus"`) all enter there once. C1 has no spending, so cash held equals cash earned.

`CashDirector` listens to `Events.npc_killed(npc, by_player)`. Each NPC remembers its *last attacker* via `note_attacker()`, which is called by melee, bullets/pellets, thrown weapons, vehicle impacts and blasts. A wall slam after your knockback still credits you. With `requires_player_kill` on (the default), deaths you didn't cause drop nothing. Practice dummies never drop cash; they respawn and would be a farm.

Values (`data/cash_config.tres`) are deliberately small next to job payouts:

| Role | Drop chance | Value |
| --- | ---: | ---: |
| Civilian | 55% | $15–60 |
| Police | 35% | $25–70 |
| Armed hostile / robbery guard | 100% | $120–220 |

That works out to roughly $20 per civilian on average; all 16 civilians together are worth about $330, and farming 100 officers yields about $1,650 — less than one Boost. **Bounds:** 90 s lifetime, a soft cap of 40 (oldest removed first), 34-unit collection radius on foot and 64 units in a vehicle. Restart clears everything.

## Weapons

| | Knife | Bat (existing) | Pistol (existing) | Shotgun |
| --- | --- | --- | --- | --- |
| Damage | 3 (one-hit on ordinary NPCs) | 3 | 3 | 4 per target per trigger pull |
| Reach / range | 56 | 86 | 1,680 | 540 (7 pellets, 28° spread) |
| Arc | 64° | 130° | — | — |
| Recovery / cadence | 0.17 s | 0.40 s | 0.22 s | 0.80 s |
| Knockback | 140 | 640 | 270 | 580 |
| Ammo (in the weapon) | — | — | 8 | 4 |
| Gunfire report | — | — | severity 1.5 / 700 | severity 2.0 / 950 |
| Throw | 3 dmg, fast | 3 dmg | 2 dmg | 3 dmg, heavy |

**Shotgun volley rule:** all pellets from one trigger pull share a `ShotVolley`. The first pellet to reach a body applies the weapon damage and knockback once; later pellets from that pull are absorbed by the same body. One pull can still hit several different targets. The rule applies to cars (16 health per pull, versus the pistol's 12), barrels (one pull lights one) and the player: an enemy volley wounds you once instead of killing you outright.

NPCs can technically fire any `WeaponData` through the shared `FirearmShot`, but **no NPC is issued a shotgun in C1**. Police and hostiles keep pistols.

The knife and shotgun have code-drawn held, pickup and thrown visuals, plus new synthesized "stab" and "shotgun" cues. Pickups now show their weapon title, and ammo for firearms.

## Limited readability pass

- **Heat:** four flame icons. Lit flames flicker and glow hotter per level; the word beside them (CLEAR / INVESTIGATING / PURSUIT / SEARCHING) keeps the state readable without colour.
- **Payphones:** a code-drawn booth (hood, housing, handset that rattles when ringing, coin box) with expanding ring arcs and an "E / BOOST|ROB|DESTROY" label.
- **Vehicles:** a `VehicleData.paint` palette. Compact olive, sedan blue, patrol dark with a white livery and a red/blue lightbar that flashes while police drive it; mission-marked sedans are red with a gold roof stripe. This replaces the old `title == "SEDAN"` tint check.
- **Objective card:** a panel with a job icon (car / cash bag / crosshair / handset), the job title, the objective and a countdown that turns red under 30 s.
- **World and minimap markers:** per job — gold rings, a hold-up progress ring, a red crosshair for Destroy targets, a dashed escape ring, a bag icon above the player while carrying, and a minimap crosshair per target plus the escape circle.
- **HUD top bar:** CASH × NOTORIETY = SCORE, strikes left, and the big clock.
- **Results screen:** stamped-paperwork panel in the existing cream / ink / gold / red palette.

**Still placeholders:** every NPC (code-drawn), the knife and shotgun art, the cash bundle, the bag, barrels, wrecks and explosions, the environment. Sedan and patrol cars are still the compact sprite with paint, not distinct silhouettes. All sounds are synthesized. Asset requests are in `Pardon_Me_Assets_Needed.md`.

## Configurable values

| Resource | Values |
| --- | --- |
| `data/run_tuning.tres` | `run_seconds` 720, `dawn_hour` 6, `final_warning_seconds` 60, `dawn_bonus_fraction` 0.25, `notoriety_cap` 6, period hours/names |
| Command line | `-- --run-seconds=N` (session only; the resource file is not edited), `-- --seed=N` (existing) |
| `data/missions/first_boost.tres` | reward, notoriety, retry delay, eligible cars, delivery radius/speed, phone |
| `data/missions/receipt_row_rob.tres` | reward, notoriety, time limit 300, retry 6, store point, alarm/zone radius, hold 3 s + decay, guard points, alarm severity/radius, escape radius, low-Heat bonus/threshold, quick bonus/time |
| `data/missions/warehouse_destroy.tres` | reward, notoriety 2, time limit 240, retry 6, target vehicle, positions/rotations, runner index, spook radius, exit points, escape distance, leave radius, chain/multi bonuses and window |
| `data/cash_config.tres` | per-role chance and range, player-kill requirement, lifetime, soft cap, collect radii |
| `data/weapons/knife.tres`, `shotgun.tres` | all table values above, plus `pellets`, `spread_degrees`, `recoil`, `noise_severity`, `noise_radius` (new `WeaponData` fields; pistol and bat defaults unchanged) |
| `data/vehicles/*.tres` | new `paint`, `marked` |

## Verification

All commands run from the project folder with `/Applications/Godot.app/Contents/MacOS/Godot`.

**Baseline before C1** (see `GOAL_C1_PLAN.md`): 14 of 15 retained suites passed (289 checks). `b5_escape` failed 2 of 4 on untouched B.5 code.

**After C1 — retained suites** (`--headless res://tests/<suite>.tscn`, logs `tests/c1_final_*.log`):

| Suite | Before C1 | After C1 |
| --- | ---: | ---: |
| acceptance | 36 | 36 |
| edge_cases | 14 | 14 |
| physics_revision | 33 | 33 |
| art_radio | 42 | 42 |
| district_layout | 21 | 21 |
| district_integration | 41 | 41 |
| district_combat | 22 | 22 |
| district_safety | 16 | 16 |
| district_drive | 3 | 3 |
| b5_weapons | 10 | 10 |
| b5_pressure | 10 | 10 |
| b5_response | 14 | 14 |
| b5_explosions | 12 | 12 |
| b5_delivery | 15 | 15 |
| b5_escape | 2 pass / 2 fail | 2 pass / 2 fail (same two checks, same cause) |
| **Total passing** | **291** | **291** |

Every retained suite has the same result before and after C1. Headless import is clean.

**New C1 suites:**

| Suite | Command | Result | Covers |
| --- | --- | --- | --- |
| `c1_run_loop` | `--headless res://tests/c1_run_loop.tscn` | 37 / 37 | Clock rate, 23:00 NIGHT mapping, wrap-around windows, configurable 8 s day, warning once, dawn once, clock stop, no double end, score arithmetic, results values, focus, restart state, no autoload-connection growth, stable node count, death mid-job with cause and zero-cash note, restart via button, a third run with a Boost to dawn (6,250) |
| `c1_missions` | `--headless res://tests/c1_missions.tscn` | 45 / 45 | Phone mapping, single active job, Rob success with both bonuses, decay, no double reward, guard retirement; Destroy success through real player-lit barrel chains with both bonuses and +2; Rob failure by timer and by burned bag; Destroy failure by uncredited wreck, by a driven runner escaping and by timer; Boost failure through the backbone; failures never block later jobs; counts and history |
| `c1_cash` | `--headless res://tests/c1_cash.tscn` | 20 / 20 | Drop on player melee kill (not instant cash), range, single collection, no duplicates, no drop for non-player kills, police and hostile tables via bullet and throw, vehicle collection radius, rejected awards, soft cap, lifetime, mission cash through the same interface, restart cleanup |
| `c1_weapons` | `--headless res://tests/c1_weapons.tscn` | 28 / 28 | Knife one-hit, light knockback, reach limit versus bat, fast recovery versus bat, throw/land/recover/drop; shotgun ammo, 7 pellets, one gunfire report, cadence, three spread targets, one volley into a car, range, barrel ignition and attribution, NPC kill attribution, empty click, empty throw, enemy volley wounds once, death while holding with the shooter named, clean restart |
| `c1_entry` | `--headless res://tests/c1_entry.tscn -- --run-seconds=5` | 5 / 5 | The real entry scene honours the command-line day length, an unattended day reaches dawn and results, and restart keeps the length |
| `c1_soak` | `--headless res://tests/c1_soak.tscn` | 8 / 8 | Two consecutive **full 720 s days** with live AI: day 1 idle, day 2 a live Rob with active guards, then hiding |
| `c1_visual` | `res://tests/c1_visual.tscn` (windowed) | 13 / 13 | Screenshots below |

**New checks: 156** (135 in the fast headless suites, 8 in the soak, 13 in the visual captures). Soak detail from `tests/c1_soak.log`:
- **Day 1:** dawn at clock 720.0 s (real 720.3 s); node count flat at 223.
- **Day 2:** live Rob against active guards, completed with both bonuses ($4,450); peak Heat 1; dawn at clock 720.0 s (real 724.0 s); node peak 226.

The soak ran on the build *before* the final cosmetic fixes (popup position, pickup placement, phone label width, Rob objective text, phone markers cleared at run end). Every fast suite above was re-run after those fixes.

**Live window:** the real entry scene was launched in a window with `-- --run-seconds=15` and screen-captured mid-run (15:34 AFTERNOON) and at dawn (results with the zero-cash explanation). Nobody pressed a key: this confirms the real presentation path, not play feel. The captures contained the desktop, so they were deleted rather than stored.

**Screenshots** (`screenshots/2026-09-27_PardonMe_C1_*.png`, captured from the running build with staged positions and real systems): `payphone_idle_hud`, `hud_heat_flames`, `knife_stab`, `shotgun_blast`, `rob_holdup`, `rob_bag`, `destroy_runner`, `vehicle_palettes`, `cash_pickups`, `final_minute_warning`, `results_died`, `results_dawn`. Every image was opened and checked. Problems it found and fixed: a cash popup overlapping the score line and later the results panel, pickups on top of the yard label and then touching a parked car, a clipped "E / DESTROY" phone label, and Rob text reading "950 units" (now "outside the gold ring on your map").

**Supplied-asset preservation:** all 15 supplied art, music, logo, mockup and design files match `docs/supplied_files_sha256.json` byte for byte. The only mismatches are the two authorised living docs and macOS `.DS_Store` files. Exact changed-file inventory: `docs/c1_changed_files.json`. `scenes/` and `project.godot` are unchanged.

## Status by evidence level

| Item | Implemented | Automated test | Live play | Notes |
| --- | :-: | :-: | :-: | --- |
| Compressed day, warning, dawn, results, restart | ✓ | ✓ | window observed, not played | Full-length days covered by the soak |
| Death → results with cause | ✓ | ✓ | — | |
| Mission backbone + Boost port | ✓ | ✓ (retained + new) | — | |
| Rob | ✓ | ✓ success + 2 failures | — | Balance unknown |
| Destroy (incl. runner) | ✓ | ✓ success + 3 failures | — | Runner route choice untested for feel |
| Street cash | ✓ | ✓ | — | |
| Knife / shotgun | ✓ | ✓ | — | Feel unproven |
| Readability pass | ✓ | screenshots | — | |
| Offer time windows, `faction_id` | scaffolded (data fields + clock test) | window test only | — | No job uses them |
| NPC shotgun use | path exists | enemy volley test | — | Deliberately not issued |
| Personal bests, favours, factions, day/night visuals, C2 vehicles | deferred | — | — | |

## Known limitations

- **No human has played C1.** The 12-minute length, reward values, guard lethality, runner speed, cash rates and shotgun strength are provisional.
- **One configuration per template.** A day offers at most three completions: Boost once, Rob once, Destroy once. Retries after failure are unlimited within the day. If 12 minutes feels empty after the three jobs, that's a content-volume finding, not a bug.
- **Phone-to-job mapping is fixed** (yard = Boost, Receipt Row = Rob, Warehouse = Destroy), so offers don't shuffle per run. The seed still varies the Boost target.
- **Rob:** guards reuse the plaza hostile's AI, and their spawn points are fixed. The escape requires losing *identification*, so a sustained pursuit can run out the 300 s timer.
- **Destroy:** only one runner. Its exit choice is a simple "farthest from you" heuristic, and it has no driver NPC (like police cruisers). It can get stuck on parked cars, reverse and retry; this is not traffic AI.
- **Cause of death** names only the shooter's role.
- **Cash:** no carried/secured split, banking or spending.
- **The escape check is environment-sensitive.** `b5_escape` still fails in this environment exactly as it did before C1 (see the plan).
- The retained 180 s weapon-drop cleanup and the new 90 s cash lifetime are separate systems.
- Exported builds, web export, physical controllers and a human endurance session remain unverified.

## C2 integration risks (motorcycle, rider ejection, police bikes, traffic, driver ejection)

1. **`ToyCompact` is the only vehicle class and a `CharacterBody2D`.** A motorcycle with rider ejection needs either a subclass or a `VehicleData`-driven variant: occupant exposure, a narrower footprint, and a sprite other than `SpriteArt.COMPACT`. Missions, cash and weapons don't hard-code the compact; they use `ToyCompact`/`VehicleData` generically, and Boost and Destroy select vehicles by data.
2. **Two road drivers now exist.** `PoliceCruiserBrain` has its own steering loop and `RoadFollower` is the reusable copy. C2 traffic should use `RoadFollower` and migrate the cruiser brain to it, rather than adding a third.
3. **Occupied-car theft currently teleports a hidden "seated" civilian out.** Real civilian drivers following roads will need a proper occupant model, which the cruiser deliberately avoided.
4. **Determinism.** Navigation occupancy refresh and some mission handoffs run in `_process` (real time), which is why `b5_escape` now fails on unchanged code. Traffic will add more moving obstacles and more `_process`-driven state. Move path/occupancy refresh to physics time before adding traffic.
5. **Vehicle-impact attribution** is `driver != null`. AI-driven civilian cars will correctly count as non-player, but a player riding a motorcycle that gets ejected must keep the attribution of the crash that ejected them.
6. **The spawn director and board retirement** both remove cars and NPCs off-screen. Traffic spawning needs one owner for vehicle lifetimes to avoid double frees (`game.cars` is edited by both today).

## Recommended human playtest questions

1. Play two full days back to back. Did you want to start a third? At what point in the first day did you know what you'd do differently in the second?
2. Is 12 minutes right? Were there dead stretches after the three jobs, or never enough time?
3. Rob: are two guards a fight or a formality? Is the 3-second hold readable while being shot at? Does "lose identification to escape" feel fair or tedious?
4. Destroy: did you find a chain reaction on your own? Is the runner catchable and exciting, or frustrating? Did an uncredited wreck ever fail you unfairly?
5. Cash: did you go out of your way for street cash? Did it ever beat doing a job? Did it tempt you into Heat you regretted?
6. Knife versus bat versus shotgun: does each have a reason to exist? Does the shotgun make melee irrelevant (a Bible warning sign)?
7. Is the Money × Notoriety arithmetic on the results screen understandable at a glance? Does the dawn bonus make surviving feel like the goal?
8. Did the Heat flames, objective card and markers ever hide or mislead gameplay state?

## Files

See `docs/c1_changed_files.json`: 23 files added, 27 modified, 0 removed, and 14 new test files (7 suites — c1_run_loop, c1_missions, c1_cash, c1_weapons, c1_entry, c1_soak, c1_visual — each a script plus its scene). The plan is `docs/GOAL_C1_PLAN.md`. The living documents received additive dated sections.
