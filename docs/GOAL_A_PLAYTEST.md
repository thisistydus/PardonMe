# PARDON ME — Goal A playtest

**Playtest revision 2:** generated player, compact and target art; four supplied radio stations with random broadcast offsets and a vehicle-only logo card. Revision 1 throwing, target launch and warned explosions remain included.

**Historical Goal A guide:** the project now also has Goal B+ at `scenes/district.tscn`; see `docs/GOAL_B_PLAYTEST.md`. Open `scenes/game.tscn` directly to use this preserved regression yard.

This is the movement toy only. The kickoff pack remains the authoritative scope. Stop here for feel feedback before Goal B.

## Open and run

Open `project.godot` using the installed Godot 4.7 stable at `/Applications/Godot.app`, then press **F5**. The main scene is `scenes/game.tscn`.

From a terminal in this folder:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --path .
```

The project uses the Compatibility renderer, a 1280×720 viewport and proportional, letterboxed UI scaling. There is no installation, network dependency or downloaded asset requirement. No standalone export is supplied.

## Exact controls

| Action | Keyboard / mouse | Controller binding (not hardware-tested) |
| --- | --- | --- |
| Move on foot | W A S D | Left stick |
| Aim independently | Mouse | Right stick |
| Use fists / bat / pistol | Left click; one press per attack | Right trigger; one press per attack |
| Pick up / swap / enter / exit | E | A / bottom face button |
| Throw held weapon; return to fists | Right click | X / left face button |
| Drop held weapon gently | Q | Left-stick click |
| Drive | W accelerate; S brake then reverse; A/D steer | Left stick up/down/left/right |
| Handbrake | Space (in vehicle) | B / right face button |
| Restart entire test yard | R, including while paused/dead | Y / top face button |
| Pause / resume | Esc | Start |
| Debug overlay | F3 (Fn may be needed on Mac) | Back / Select |
| Camera shake on/off | F4 (Fn may be needed on Mac) | Left shoulder |
| Select radio station / Off (in car) | 1 Anvil, 2 Backspin, 3 K-Buck, 4 Pulse, 5 Off; number row or keypad | C / right shoulder cycles all stations and Off |
| Pause/results buttons | Mouse, Tab and Enter | D-pad and A via Godot UI actions |

There is no dodge, reload or weapon inventory. Throws damage targets: the bat incapacitates; the pistol deals two damage points and stuns, even with no ammo. Weapons land as recoverable pickups. The pistol has **eight total rounds**, preserved when dropped and picked up; R restores the yard's supplies. The player starts with fists and can carry only one other weapon.

## A short route through the toy

1. Start beside the equipment pads. Press E to take the bat. Walk north-east around cover to the canvas practice targets. Aim and swing; try catching two targets in one arc. Targets respawn after five seconds when clear.
2. Use Q to drop the bat and try fists: three hits down a target, or knock it into cover. Pick up the pistol at the other equipment pad; one round downs an ordinary target. Right-click to throw either weapon; E recovers it after landing without refilling ammunition. Cover blocks bullets, melee and throws.
3. Find the compact on the horizontal road. E near a side door enters immediately. Accelerate along the lane, steer, brake, and hit the road target: it now flies forward while the compact retains most of its speed. Try 1–4 for the stations and 5 for Off. The station card appears at the upper right only in the vehicle; songs begin mid-broadcast and keep their virtual position between selections. E exits on a clear side, stops audio and hides the card. Crash damage progresses through smoke and critical warnings; a depleted engine gives three seconds before exploding. Exit and run beyond the visible 190-unit blast ring. The inner 90 units are lethal; the outer ring wounds/pushes. Cover blocks the blast. Staying inside is lethal. A wreck remains afterward.
4. Walk toward **03 / LIVE FIRE** in the south-east. The red stationary shooter telegraphs a fixed firing line. One bullet wounds; another after the grace period kills. Try dodging the line or using cover. This is a practice fixture, not police AI.
5. R restarts from play, pause or death. The summary shows elapsed test time, targets down and seed. These are test diagnostics, not the future Money × Notoriety score.

## Verification evidence

Engine: **4.7.stable.official.5b4e0cb0f**, local macOS. Graphical runtime reported **OpenGL Compatibility / Apple M2**.

- Staged import and headless runs passed after normal Godot support-folder access was approved: `tests/import.log`, `movement.log`, `combat_import.log`, `combat.log`, `vehicle_import.log`, `vehicle.log`.
- Native graphical window inspected at the game HUD and pause panel. E pickup, left-click attack and Esc pause were exercised through computer use. This initial check predates revision 2, which now uses generated sprites for the three principal actors.
- **36 updated integration assertions passed**, recorded in `tests/revision_acceptance.log` (initial 35-check result retained in `tests/acceptance.log`). These cover movement/aim, player cover collision, weapon pickup/drop, fists, bat knockback, restored hit pause, semiautomatic ammunition, dropped-ammo preservation, projectile cover collision, empty pistol, entry, acceleration, steering, handbrake, exit, collision damage, high-speed target impact, warned explosion, escape, reset, pause/resume, real enemy-projectile wound/death and restart.
- **14 edge-case assertions passed**, recorded again in `tests/revision_edge_cases.log`: melee/cover occlusion, wide front arc, excluded rear target, all-blocked exit refusal/state preservation, recovery when a door clears, damage grace, debug/shake toggles, restart from pause.
- **33 new physics assertions passed**, recorded in `tests/physics_revision.log`: empty/full pistol and bat throws, recovery/ammo conservation, cover and misses, no fists/vehicle throws, car momentum and airborne launch, wall-behind-target collision, warning timing, radial damage, occlusion, inner/outer player damage, occupant death, escape and restart cleanup.
- **Initial-build** ten-minute automated endurance result: **passed — 600.1 real seconds, 87 complete cycles, 435 assertions, exit code 0**, recorded in `tests/endurance.log`. Node count was 67 after every completed cycle; no errors or warnings were logged. Each cycle picks up a bat, hits a target, enters/drives/exits, receives lethal live fire, then restarts in the same process. It runs at real elapsed time without accelerated simulation. It was headless so the user could keep the graphical play window. This historical run predates throws/explosions; no new ten-minute soak is claimed for revision 1.
- The user reported that baseline movement works and shooting/bat swinging feel good. Human judgement of the new launch, throw and explosion tuning remains **pending playtest**. Automated assertions do not prove these subjective acceptance criteria.
- **Revision 2:** 42 art/radio checks passed in `tests/art_radio.log`; graphical OpenGL run passed those plus five saved-frame checks in `tests/art_radio_visual.log`. Inspected `art_on_foot.png` and all four `radio_station_*.png` images at 1280×720. Real alpha, four decoded audio streams, physical row/keypad bindings, seeking, looping, pause, Off, entry/exit, death and restart are covered. Existing 36 acceptance, 14 edge and 33 physics checks passed again in `tests/art_radio_acceptance.log`, `art_radio_edge_cases.log` and `art_radio_physics.log`.
- First-pass art uses static poses with procedural motion; final animation and radio loudness balancing remain human playtest items.
- Controller hardware, exported desktop builds and browser exports remain untested.

Reproduce checks from this project directory:

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://tests/acceptance.tscn --log-file ./tests/revision_acceptance.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://tests/edge_cases.tscn --log-file ./tests/revision_edge_cases.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://tests/physics_revision.tscn --log-file ./tests/physics_revision.log
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . res://tests/acceptance.tscn --log-file ./tests/endurance_rerun.log -- --soak
```

Radio check: `Godot --headless --path . res://tests/art_radio.tscn`; use the installed executable path above. Add `-- --visual` without `--headless` to save rendered inspection frames.

Use `-- --seed=12345` on the normal game command to reproduce a different small target-placement variation. Default seed is 771104; restart retains it. Radio broadcast offsets intentionally randomize independently on restart. Mission selection is not implemented.

## Created and modified files

Created:

- `project.godot`, `.gitignore`, `scenes/game.tscn`.
- `scripts/game.gd` — composition root.
- `scripts/actors/player.gd`, `practice_target.gd`, `compact.gd`, `vehicle_data.gd`.
- `scripts/combat/weapon_data.gd`, `weapon_controller.gd`, `projectile.gd`.
- `scripts/world/arena.gd`, `weapon_pickup.gd`.
- `scripts/systems/events.gd`, `feedback.gd`, `run_manager.gd`, `run_config.gd`.
- `scripts/ui/hud.gd`.
- `data/weapons/fists.tres`, `bat.tres`, `pistol.tres`; `data/vehicles/compact.tres`; `data/run_config.tres`.
- `tests/acceptance.gd`, `acceptance.tscn`, `edge_cases.gd`, `edge_cases.tscn`, and engine log files.
- `docs/BUILD_STATUS.md`, `GOAL_A_PLAYTEST.md`, `supplied_files_sha256.json`, and preservation/file-manifest reports.
- Godot-generated `.uid` script identifiers, `.import` image metadata and local `.godot` cache. These are sidecars; supplied PNGs are not modified.

Modified supplied files (additive status updates only):

- `Pardon_Me_Known_Limitations.md`.
- `Pardon_Me_Assets_Needed.md`.

The kickoff, older bible, all nine images, four music sources and existing metadata remain preserved; see `docs/asset_preservation_report.json` for hash verification. Exact created-file inventory is in `docs/created_files.txt` (cache excluded).

### Revision 1 changed files

- Added `scripts/combat/thrown_weapon.gd` and `vehicle_explosion.gd` (plus generated UIDs); `tests/physics_revision.gd` and `.tscn`; revision engine logs.
- Modified `project.godot` (throw/drop Input Map), `data/weapons/bat.tres`, `scripts/combat/weapon_data.gd`, `scripts/actors/player.gd`, `practice_target.gd`, `compact.gd`, `vehicle_data.gd`, `scripts/systems/feedback.gd`, `scripts/ui/hud.gd`, and `tests/acceptance.gd`.
- Updated both living production documents, this guide, build status, and file/preservation reports.

### Revision 2 changed files

- Added three selected sprites and retained generation variants under `Art/Generated`; four supported song derivatives under `Music/Imported`. All supplied source assets remain unchanged.
- Added `scripts/world/sprite_art.gd`; `scripts/systems/radio_station_data.gd`, `radio_library.gd`, `radio_manager.gd`; `data/radio/library.tres` and four station `.tres` resources.
- Updated actor drawing in `player.gd`, `practice_target.gd`, `compact.gd`; added vehicle ownership signals in `events.gd`, composition in `game.gd`, and the top radio card in `hud.gd`.
- Updated `project.godot` with row/keypad radio actions; added `tools/configure_radio_inputs.gd`, `tools/convert_radio.py`, `tests/art_radio.gd` and `.tscn`, test logs and rendered images.
- Added art prompts, alpha inspection and audio conversion reports; updated these docs and preservation inventory. `.tools` contains the pinned conversion utility, ignored by Godot and version control.

## Next decision

Play for ten minutes and judge the bat, pistol, compact entry, steering/crashes, and desire to restart. Feedback should keep the next iteration in Goal A until those feel right. No Goal B systems have been started.
