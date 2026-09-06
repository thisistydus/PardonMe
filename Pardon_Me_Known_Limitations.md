# Known Limitations — Pardon Me

This file defines honest limitations of the current game-jam baseline. It exists to stop placeholder behavior, speculative features, and AI-generated scaffolding from being mistaken for completed design.

Update each item when implementation changes. Do not silently remove limitations; mark them resolved and note the replacement behavior.

---

## Goal B+ verified district update — 2026-09-06

This update supersedes historical Goal A-only statements below; the old entries are retained as development history. The current playable scope is the First Playable District described in `docs/GOAL_B_PLAYTEST.md`.

- **Resolved:** isolated-yard-only geography. A 4800×3600 handcrafted street grid now includes connected long roads, tighter street, two visible car-only shortcut gates, seven cars, parking, plaza, garage/storefront markings, three phones and visible boundaries. Actual driving to the garage and actor pathing around a block passed.
- **Resolved:** no civilian or hostile AI. Sixteen civilian slots and one hostile use wander/alert/panic/flee and suspicion/pursuit/telegraphed attack states. Existing throws, bat, firearm, car launch and warned explosions were directly verified against city archetypes. Their art remains procedural; no schedules, traffic or interiors.
- **Resolved:** no Heat/police. Five Heat levels use witnessed or audible reports, visual identification, foot investigation/pursuit/search/return and capped off-screen reinforcement spawning. An unknown report does not track the hidden player. LOS break plus leaving the search radius and eight unseen seconds clears Heat. No AI vehicle pursuit, roadblocks or vehicle-change disguise; these optional expansions remain deferred.
- **Resolved:** no navigation minimap. North-up simplified geometry, player/car facing, phones, garage, objective and search area are shown. Police visibility is restricted to local sight or active pursuit/search. M enlarges the map. No global hostile radar.
- **Resolved:** no playable mission/score. One resource-driven Boost job can award $2500 and +1 Notoriety, producing $2500 × 2 = 5000. A destroyed target fails gracefully and a later offer uses another car. One successful job per run; R resets. No Rob/Destroy missions, full mission pool, dawn clock or personal records yet.
- **Resolved in part:** only one compact. Seven cars include two sedan data variants and one alarm-equipped patrol compact. Occupied-car theft ejects a civilian owner. The sedan/patrol art reuses the compact; no distinct authored silhouettes or police driving AI. F6 local recovery preserves damage and is disabled during Heat/explosion warning.
- Existing Goal A mechanics and all four supplied radio stations remain tested. New HUD/debug/pause panels expose score, mission and police search data. Cues are synthesized placeholders. Source PNG/M4A bytes remain unchanged.
- Current evidence, exact controls, created/modified files, manual scenarios and remaining limits are in `docs/GOAL_B_PLAYTEST.md`. Historical soak logs predate this district. No new endurance, exported-build or physical-controller claim is made.

## Goal A implementation update — 2026-09-05

The sections below retain the broader jam baseline. They are **not a feature-completion list**. This update describes the actual movement toy.

### Art and radio revision 2 — 2026-09-06

- **Resolved: player, compact and practice targets were entirely procedural geometry.** Three generated transparent PNG sprites now render in the existing arena, with procedural movement sway, aim rotation, hit flash, airborne tumble and damage overlays. These are first-pass static poses, not complete frame animation sets. Weapons, environment, effects and charred-wreck details remain code-drawn. Selected artwork and prompts are recorded in `docs/ART_PROMPTS.md`.
- **Resolved: no radio playback / unsupported source containers.** The four original M4As remain unchanged; separate Ogg Vorbis derivatives under `Music/Imported` were fully decoded with FFmpeg and played through Godot. Four station resources bind each original logo to its song. No runtime conversion or external utility is required.
- Keys **1 Anvil, 2 Backspin, 3 K-Buck, 4 Pulse, 5 Off** work on both number row and numeric keypad while driving. C / right shoulder cycles. The current station logo and track card stay at the upper right while in the car; exiting, death or explosion stops playback and hides the card. Off hides the logo. The car remembers its station, including Off.
- Each station gets a random nonzero initial position per run, independent of the gameplay seed. Virtual broadcasts continue while on foot or listening to another station; re-entry and switching resume the current broadcast position. Songs loop. Pause freezes music and broadcast time. Only one audio stream plays at once.
- Verification: 42 focused checks passed headlessly; the graphical run passed those plus five rendered-image saves. All four stations produced decoded audio samples; track seeking, looping, keypad, Off, exit, pause, destruction and restart were exercised. Rendered player/car/target and all station cards were inspected. Existing combat/driving suites are recorded in the playtest guide.
- Still one song per station, no DJ reactivity, no per-track loudness normalization or volume UI. The initial mix uses radio playback at −12 dB. Full character animation and authored wreck/explosion art remain polish work. The earlier ten-minute soak predates both revisions.

### Playtest revision 1 — requested physical interactions

- **Resolved: targets stopped the compact.** Fast impacts now launch targets into a brief airborne tumble with strong forward momentum. The compact retains 90% of its speed per body hit and takes minor damage. Walls still stop/bounce it, including a wall directly behind a target. The airborne effect is an arcade visual over 2D collision, not a 3D ragdoll.
- **Resolved: held weapons could only be dropped.** Right-click / controller X throws the held bat or pistol along the aim direction. Q / left-stick click drops it gently. Fists stay permanent. Throws stop at cover, damage one target, then become recoverable pickups with the exact remaining ammo. Bat throws incapacitate ordinary targets; pistol throws deal two of a target's three damage points and stun, including when empty. This uses generic WeaponData throw values so future held weapons use the same path.
- **Resolved: damaged cars only became disabled.** Depleting the compact starts a three-second, non-resetting explosion countdown with smoke, accelerating beeps, a HUD timer, and a blast-radius ring. The explosion applies one radial damage event, then leaves a non-drivable wreck. Solid cover blocks the blast. The radius is 190 world units: the inner 90 is lethal to the player, the outer ring wounds/pushes, and remaining inside the car is lethal. Ordinary bullet grace does not protect against the lethal core. Exit during the countdown remains available.
- Explosion damage can hit targets and other vehicles; multi-car chain reactions are not part of the one-compact playtest. No spreading fire, ongoing burning damage, or destructible building simulation has been added.
- Verification for this revision: 33 focused assertions plus 36 updated baseline and 14 edge-case assertions passed. The prior ten-minute endurance log describes the initial build, not this revision.

### Resolved at Goal A

- Blank-project status is resolved: a Godot **4.7 stable** project now starts at `scenes/game.tscn`.
- Normalized keyboard movement, independent mouse/right-stick aim, permanent fists, one held bat or pistol, E pickup/swap, and drop are implemented.
- Fists take three hits against a practice target, stun briefly, and can finish it against a wall. Bat hits down ordinary targets with strong knockback. The eight-round pistol fires once per press; dropped ammunition is retained; there is no reload or reserve.
- Player wounds on the first bullet and dies on the next, with 0.9 seconds of damage grace. Death opens a test summary, and R resets the scene inside the same running project.
- One compact supports nearest-door entry, clear-space exit selection, acceleration, reverse/braking, steering, handbrake, target impacts, collision damage, smoke, and a three-second warning before an area-damage explosion.
- Temporary melee arcs, tracers, hit bursts, hit pause, camera response, and synthesized sound effects are implemented. F4 toggles shake for the current test session.
- The small handcrafted arena has cover, practice targets, equipment, a driving lane, and one stationary live-fire target with a visible aim warning. Targets return after five seconds if the respawn location is clear.
- Debug HUD includes actor state, vehicle health/state, seed, and explicit labels for unimplemented Heat and missions.
- Automated integration checks and a native-window visual check are recorded in `docs/GOAL_A_PLAYTEST.md`; no subjective claim about excellent bat feel is made from automated tests.

### Current limits and deliberate deferrals

- **Goal A only.** No four-block district, police AI, civilians, Heat, Money, Notoriety, missions, twelve-minute day/dawn, score calculation, personal bests, favors or narrative yet. **Radio playback is now implemented by revision 2.** The HUD shows elapsed test time and targets down, not a simulated score.
- The shooter is a stationary test fixture, not a police officer. It fires in a locked direction after a warning. There is no chase, search, or city AI.
- **Resolved in part by revision 2:** player, compact and targets use generated sprites, and original station logos appear in the radio card. Environment and weapon geometry remain temporary. Mockups remain references; the title logo is preserved but not yet used in a title screen.
- Sounds are short procedural substitutes. Engine sound is a simple oscillator loop; there is no tire-skid audio, authored Foley, positional mix pass or final loudness pass. **Music is now supplied by the four radio stations in revision 2.**
- Only the compact is implemented. **The original disable-only limitation is resolved by revision 1: it explodes and leaves a wreck.** Driving uses a CharacterBody2D arcade model, not rigid-body vehicle simulation; no suspension, traffic or generalized vehicle-to-vehicle physics is claimed.
- The sole car stays wrecked after exploding until restarting the test. If all exit positions are blocked, exit is refused with a message. Standard arena geometry provides room, but contrived complete enclosure requires R.
- No knife, shotgun, inventory, reload, dodge, healing, or armor in this milestone. **The original no-throw limitation is resolved by revision 1:** right-click throws with damage; Q still drops at the player's position.
- Desktop Godot execution is verified. Export templates, packaged executables, web export and hardware-controller play have not been tested. Controller Input Map and right-stick aiming are defined; keyboard/mouse is the tested path.
- The reproducible seed changes small target-placement offsets; it is retained on restart and displayed in the test summary. It is not a mission seed until missions exist.
- No game save is written. Shake preference resets on restart. Input remapping, volume sliders, aim assistance and reduced-flash options remain future work.
- Supplied M4A files contain Opus audio in MP4 containers. macOS `afinfo` failed to open them, and Godot's import scan did not import them as audio. **Resolved in revision 2:** separate Ogg Vorbis files decode and play in Godot; originals remain untouched.
- The ten-minute automated soak exercises repeated resets and interactions. It cannot certify subjective feel or replace ten minutes of human play. Goal B must wait for feedback.

## 1. Current Project State — Expected

- The project begins as a blank Godot workspace containing supplied logos and four radio tracks.
- No gameplay system should be assumed complete until inspected and run.
- Initial art may be placeholder geometry.
- Mockups are visual references, not production UI textures or exact layouts.

---

## 2. Scope Is a Vertical Slice, Not a Small Open World

- One handcrafted district only.
- Approximately four dense playable blocks.
- No seamless larger city.
- No procedural road layout.
- Buildings are primarily exterior collision and roof shapes.
- Enterable interiors are excluded from the first playable.

The map proves combat, pursuit, navigation, and mission density—not exploration scale.

---

## 3. The Time Loop Is Mechanically Present but Narratively Unexplained

- The player receives a brief opening premise.
- Dawn or death restarts the day.
- The cause of the recurrence is not explained in the jam build.
- NPC memory and branching loop dialogue are not required.
- Radio déjà vu is deferred.

The lack of explanation is intentional mystery, not missing exposition.

---

## 4. Meta-Progression Is Deferred

- Leverage is not part of the first playable.
- Starting favors are not required for the initial fun test.
- No permanent health, damage, speed, or money upgrades.
- No unlock economy should be created before the core run is validated.

Local high scores and run history are sufficient initially.

---

## 5. Money Is Simplified

- All earned Money counts toward score in the initial implementation.
- Carried versus secured Money is deferred.
- No bank, fence, deposit-risk system, spending, shops, or economy.
- Death records the current score rather than erasing the run.

This intentionally prioritizes validating Money × Notoriety over punishment balance.

---

## 6. Notoriety Is a Simple Tier Multiplier

- Starts at ×1 and caps at ×6 for the jam.
- Missions provide the primary gains.
- A small set of feats provides partial progress.
- Notoriety does not decay.
- There is no social reputation simulation.
- Factions do not independently track the player.

Notoriety is a score mechanic, not a full world-state model.

---

## 7. Police Simulation Is Intentionally Shallow

- Five Heat states, 0–4.
- Detection relies on readable line of sight, radius, and witnessed events.
- Police do not understand the pardon.
- No advanced dispatch simulation.
- No legal system, court process, evidence model, or factional police politics.
- Roadblocks and vehicle pursuit may be stretch features.
- Spawn points are authored and should remain outside immediate player view.

Police must feel fair before they feel intelligent.

---

## 8. Arrest Is Deferred

- Death is the primary failure state.
- Officers may attack rather than perform complex arrest behavior.
- Booking, forced release, lost hours, confiscation, and comeback runs are post-baseline systems.

The narrative supports arrest, but it is not required to prove the arcade loop.

---

## 9. Combat Is Small but Must Feel Finished

- Permanent fists plus one held weapon.
- No backpack or weapon inventory.
- Initial weapons: bat, knife, pistol, shotgun.
- Ordinary enemies use low durability.
- Player uses a two-strike wounded/death model.
- No armor system until starting favors are tested.
- No weapon rarity or randomized stats.
- Enemy weapon pickup is not required.

Weapon count is deliberately limited so animation, timing, feedback, and collision can be tuned.

---

## 10. Fire Propagation Is a Stretch Goal

- Flamethrower is excluded from the first playable.
- Burning NPC panic, contact spread, environmental ignition, and performance caps are unimplemented until the base combat loop is stable.
- Fire must use tagged targets and bounded propagation if added.

Do not build a generalized fire simulation during the movement-toy milestone.

---

## 11. Driving Is Arcade-Level

- Three vehicle classes initially: compact, sedan, police cruiser.
- No licensed makes or realistic vehicle simulation.
- No customization, ownership, garages, traffic laws, or fuel.
- Civilian traffic AI may be static or extremely simple.
- Vehicle damage uses a few discrete states.
- Changing vehicles can break identification only after police logic supports it.

Driving must be immediate and fun; realism is not a target.

---

## 12. Mission Variety Comes From Configuration

- Three templates initially: Boost, Rob, Destroy.
- Six authored configurations.
- Only one active mission.
- Mission delivery uses payphones.
- Robbery can occur at an exterior trigger rather than an interior.
- No cinematic scenes, dialogue trees, escort AI, or bespoke mission maps.
- A large mission pool is a post-jam content goal.

Mission data should be extensible without pretending six variants equal a finished campaign.

---

## 13. Civilians Are Reactive Props, Not Full NPCs

- Basic wandering, panic, fleeing, collision, damage, and death states.
- No schedules, relationships, memory, dialogue, needs, or homes.
- Crowd density must remain within performance limits.
- Civilian harm increases Heat but should not be the optimal score strategy.

---

## 14. Radio Is Initially a Playback System

- Four supplied station identities.
- One supplied track per station.
- Stations cycle while driving.
- Track persistence between cars is optional initially.
- No dynamic DJ, talk radio, advertisements, police interruptions, or reactive music required.
- Station logos and files must be loaded through data rather than individually hard-coded.

The shared radio universe is a creative pillar but not a blocker for the mechanical prototype.

---

## 15. UI Mockups Are Directional

- Mockups communicate hierarchy, tone, palette, and information placement.
- Exact fonts, spacing, dimensions, icons, and textures are not locked.
- Generated text or tiny details should not be extracted as final assets.
- Final UI must remain readable at 1280×720 and scale to other desktop resolutions.

---

## 16. Persistence Is Local and Minimal

- Save settings, personal bests, and optionally recent run summaries.
- No cloud saves required for jam.
- No accounts, authentication, telemetry, achievements, or online leaderboard.
- Seeded runs support debugging, not guaranteed competitive daily challenges.

---

## 17. Performance and Web Export Are Aspirational

- Desktop is the testing target.
- Architecture should avoid obvious web-export blockers.
- Web deployment is not considered proven until an exported build is tested.
- Large crowds, physics debris, pathfinding, audio streaming, and fire propagation may require platform-specific limits.

Do not claim web readiness based solely on editor play.

---

## 18. Accessibility Is Incomplete During Gray Box

Planned but not necessarily implemented in the first playable:

- Camera-shake toggle
- Reduced flashing
- Master/music/effects volume controls
- Aim assistance for controller
- Input rebinding
- High-contrast Heat and objective indicators
- Subtitle support for future radio speech

Avoid baking essential information exclusively into color, sound, or screen shake.

---

## 19. AI-Assisted Development Guardrails

- Generated code must be run and verified in Godot.
- Parser success is not proof of correct gameplay.
- Placeholder methods must be labeled.
- No feature should be described as complete without an observable test.
- Existing assets and user-authored work must be preserved.
- No destructive git or filesystem operations.
- Large rewrites require a concrete reason and regression check.
- Each milestone ends with controls, modified files, honest limitations, and manual test steps.

---

## 20. Current Definition of Done

The baseline is successful when a player can:

1. Start a run.
2. Move and aim responsively.
3. Use satisfying melee and one firearm.
4. Enter, drive, crash, and exit a vehicle.
5. Trigger and escape police Heat.
6. Complete one mission for Money and Notoriety.
7. See Money × Notoriety update live.
8. Die or reach dawn.
9. Review the score.
10. Restart without reloading the project.

Anything beyond this is expansion until these ten actions work together reliably.

