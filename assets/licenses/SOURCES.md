# ASSET SOURCES & LICENSES

Saare assets **free / open license** ke hain. Har file ke saath uska source hai —
agar future me koi asset hatana pade to bas us folder ko delete kar dena.

---

## 1. City kit — KayKit City Builder Bits (CC0)
- **Source:** https://github.com/KayKit-Game-Assets/KayKit-City-Builder-Bits-1.0
- **Author:** Kay Lousberg (KayKit)
- **License:** CC0 1.0 (public domain — commercial use allowed, credit optional)
- **Files:** `assets/city/*.gltf` + `.bin` + `citybits_texture.png`
- **What:** buildings A–H, road tiles, cars (sedan/hatchback/taxi/police/stationwagon),
  streetlight, traffic lights, benches, bushes, dumpster, hydrant, watertower, boxes.
- **Scale:** kit 2×2 units per tile → game me `Kits.CITY_SCALE = 4.0` se 8m tile.

## 2. Characters — Quaternius "Universal Base Character" + animations (CC0)
- **Source:** https://github.com/NafisRayan/Animate-Rigged-Humanoid-No-Blender
  (mirror of Quaternius' Universal Base Characters + Universal Animation Library)
- **Original:** https://quaternius.com — packs "Universal Base Characters" & "Universal Animation Library"
- **License:** CC0 1.0
- **Files:** `assets/characters/human_male.glb`, `human_female.glb`
- **Specs:** ~14.5k triangles, 65 bones, **86 animations** (Idle_Loop, Jog_Fwd_Loop,
  Sprint_Loop, Jump_*, Crouch_*, Sitting_*, Driving_Loop, Punch_*, Pistol_*, Death01…),
  PBR textures embedded (base color / normal / roughness).

## 3. Audio — Kenney (CC0)
- **Source (ambience):** https://github.com/mdabees/kenney-starter-kit-city-builder
  → `sounds/ambience.ogg` (city ambience loop)
- **Source (SFX):** https://github.com/KenneyNL/Starter-Kit-3D-Platformer
  → `walking.ogg` (footsteps), `jump.ogg`, `land.ogg`, `fall.ogg`
- **Source (UI):** Kenney city-builder `placement-a.ogg` → `ui_click.ogg`
- **Author:** Kenney (kenney.nl) · **License:** CC0 1.0

## 4. Synthesized audio (is repo me generate kiya gaya — CC0)
Ye files Python + numpy se **is project ke liye generate** ki gayi hain, isliye
in par koi third-party license nahi hai:
- `assets/audio/engine_loop.wav` — gaadi ka engine (2s loop)
- `assets/audio/siren_loop.wav` — police siren (4s loop)
- `assets/audio/rain_loop.wav` — baarish (9s loop)
- `assets/music/ambient_night.wav` — 69s dark ambient music bed (loop)

> Music/accent ko upgrade karna ho to `docs/ASSETS.md` dekho — wahan real
> composers/CC0 music ki list hai.

## 5. Shaders & code
- `shaders/*.gdshader`, `scripts/**` — is repo ke saath, AGPL-3.0 (root `LICENSE`).
  Commercial game banane se pehle license badalna hai (docs/00 me detail).
