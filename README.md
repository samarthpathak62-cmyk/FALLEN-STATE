# FALLEN STATE

**"A city that never sleeps."** — Godot 4 me ek living open-world crime game.

Yeh repo ab **real assets wala playable vertical slice** hai (sirf graybox nahi):
rigged humans with 86 animations, modular city kit, 3D gaadiyan, synth audio,
cinematic post-processing, aur **weak laptop ke liye quality presets**.

---

## Chalao (3 step)

1. [godotengine.org/download](https://godotengine.org/download) → **Godot 4.4+** (standard, non-.NET)
2. Godot → **Import** → `project.godot` → **Import & Edit**
3. ▶ Run

> **Pehli baar 1-3 minute lag sakta hai** — 70MB ke character models import ho rahe hote hain
> (86 animations × 2 models). Uske baad instant. Agar "importing" dikhe to ruk jao, band mat karo.

---

## Andar kya hai

| System | Detail |
|---|---|
| **Real characters** | Quaternius Universal Base Character — 14.5k tris, 65 bones, **86 animations** (idle/jog/sprint/jump/drive/crouch/punch…) |
| **Living city** | 13×13 tile district (104m) — KayKit modular kit: 8 building types, roads, junction, streetlights, props |
| **Driving** | 5 gaadiyan (sedan/hatchback/taxi/police/wagon), gear-less arcade physics, engine audio, headlights, weather grip |
| **NPCs** | 8/14/22 (quality ke hisaab se) — time-based routine (commute/nightlife), gaadi dekh kar bhaagna, distance LOD |
| **Day/night** | 24 min = 1 din, sun angle + sky gradient + fog + ambient, 19:30 se raat |
| **Weather** | clear / rain / fog — rain me grip 0.72, fog density 5× |
| **Audio** | Kenney ambience + footsteps + synthesized engine/siren/rain + 69s ambient music |
| **Look** | ACES tonemap + fog + vignette + film grain shader + emissive streetlights |
| **Money/economy** | Corner Store kiosk (E) — coffee $5, intel $200 |
| **Missions** | 3-step chapter + objective marker + random accident event |
| **Save/Load** | F5 / F9 (JSON) |
| **Quality presets** | LOW / MEDIUM / HIGH — F10 se cycle, ya Esc menu se |

---

## Controls

| Key | Kaam |
|---|---|
| `W A S D` | chalna / driving |
| `Shift` | daudna / tez |
| `Alt` | dheere chalo (city dekhne ke liye) |
| `Space` | jump |
| `Mouse` | camera |
| `E` | interact (Corner Store, accident help) |
| `F` | gaadi me baitho / utro |
| `H` | horn |
| `F5` / `F9` | save / load |
| `F10` | graphics preset (LOW → MEDIUM → HIGH) |
| `Esc` | pause menu / mouse free |

---

## Bina GPU wale laptop par (important)

Default preset **MEDIUM** hai. Agar 30 FPS se neeche jaaye:

1. `F10` ek baar dabao → **LOW**
2. LOW me: shadows off, MSAA off, glow off, sirf 3 street lights, 8 NPC
3. Window chhota karo (`1280×720` se `960×540`)

Details + tuning: **[docs/PERFORMANCE.md](docs/PERFORMANCE.md)**

---

## Folder structure

```
project.godot
assets/
  city/          KayKit city kit (gltf + atlas texture)  [CC0]
  characters/    human_male.glb / human_female.glb       [CC0]
  audio/ music/  Kenney + synthesized                   [CC0]
  licenses/      SOURCES.md — har asset ka source
scenes/          main, player, car, npc (root + script only)
scripts/
  core/          game.gd (autoload) · kits.gd (assets) · audio.gd (Sound)
  world/         main.gd · city.gd · day_night.gd · weather.gd · kiosk.gd
  player/        player.gd
  vehicles/      car.gd
  npc/           npc.gd
  systems/       missions.gd · events.gd · incident.gd
  ui/            hud.gd · pause_menu.gd
shaders/         post_vignette · post_grain
docs/            00-KYA-KARNA-HAI · ASSETS · PERFORMANCE · ROADMAP · TECH-NOTES
```

---

## Docs

- **[docs/00-KYA-KARNA-HAI.md](docs/00-KYA-KARNA-HAI.md)** — plan, engine choice, 30 din, 10 galtiyan
- **[docs/ASSETS.md](docs/ASSETS.md)** — asset list + **realistic assets kaise laayein (exact links)**
- **[docs/PERFORMANCE.md](docs/PERFORMANCE.md)** — weak laptop par 60 FPS
- **[docs/ROADMAP.md](docs/ROADMAP.md)** — M0 → M10
- **[docs/TECH-NOTES.md](docs/TECH-NOTES.md)** — code samjho, naya feature jodo

---

## Credits

City kit: **KayKit (Kay Lousberg)** · Characters & animations: **Quaternius** ·
Audio: **Kenney** (kenney.nl) · Engine: **Godot**.
Details + licenses: [assets/licenses/SOURCES.md](assets/licenses/SOURCES.md)

## License note

Repo code: **AGPL-3.0** (`LICENSE`). Assets: **CC0**.
Game bechna hai → code ka license MIT ya proprietary karna hoga (`docs/00` me detail).
