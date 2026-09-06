# PARDON ME — First Playable District / Goal B+

Build date: **2026-09-06**. Godot **4.7.stable.official.5b4e0cb0f**, Compatibility renderer, 1280×720 scalable canvas. This is the first reactive district prototype, not the full twelve-minute jam run.

## Run

Open `project.godot` with `/Applications/Godot.app` and press F5. The district entry is `scenes/district.tscn`; `scenes/game.tscn` preserves the original Goal A yard and remains the fixture for its regression suites.

From this project directory:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path . res://scenes/district.tscn
```

## What is implemented

A 4800×3600 handcrafted district has three long north/south and east/west roads, a tighter secondary street, two pedestrian shortcuts with visible car-only gates, distinct block roof colors, a plaza, parking, marked storefront, delivery garage, three payphones, visible outer barriers and authored police response points. The municipal test area retains three respawning practice dummies and bat/pistol pickups.

Seven enterable vehicles reuse the Goal A handling model: four ordinary compacts, two sedan variants and one marked patrol compact. Sedans use different acceleration/steering/durability data and a blue tint of the existing art. One parked compact has an owner who is ejected and panics when it is stolen. The patrol compact reports a theft alarm. It is a visual/data variant, not an AI-driven police cruiser. Parked cars and wrecks obstruct movement; navigation updates their occupancy once per second. F6 can move a stopped vehicle to a clear nearby road while Heat is zero, preserving its damage. Exploding or wrecked cars cannot use recovery. Camera zoom eases out while driving.

Sixteen civilians (including the seated owner), one armed hostile and two ambient officers populate authored areas. Civilians wander, alert, panic and flee. The hostile has a suspicion interval, pursuit and telegraphed pistol shots with pauses. Existing fists, bat, pistol, throws, car launches, wounded/death states and warned explosions apply to city NPCs. NPC artwork is code-drawn. Bodies have no gameplay respawn; off-screen bodies older than 25 seconds can be cleaned up. R restores the population.

Heat has levels 0–4, independent of scoring. Witnesses and audible reports create a last-reported crime location; direct police sight can identify the player. An isolated victim is not counted as an additional witness to their own quiet assault. NPC gunfire does not falsely count as player crime. A patrol-car theft alarm reports the car's location without automatically identifying a remote suspect. Foot police investigate, alert, pursue, search and return. The response cap rises to eight officers at Heat 4, with faster reinforcement timing. Reinforcements use authored points outside an expanded camera rectangle and at least 800 world units away. Break line of sight, leave the displayed search radius and remain outside/unseen for eight seconds to clear Heat.

A north-up minimap shows simplified roads/buildings, player position/facing and vehicle marker, available phones, garage, active objective and police search perimeter. Police markers appear only for locally visible officers or units participating in pursuit/search. Hostiles are not globally exposed. M enlarges the map; an off-map objective is clamped to its edge. World-space gold rings mark the Boost target/delivery point.

One data-driven Boost configuration selects a parked eligible vehicle using the retained seed. Answer a phone, enter the marked car and stop it inside the east garage's gold zone to earn **$2500 and one Notoriety tier: $2500 ×2 =5000**. Only one job is active and one successful job completes per run. Destroying its target fails the job, then reopens phones after four seconds with that target retired. Completing a job retires all offers for this prototype run; R allows another attempt. No payout from civilian harm or Heat farming.

The HUD shows Money × Notoriety, elapsed district time, condition, Heat/search state, mission, equipment/ammo, vehicle condition, radio and minimap. Death/pause panels show current score, completed missions, peak Heat and seed. R restarts within the same process.

## Exact controls

| Action | Keyboard / mouse | Existing controller binding |
| --- | --- | --- |
| Move / steer | WASD | Left stick |
| Independent aim | Mouse | Right stick |
| Attack held weapon / fists | Left click, once per attack | Right trigger |
| Throw held weapon | Right click | X / left face button |
| Drop gently | Q | Left-stick click |
| Pickup, phone, enter/exit | E | A / bottom face button |
| Accelerate / brake-reverse | W / S | Left stick up / down |
| Handbrake | Space | B / right face button |
| Radio | 1 Anvil, 2 Backspin, 3 K-Buck, 4 Pulse, 5 Off | C / right shoulder cycles |
| Enlarge map | M | No dedicated binding yet |
| Recover nearby stopped car (Heat 0 only) | F6 | No dedicated binding yet |
| Debug | F3 | Back / Select |
| Camera shake | F4 | Left shoulder |
| Pause | Esc | Start |
| Restart district | R | Y / top face button |

Mac function keys may require Fn. Both number row and numeric keypad select radio. All four supplied logos/tracks, independent randomized broadcast starts, looping and vehicle-only playback remain intact. The current station card stays visible in the car; exiting hides/stops it. Pause freezes broadcasts. Controller actions are defined; physical controller hardware remains untested. No reload or inventory; the pistol has eight rounds and can be thrown when empty.

## Verification and limits of evidence

- Goal A regression: **36 acceptance +14 edge +33 physics +42 radio =125 checks passed** in `tests/district_goal_a_*.log`. The final radio rerun is separately recorded. These exercise movement, aiming, melee, ammo, throws, launch/momentum, collision damage, warned explosions, exit safety, wounds/death, pause/restart and radio audio samples.
- District layout: **21 checks** for population-independent geometry, seven vehicle entry/exits, sedan data, connected paths, full-speed road driving and car-only gate/foot passage.
- District integration: **41 checks passed**, including an isolated-victim reporting check. Covers witnessed/unknown crime, panic/flee, Heat 2 pursuit/search/escape, off-screen spawning, Boost success/reward/failure/retry, radio ownership, recovery, debug/map and restart.
- City combat: **22 checks** for civilian/hostile/police responses to empty pistol throws, bat, firearm and car impacts; deliberate pistol-plus-bat vehicle destruction, clustered warned explosion, hostile LOS/suspicion/telegraph, two-strike death and restart.
- Safety: **16 checks** for occupied/patrol theft, unknown-suspect investigation, map privacy, NPC crime attribution, all Heat thresholds, actual actor travel around building corners and two additional restarts.
- Driven Boost: **3 checks**. Actual Input Map driving followed six road waypoints from the parked marked compact to the garage, approximately 3352 world units, health100 at delivery and score5000. Only player placement at the starting phone/door was staged; the mission car was not teleported during this driving test. Population decisions were disabled to isolate road/handling verification.
- Graphical OpenGL run saved on-foot, driving/radio, enlarged-map and debug images in `screenshots/2026-09-06_PardonMe_Bplus_*.png`. Inspected their information hierarchy and map proportions. The short active-population load is recorded in `tests/district_visual_verified.log`; **120 FPS**, median frame **7.82 ms**, p95 **12.97 ms**, 29 NPC nodes after a ten-second run with active police projectiles, radio, debug/minimap and a warned vehicle explosion. This is an observation on Apple M2, not an export benchmark or long soak.
- Early failures are retained in their original logs: player exit incorrectly inherited the car-only gate layer (fixed and verified); a combat fixture snapped20 pixels off the pistol's line (fixture corrected); the initial Goal A throw test failed twice before an instrumented unchanged-code run passed. Final full Goal A suites passed, but the initial timing sensitivity is not claimed to have a proven root cause.

The final verified gameplay total is **228 checks** (125 preserved Goal A +21 layout +41 integration +22 city combat +16 safety +3 driven delivery), plus graphical capture/load checks. Latest car-combat log: `tests/district_weapon_car_fixed.log`. Audio shutdown diagnostics are retained (`district_drive_verbose_stdout.log`); the clean verification is `district_drive_shutdown_fixed.log`. Quit now stops audio and waits 150 ms for mixer release before exiting.

Final suite logs use `tests/district_final_{layout,integration,combat,safety,drive,radio}.log`. Check those for final counts/results; failure logs are retained and must not be mistaken for current passing evidence. No new ten-minute endurance run is claimed.

## Created and modified files

Added `scenes/district.tscn`; `data/vehicles/sedan.tres`, `patrol.tres`; `data/missions/first_boost.tres`; `tools/configure_district.gd`.

Added `scripts/district/`: composition (`district_game.gd`), geometry (`layout.gd`), navigation (`navigation.gd`), NPC decisions (`npc.gd`), crime/Heat (`heat_manager.gd`), spawning (`spawn_director.gd`), recovery (`vehicle_recovery.gd`), mission data/logic (`boost_data.gd`, `boost_manager.gd`), scoring (`score_manager.gd`), phone interaction (`payphone.gd`), marker component (`map_marker.gd`), minimap (`minimap.gd`), world objective presentation (`wayfinding.gd`) and HUD (`district_hud.gd`).

Shared changes: `player.gd` chooses nearest valid vehicle and handles nearby phone interactions; `compact.gd` uses car-only gates, ownership presentation/events and damage attribution; `vehicle_data.gd` exposes patrol status; `projectile.gd`, `weapon_controller.gd`, `thrown_weapon.gd`, `vehicle_explosion.gd` report player-caused crimes without changing attack tuning; `practice_target.gd` labels its shots as non-player; `events.gd` adds crime/phone/mission signals; `feedback.gd` adds synthesized civic/mission cues; `radio_manager.gd`, `run_manager.gd` and `hud.gd` release audio before Quit; `project.godot` adds M/F6 actions and the district startup.

Added six district test scripts/scenes plus logs, benchmark images and documentation. The shared test harness now retains failure exit codes rather than printing a misleading successful completion after an assertion. Exact inventory and supplied-file hashes are recorded in `docs/created_files.txt` and `asset_preservation_report.json`.

## Honest limitations and omitted optional systems

- Police pursue on foot only. Heat 3/4 scale officer counts and response rate; no vehicle pursuit, roadblocks or squad tactics. These optional systems were omitted to preserve stable driving and focus on witnessed pursuit/escape.
- No civilian driving simulation, schedules or interiors. Parked vehicles are CharacterBody2D obstacles, not a full rigid-body traffic model. Sedan/patrol appearance reuses the existing compact texture.
- One Boost configuration, one completed job per run. Storefront is a marked future interaction location; no robbery logic. No full mission pool, spending, banking, personal-best save, day/dawn clock or progression.
- Changing cars preserves radio station ownership but does not clear police identification. Escape still requires LOS/radius/cooldown.
- Civilians have lightweight pathing and local avoidance. Static A* cells refresh parked-car occupancy once per second; dense moving-car crowd interactions can still be awkward. Small fleeing circles and simple search destinations are intentional prototypes.
- Off-screen actor cleanup is bounded; civilians do not repopulate during free play. Restart restores them. Spawn points are authored, not adaptive tactical placements.
- Most city visuals, NPCs, weapon/effect drawings and all non-music sounds are placeholders. No final loudness pass, full sprite animation, reduced-flash setting, input rebinding or volume UI.
- Desktop runtime tested. Packaged desktop exports, web builds, controller hardware and extended endurance remain unverified.

## Manual playtest route

1. Take the bat near spawn and hit/throw it at the municipal dummies. Pick up the pistol, empty it, then throw it. R resets supplies.
2. Answer the nearby phone and use M to locate the marked vehicle. Drive north to the broad road, east to the far north/south road, then south toward the garage; stop inside the gold box. Check the reward and radio switching en route.
3. Steal the occupied car in the parking lot or the marked patrol compact on the south road. Observe reported Heat, then let an officer visibly identify you. Break LOS around a block and leave the map's search perimeter. Stay unseen until clear.
4. Approach the red hostile near the plaza's north edge. Use cover during its visible aim warning, then compare bat/pistol/throw approaches.
5. Damage a car until its three-second warning begins; exit and lure city actors near the blast. Test several-car parking and low-speed escape. F6 recovers a stopped usable car only outside pursuit.
6. Die, restart, and repeat the phone/vehicle/delivery flow. Watch for stuck NPC corners, unreadable search feedback, radio mix and accidental interface obstruction.

**Most valuable next milestone:** a human pursuit-and-escape tuning pass in this district, especially police readability and navigation under vehicle chaos, before adding more mission content.
