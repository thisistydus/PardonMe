# Goal B.5 — Pressure and Payoff

2026-09-07. Open `project.godot` with Godot **4.7 stable**, F5. Default scene remains `scenes/district.tscn`; the original yard remains available. This is the B.5 pressure/weapon/explosion/delivery iteration, not the timed-run milestone. Tydus and Nathan's approximately 40-minute successful B+ playtest is human baseline evidence, not a B.5 endurance claim.

## What changed

Shared police/player pistol emission and finite magazines; heat-scaled searches; five coordinated officer roles; road-following cruiser response; one authored roadblock per escalation; six deliberately placed barrels; shared explosion attribution/chain reporting; explicit Boost surrender and removal; native text proof; expanded debug/minimap; runtime screenshots and focused tests. No supplied art or music was regenerated or changed.

The original compact acceleration, steering, handbrake, damage thresholds, melee timing and pistol cooldown values are retained. Car collision now also recognizes the on-foot player and transfers impact damage to other vehicles/barrels. A stress test exposed ordinary police walking into cars triggering the old knockback wall-kill rule; that rule now applies only while stunned/airborne. Existing launch and wall-impact tests still pass.

## Exact controls

| Action | Keyboard/mouse | Controller action |
| --- | --- | --- |
| Move | WASD | Left stick |
| Aim | Mouse | Right stick |
| Attack | Left mouse | Right trigger |
| Throw held weapon | Right mouse | X / west face |
| Drop gently | Q | Left-stick click |
| Pick up / phone / enter / exit | E | A / south face |
| Confirm valid Boost delivery | E | Same interaction action |
| Drive | W accelerate; S brake/reverse; A/D steer | Left stick |
| Handbrake | Space | B / east face |
| Radio | 1 Anvil; 2 Backspin; 3 K-Buck; 4 Pulse; 5 Off | C / right shoulder cycles |
| Enlarged map | M | No dedicated binding yet |
| Debug | F3 | Back/select |
| Camera shake | F4 | Left shoulder |
| Safe local recovery | F6; stopped, Heat 0, usable car | No dedicated binding yet |
| Restart | R | Y / north face |
| Pause | Esc | Start |

Radio number keys also accept the numeric keypad. Radio logos/music are vehicle-only, with independent randomized initial broadcast offsets and station time continuing virtually between selections. Physical controller hardware remains untested.

## Police and tuning

Open `data/pressure_config.tres` in the Inspector. Its `PressureConfig` script contains readable defaults. Existing WeaponData and VehicleData resources remain authoritative for weapon and handling properties.

| Heat | Radius (world units) | Unseen time outside area | Foot officer cap | Reinforcement interval |
| ---: | ---: | ---: | ---: | ---: |
| 0 | 0 | 0 | 2 | 5 s |
| 1 | 380 | 6 s | 3 | 5 s |
| 2 | 720 | 10 s | 8 | 3 s |
| 3 | 1150 | 15 s | 14 | 2 s |
| 4 | 1700 | 20 s | 22 | 1.5 s |

Search begins after 1.2 seconds unseen. Escape timing starts after a LOS break and leaving the authoritative circle. Sight or legitimate reports update last-known position; hidden movement does not. A small map inside a large search area is tinted red; M shows the whole circle. Vehicle changes do not yet disguise identity.

- **Pursuer:** direct viable path to observed suspect, limited to a share of the roster.
- **Interceptor:** periodically selects a road intersection near a bounded prediction from observed velocity (1.3 seconds, maximum 500 units); prediction stops being refreshed when sight is stale.
- **Search:** distributed sectors around last-known position, with slowly changing depth.
- **Containment:** perimeter/intersection assignment; nearby detection closes into pursuit.
- **Tactical:** Heat 4 only; maintains a different engagement distance. Same health and pistol, no new shotgun.

Role proportions use editable repeated-name cycles per Heat. Coordinator interval 1.2 s; paths refresh independently at approximately 0.8–1.05 s. Officers vary within 195–225 movement speed, 0.5–0.85 s reaction and 280–350 engagement distance. Local separation limits stacking. F3 shows role/state/ammo over each nearby officer, assigned search/intercept/containment destinations and response summaries. These are lightweight assignments, not sophisticated traffic prediction or squad tactics.

## Honest weapon economy

Player and city NPCs call the same `FirearmShot` using WeaponData damage, force, projectile speed (1050), range (1680), sound and magazine capacity (8). Player cooldown remains 0.22 s. NPCs deliberately aim, telegraph and wait approximately 1.7–2.1 seconds between shots; this is firing discipline above the same weapon minimum cooldown, not different ballistics. Hostile timing remains 1.8 s. NPC aim locks during its warning; there is no hidden damage or bullet-speed advantage.

NPCs start with at most one magazine (configurable fraction of capacity), never reload or replenish automatically, and drop exactly one pistol with the remaining rounds when killed. Empty drops stay empty and throwable. Repeated lethal hits do not duplicate drops; despawn creates no drop. Pickups become eligible for cleanup only above a **soft cap of 64**, older than **180 seconds**, farther than **1800 units** and off-screen. Nearby fighting resources are preserved; the cap can be exceeded locally. Spent officers still move/search but stop shooting. This finite-ammo behavior needs human pressure tuning. The original stationary yard shooter remains an explicitly separate infinite-ammo training fixture.

## Cruisers and roadblock

Heat 3 enables up to two responding patrol compacts, with a 12-second reinforcement interval. Spawns use clear authored road-access points outside the expanded camera and beyond 800 units. A small road graph feeds throttle/steer/brake inputs into existing car handling. Drivers use dispatch last-known position plus their own bounded LOS observations. Slow corners, periodic replanning and a reverse maneuver provide readable, imperfect pursuit. They can get delayed by parked cars and tight congestion; this is not a traffic simulator.

Low Heat or a damage fuse makes a cruiser abandoned; an abandoned or sufficiently stopped cruiser can be stolen, triggering the patrol theft alarm. Exploded wrecks remain unavailable. Officers physically dismounting from AI cruisers was optional and is **deferred** to avoid introducing another occupant state machine; cruiser drivers are represented by the control adapter. Existing occupied civilian-car theft still ejects its owner.

Heat 4 activates one two-car roadblock at one of three horizontal-road anchors: (3500,600), (1600,1800), (3500,3000). Up to two officers join within the shared cap. The parked cars are the barriers; no separate barrier asset was needed. They can be stolen or destroyed, and a side bypass remains. A latch prevents repeated spawning while Heat stays high. At Heat 1 or lower, owned cars/officers/marker are removed; a car already stolen by the player is retained as player property. Discovery/range restrict map markers.

## Barrels and shared blasts

Six barrels occupy a plaza maintenance cluster, an alley, warehouse parking and a southern roadblock approach. They are procedural red/gold props. Health 8, bullet multiplier 2, radius 220, lethal player core 65, maximum object damage 150, maximum force 1250 and base fuse 0.65 s are centralized. Melee, throws, bullets, cars and other blasts all damage them.

Vehicles retain their existing 190-unit blast and three-second warning. Both use `receive_blast` plus the existing radial explosion scene/script, cover checks, impact and audio. Chained detonations add 0.1–0.35 s of variation; fuses never restart on repeated damage. Attribution propagates from the initiating player damage. Witnessed player-caused blasts create Heat. A chain of three or more attributed objects reports **one debug feat**, without silently adding a new Notoriety economy. Explosions apply damage once, effects expire, and barrels do not respawn until restart. Healthy separated cars may only be damaged; damaged cars make reliable chains. No spreading fire.

## Boost delivery

Only the marked target, stopped inside the garage with no active destruction fuse, shows **E — DELIVER VEHICLE**. Confirmation validates an exit, relinquishes the car, places the player at a clear exterior apron point and locks control for 0.65 seconds while the vehicle fades. The car becomes unavailable immediately, is removed along with its collision body, clears mission markers and grants one reward: $2500 and +1 Notoriety by default. Score becomes 5000 at ×2. Player resumes on foot; free play continues. No automatic delivery, retained car or recovery exploit.

Wrong cars, leaving before confirmation, manual exit and destruction before confirmation do not reward. Destroying the target still reopens phones after four seconds and retires that target. Restart discards a pending transaction. One completed Boost per run remains the content limit.

## Text and licensing

`scenes/text_proof.tscn` demonstrates native RichTextLabel color, font size, inline original station logo and typewriter reveal. It is isolated from the HUD. See `B5_TEXT_EVALUATION.md` for official source links and compatibility assessment. Typewriter Label 1.0.1 (Pigno/Pignomaster, MIT) was evaluated but **not incorporated**, modified or exported. Native APIs cover the current need; no dependency or Scribble port was added.

## Verification and benchmarks

Pre-change baseline: 228 checks across nine suites. Retained logs distinguish failed development attempts from selected passing evidence. Focused B.5 suites cover finite magazines, drop ownership/cleanup, radius/duration/privacy, 20-officer assignments, cruiser response, roadblock cleanup, barrel/vehicle chains, explicit handoff and all listed delivery edge cases. `tests/b5_escape.gd` drove a real four-waypoint Heat-4 escape with all responses enabled, surviving at 93 vehicle health, then cleared Heat and removed the roadblock.

Physics fixtures now wait for simulated time rather than wall time under parallel CPU load, and the observer is placed outside the test car's sweep after adding on-foot-player collision. Those corrections do not weaken gameplay assertions. Complete final evidence and performance are in `b5_verification.json` and `b5_performance.json` once verification finishes.

Actual runtime PNGs are under `screenshots/2026-09-07_PardonMe_B5_*.png`: on-foot pursuit, expanded search, mixed roles, maximum-Heat minimap, cruiser pursuit, roadblock, drop and pickup, barrel/vehicle chain, Boost confirmation and removal, and stress/debug. Scenes are deliberately staged using real runtime systems; no generated illustrative substitutes. Stress uses a protected observer car to keep the renderer, radio and AI active through the full measurement. This is a short local Apple M2 Compatibility-renderer sample, not a human endurance, packaged-desktop or web-export certification.

## Remaining needs and next human test

Final officer/tactical/civilian animation, a distinct cruiser silhouette, authored barrel and wreck/explosion art, siren/Foley/mix/volume controls and production city textures remain needed. Existing generated sprites and supplied radio assets stay in use. No Rob/Destroy missions, full dawn timer/results, records, disguise, traffic, reloads, new firearms or dialogue system were added.

Test a pistol-to-empty-throw-to-police-pickup loop; observe whether role changes are readable; escape Heat 4 using alleys and a car; bypass or steal through a roadblock; lure police into damaged-car/barrel chains; deliver under pressure and try to keep/recover the car; restart mid-fade. Report camping/stacking, stuck cruisers, too-easy ammo exhaustion and unclear map boundaries.

**Most valuable next milestone:** Tydus and Nathan's human B.5 pursuit/weapon-economy balance pass, before adding the twelve-minute score run or broader missions.

## Files

Exact created/modified source, test, scene and resource paths are listed in `b5_changed_files.json`. Documentation adds this report, the plan, text evaluation, verification/performance/preservation reports and a source checkpoint ZIP/manifest; the two living production documents and build checkpoint/status receive additive updates. Generated `.uid`/`.import` metadata is engine-owned. No Git push or export is claimed.
