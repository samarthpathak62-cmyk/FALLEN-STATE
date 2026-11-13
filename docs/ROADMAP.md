# ROADMAP — M0 → M10

Status: ✅ done · 🟡 adhoora · ⬜ pending
Rule: ek time par ek milestone. Naya idea → `IDEAS-BACKLOG.md`.

---

## M0 — Foundation ✅
Godot 4 project, GL Compatibility, `Game`/`Kits`/`Sound` autoloads, JSON save (F5/F9),
quality presets, HUD, pause menu.
**DoD:** F5 → band → kholo → F9 → same jagah, same paisa. ✅

## M1 — Player feel ✅
CharacterBody3D + SpringArm3D camera, real rigged character (86 anims),
walk/jog/sprint/jump animation blending, footsteps, vehicle enter/exit.
**DoD:** 5 min khelo, chalna smooth lage. (Aur tune karna hai — 3 hafte ka kaam hai.)

## M2 — City ✅
13×13 tile district KayKit kit se: roads, junctions, 8 building types, props,
streetlights, ground. Scale system (`Kits.TILE`, `CITY_SCALE`).
**DoD:** city "city" lage, khali maidan na lage. 🟡 (aur props/density chahiye)

## M3 — Vehicles ✅ (v1)
5 gaadiyan, arcade physics, engine audio + pitch, headlights, weather grip, horn.
⬜ Vehicle damage/repair, ⬜ AI traffic, ⬜ bike/boat/heli, ⬜ garage.

## M3.5 — Atmosphere ✅
Day/night (24 min), sky/fog/ambient colors, weather (clear/rain/fog), rain particles,
ACES tonemap, vignette + grain shaders, ambient music.

---

## M4 — NPC life 2.0 ⬜ ← **agla kaam** (3-4 hafte)

- [ ] **NavigationAgent3D** + baked navmesh (NPC deewar me na ghusen)
- [ ] **Schedule JSON**: `{6:"home", 8:"work", 13:"cafe", 18:"home", 22:"bar"}`
- [ ] Locations registry (work/cafe/bar ke coordinates city.gd se)
- [ ] States: `commute / working / idle / flee / talk`
- [ ] **Statistical LOD**: 60m se dur NPC = sirf data (mesh + anim + physics band)
- [ ] Crowd pool: 14 full NPC + 40 simple
- [ ] NPC player ko dekhe, raasta de, darr kar bhaage
- [ ] Personality tags ("rude", "helpful") — future consequences ke liye

**DoD:** ek NPC ko 20 min follow karo — subah ghar se kaam, shaam cafe, raat ghar.
Player ignore kare to bhi life chale.

## M5 — Interiors ⬜
- [ ] Street kiosk → asli enterable shop interior (`.tscn`)
- [ ] Door system (locked/open/breakable)
- [ ] 5 interiors: ghar, cafe, police station, apartment, warehouse
- [ ] Enter/exit fade transition
- [ ] Loot/interaction objects

## M6 — Missions + dialogue ⬜ (2-3 hafte)
- [ ] Missions JSON me (code nahi)
- [ ] Objective types: goto / interact / drive_to / survive / talk / steal
- [ ] Dialogue box + choices
- [ ] Branching (flag set → baad me different mission)
- [ ] 6 missions (3 story + 3 side), fail/retry

## M7 — Police / crime ⬜ (3 hafte)
- [ ] Crime events (reckless / assault / theft / trespass)
- [ ] Witness system (dekha kisi ne? call kiya?)
- [ ] Heat 0-5 levels (abhi sirf 0-100 number hai)
- [ ] Police AI: dispatch → search → chase → arrest/fine
- [ ] Jail/hospital flow, per-district reputation

## M8 — Economy + properties ⬜ (2 hafte)
- [ ] Jobs (delivery/taxi/mechanic), properties, passive income, expenses
- [ ] Shop catalog JSON, inventory v1

## M9 — Audio + weather 2.0 ⬜
- [ ] Audio buses mix, district soundscapes, dynamic music
- [ ] Storm/heat/fog variants, wet road shader, puddles

## M10 — Polish ⬜
- [ ] World streaming, occlusion culling, MultiMesh props, texture budget
- [ ] Graphics settings menu (resolution scale, texture quality)
- [ ] Controller support, remapping, save versioning
- [ ] *(optional)* multiplayer — sirf single player complete hone ke baad

---

## Timeline (2h/day)

| Mahina | Milestone | Result |
|---|---|---|
| 1 | M4 shuru | NPC schedules + navmesh |
| 2 | M4 complete | city me log jeete hain |
| 3 | M5 | interiors |
| 4 | M6 | 6 missions + branching |
| 5 | M7 | police system |
| 6 | **Trailer + itch.io demo** 🔥 | vertical slice |
| 7-8 | M8 | economy/properties |
| 9 | M9 | audio/weather 2.0 |
| 10-11 | Content (15 missions, 3 districts) | 2-3 ghante ka game |
| 12 | M10 polish | release candidate |

---

## Definition of Done (har feature)

1. 10 min test me crash na ho
2. Save/load ke baad bhi kaam kare
3. Console me error/warning na ho
4. Kisi dost ne bina explanation ke use kar liya ho
5. Commit message me milestone ho (`M4: navmesh bake`)

---

## Playtest notes

| Date | Kaun | Accha laga | Boring/confusing | Fix |
|---|---|---|---|---|
| | | | | |
