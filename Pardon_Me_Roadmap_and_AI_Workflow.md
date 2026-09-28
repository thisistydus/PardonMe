# PARDON ME — Roadmap, Next Milestone, and an AI-Workflow Assessment

**Written:** 2026-09-26, by Claude Code (Sonnet 5), as a non-interactive exploratory pass.
**Scope of this document:** compare the stated vision (the MVP Bible and Astra Kickoff Pack) against the actual current build (Goal B.5, dated 2026-09-07), verify that comparison against the live project rather than only the docs, and recommend what to build next and how.

---

## 0. What was actually checked before writing this

Docs alone are not evidence — this project's own culture agrees (see `Pardon_Me_Known_Limitations.md` §19). So before writing any recommendation below, the following was run against the live tree, today:

- Read all five top-level strategy docs and all seven `docs/` build logs.
- Confirmed the installed engine (`/Applications/Godot.app`, `4.7.stable.official.5b4e0cb0f`) matches the pinned version in `README.md`.
- Ran `godot --headless --import` — clean, no errors.
- Ran `tests/district_integration.tscn` headlessly — **41/41 checks passed**, matching the count recorded in `docs/GOAL_B_PLAYTEST.md`.
- Read four of the dated `screenshots/2026-09-07_PardonMe_B5_*.png` captures (on-foot pursuit, cruiser pursuit, roadblock, barrel/vehicle chain) to see the actual pixels, not just the prose describing them.
- Read the largest gameplay scripts (`compact.gd`, `npc.gd`, `player.gd`, `district_game.gd`) and grepped the full `scripts/` and `data/` trees for `day_night`, `CanvasModulate`, `dawn`, `faction`, `leverage`, `notoriety_tier`, `arrest`, and mission-type classes beyond Boost.

Result: the docs are accurate. Nothing below contradicts them; this document exists to connect them to the original Bible and turn that gap into a sequenced plan. There are no commits yet in this repo (`git log` reports no history on `main`), so everything described here lives only in the working tree — worth committing before the next milestone starts.

---

## 1. The one-paragraph verdict

Pardon Me's **systems** are ahead of where most jam prototypes get to: a real Heat state machine with five coordinated police roles (pursuer, interceptor, search, containment, tactical), cruiser AI that follows a road graph, one roadblock per escalation tier, chained barrel/vehicle explosions with attribution, and a working (if single-mission) Money × Notoriety loop — all on a clean, modular, signal-and-resource-driven architecture with genuinely unusual self-testing discipline (228+ headless assertions retained across nine suites, re-verified today). Its **content and identity** are still Milestone-1 thin: one drivable vehicle model (a sedan and patrol car are the same texture with different numbers), three weapons, exactly one mission, no day/night cycle, no arrest flow, no factions, no meta-progression, and almost no authored art — three static generated sprites, everything else is code-drawn rectangles, diamonds, and permanent debug text. The next build should not add new systems. It should spend its entire budget widening the content that already lives inside the systems you have, and closing the run loop end-to-end so a full 12-minute day can actually be played twice in a row.

---

## 2. Vision vs. current build, pillar by pillar

| Vision pillar (from the Bible) | Bible target | What actually exists now (verified) | Gap |
| --- | --- | --- | --- |
| Interactive open world | 4–6 dense blocks, chase geometry over architecture | One 4800×3600 handcrafted district; roads, gates, plaza, garage, 3 phones — matches the *vertical-slice* target the Bible itself asks for | **On target** — this pillar was scoped correctly from day one |
| Missions raising/lowering faction standing | 8 reusable templates, 6–8 offered/run, faction reactions | One Boost mission, one configuration, no faction system exists in code at all | **Large** — nothing to extend yet except the template pattern |
| Multiple weapons | 4 melee + 2–3 firearms for jam baseline | Fists, bat, pistol (+ throw for both) | **Moderate** — knife and shotgun were explicitly scoped for this exact milestone and aren't in yet |
| Multiple vehicles | Compact, sedan, police cruiser as distinct classes | 1 art asset reused for all 3; sedan/patrol are `VehicleData` stat variants only | **Moderate** — the data layer is ready, the identity isn't |
| Day/night cycle | Lighting + activity gating by time of day | Not started — no `CanvasModulate`, no time-of-day hook anywhere in the codebase | **Large**, and untouched |
| Collectibles / side activities / secrets | Explicitly part of the final vision | Not started | **Large**, and untouched (correctly deferred — never promised for this phase) |
| Hotline-Miami melee feel | Fast, physical, satisfying at close range | Hit-pause, knockback, throw-to-recover, airborne launch are implemented and passed one ~40-minute human session (per `docs/GOAL_B5_PLAN.md`) | **Small-moderate** — mechanically real, but only one weapon is content-complete and no blind (non-dev) playtest has happened yet |
| Fun, responsive driving | Beat GTA1/2 on feel, not realism | Arcade `CharacterBody2D` handling, 4 damage states, warned explosion, chain reactions — implemented for the one vehicle | **Small** — feel is plausibly there; distinct-vehicle identity is the missing half |
| Roguelite meta-progression, run modifiers, mission pool variety | Central to replay value | Explicitly and repeatedly deferred in every doc; zero code exists | **Large**, but *honestly* deferred — this was never accidentally skipped, it was a deliberate scope decision documented every time |

---

## 3. What's genuinely working well — said plainly, because it's earned

- **The Heat/police stack is the hardest system in a GTA-like, and it already works.** Five coordinated officer roles, a cruiser AI that follows an actual road graph, one roadblock per Heat-4 escalation, shared player/NPC weapon code (`FirearmShot`) with honest finite ammo — and it's still regression-tested today (41/41 on `district_integration`, matching historical counts).
- **The architecture will not need a rewrite to grow.** 3,073 lines of GDScript spread across ~35 small, single-responsibility files (the largest, `compact.gd`, is 284 lines); typed `Resource` data for weapons/vehicles/missions/pressure tuning; `Events` as the only autoload; signals over polling. This is exactly the shape you want before 5–10x'ing content — the risk of the *next* milestone breaking the current one is low.
- **The project's own honesty habit is the real safety net.** `Known_Limitations.md` and `Assets_Needed.md` are dated, specific, and match the code — verified today by grepping for the systems they say don't exist yet (faction, day/night, arrest, Leverage: zero hits, exactly as claimed). That discipline is what keeps an AI-assisted codebase from quietly accumulating scaffolding that only *looks* finished. Keep doing this exactly as-is.

---

## 4. What needs attention before the vision becomes true

- **Visual identity is the actual risk to momentum right now — not a missing system.** Every screenshot reads as a debug build: olive/grey rectangles, one recolored car, permanent debug text over the action. The Bible itself says not to spend on final art until movement feels good (§Tonight's Decision Rule) — and by the B+/B.5 human session, it apparently does. That means this is now the natural next unblock, and it's an *art* pass targeted at systems already proven fun, not a new system.
- **The run loop doesn't close yet.** There's a live Money × Notoriety readout, but no day clock, no dawn, no results screen, no restart-with-persistence. Until that exists, nobody — including you — can honestly answer "is one more run worth it?", which is the single success criterion the Bible cares most about (§17, item 10: "Dawn feels like a complete ending"). This was already identified as Goal C in the Astra Kickoff Pack and has simply not been reached yet.
- **Content breadth belongs inside existing systems before new categories get added.** Two more mission templates using the proven Boost pattern, two distinct vehicle identities, two more weapons — all additive, all low-risk, all directly requested by the locked MVP parameters that haven't been touched yet.

---

## 5. Recommended next test build — "Milestone 4: The Closed Loop"

Following this project's own template (a named Goal with a locked scope and an explicit non-goal list):

**Question this build must answer:** does a complete, repeatable 12-minute day feel worth playing twice in a row?

**Must ship**
- A day clock (morning → dawn, ~12 real minutes) driven off the district time already tracked in the HUD.
- A dawn/results screen: money, notoriety, missions completed, peak Heat, restart — this is Bible §9's results-screen spec, none of which is built yet.
- Two more mission templates (**Rob**, **Destroy**) using the existing `BoostManager` as the pattern — the mission-manager shape is already proven, so this is repetition of a working pattern, not new design risk.
- Distinct sedan and patrol-car identity (art and/or silhouette, not just a stat variant of the compact texture) — the cheapest available fix for "this doesn't look like a debug build" that is also a design-locked vehicle class from the MVP parameters.

**Explicit non-goals for this build** (protecting scope the way every prior Goal doc does): no day/night lighting, no faction standing, no Leverage/meta-progression. Those come after the loop closes, not before.

**Sequencing note:** close the loop before the art pass. A results screen you can actually reach twice is more informative for testing than nicer sprites around a loop that still ends nowhere.

---

## 6. Milestone roadmap after that

- **Milestone 5 — Identity pass.** Full character/vehicle art roster, an authored environment kit replacing code-drawn rectangles, and the day/night lighting cycle (`CanvasModulate` + time-linked mission/activity gating — the Bible ties specific missions and risk levels to time of day, so this is content-shaping, not just cosmetic).
- **Milestone 6 — Faction and Notoriety depth.** Per-faction standing, missions that move it in both directions, and an actual arrest flow (currently death is the only failure state — arrest is fully specified in the Bible but has zero code).
- **Milestone 7 — Roguelite layer.** Leverage/starting favors, seeded mission-pool shuffling, one daily modifier, collectibles and secrets.
- **Milestone 8 — Production pass.** Full sprite animation, audio mix/Foley, physical-controller verification, export-template testing (desktop/web), performance pass at full NPC density.

---

## 7. What a predominantly-AI workflow is good for here, and what it isn't

This project is itself the evidence for both halves of this answer — Goals A through B.5 were all built this way.

**AI-strong, already proven on this codebase:**
- Systemic logic — state machines, coordinated AI roles, resource-driven data, mission templates, HUD wiring, and the regression suites that catch regressions before a human has to.
- Content scaffolding at volume — once one mission template or one vehicle class exists and is tested, generating five more configurations or two more vehicle datasets is mechanical repetition of a *proven* pattern. This is close to the ideal AI-assisted task: low design risk, high volume.
- Documentation and honesty discipline — the `Known_Limitations.md` / `Assets_Needed.md` habit *is* the safety rail that keeps AI-generated systems from being mistaken for finished design. It has held for seven build phases; keep it for the next seven.

**Still needs a human, even with AI doing the labor:**
- Subjective feel calls — "does the bat feel good" is a judgment this project has correctly refused to let an AI self-certify; every Goal doc ends with "stop and wait for human feedback" before scope grows, and that discipline is exactly why the systems underneath are trustworthy.
- Visual and art direction lock-in — the three selected sprites each went through a v1 → v2 → final revision cycle (documented in `docs/ART_PROMPTS.md`) before the orthographic projection actually read correctly. That iteration needed a human eye picking between generated candidates, not just a better prompt.
- Final audio mixing, licensed content, and balance tuning under real pressure (police difficulty, ammo scarcity) — `docs/GOAL_B5_PLAN.md` itself asks for exactly this kind of human pressure-test before the timed run gets added.

---

## 8. Where Opus 5.5 specifically would earn its keep on this project

This is being written by Sonnet 5, deliberately, to keep this exploratory/documentation pass cheap — and that split is itself the recommendation, not just an aside.

- **This project's own history shows where the expensive bugs hide.** `docs/DEVELOPMENT_CHECKPOINT.md` records a real one: "an overly broad collision-mask edit had added car-only bit16 to the player on vehicle exit" — a subtle interaction between `navigation.gd`, `compact.gd`, and the player's exit logic that only surfaced in integration testing, not in any single file read in isolation. That is the exact failure mode that more reasoning budget is good for: catching a change that is correct in the file you're editing but wrong in combination with two others you're not currently looking at.
- **Milestones 4–6 above are multi-file-consistency work by nature.** A day/night clock alone has to reach into the HUD, `spawn_director`, mission availability windows, `heat_manager`, and the radio system simultaneously and keep them mutually consistent. A model that can hold the whole interacting system in view — rather than needing the work pre-broken into small, independently-safe chunks — is a better fit for that shape of task than for, say, writing one more `VehicleData` resource.
- **The project's testing culture is built for longer, less-supervised runs.** 228+ retained assertions and a documented "no feature is complete without an observable test" rule (`Known_Limitations.md` §19) is exactly the environment that rewards a model willing to work a long stretch autonomously and self-verify before reporting back, rather than one tuned for fast, cheap, well-scoped turns.
- **Concretely:** reach for Opus 5.5 for Milestone 4 (day clock + results screen + two new mission templates, because it touches ~6 existing systems at once) and for Milestone 6 (faction/Notoriety depth, because it's new cross-cutting state, not an extension of one). Keep using Sonnet for single-resource content (one more weapon, one more mission config), playtest-log writing, and exploratory passes like this one — that split spends the extra reasoning where the blast radius is actually large, and saves plan usage everywhere else.

---

## 9. If you only do one thing next

Build Milestone 4. Right now the project can tell you your score — it can never tell you the day is over. Nobody, including you, can honestly evaluate "is one more run worth it" — the single question this whole design is built to answer — until that loop actually closes.
