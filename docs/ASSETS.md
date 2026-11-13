# ASSETS — abhi kya hai, aur realistic banane ke liye kya karna hai

---

## 1. Sach baat pehle (yeh padhna zaroori hai)

Tumne kaha: *"internet se search karke download karke banao, realistic ho"*.

Maine sab download kiya jo **legally free** hai — lekin ek limitation thi:
mere paas is sandbox me sirf **GitHub** tak internet hai. Kenney/Poly Haven/Mixamo/
Sketchfab/Freesound jaise sites block hain. Isliye maine GitHub par jo **CC0 (public domain)**
packs milte hain wo liye — aur wahi standard packs hain jo har indie dev use karta hai:

| Abhi repo me | Size | Kaisa dikhta hai |
|---|---|---|
| KayKit City Builder Bits | 1.3 MB | **stylized-realistic** (clean, readable, GTA-lite feel) |
| Quaternius Universal Base Characters | 68 MB | semi-realistic humans, **PBR textures + 86 animations** |
| Kenney + synthesized audio | 3.6 MB | solid |

**Ye "photoreal" nahi hai — ye "stylized realistic" hai.** Aur ye galti nahi thi:

1. **Photoreal iGPU par nahi chalta.** 4K PBR textures + 3 light sources per object +
   post-processing = 15 FPS on integrated graphics. Tumhara requirement tha
   *"bina GPU ke laptop par bhi lag na ho"* — ye dono ek saath possible nahi.
2. **Photoreal characters (Mixamo/Metahuman/Scanstore) ka license** commercial release
   me complicated hota hai, aur 68MB ke character ko 400MB banate hain.
3. **Art direction > asset quality.** Same city kit ko agar tum HDRI sky + fog +
   color grade + good shadows dete ho, wo $500 ke asset pack se better lagta hai.
   Ye repo me already lagi hui hai (ACES tonemap, fog, vignette, grain).

**Aur important:** tumhare paas **puri internet** hai. Main tumhe exact list de raha hoon —
tum apne PC par 30 minute me realistic assets la sakte ho. Neeche section 4.

---

## 2. Abhi repo me kya hai (aur kaise swap karna hai)

### City — `assets/city/*.gltf`
| Model | Kya | Use |
|---|---|---|
| `building_A` … `building_H` | 8 building types, 2×2 tile | `city.gd::_building()` |
| `road_straight`, `road_junction` | sadak + chauraha | `city.gd::build()` |
| `base` | pavement tile | block floor |
| `car_sedan/hatchback/taxi/police/stationwagon` | 5 gaadiyan | `main.gd::CAR_KINDS` |
| `streetlight`, `trafficlight_A/B` | poles | `city.gd::_place_streetlights()` |
| `bench`, `bush`, `dumpster`, `firehydrant`, `trash_A`, `box_A/B`, `watertower` | props | `city.gd::_park/_sidewalk_props` |

**Naya building add karna:** naya `.gltf` + `.bin` `assets/city/` me daalo (same 2×2 tile
grid me model ho), phir `city.gd` ke `names` array me naam add karo. Bas.

### Characters — `assets/characters/human_male.glb`, `human_female.glb`
- 14.5k tris, 65 bones, **86 animations**
- Animation names jo code use karta hai (substring match):
  `idle` → `Idle_Loop` · `jog` → `Jog_Fwd_Loop` · `sprint` → `Sprint_Loop` ·
  `jump_start` / `jump_loop` → same · `driving` → `Driving_Loop`
- Gender: `npc.setup(index, male: bool)` — even/odd se alternate hota hai

**Naya character lagana:**
1. `assets/characters/` me naya `.glb` daalo
2. `scripts/core/kits.gd` me `CHAR_MALE` / `CHAR_FEMALE` path badlo
3. Agar animation names alag hain → `Kits.find_anim()` substring se khud dhoond lega
   (`idle`, `walk`, `run`, `jump`…). Na mile to `Kits.play_anim()` false return karega
   aur character T-pose me khada rahega — tab naam check karo.

### Scale convention (iska dhyan rakhna)
| Cheez | Size |
|---|---|
| 1 city tile | **8 m** (`Kits.TILE`) |
| Kit unit | 2 m (`Kits.CITY_SCALE = 4.0`) |
| Character | 1.82 m |
| Gaadi | 4.4 × 1.9 m |
| Floor (`GROUND_Y`) | 0.1 m |
| Building | 8 × 8 m, 6–12 m uncha |

Koi bhi naya model laao to **Godot me import karke scale check karo** (1 unit = 1 metre
rakho). Galat scale = giant ya bonsai city.

---

## 3. Audio asset swap

| File | Kya | Badalna hai to |
|---|---|---|
| `assets/audio/ambience.ogg` | city ambience loop | koi bhi city ambience loop (ogg/wav) |
| `assets/audio/footsteps.ogg` | kadam | Kenney "Impact Sounds" |
| `assets/audio/engine_loop.wav` | engine | Freesound "car idle loop" |
| `assets/audio/siren_loop.wav` | siren | Freesound "police siren loop" |
| `assets/music/ambient_night.wav` | music bed | neeche list dekho |

Sound system `scripts/core/audio.gd` me hai — file path badlo, code nahi.

---

## 4. REALISTIC assets kahan se laao (tumhare PC par, 30 min)

### Sabse bada upgrade: **HDRI sky** (1 file, poora look badal jata hai)
- https://polyhaven.com/hdris → free CC0. "kloppenheim", "venice_sunset", "dikhololo_night" try karo.
- 2K resolution lo (4K mat lo — iGPU mar jayegi).
- Godot me: `WorldEnvironment → Sky → PanoramaSkyMaterial → Panorama = hdri.hdr`.
  `main.gd::_setup_environment()` me `ProceduralSkyMaterial` ki jagah lagana hai.

### Characters (modern people — GTA style)
- **Mixamo** (free, Adobe login): https://mixamo.com — 100+ characters, 2500+ animations.
  "Y Bot"/"Swat"/"Casual" characters + walk/run/idle/jump. `.fbx` for Godot 4.4 (FBX works) ya
  glTF. **Ye tumhare game ka sabse bada upgrade hoga.**
- **Quaternius** (CC0): https://quaternius.com — "Ultimate Modular Men/Women" (t-shirt/jeans)
- **Sketchfab**: filter `Downloadable + CC0` — "low poly civilian", "modern character"

### Buildings / city (realistic)
- **Poly Haven models** (CC0): https://polyhaven.com/models — furniture, props, street stuff
- **Kenney City Kit (Commercial)** — paid $20, road/buildings ka bada set
- **Sketchfab CC0** — "modular building", "city block"
- **Blender** se apna block banao (21 din ka Blender basics → 1 din me ek building)

### Materials / textures
- **ambientCG**: https://ambientcg.com (CC0, PBR: asphalt, concrete, brick, metal)
- **Poly Haven textures**: https://polyhaven.com/textures (CC0)
- 1K textures kaafi hain (2K sirf hero assets ke liye)

### Audio / music
- **SFX:** https://freesound.org (CC0 filter), https://pixabay.com/sound-effects/
- **Sonniss GDC bundle** (free, GBs of pro SFX, yearly)
- **Music (free/CC0):** https://incompetech.com (Kevin MacLeod, credit), Pixabay Music,
  https://freemusicarchive.org (CC0 filter)
- **Paid (best):** Artlist / Epidemic Sound (~$15/month) — jab game release ke kareeb ho

### Tools
- **Blender** (free) — models, rig, export glTF
- **Material Maker** (free) — procedural PBR textures
- **Audacity** (free) — audio edit/loop
- **HandBrake / ffmpeg** — video, audio convert

---

## 5. Realism ka checklist (bina FPS khoye)

Realism **tech se nahi, in 8 cheezon se** aata hai — order of impact:

1. **HDRI sky + sun angle** — sabse bada (10 min ka kaam, 40% look)
2. **Fog** (distance me objects halke ho jaayein) — already on
3. **Color grade** (ACES + saturation/contrast) — already on
4. **Shadows** (kam se kam sun ki) — MEDIUM preset
5. **Grime/detail textures** — asphalt par noise, deewaron par stains
6. **Props density** — khali street kabhi realistic nahi lagti (dumpster, hydrant, trash)
7. **Motion** — NPC chalte hue, gaadi ka suspension bounce, camera lag
8. **Audio** — footsteps, engine, dur ki siren (sound = 30% "real" feeling)

Advanced (baad me, jab pipeline set ho):
- **SSAO / SSIL** — sirf Forward+ me (iGPU par off)
- **Decals** — paani ke puddle, graffiti (Godot me `Decal` node)
- **Lightmap baking** — static raat ka lighting, poora free
- **Vertex color grime** — Blender me paint karke laao

---

## 6. Legal — release se pehle

- CC0 = credit optional, commercial OK ✅
- "Free for personal use" = **game bech nahi sakte** ❌
- Mixamo animations: Adobe terms — commercial use allowed, par asset ke roop me
  redistribute nahi kar sakte (game ke andar baked hai to theek)
- Music: har track ka license alag — `assets/licenses/MUSIC-NOTES.md` banao aur
  har file ka source + license likho. **Ye ek din tumhe lawsuit se bachayega.**
