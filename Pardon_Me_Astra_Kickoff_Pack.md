# PARDON ME — Astra Kickoff Pack

## Purpose

This is the implementation baseline for the first GPT-6 Astra-assisted Godot build. It converts the broader design bible into a narrow, testable game-jam target.

The first build is not expected to prove the full content library, time-loop mystery, radio universe, meta-progression, or final art direction. It must answer one question:

> Is it immediately fun to earn Money, raise Notoriety, and survive escalating Heat by alternating between melee combat, gunplay, and reckless driving?

You are working in the Documents/Godot/PardonMe folder exclusively, and using the Godot installation on my machine.  There is no Godot project created, but the folder has logos, music files, and other documents.  Please review all, as the Known Limiations and Assets needed .mds are intended for you to edit.

---

## 1. Locked MVP Parameters

| Parameter | Locked baseline |
| --- | --- |
| Engine | Godot 4.x, typed GDScript |
| Perspective | Top-down 2D |
| Platform | Desktop first; web-compatible architecture where practical |
| Display target | 1280×720, scalable UI |
| Inputs | Keyboard/mouse first; controller actions defined from the beginning |
| Run duration | 12 real minutes representing 24 in-game hours |
| Map | One handcrafted district, approximately 4 dense blocks |
| Player durability | Two bullet strikes: wounded, then dead |
| Enemy durability | One firearm hit; melee varies by weapon |
| Weapon capacity | One held weapon plus permanent fists; no inventory |
| Vehicles | Compact, sedan, police cruiser |
| Mission templates | Boost, Rob, Destroy |
| Mission configurations | Six total, with only a subset offered each run |
| Heat | Five levels, 0–4 |
| Notoriety | Starts at ×1; missions and feats raise tiers |
| Money | All money earned counts in the first implementation; banking deferred |
| Final score | Money × Notoriety, plus a dawn survival bonus |
| Failure | Death ends and scores the run; immediate restart available |
| Meta-progression | Deferred until the core run is validated |
| Radio | Four supplied stations rotate tracks; one song per station is sufficient |

### Explicit cuts from the first playable

- Arrest and release flow
- Secured versus carried money
- Time-loop exposition beyond a short opening card
- Flamethrower and spreading fire
- Civilian driving simulation
- Interiors
- Starting favors and Leverage
- Dynamic DJ commentary
- Procedural map generation
- Online leaderboards
- Advanced mission chains

These are not rejected features. They are protected from becoming prerequisites for the fun test.

---

## 2. Core Score Rules

### Money

Money is the base value of the run. It is earned by:

- Collecting cash drops
- Completing mission objectives
- Delivering marked vehicles
- Destroying marked targets
- Robbing designated locations

For the first build, Money cannot be spent. It exists only as score fuel.

### Notoriety

Notoriety is the score multiplier and the player's strategic reason to complete missions rather than endlessly farm small cash pickups.

- Starts at ×1
- Mission completion grants one tier
- Significant optional feats add partial progress
- Never decreases during a run
- Jam target cap: ×6

Suggested feat progress:

| Feat | Notoriety progress |
| --- | ---: |
| Escape Heat 2+ pursuit | 25% |
| Destroy a roadblock | 20% |
| Steal an occupied police cruiser | 20% |
| Complete a mission while wounded | 25% |
| Complete a mission at Heat 4 | 50% |

Repeated feats of the same type should award reduced progress until another feat occurs.

### Heat

Heat is not score. It is pressure.

| Level | Response |
| ---: | --- |
| 0 | Ambient police only |
| 1 | One officer investigates |
| 2 | Active foot pursuit and shooting |
| 3 | Multiple units and vehicle pursuit |
| 4 | Aggressive reinforcement spawning and roadblocks |

Heat rises from witnessed crimes, gunfire, hitting civilians, attacks on police, vehicle theft, and property destruction. It falls only after line of sight is broken and the player leaves the search area.

### Final calculation

```text
BASE SCORE = MONEY × NOTORIETY
DAWN BONUS = 25% of BASE SCORE
FINAL SCORE = BASE SCORE + DAWN BONUS, if the player survives the clock
```

Death records the current base score. A failed run is still allowed to become a high score.

---

## 3. Combat Baseline

### Movement and aiming

- WASD movement
- Mouse aim, independent of movement
- Left mouse uses held weapon
- Right mouse throws or drops held weapon if supported; otherwise dedicated drop action
- Space performs a short dodge or lunge only if it improves combat feel during testing
- E interacts, enters/exits vehicles, and picks up weapons

### Fists

- Always available when no weapon is held
- Short range
- Fast recovery
- Requires multiple hits or a wall impact to kill
- Can knock a target down briefly

### Baseball bat

- Wide arc
- Moderate recovery
- Strong knockback
- One clean hit incapacitates ordinary enemies

### Knife

- Very short reach
- Fast attack and recovery
- Minimal knockback
- One clean hit kills

### Pistol

- Semi-automatic
- Readable projectile or tracer
- Limited magazine/ammunition
- One hit kills ordinary enemies
- Gunfire immediately creates significant Heat

### Shotgun

- Wide close-range spread
- Strong recoil feedback
- Very limited ammunition
- Capable of hitting multiple targets
- Creates more Heat than the pistol

### Feel requirements

Every successful hit needs:

- Brief hit pause
- Directional knockback
- Strong sound
- Impact effect
- Clear enemy state change
- Small camera response, with accessibility toggle later

If the bat does not feel satisfying in an empty gray box, content production pauses until it does.

---

## 4. Driving Baseline

### Vehicle behavior

- Arcade acceleration and braking
- Steering becomes stronger with movement but never unresponsive at low speed
- Vehicles rotate physically rather than snapping to directions
- Player can enter the nearest valid door position with E
- Entering/exiting should take less than half a second
- Collisions damage vehicles and apply impulses
- High-speed impacts damage or kill NPCs
- Police can pursue using cruisers at Heat 3+

### Vehicle identities

| Vehicle | Strength | Weakness |
| --- | --- | --- |
| Compact | Quick turning and acceleration | Low durability |
| Sedan | Balanced baseline | No exceptional strength |
| Police cruiser | Fast and durable | Theft immediately increases Heat |

### Damage states

1. Healthy
2. Smoking, with slight handling degradation
3. Critical, with strong smoke and warning feedback
4. Disabled or exploded after a short readable delay

The player must have enough warning to abandon a dying vehicle.

---

## 5. Mission Baseline

Mission offers appear at ringing payphones. Each run selects configurations from the available pool using a seed.

### Boost

1. Answer phone.
2. Mark one parked vehicle.
3. Steal it.
4. Deliver it to a marked garage.
5. Award Money and one Notoriety tier.

### Rob

1. Answer phone.
2. Mark a robbery zone or exterior storefront trigger.
3. Reach and remain in the zone during a short hold-up timer.
4. Collect the cash.
5. Escape the immediate search area.
6. Award Money and one Notoriety tier.

No enterable interior is required; the first version can stage the interaction at a storefront boundary.

### Destroy

1. Answer phone.
2. Mark a vehicle or environmental target.
3. Destroy it through weapons or vehicle collision.
4. Award Money and one Notoriety tier.

### Mission constraints

- Only one active mission
- Declining or ignoring an offer has no penalty
- At least two payphones are available at run start
- Completed configurations are removed from the current run
- High-value variants become eligible later in the clock
- Mission logic is data-driven so new configurations do not require new scripts

---

## 6. Twelve-Minute Run Pacing

| Real time | In-game period | Expected experience |
| --- | --- | --- |
| 0:00–3:00 | Morning | Find weapon/vehicle; accept first mission |
| 3:00–6:00 | Afternoon | Second mission; Heat systems become meaningful |
| 6:00–9:00 | Evening | Better payouts; vehicle pursuit likely |
| 9:00–12:00 | Night | Maximum-risk scoring push |
| 12:00 | Dawn | Survive, apply 25% bonus, show results |

The clock never pauses during missions. Pause menus may pause gameplay in single-player.

---

## 7. First-Pass World Layout

The gray-box map should support play before it resembles a city.

Required spaces:

- One broad central intersection
- One long horizontal road for pursuit
- One long vertical road
- Two narrow alleys that cars cannot use
- One parking lot containing several vehicles
- One plaza with civilians and cover obstacles
- One garage delivery zone
- Two storefront robbery zones
- Four payphones
- Two marked destroy targets
- Police-spawn zones located off-screen and outside immediate player view

Buildings can initially be collision rectangles with roof colors. Roads, sidewalks, alleys, and interactive zones must be visually distinct.

---

## 8. Radio Baseline

The supplied content includes:

- 96.9 The Anvil logo and one song
- Backspin 98 logo and one song
- K-Buck logo and one song
- Pulse logo and one song

First-pass behavior:

- The current vehicle owns radio playback.
- Entering a vehicle starts or resumes a selected station.
- A station switch action cycles through four stations and Off.
- HUD briefly displays station logo and track title.
- Track position can continue globally between vehicles if simple to implement; restarting on entry is acceptable for the first playable.
- Police radio interruptions and reactive DJs are deferred.

Audio files and logos should be discovered through a small data resource rather than hard-coded scene paths.

---

## 9. UI Baseline

### Visual-direction references

- `Pardon_Me_Mockup_Title.png` — title hierarchy and city tone
- `Pardon_Me_Mockup_Gameplay.png` — target HUD hierarchy and representative action
- `Pardon_Me_Mockup_Favors.png` — post-MVP starting-favor presentation
- `Pardon_Me_Mockup_Results.png` — dawn scoring and newspaper presentation

These are reference images, not production textures. Small generated lettering, exact geography, individual props, and incidental branding are not canon. Implement information hierarchy and tone, not a pixel-for-pixel recreation.

### Active-run HUD

- Top left: remaining time and current period
- Top center or upper right: Money × Notoriety = live score
- Right edge: Heat level
- Bottom corner: held weapon and ammunition
- Temporary lower-third: mission objective
- Temporary radio card: station logo and track

The interface should use the game's cream, near-black, muted red, and dirty gold palette. It should resemble stamped municipal paperwork disrupted by arcade feedback—not a direct imitation of any GTA interface.

### Results screen

Must show:

- Money earned
- Notoriety multiplier
- Base score
- Dawn bonus, if applicable
- Final score
- Missions completed
- Highest Heat
- Personal-best indicator
- Restart and quit actions

---

## 10. Technical Architecture Guardrails

Use modular systems with signals and data resources. Avoid building the entire game in one scene script.

Recommended major nodes/systems:

```text
Game
├── RunManager
├── ScoreManager
├── HeatManager
├── MissionManager
├── TimeManager
├── RadioManager
├── World
├── Player
├── SpawnDirector
└── UI
```

### Required principles

- Typed GDScript
- Input Map actions rather than raw key checks
- Resource or JSON-driven weapons, vehicles, missions, and stations
- Signals for cross-system events
- Seed retained and displayed on results screen
- No silent errors or placeholder methods that pretend to work
- Debug overlay for player state, Heat, active mission, vehicle health, and seed
- Save only settings and local records during the first pass
- Separate simulation values from UI presentation

### Suggested data resources

- `WeaponData`
- `VehicleData`
- `MissionDefinition`
- `MissionVariant`
- `RadioStationData`
- `RunConfig`

---

## 11. Core First-Pass Goals

### Goal A — The movement toy

The player can move, aim, swing a bat, fire a pistol, kill a dummy enemy, enter a compact car, drive, exit, and be killed.

**Pass condition:** Ten uninterrupted minutes of testing without input lock, scene failure, or broken state transition.

### Goal B — The hostile city

Civilians wander and panic. Police detect visible crime, pursue, shoot, lose line of sight, and search. Heat rises and falls.

**Pass condition:** A player can intentionally create and escape a Heat 2 pursuit through readable play.

### Goal C — The score loop

Money increases from crime, a mission raises Notoriety, the live score updates, the clock reaches dawn, and death or dawn opens results.

**Pass condition:** A complete run can start, score, end, and restart without reloading the project.

### Goal D — The identity pass

The title logo appears, supplied radio stations work in vehicles, the HUD uses the visual palette, and impacts have satisfying audiovisual feedback.

**Pass condition:** A person seeing 30 seconds of gameplay can identify the game as a deliberate arcade crime score attack rather than a generic Godot prototype.

---

## 12. Recommended Astra Build Sequence

1. Audit the folder and report discovered assets without renaming or deleting anything.
2. Create the Godot project structure, Input Map, autoloads, and debug scene.
3. Implement player movement and aim.
4. Implement the shared weapon interface, fists, bat, and pistol.
5. Implement damage, wounded state, death, and restart.
6. Implement one compact vehicle and entry/exit.
7. Build the gray-box district.
8. Add civilians with wander and panic states.
9. Add police detection, pursuit, attack, and Heat 0–2.
10. Add Money, Notoriety, clock, and live score HUD.
11. Add one complete Boost mission.
12. Add dawn/results/restart.
13. Expand police to Heat 4, add two vehicles and two mission templates.
14. Integrate radio assets and presentation polish.

At the end of every step, run the project, fix parser/runtime errors, and leave a short status note describing what works, what remains placeholder, and the next test.

---

## 13. Copy-Paste Astra Kickoff Prompt

```text
You are building the first playable baseline of PARDON ME, a top-down 2D arcade action score-attack in Godot 4.x.

Before editing anything:
1. Inspect the entire project folder.
2. Identify the Godot version, existing files, radio station logos, audio tracks, and game logo.
3. Preserve all supplied assets exactly. Do not delete, overwrite, rename, or regenerate them.
4. Report the proposed scene tree, scripts, data resources, Input Map actions, and implementation sequence.

Core fantasy:
The player has one repeating 24-hour pardon to make money and become notorious while local police—unaware of the pardon—respond normally. A run lasts 12 real minutes. Final score is Money × Notoriety, with a 25% bonus for reaching dawn.

The first implementation must prove three things together:
- Lethal, satisfying top-down melee/gun combat
- Immediate arcade vehicle entry, driving, collisions, and escape
- A complete Money/Notoriety/Heat score loop

Read and follow Pardon_Me_Astra_Kickoff_Pack.md as the authoritative scope and acceptance document.

Technical requirements:
- Godot 4.x with typed GDScript
- Keyboard/mouse first, but define controller-ready Input Map actions
- 1280×720 baseline with scalable UI
- Modular scenes and systems; no monolithic god script
- Signals for cross-system communication
- Data-driven weapons, vehicles, missions, run configuration, and radio stations
- Seeded mission selection and a visible seed on the results screen
- Debug overlay for player state, Heat, mission, vehicle health, and seed
- No silent placeholder implementations
- Never perform destructive filesystem or git operations
- Preserve unrelated user work

Begin only with Goal A: the movement toy.
Implement player movement, independent mouse aiming, fists, baseball bat, pistol, damage, wounded state, death/restart, one compact vehicle, and vehicle entry/exit in a small test arena. Use placeholders where supplied art is not applicable.

Do not implement the full city, mission pool, meta-progression, time-loop narrative, flamethrower, fire propagation, radio reactivity, or advanced UI yet.

After Goal A:
1. Run the project and fix all parser/runtime errors.
2. Verify each acceptance criterion directly.
3. Provide exact controls.
4. List created/modified files.
5. Note honest limitations.
6. Stop and wait for playtest feedback before beginning Goal B.
```

---

## 14. Tonight's Decision Rule

Do not judge the project by how many systems Astra produces. Judge it by the first five minutes with the movement toy.

Continue if:

- The bat feels excellent.
- Entering a car is immediate.
- Driving through a hostile space creates instinctive laughter or panic.
- A pistol feels powerful without replacing melee.
- Death makes you want to restart.

If those are not true, keep iterating on Goal A. No amount of mission content, radio lore, or procedural variety can repair a weak physical foundation.
