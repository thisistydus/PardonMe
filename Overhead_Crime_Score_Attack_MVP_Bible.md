# PARDON ME

## Game Jam MVP Bible — Second Pass

**Studio context:** Amigo Park Experiment  
**Format:** Single-player top-down arcade action roguelite  
**Target engine:** Godot 4.x  
**Jam context:** Amnesia Fortnight-style sprint  
**Target run:** 12–18 minutes  
**Core score:** Money × Notoriety  
**Current tagline:** *Everything is forgiven—if you live until morning.*

---

## 1. The Pitch

You helped local authorities arrest the most powerful criminal in the city. In exchange, you received an impossible reward: immunity from prosecution for anything you do during the next 24 hours.

There is one problem. The local police were never told.

You have one day to steal as much money and build as much Notoriety as possible while beat cops, tactical units, betrayed criminals, and an increasingly hysterical city try to stop you. If you survive until dawn, the agreement becomes public and you keep everything.

Then morning begins again.

**Pardon Me** is a top-down action roguelite combining the lethal speed and physical commitment of *Hotline Miami*, the projectile chaos and weapon improvisation of *Nuclear Throne*, and the driving, police escalation, and civic satire of early *Grand Theft Auto*.

It is not a miniature lifestyle simulator. It is a violent arcade toy set in a city that reacts dramatically to the player's decisions.

### Design thesis

> Make money. Become notorious. Survive the same legally protected day until you are finally good enough to ruin it properly.

### Why this game now

As large open-world crime games increasingly emphasize realism, simulation, and lifestyle detail, **Pardon Me** occupies the opposite space: immediate controls, compressed geography, disposable vehicles, fragile bodies, exaggerated weapons, rapid restarts, and score-chasing nonsense.

---

## 2. Player Fantasy and Tone

The player is not gradually becoming an untouchable crime lord. They are improvising through the most consequential day of their life, repeatedly.

The desired tone is mechanically intense, structurally arcade-like, comedically bureaucratic, violent but visually stylized, and rich in fictional brands, radio personalities, and civic detail.

The central joke is that the city maintains a veneer of politeness and procedure while experiencing complete bedlam. The title works as both the protagonist's legal status and the sarcastic apology accompanying reckless driving.

### Tone guardrail

The game should reward daring criminal spectacle, not make civilian suffering the optimal scoring strategy. Random violence creates Heat and systemic consequences, but valuable Notoriety comes primarily from missions, pursuit feats, skillful chains, and authored acts of chaos.

---

## 3. The Time Loop

The pardon applies to one calendar day. At dawn—or upon death—the protagonist wakes on the same morning with the same document waiting nearby. The city returns, but the day's opportunities, mission availability, item placement, and certain events are rearranged.

The game does not initially explain the loop. Its existence can be established with a single impossible clause:

> This agreement remains valid for one calendar day, including any recurrence thereof.

The mystery may later involve the arrested crime boss, the district attorney, a supernatural technicality, or something embedded in the agreement. The jam build does not need to answer it.

### Narrative function

The loop explains immediate restarts, randomized missions, repeated versions of the city, horizontal meta-progression, radio déjà vu, and the player's growing knowledge.

### What persists

Money and Notoriety reset because they define each run's score. The player retains:

- Records and completed challenges
- Unlocked starting favors
- New mission possibilities
- Cosmetic options
- Fragments of story and radio continuity

The player's real permanent advantage is knowledge of the map, weapons, vehicles, police behavior, and mission possibilities.

---

## 4. Core Game Loop

1. **Wake up:** Receive the pardon and select one unlocked starting favor.
2. **Enter the district:** Begin on foot near several readable opportunities.
3. **Acquire resources:** Steal a vehicle, find a weapon, rob a target, or accept a mission.
4. **Earn Money:** Take cash, fence vehicles, complete profitable crimes, and secure valuables.
5. **Build Notoriety:** Complete missions and perform varied high-risk feats.
6. **Create Heat:** Visible crimes provoke increasingly dangerous police responses.
7. **Improvise:** Switch between melee weapons, firearms, vehicles, items, and environmental hazards.
8. **Push the run:** Attempt harder and more valuable work as the day advances.
9. **Reach dawn, die, or get arrested.**
10. **Calculate score:** Money × Notoriety, plus clearly stated bonuses.
11. **Earn Leverage:** Complete challenges that unlock new starting choices.
12. **Wake up again.**

### The intended decision every 20–40 seconds

- Do I pursue Money or Notoriety next?
- Is this weapon worth changing my approach for?
- Can I maintain momentum without letting Heat become lethal?
- Is my current vehicle protection or a burning coffin?
- Is this mission worth the time remaining?
- Do I bank carried Money or keep pushing?

### Starting state

Each run begins on foot, at zero Heat and ×1 Notoriety, with basic unarmed capability and at least two low-risk opportunities nearby. The first meaningful action should occur within 15 seconds.

---

## 5. Score Economy

| Meter | How it grows | What it does |
| --- | --- | --- |
| **Money** | Robberies, payouts, fenced cars, valuables | Provides the base score |
| **Notoriety** | Missions, diverse crime chains, pursuit feats | Multiplies Money |
| **Heat** | Witnessed crimes, gunfire, police attacks, destruction | Determines police response |

### Final score

> **Final Score = Secured Money × Notoriety + Bonuses**

Example: $18,400 secured at ×7 Notoriety produces a base score of 128,800.

Money makes the run materially successful. Notoriety makes it legendary. Heat is the hostile pressure created while pursuing both.

### Money states

- **Carried Money:** Can be lost through arrest and may be lost at death.
- **Secured Money:** Deposited at a safehouse, corrupt bank, or fence and guaranteed to count.

Securing Money costs time and interrupts the action chain. This creates a choice between protecting a good run and preserving momentum. For the jam, death should still record a meaningful score rather than erase an entertaining failure.

### Notoriety

Notoriety never decays during a run. It represents the story the city will tell about this version of the day.

| Multiplier | Working title |
| ---: | --- |
| ×1 | Nobody |
| ×2 | Suspect |
| ×3 | Offender |
| ×4 | Menace |
| ×5 | Public Enemy |
| ×6 | Citywide Problem |
| ×7+ | Increasingly absurd civic labels |

Missions grant large, predictable gains. Smaller feats fill progress toward the next multiplier:

- Escape a sustained pursuit
- Destroy or bypass a roadblock
- Complete an objective with a burning vehicle
- Steal a police vehicle during active pursuit
- Chain several different crimes
- Finish an optional mission condition
- Use an environmental hazard effectively

Repeated safe actions have diminishing returns. Civilian casualties create Heat without providing efficient Notoriety.

### Sparse score bonuses

- Dawn survival
- No arrest
- No starting favor
- Mission variety
- Highest Heat survived
- Exceptional feat badges

Money × Notoriety remains the dominant source of score.

---

## 6. The Clock

The fictional 24 hours occur across approximately 12–18 real minutes. Each period changes traffic, mission availability, police behavior, lighting, and radio presentation.

| Period | Function |
| --- | --- |
| Morning | Low-risk setup and introductory missions |
| Afternoon | Broader mission pool; criminal retaliation begins |
| Evening | Valuable jobs and heavier police response |
| Night | Maximum-risk missions and unusual weapons |
| Dawn | Score resolution and loop restart |

Time flows continuously. Missions should consume fixed time only if playtesting shows that continuous time alone does not create meaningful opportunity cost.

---

## 7. Mission Pool

The city contains more missions than can be completed in one day. Each loop presents a selection based on time, prior actions, Notoriety, and controlled randomness.

### Target structure

- 6–8 missions offered during a normal run
- 3–5 realistically completable
- Some mutually exclusive opportunities
- Short chains with alternate later steps
- Higher-value work unlocked by Notoriety
- Late-night capstone jobs influenced by earlier behavior

### Reusable templates

1. **Boost:** Steal a marked vehicle and deliver it.
2. **Rob:** Enter a business, take the cash, and escape.
3. **Courier:** Collect and deliver a package before time expires.
4. **Destroy:** Eliminate a vehicle, object, or small location.
5. **Getaway:** Collect offenders and lose pursuit.
6. **Hit:** Eliminate or disable a marked target.
7. **Intimidate:** Cause enough controlled damage to force compliance.
8. **Raid:** Enter a high-risk location, take an object, and escape.

The jam target is three polished templates and six configurations. A fuller prototype can grow toward 20–30 configurations before needing more mission code.

### Variables

- Start, target, and destination
- Required weapon or vehicle class
- Time allowance
- Police-response modifier
- Rival involvement
- Optional objective
- Money and Notoriety payout
- Time-of-day availability
- Follow-up flags

Payphones are the primary jam delivery method. Later sources may include radio calls, contacts, pagers, police scanners, and street events.

---

## 8. Combat Philosophy

Combat should feel immediate, lethal, physical, and improvisational. The player uses whatever is nearby rather than preserving a perfect build.

| Approach | Strength | Cost |
| --- | --- | --- |
| Melee | Quiet, fast, no ammunition | Requires proximity and commitment |
| Guns | Reliable range and crowd control | Scarce ammo and rapid Heat |
| Vehicles | Mobility, armor, impact damage | Poor precision and high visibility |
| Heavy weapons | Exceptional chaos and Notoriety potential | Rare and immediately escalatory |

### Lethality

Recommended starting model:

- The first bullet causes a wounded state with severe feedback and a brief grace period.
- The second bullet kills.
- Body armor absorbs one hit.
- A rare first-aid item clears the wounded state.
- Enemies generally die from one clean shot or a few readable melee impacts.

Difficulty comes from positioning, timing, numbers, and chaos rather than health bars.

### Melee emphasis

Melee is not a fallback. It should be the fastest and most satisfying method at close range, supported by strong animation timing, hit pause, sound, knockback, and environmental interaction.

**Jam set:** fists/shove, baseball bat, knife, crowbar.

**Expanded set:** hammer, machete, tire iron, fire axe, golf club, broken bottle, stun baton, and improvised street objects.

Weapons differ through reach, swing time, recovery, knockback, noise, and special behavior—not incremental rarity statistics.

### Gunplay

Gunplay uses twin-stick or mouse aiming, readable projectiles, controller assistance, and ranges appropriate to the screen.

**Jam set:** pistol and shotgun; automatic weapon as a strong stretch goal.

**Later:** revolver, sawed-off shotgun, SMG, rifle, grenade launcher, flamethrower.

### Fire propagation

The flamethrower creates moving hazards rather than merely applying damage. Burning NPCs:

1. Flee from the original source.
2. Ignite another character after sustained contact.
3. Ignite specifically tagged environmental objects.
4. May enter traffic or disrupt combat formations.
5. Expire after a short, predictable duration.

Propagation is capped by duration, contact time, and valid targets. It should create spectacular incidents without becoming the only optimal strategy or causing runaway performance costs. For the jam, it is a stretch goal and must not block the complete score loop.

---

## 9. Driving

Cars are disposable weapons, armor, escape tools, and temporary identities. The player should frequently abandon a damaged or recognized car.

### Vehicle classes

1. Compact — agile, common, fragile
2. Sedan — balanced baseline
3. Muscle car — fast, poor turning, valuable
4. Van — slow, durable, mission utility
5. Police cruiser — strong but instantly escalates Heat when stolen

Required behavior includes immediate entry/exit, responsive arcade handling, clear collisions, pedestrian and prop impacts, readable vehicle damage, police identification, and vehicle swapping as a pursuit tactic.

The game preserves consequence without preserving the clumsy controls of its inspirations.

---

## 10. Police and Heat

Police Heat is the dynamic difficulty curve. It rises through witnessed crimes, gunfire, civilian harm, destruction, attacks on police, and repeated visible offenses.

| Heat | Response |
| ---: | --- |
| 0 | Ambient patrols |
| 1 | One nearby unit investigates |
| 2 | Active vehicle and foot pursuit |
| 3 | Reinforcements and roadblocks |
| 4 | Tactical response and broad search |
| 5 | Near-continuous citywide manhunt |

Losing police requires breaking line of sight, leaving the search radius, changing identified vehicles, using alleys, and avoiding new visible crimes during cooldown. Heat can fall, but the day's response floor may rise after major missions.

### Arrest

Arrest damages rather than necessarily ends a run. Officers process the protagonist until a higher authority forces their release.

Potential costs include several in-game hours, all carried Money, current equipment, the active chain, and a higher minimum Heat. Death ends the run; arrest mutilates it and permits a desperate comeback.

---

## 11. Roguelite and Meta-Progression

**Pardon Me** is an arcade score attack with roguelite structure. It uses shuffled opportunities, quick iteration, and horizontal unlocks without loot tiers or permanent stat inflation.

### Randomized each loop

- Mission selection, placement, and optional objectives
- Weapon and item locations
- Valuable target vehicles
- Patrol starting positions
- Temporary street events
- One announced daily modifier
- Late-night capstone options

### Consistent between loops

- Map geometry and shortcuts
- Weapon behavior
- Vehicle handling
- Damage rules
- Police logic
- Scoring math

### Leverage and starting favors

Challenges earn **Leverage**, representing information and relationships remembered across loops. Leverage unlocks choices rather than stacking statistics:

- Body armor
- Chosen melee weapon
- Pistol with limited ammunition
- Nearby starter vehicle
- Police scanner
- One revealed mission
- Alternate starting location
- Small starting cash reserve

The player selects one favor at the beginning, eventually perhaps two. Strong favors may reduce final score; selecting none may grant a modest bonus. Meta-progression assists learning without invalidating high-level runs.

---

## 12. World and Radio Identity

### District

A fictional late-1980s or early-1990s coastal downtown comprising four to six dense blocks rather than literal city scale.

The proof district contains one major intersection, two chase routes, two pedestrian shortcuts, a parking lot, a plaza, a police-adjacent danger zone, a delivery garage, three shallow interiors, six payphones, and several deposit points.

### Shared radio universe

Radio is the primary vessel for humor, lore, and continuity. Existing station identities such as **96.9 The Anvil**, **Backspin 98**, **K-Buck**, and **Pulse** can recur across Amigo Park projects without requiring shared plots.

Radio provides fictional music and artists, recurring advertisement arcs, DJ reactions, police bulletins, mission offers, alternate loop broadcasts, subtle déjà vu, and connections among brands and public figures across games.

The jam needs one station identity, one short music loop, several DJ lines, and police interruptions. A full radio library is future-facing content, not a jam dependency.

---

## 13. Jam Scope

### Must ship

- One compact district
- One 12–15 minute accelerated day
- Responsive movement
- Four melee options including fists
- Two firearms
- Three drivable vehicle classes
- Basic civilian navigation and panic
- Five Heat levels
- Police pursuit on foot and in vehicles
- Three mission templates with six configurations
- Money, Notoriety, and score calculation
- One deposit point
- Death, arrest, and dawn outcomes
- One starting favor
- Rapid restart and results screen
- Placeholder or first-pass radio identity

### Strong stretch goals

- Third firearm and more melee weapons
- One daily modifier
- Capstone job
- Police scanner
- Newspaper result page
- Dynamic radio responses
- Environmental fire propagation

### Outside the jam

- Multiple districts
- Procedural maps
- Full campaign or time-loop explanation
- Complex dialogue and inventory
- Loot rarity tiers
- Permanent health or damage upgrades
- Sophisticated traffic simulation
- Online leaderboards
- Dozens of radio tracks

---

## 14. Asset Budget

### Jam-ready target

| Category | Target |
| --- | ---: |
| Modular environment tiles/facades | 35–45 |
| Street props and decals | 20–25 |
| Player character | 1 animated set |
| Civilian archetypes | 4 plus palette variants |
| Police archetypes | 2 |
| Criminal/contact designs | 2 |
| Vehicles | 3 plus police variant |
| Melee weapons | 4 |
| Firearms | 2–3 |
| Pickups/favors | 4–6 |
| Effects | 8–12 |
| HUD/menu components | 20–25 |
| Music | 1–2 loops or layered tracks |
| Sound effects | 35–50 |
| Radio/voice lines | 12–20 |

Prioritize animation feel, impacts, readable projectiles, vehicle handling, and scoring feedback over decorative variety.

### Solid proof-of-concept target

| Category | Target |
| --- | ---: |
| Visual source assets | 170–220 |
| Audio files | 75–100 |
| Base characters | 16 |
| Base vehicles | 8, yielding roughly 18 variants |
| Melee weapons | 8–10 |
| Firearms/heavy weapons | 6–8 |
| Mission configurations | 20–30 |
| Radio songs | 6–10 |
| Commercials/interstitials | 10–15 |
| Headlines, ads, names, short text | 150+ pieces |

---

## 15. Technical Systems

### Essential

- Player movement, aiming, melee, damage, and death
- Weapon pickup and swapping
- Vehicle entry, exit, handling, damage, destruction
- Civilian navigation and panic
- Police detection, pursuit, search, attack, reinforcement
- Heat state machine
- Mission-template framework
- Money and deposit system
- Notoriety progression
- Day clock and time-of-day events
- Controlled-random run director
- Arrest and release
- Results and high-score storage
- Rapid seeded restart

### Deferrable

- Advanced fire propagation
- Rival-faction simulation
- Dynamic radio assembly beyond state triggers
- Persistent narrative tracking
- Multiple districts and online services
- Sophisticated civilian driving
- Deep inventory or weapon modification

---

## 16. Production Order

### Milestone 1 — The violent toy

Prove that moving, swinging one melee weapon, firing one gun, stealing one car, and being pursued by one officer already feels good.

### Milestone 2 — The scoring loop

Add Money, Notoriety, Heat, one mission, the clock, death, and final score. A complete ugly run is more valuable than an attractive disconnected sandbox.

### Milestone 3 — The jam game

Add the district, three mission templates, weapon variety, arrest, deposit, civilian panic, five Heat levels, one favor, audio, and results presentation.

### Milestone 4 — Systemic spectacle

If time remains, add fire propagation, roadblocks, a capstone mission, dynamic radio, and newspaper results.

---

## 17. Success Criteria

The jam succeeds if:

1. The first crime happens within 15 seconds.
2. Melee feels satisfying before content variety is considered.
3. Driving creates escape options and accidental comedy.
4. Players understand Money, Notoriety, and Heat.
5. Money × Notoriety makes players alternate between profit and spectacle.
6. Players knowingly take one more dangerous opportunity late in the day.
7. A run cannot consume all available mission content.
8. Death produces an immediate restart.
9. Players recount a systemic incident afterward.
10. Dawn feels like a complete ending, not a fragment of a campaign.

### Warning signs

- Guns make melee irrelevant.
- Melee enemies are passive targets.
- Random civilian harm is the best Notoriety strategy.
- Fire eclipses every other weapon.
- Police appear without readable logic.
- One vehicle solves every pursuit.
- Meta-progression becomes required.
- Mission travel outweighs execution.
- Loot collection replaces momentum.

---

## 18. Open Questions

1. Does death score carried Money, secured Money only, or apply a percentage penalty?
2. How much time should arrest remove?
3. Do missions grant full Notoriety tiers or progress?
4. How many melee weapons feel meaningfully distinct within the jam?
5. Can enemies pick up dropped weapons?
6. Does the player carry one melee weapon and one firearm, or one weapon total?
7. Does an action chain affect Notoriety or a separate bonus?
8. How visible should the time-loop mystery be initially?
9. Can the player voluntarily end active play at a safehouse?
10. Should starting favors reduce score, grant challenge bonuses, or remain neutral?

---

## 19. Current Recommendation

Build **Pardon Me** first as a complete score loop:

> Wake up. Choose one advantage. Take a weapon. Steal a car. Earn Money. Complete missions for Notoriety. Survive the Heat. Reach dawn. Multiply the result. Wake up again.

The game's strongest potential is the collision between precise lethal combat and imprecise urban chaos. Every system should contribute to the temptation to attempt one more job, steal one more car, or turn one manageable fire into a citywide problem before morning.

