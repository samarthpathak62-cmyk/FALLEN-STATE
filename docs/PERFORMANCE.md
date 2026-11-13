# PERFORMANCE — bina GPU wale laptop par 60 FPS

Target: **720p / 60 FPS / Intel Iris Xe, Vega 8, GTX 1050, MX150** jaisi machine.
Ye document batata hai ki is project me kya kya pehle se optimise kiya gaya hai,
aur aage kya dhyan rakhna hai.

---

## 1. Presets (F10 se cycle)

| | LOW | MEDIUM (default) | HIGH |
|---|---|---|---|
| Sun shadows | ❌ off | ✅ 90m | ✅ 140m, 4 splits |
| MSAA | off | 2× | 4× |
| Shadow atlas | 1024 | 2048 | 4096 |
| Glow / bloom | ❌ | ✅ | ✅ |
| Street lights (omni) | 3 | 6 | 12 |
| NPCs | 8 | 14 | 22 |
| Rain particles | 350 | 700 | 700 |
| Fog density | 0.0012 | 0.0018 | 0.0022 |

> Preset **start par load hota hai** (NPC count). Runtime me badalne se
> shadows/MSAA/lights turant badalte hain, NPC count next run me.
> Setting `user://fallen_state_settings.json` me save hoti hai.

---

## 2. Project me pehle se kya optimise hai

| Technique | Kahan | Fayda |
|---|---|---|
| **Character LOD** | `npc.gd::_update_lod()` | 58m se dur NPC ka skinned mesh chhup jata hai — **skinning sabse mehanga hissa hai** |
| **Ek ground collision plane** | `city.gd::_build_ground()` | 200 tiles par 200 collision bodies nahi |
| **Tiles = visual only** | road/base tiles me collision nahi | physics cost ~0 |
| **Box collision** (trimesh nahi) | `kits.gd::add_box_collision()` | building collision sasta |
| **Flat tile scaling** | `Kits.spawn_city(..., flat=true)` | 40cm curb ka step-problem bhi gaya, physics bhi |
| **Omni light limit** | `city.gd::_place_streetlights()` | max 12 lights, shadow off |
| **1 spotlight** per gaadi, sirf driven car | `car.gd` | 10 lights nahi |
| **CPUParticles3D** rain | `weather.gd` | har driver par chalta hai (GPU particles drivers par toot sakte hain) |
| **CPUParticles count by quality** | `weather.gd::_build_rain()` | 350 vs 700 |
| **Shared GLTF materials** | Godot instancing | 45 buildings, 1 material/texture atlas |
| **Vignette/grain shaders** | `shaders/` | screen read nahi karte (hint_screen_texture nahi) → ~0 cost |
| **No SSAO/SSR/GI** | — | GL Compatibility me nahi, aur zaroorat bhi nahi |

---

## 3. Cost ka sach (kya mehanga hai)

1. **Shadows** — sabse mehangi cheez jo tum on/off kar sakte ho. LOW me off.
2. **Skinned characters** — 65 bones × 14 NPC. Isliye LOD + quality-based count.
3. **Omni/Spot lights** — har light har object ke shader cost badhati hai. 6-8 max.
4. **Transparent / alpha** — rain, fog, particles: **overdraw** karte hain. Full-screen
   rain mehanga hai; isliye 700 particles aur ek 28m box.
5. **4K textures** — character GLB me 2K-4K textures hain. Import me Godot unhe
   VRAM-compress karta hai, par agar aur characters add karo to:
   `Import → texture → Compress Mode = VRAM Compressed`, size = 1024.

---

## 4. FPS kam aa raha ho to — is order me karo

1. `F10` → **LOW**
2. Window chhota: 1280×720 → 960×540 (`project.godot` → display)
3. `NPC_COUNTS` `[8, 14, 22]` → `[5, 8, 12]` (`main.gd`)
4. Rain off: `weather.gd` → `_apply(State.RAIN)` me `rain_particles.emitting = false` kar do,
   ya `amount = 200`
5. Fog density badhao (`0.0012`) — dur ke objects "gayab" ho jate hain, culling jaisa effect
6. Character textures 1024 pe laao (neeche)

## 5. FPS naapne ka tarika

Godot → **Debugger → Monitors**:
- `Time/FPS`, `Time/Process`, `Time/Physics Process`
- `Raster/Draw Calls` — **target < 400**
- `Raster/Objects` — target < 1500
- `Video/Video Memory` — 512MB GPU ke liye < 400MB rakho

`Process` 16ms se upar jaaye = CPU bottleneck (scripts/physics).
`Draw Calls` zyada = GPU/CPU submit bottleneck (objects kam karo).

---

## 6. Aage kya optimise karna hai (roadmap)

- [ ] **MultiMesh** se 200+ chhote props (bottle, trash, cones)
- [ ] **Visibility ranges** (`GeometryInstance3D.visibility_range_begin/end`) — buildings
      dur se chhup jaayein
- [ ] **Occlusion culling** — haan, ye Godot 4 me hai (`OccluderInstance3D`), shahar me
      bada fayda
- [ ] **Statistics-based NPC sim** (player se dur NPC = sirf position math) — M4
- [ ] **Texture budget pass** — 1K max, hero assets 2K
- [ ] **Upgrade upscaling** — Godot 4.4 me FSR2 / MetalFX sirf Forward+ me (compat me nahi)
