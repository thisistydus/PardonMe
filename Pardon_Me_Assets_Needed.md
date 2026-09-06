# Asset & Clarification Requests — Pardon Me

Prioritized by blocking impact for the game-jam baseline. This is a living production file and should be updated whenever an asset is added, replaced, or ruled unnecessary.

## Goal B+ asset status — 2026-09-06

The first district is playable using existing source assets and explicit procedural substitutes. Earlier requests below remain unresolved for final production unless marked here.

- **Map-playtest blocker resolved:** authored code-drawn street grid, sidewalks, buildings, car-only gates, parking marks, plaza cover, three phones, garage/storefront zones and visible outer boundary now support traversal and mission testing. A finished city environment kit remains needed.
- **Population-playtest blocker resolved:** code-drawn civilian, hostile and police silhouettes plus alert marks, state labels and shot telegraphs are integrated. Authored character sets, full animations and civilian variants remain needed.
- **Vehicle variety substitute:** original compact sprite and handling remain; blue sedan variants and a striped patrol compact use data differences. Seven cars are enterable. Distinct sedan/cruiser art and authored wrecks remain requested. No new supplied-image edits or regeneration.
- **Navigation/HUD blocker resolved:** north-up map, world objective ring, Money×Notoriety, Heat/search, Boost objective and expanded debug/results data are implemented. Map/UI are code-drawn in the existing cream/ink/red/gold palette. Full dawn/results art and title presentation remain deferred.
- **Mission-playtest blocker resolved:** one Boost definition and success/failure/retry behavior. Robbery zone is only a marked location; robbery content/art remain future needs.
- **Feedback substitute:** synthesized report/Heat/police alert/search/escape/mission/reward cues added. Original four songs/logos and their existing derived Ogg streams remain intact. Authored Foley, voice, mix/volume controls and additional music are still polish needs.

See `docs/GOAL_B_PLAYTEST.md` for verified behavior and limits. No additional external assets block the district feel test.

## Goal A asset status — 2026-09-05

No additional source art is blocking the movement-toy playtest. Existing requests below remain recorded for later milestones; temporary substitutes do not resolve the final asset needs.

| Request | Goal A replacement / status |
| --- | --- |
| Player animation | Generated red-jacket sprite with procedural sway, independent aim and wound flash; full animation set still needed |
| Bat/fists/pistol | Procedural held/pickup drawings and HUD labels; temporary |
| Compact | Generated olive/cream overhead sprite drawn 92×48 over unchanged 86×44 collision footprint; +X forward, center pivot, doors at (−4, ±48); authored wreck still needed |
| Enemies | Generated overhead practice-target sprite, tint and telegraph for stationary shooter; city characters deferred |
| Combat effects | Code-drawn melee arc, muzzle flash, swept tracer, sparks, hit pause, camera shake |
| Impact audio | Synthesized bat, fist, gun, injury, collision, interaction effects and simple engine loop; authored audio still needed for a production mix |
| Environment | Small code-drawn collision yard and cover; district art deferred |
| UI | Cream/ink/gold test HUD, pause/death panel and debug overlay; radio card now uses all four supplied logos; title/results art integration deferred |

### Playtest revision 1 substitutes

- Added spinning thrown-weapon visuals for bat and pistol; landed weapons reuse the existing pickups. Final throw/landing art and impact Foley remain polish needs.
- Added airborne target tumble, ground shadow and simulated height for high-speed impacts. This is a procedural placeholder, not a ragdoll asset request.
- Added a smoke/countdown warning, expanding blast ring, burst/smoke effect, synthesized explosion and warning beep, and charred wreck drawing. These unblock explosion testing; authored explosion and wreck assets remain requested for the final look.
- No supplied image or music file was modified, replaced, or regenerated.

### Art and radio revision 2 — 2026-09-06

- New selected source PNGs: `Art/Generated/player_v1.png`, `compact_final.png`, `practice_target_final.png`. Builtin image generation produced the assets; genuine alpha was inspected and recorded in `docs/art_alpha_inspection.json`. Earlier variants remain preserved but are not used at runtime.
- Characters draw at approximately 44–48 world units, the compact at 92×48. `scripts/world/sprite_art.gd` records source regions to omit transparent padding without modifying PNG bytes. These are static poses with procedural motion, not complete sprite sheets.
- Four original station logos are imported directly. `data/radio/library.tres` and four station resources pair them with their track titles and supported streams.
- One derived Ogg per station is under `Music/Imported`; `tools/convert_radio.py` records the reproducible, non-overwriting conversion. `docs/radio_conversion.json` records source/output metadata. A project-local pinned FFmpeg utility under `.tools` was used only for conversion, is excluded from Godot, and is not needed to play.
- Number row/keypad 1–4 selects stations, 5 Off; C/right shoulder cycles. A persistent upper-right logo/track card appears only while in the car. Every station begins at a random broadcast offset and advances virtually between selections. No further songs or logos are blocking this radio playtest.
- Remaining art needs: a coherent full animation set, authored wreck and explosion effects, environment kit and final weapon art. Remaining audio needs: authored Foley, balanced mix and volume controls.

### Supplied file audit

- Five PNG logos, each **1536×1024**, under `Art/Logos`: `Pardon_Me_Logo_v1.png`, `TheAnvil.png`, `Backspin.png`, `K-Buck.png`, `Pulse.png`.
- Four PNG mockups, each **1672×941**, under `Mockups`: title, gameplay, favors, results. These are visual references only.
- Four source tracks under `Music`, all **Opus audio in MP4/M4A containers** (container inspection, not listening verification):
  - `Warranty Void.m4a` — 342.80 seconds.
  - `Ask for the Receipt.m4a` — 271.53 seconds.
  - `The Devil Can't Drive My Truck.m4a` — 318.96 seconds.
  - `Airplane Mode.m4a` — 259.08 seconds.
- The title-to-station mapping is not explicitly stored in a supplied manifest. Likely associations from filenames are Anvil/Warranty Void, Backspin/Ask for the Receipt, K-Buck/The Devil Can't Drive My Truck, Pulse/Airplane Mode; these associations were **inferred from filenames** and are now integrated as the announced default for revision 2.
- **Resolved in revision 2:** full FFmpeg decode checks and Godot playback verified the separate Ogg Vorbis derivatives. End-to-start looping was tested. No authored seamless loop points or track loudness normalization are claimed; the original M4As remain byte-identical.
- SHA-256 baseline of all supplied files: `docs/supplied_files_sha256.json`. The two living production documents are the only supplied files intentionally edited.

### Scope correction

The authoritative kickoff limits Goal A to fists, bat, pistol and compact. Knife/shotgun and the other two vehicles belong to later MVP steps. The older crowbar request below is not a locked MVP prerequisite. Do not commission bulk art until the movement toy receives feedback.

## Already Supplied

- **Game logo:** Pardon Me v1
- **Radio station logos:** 96.9 The Anvil, Backspin 98, K-Buck, Pulse
- **Radio music:** One corresponding song for each of the four stations

These files should be discovered in the project before implementation. Preserve their filenames and original bytes unless Tydus explicitly approves a change.

---

## 1. Player Placeholder or Sprite Set — Blocking

**Needed for:** movement, aiming, melee, weapon holding, vehicle entry/exit, wounded state, death.

### Minimum jam specification

- One top-down player design
- Idle and run
- Four-direction or eight-direction presentation
- Melee swing
- Firearm aim/fire
- Wounded feedback
- Death/downed frame
- Visual pivot and hand positions documented

### Acceptable first-pass substitute

A clean colored capsule or simple procedural silhouette with an aim indicator. Astra should not spend coding time generating detailed animation art before movement feel is approved.

---

## 2. Combat Effects — Blocking for Feel Review

**Needed for:** determining whether the physical foundation is satisfying.

### Minimum set

- Melee arc or swipe
- Generic impact burst
- Bullet tracer/projectile
- Muzzle flash
- Hit flash
- Bloodless damage marker or stylized debris
- Wounded-state effect
- Death effect
- Small explosion
- Smoke particles

### Clarification needed later

Choose the final violence presentation: abstract arcade effects, stylized blood, or an accessibility-selectable combination.

---

## 3. Melee Weapons — Blocking for Jam Baseline

### Required

- Fists or shove representation
- Baseball bat
- Knife
- Crowbar

Each weapon needs a world pickup sprite, held sprite, and HUD icon. These may reuse the same source art if it remains readable.

### Post-baseline candidates

- Hammer
- Machete
- Tire iron
- Fire axe
- Golf club
- Broken bottle
- Stun baton
- Improvised street objects

---

## 4. Firearms — Blocking for Jam Baseline

### Required

- Pistol
- Shotgun

### Strong stretch goal

- Automatic weapon or SMG

### Later candidates

- Revolver
- Sawed-off shotgun
- Rifle
- Grenade launcher
- Flamethrower

Each firearm needs world, held, and HUD presentation. The flamethrower additionally requires flame stream, burning state, contact ignition, smoke, and tagged environmental-fire assets.

---

## 5. Vehicles — Blocking

### Required base designs

- Compact
- Sedan
- Police cruiser

### Required states

- Healthy
- Smoking
- Critical
- Disabled or destroyed

### Minimum visual requirements

- Clean top-down silhouette
- Consistent scale and pivot
- Driver position documented
- Collision footprint documented
- Brake lights optional for jam
- Palette variants optional

### Post-jam additions

- Muscle car
- Van
- Taxi or delivery vehicle
- Civilian color variants

---

## 6. Characters — Blocking for Hostile-City Milestone

### Required archetypes

- Four civilian appearances or one base with four strong palette/clothing variants
- One patrol officer
- One armed/tactical police variant
- One mission-contact or criminal variant

### Minimum animation states

- Idle
- Walk/run
- Panic/flee
- Attack for police/criminals
- Downed/death

Shared skeletons and animation sets are encouraged.

---

## 7. Gray-Box Environment Kit — Blocking

### Required

- Road straight, corner, intersection, and markings
- Sidewalk and curb
- Alley surface
- Building collision/roof blocks
- Parking spaces
- Garage delivery zone
- Storefront robbery marker
- Payphone
- Police spawn marker visible only in debug
- Basic cover props: dumpster, barrier, parked-object proxy

The first map should prioritize chase geometry and readable collision over architectural detail.

---

## 8. Environment Art Pass — Polish

### Solid proof target

- 35–45 modular road, sidewalk, roof, and facade assets
- 20–25 props and decals
- One central intersection identity
- One plaza or park
- One delivery garage
- Two storefront exteriors
- Four payphone placements
- Alleys visually distinct from roads

### Shared-world opportunities

- Posters for fictional artists
- Radio station billboards
- Recurring companies and products
- Government signage supporting the pardon premise

---

## 9. HUD and Interface — Blocking for Score-Loop Milestone

### Required screens/components

- Title screen using supplied logo
- Time-of-day and countdown display
- Money display
- Notoriety multiplier and progress
- Live score equation
- Heat indicator, levels 0–4
- Held weapon and ammunition
- Mission objective card
- Radio station card using supplied station logos
- Death screen
- Dawn/results screen
- Personal-best indicator
- Debug overlay

### Visual direction

Warm cream, near-black, muted bureaucratic red, and dirty gold. Government paperwork and municipal stamps disrupted by aggressive arcade motion. Do not imitate a specific GTA interface.

---

## 10. Audio — Partially Supplied

### Already supplied

- Four station songs

### Blocking for feel review

- Bat swing and impact
- Knife attack and impact
- Pistol shot
- Shotgun shot
- Bullet impact
- Player wounded/death
- Vehicle engine loop
- Tire skid
- Vehicle collision, light/heavy
- Police siren
- UI Money gain
- UI Notoriety increase
- UI Heat increase
- Mission accept/complete

### Polish

- Civilian panic barks
- Police commands
- Dispatcher lines
- DJ identifiers
- Station-change stingers
- City ambience
- Additional fictional songs and commercials

---

## 11. Narrative and Text — Non-Blocking

### Required before public jam build

- One opening pardon card
- One time-loop reset line
- Six mission descriptions
- Notoriety tier names
- Results labels
- Basic content warning and controls

### Later

- Reactive radio lines
- Recurring advertisements
- Newspaper headlines
- Déjà vu variants
- Time-loop mystery fragments
- Shared-universe references

---

## 12. Asset Import Standards — Must Be Decided Before Bulk Production

- Working resolution and pixel density
- Character and vehicle scale
- Sprite pivot convention
- Direction-count convention
- Texture filtering policy
- PNG transparency and alpha cleanup
- Audio loudness target
- Loop-point standard for music
- Naming convention and folder structure

Do not commission or generate large sprite batches until a single player, enemy, vehicle, and environment sample have been tested together in-engine.

