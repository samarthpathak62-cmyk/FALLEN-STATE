# ROADMAP — M0 se M10, 12 mahine

Har milestone me: **Goal**, **Tasks**, **Done ka matlab** (DoD), **Time**.
Rule: ek time me ek milestone. Naya idea aaye to `IDEAS-BACKLOG.md` me daalo, yahan nahi.

Status: ✅ done · 🟡 adhoora · ⬜ pending

---

## M0 — Foundation ✅ (yeh repo)

**Goal:** "kuch bhi chalta hua ho" — engine, structure, save, HUD.
- [x] Godot 4 project, GL Compatibility renderer
- [x] `Game` autoload (money, hour, heat, flags, save/load, input map)
- [x] Folder structure + scene/script split
- [x] JSON save system (F5/F9)
- [x] HUD (clock, money, heat, objective, prompts, toasts)

**DoD:** F5 dabao, game band karo, dobara chalao, F9 dabao — same jagah, same paisa.

---

## M1 — Player feel ✅

**Goal:** chalna-mouse-look *accha* lage (yeh 3 din me khatam nahi hota, 3 hafte lagte hain).
- [x] CharacterBody3D + capsule, gravity, jump
- [x] SpringArm3D third-person camera (deewar me na jaye)
- [x] Walk / sprint split
- [ ] ⬜ Camera shake, head-bob, footstep sounds
- [ ] ⬜ Aim/cover stance (bina gun ke bhi, future ke liye)
- [ ] ⬜ Animation tree (Mixamo idle/walk/run/jump)

**DoD:** ek dost 5 min khele aur bole "chalna smooth hai" — bina tujhe batae.

---

## M2 — World graybox ✅

- [x] Procedural 4×4 district (roads, sidewalks, buildings, parks)
- [x] Shared material cache (draw call control)
- [x] Streetlights + building window bands
- [ ] ⬜ 3 more districts (suburb, industrial, poor neighbourhood)
- [ ] ⬜ Navmesh bake tooling
- [ ] ⬜ Minimap / map screen

**DoD:** 3 districts, 60+ buildings, sab blocks me kuch na kuch interesting.

---

## M3 — Vehicles ✅ (v1)

- [x] Arcade car physics (accel, brake, reverse, steering grip)
- [x] Enter/exit with F, headlights at night
- [x] 4 cars spawn
- [ ] ⬜ Vehicle damage + repair shop
- [ ] ⬜ Bike + boat + helicopter (alag `VehicleBase` class)
- [ ] ⬜ AI traffic (lane following)
- [ ] ⬜ Garage / vehicle storage

**DoD:** 3 vehicle classes, traffic me gaadiyan lane follow karein, 10 min drive karke maza aaye.

---

## M4 — NPC life 2.0 ⬜ ← **agla kaam yahi hai** (3-4 hafte)

**Goal:** NPC "randomly ghoomne wale boxes" se "log" ban jayein.

- [ ] NavigationAgent3D + baked navmesh (buildings ke aas paas na atkein)
- [ ] **Schedule system**: har NPC ka JSON — `{6: "home", 8: "work", 13: "cafe", 18: "home", 22: "bar"}`
- [ ] Locations registry (work/cafe/bar/shop ke coordinates)
- [ ] NPC states: `commute / working / idle / flee / talk`
- [ ] **Simulation LOD** — player se 60m dur NPC sirf "statistical" ho (position math se update, mesh off)
- [ ] Crowd pool: 16 full NPC + 40 simple NPC (MultiMesh capsules)
- [ ] Player se react: nazar, raasta dena, darr
- [ ] Naam + personality tags ("rude", "helpful") — future consequences ke liye

**DoD:** 20 min game chalao, ek NPC ko *follow* karo — wo subah ghar se nikle, kaam jaye, shaam ko cafe, raat ko ghar. Player ignore kare to bhi life chale.

**Reference feel:** RDR2 ke NPC routines (sirf 1% emulate karna hai, wo bhi kaafi hai).

---

## M5 — Enterable buildings ⬜ 🟡 (1 enterable abhi hai)

- [x] Ek shop with working door + interior + UI
- [ ] Interior scenes alag `.tscn` me (har building ka apna interior)
- [ ] Door system: `Door` node (locked / open / breakable)
- [ ] 5 enterable types: ghar, cafe, police station, apartment, warehouse
- [ ] Interior enter/exit fade + camera transition
- [ ] Multi-floor (stairs / elevator)
- [ ] Loot / interaction objects (drawer, fridge, safe)

**DoD:** 5 buildings me ghus sakte ho, har ek me kuch karne ko hai.

---

## M6 — Missions + dialogue ⬜ (2-3 hafte)

- [ ] Mission data JSON me (code nahi): steps, conditions, rewards
- [ ] Objective types: `goto / interact / drive_to / survive / talk / steal`
- [ ] Dialogue system (simple box, 2-3 choices)
- [ ] **Branching**: choice A → flag set → baad me different mission
- [ ] Mission markers + phone/messaging UI
- [ ] 6 missions: 3 story + 3 side
- [ ] Mission fail + retry states

**DoD:** 6 missions khelo, ek mission ke 2 endings hon, aur ending ke baad duniya me kuch badla ho.

---

## M7 — Police / crime / consequences ⬜ (3 hafte)

- [ ] Crime events: `reckless_driving / assault / theft / gunshot / trespass`
- [ ] Witness system (dekha kisi ne? NPC ne call kiya?)
- [ ] Heat levels 0-5 (abhi sirf number hai)
- [ ] Police AI: dispatch → search → chase → arrest / fine
- [ ] Ambulance + fire department (incident ke saath)
- [ ] Jail / hospital / respawn flow
- [ ] **World memory**: `flags` + per-district reputation

**DoD:** gaadi todo → police aaye → bhaago ya pakde jao → 5 min baad world ne yaad rakha ho.

---

## M8 — Economy + properties ⬜ (2 hafte)

- [ ] Job system (delivery, taxi, mechanic) — paisa kamane ke 3 tarike
- [ ] Properties: kharido, andar jao, garage, storage
- [ ] Passive income (business invest)
- [ ] Expenses (rent, fuel, repair) + bank UI
- [ ] Shop catalog data (JSON): weapons, clothes, food, parts
- [ ] Inventory v1 (6 slots, hotbar)

**DoD:** 1 ghanta khelo aur paisa meaningful lage — "kya kharidu" ka decision ho.

---

## M9 — Weather + audio ⬜ (2 hafte)

- [ ] Weather state machine: sunny / cloudy / rain / storm / fog / heat
- [ ] Rain particles + wet roads + puddle reflections (fake se kaam chal jata hai)
- [ ] Weather → gameplay: grip, NPC behaviour, visibility, mission rules
- [ ] Audio buses: SFX / Music / Ambience / Vehicles
- [ ] District soundscapes (downtown / suburb / industrial)
- [ ] Dynamic music (explore / chase / mission)

**DoD:** headphones lagao, 10 min chalao — "city" sunai de.

---

## M10 — Polish, streaming, performance, multiplayer ⬜

- [ ] World streaming (region scenes load/unload)
- [ ] LOD + occlusion + MultiMesh pass
- [ ] Graphics settings menu (low/med/high) — "weaker hardware" ke liye
- [ ] Save versioning + migration
- [ ] Full controller support + remapping
- [ ] Options: sensitivity, audio, subtitles
- [ ] Crash logging + bug report
- [ ] *(optional)* Multiplayer: dedicated-server ya co-op — **sirf jab single player complete ho**

---

## Timeline (realistic, 2h/day)

| Mahina | Milestone | Result |
|---|---|---|
| 1 | M0 + M4 shuru | base + NPC schedules |
| 2 | M4 complete | city me log jeete hain |
| 3 | M5 | 5 enterable buildings |
| 4 | M6 | 6 missions + branching |
| 5 | M7 | police system |
| 6 | **Vertical slice + trailer** | itch.io demo 🔥 |
| 7-8 | M8 | economy + properties |
| 9 | M9 | weather + audio |
| 10-11 | Content (missions 6→15, district 1→3) | 2-3 ghante ka game |
| 12 | M10 polish | release candidate |

---

## Definition of Done (har feature ke liye)

Ek feature tabhi "done" hai jab:
1. Game **crash** na kare (10 min test)
2. **Save/load** ke baad bhi kaam kare
3. Debug output me **error/warning** na ho
4. Kisi dost ne bina explanation ke use kar liya ho
5. Commit message me milestone likha ho (`M4: NPC schedule JSON`)

---

## Playtest notes (yahan likho, har hafte)

| Date | Kaun khela | Kya accha laga | Kya boring/confusing | Fix |
|---|---|---|---|---|
| | | | | |
