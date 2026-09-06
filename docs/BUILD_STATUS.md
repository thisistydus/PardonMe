# Goal A build status

Authoritative scope: `Pardon_Me_Astra_Kickoff_Pack.md`. Goal B is not authorized until playtest feedback.

- Audit: read four design documents and viewed all nine supplied images. Found four M4A tracks; preserved originals. Godot 4.7.stable.official.5b4e0cb0f installed at `/Applications/Godot.app`.
- Structure/movement stage: Input Map, Events autoload, small collision arena, normalized movement and independent aim. Engine import and 120-frame headless run passed after macOS support-folder permission was granted. Next: combat.
- Combat/damage stage: typed weapon resources, fists, bat, eight-round semiautomatic pistol, swept bullets, pickups/drop, target stun/down/respawn, player wounds/death, feedback. Engine import and 180-frame run passed. Placeholder geometry and synthesized sound; next: vehicle and direct assertions.
- Integrated vehicle stage: compact resource, doors, collision-safe exit, arcade steering/braking, impacts and damage warning; pause/restart and debug HUD. Engine import and 180-frame run passed. Rendered OpenGL window inspected; E pickup, mouse attack and Esc pause exercised. Next: acceptance suite and ten-minute real-time endurance run.

Original artwork and music are not altered. At the initial milestone, runtime silhouettes were procedural and radio was absent. Revision 2 below replaces three silhouettes with generated sprites and integrates the supplied radio. No city, missions, Heat, scoring, progression or dawn clock are implemented.

- Direct acceptance stage: 35 integration assertions passed in `tests/acceptance.log`; 14 additional occlusion, arc, blocked-exit, grace-period and UI-action assertions passed in `tests/edge_cases.log`. An early test fixture placed the pistol shooter inside cover; moving the fixture into a clear firing lane fixed the test without changing combat. Next: complete the running ten-minute soak.
- Asset preservation: SHA-256 verification passed for all 17 supplied files outside the two authorized living documents. Both documents received additive status updates. Source M4As were inspected at container level: Opus in MP4, durations recorded in Assets Needed, no playback/conversion claimed.

- Endurance complete: **600.1 real seconds, 87 cycles, 435 assertions passed**, exit code 0. The test process stayed alive across all restarts. Completed-cycle node count remained 67. All retained engine logs are free of ERROR, WARNING and FAIL. The automated test ran headlessly while the graphical window remained available for play.
- **STOPPED AT GOAL A.** Next test is human feedback on bat feel, car entry/handling, pistol value and restart appeal. No Goal B work is begun.

## Playtest revision 1

User feedback: baseline movement works, shooting/bat feel good; targets should fly without stopping the car, held weapons should be throwable, and destroyed cars should explode with area damage.

Implemented those three changes within Goal A. Weapon/vehicle data now exposes throw and blast tuning. Right-click/X throws; Q/left-stick click drops. Existing melee and shooting recovery values are unchanged.

Engine import and startup passed. Focused physics suite: 33 assertions passed. Updated acceptance: 36 passed. Existing edge cases: 14 passed. Logs: `revision_import.log`, `revision_smoke.log`, `physics_revision.log`, `revision_acceptance.log`, `revision_edge_cases.log`. A new fixture needed one physics synchronization step after repositioning a target; production collision code passed the synchronized test. The previous 600.1-second soak remains historical evidence for the original build.

Next: playtest target launch, throw utility and explosion readability. Still no Goal B work.

## Art and radio revision 2 — 2026-09-06

User authorized the first player/compact/target art pass and the four supplied stations. Integrated three generated transparent sprites while retaining the established collision and combat simulation. Original station logos are loaded via station resources. Converted separate Ogg Vorbis copies of all four source tracks, fully decoded them, and verified Godot audio output. Keys 1–4 select stations, 5 Off (row and keypad); C/right shoulder cycles. Top-right station logo/track card is vehicle-only. Independent randomized station starts and a shared virtual broadcast clock give mid-song entry and switching. Pausing, exiting, dying, exploding and restarting all have verified radio transitions.

Clean engine import and Input Map setup passed. Focused suite: 42 checks passed headlessly; graphical suite: 47 including five image saves. All rendered cards and the actor composition were inspected. Existing acceptance/edge/physics regression suites passed 36 + 14 + 33 checks. Selected art has real alpha; rejected generation variants are retained but not referenced. No supplied art/music bytes changed. Prompts, conversion data, limitations and exact controls are recorded in the accompanying docs.

Next: human playtest of sprite readability, radio volume, throwing and compact impacts. Static poses, procedural environment/weapons/effects and a tinted wreck remain first-pass art. No new ten-minute soak is claimed. Stop at Goal A; no Goal B systems started.

## Goal B+ — First Playable District, 2026-09-06

Explicit user authorization supersedes the historical Goal A stop. Added the district, minimap, reactive population, witnessed Heat/foot police, local recovery and a resource-driven Boost/score loop while retaining the original yard scene. Phase imports/startup passed; district integration, combat, safety, actual driven delivery and original Goal A regression evidence are recorded in `GOAL_B_PLAYTEST.md` and final logs. A usage limit interrupted work once; the user redeemed a reset and resumed the full scope. Checkpoint is in `DEVELOPMENT_CHECKPOINT.md`.

Optional vehicle AI pursuit, roadblocks, traffic, vehicle disguise, dawn clock and expanded missions remain deferred. Final documentation records actual tested behavior and pending human feel review.
