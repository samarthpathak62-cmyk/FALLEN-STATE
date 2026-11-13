# TECH NOTES — code samajhne aur badhane ke liye

---

## 1. Architecture (kaun kisse baat karta hai)

```
                      ┌────────────────────┐
                      │  Game (autoload)   │  ← shared state ONLY
                      │  money / hour /    │     (koi gameplay logic nahi)
                      │  heat / flags /    │
                      │  save-load / keys  │
                      └─────────┬──────────┘
        ┌───────────┬───────────┼───────────┬────────────┐
        │           │           │           │            │
   ┌────▼───┐  ┌────▼────┐ ┌────▼────┐ ┌────▼─────┐ ┌────▼─────┐
   │ Player │  │  Car    │ │  NPC    │ │ Missions │ │ HUD      │
   └────┬───┘  └────┬────┘ └─────────┘ └────┬─────┘ └──────────┘
        │           │   (dono ek dusre ko    │
        └───────────┘    direct call karte    │
                          hain enter/exit)    │
                                     ┌────────▼────────┐
                                     │ WorldEvents     │
                                     │  └─ Incident    │
                                     └─────────────────┘
```

**Rule #1:** `Game` sirf *state* rakhta hai. Agar `game.gd` me "agar player X ke paas
jaaye to Y karo" type logic aane lage → woh logic us system ki file me jaayega.
Warna 6 mahine me `game.gd` 3000 lines ka ho jayega aur project khatam.

**Rule #2:** Systems ek dusre ko **direct method call** karte hain (`car.set_driver(player)`),
aur duniya-wide events ke liye **signals** (`Game.toast_requested`).
Har cheez ko signal bana dena bhi galti hai — code padhna mushkil ho jata hai.

---

## 2. Startup order (`scripts/world/main.gd`)

Order matter karta hai:

1. `_setup_lighting()` → sun + WorldEnvironment (baaki sab iske baad)
2. `DayNight` node → sun ko rotate karne ke liye reference
3. `world_builder.build()` → yeh `Dictionary` return karta hai:
   `{spawn, car_spawn, contact_point, shop_door, road_lines, npc_spawns, extra_car_spawns}`
4. Player spawn (kyunki HUD + missions ko player chahiye)
5. Cars + NPCs
6. HUD (isliye ki uske baad aane wale saare `Game.say()` dikhein)
7. Missions + WorldEvents → `setup(player, info)`

`main.gd` ko **200 lines se chhoti** rakho. Yeh file har naye system ke liye 3 lines badhegi, bas.

---

## 3. File map

| File | Kaam | Lines |
|---|---|---|
| `core/game.gd` | autoload: state, save/load, input map, toasts | ~230 |
| `world/main.gd` | assembly + lighting | ~150 |
| `world/world_builder.gd` | procedural district, materials, shop building | ~430 |
| `world/day_night.gd` | 24h clock, sun, sky, ambient, fog | ~110 |
| `world/shop_counter.gd` | interactable + shop UI + purchases | ~150 |
| `player/player.gd` | movement, camera, interact, vehicle hook | ~260 |
| `vehicles/car.gd` | arcade car | ~230 |
| `npc/npc.gd` | routine AI + flee | ~190 |
| `systems/mission_system.gd` | 3-step chapter + marker | ~150 |
| `systems/world_events.gd` | event spawner (timer) | ~55 |
| `systems/incident.gd` | ek event: accident + choice | ~140 |
| `ui/hud.gd` | saara HUD code se | ~130 |

---

## 4. Recipes — "naya X kaise add karun?"

### 4a. Naya enterable building (nayi dukaan)

1. `world_builder.gd` ke `_build_shop()` ko copy karo → `_build_cafe(center)`
2. Room ke andar ek interaction point banao:
   ```gdscript
   var counter := Node3D.new()
   counter.set_script(preload("res://scripts/world/cafe_counter.gd"))
   counter.position = base + Vector3(0, 0, -half_d + 3.0)
   add_child(counter)
   ```
3. `shop_counter.gd` copy karke `cafe_counter.gd` banao → UI me apne buttons
   (`interact()` + `get_prompt_text()` + `add_to_group("interactable")` — yahi 3 cheez chahiye)
4. `build()` me block loop se ek aur block reserve karo:
   ```gdscript
   elif i == 3 and j == 0:
       _build_cafe(center)
   ```

**Kyun kaam karta hai:** Player ko bas group + `interact()` chahiye — usne kabhi
"shop" ka naam nahi liya. Isliye 100 dukaanein bhi same code se chalengi.

---

### 4b. Naya random world event (chori / aag / jhagda)

1. `incident.gd` copy → `mugging.gd`
2. `_build()` me apna visual, `interact()` me apna reward
3. `world_events.gd` me:
   ```gdscript
   const MUGGING_SCRIPT := preload("res://scripts/systems/mugging.gd")
   ...
   var pick := randi() % 2
   var script := INCIDENT_SCRIPT if pick == 0 else MUGGING_SCRIPT
   ```
4. Event hamesha `add_to_group("interactable")` kare aur `interact(player)` rakhe.

---

### 4c. Naya mission

Abhi `mission_system.gd` hardcoded hai (jaan-boojh kar — pehle chalao).
Naya mission add karne ke 2 tarike:

**Sasta (aaj):** `_start()` ke `match` me case add karo + `_check_objective()` me
condition add karo.

**Sahi (M6 me):** JSON banao —
```json
{ "id": "m04", "objective": "Warehouse jao", "type": "goto",
  "point": [-84, 0, 56], "reward": 300,
  "on_complete": { "flags": { "met_boss": true } } }
```
Aur `mission_system.gd` ko generic interpreter banao. Code me mission ki *story* nahi,
sirf *engine* hona chahiye.

---

### 4d. Naya vehicle (bike / boat / helicopter)

1. `car.gd` copy → `bike.gd`
2. `VehicleBase` common class banao (`set_driver`, `release_driver`, `speed`, group `"vehicle"`)
3. `scenes/bike.tscn` banao
4. `main.gd` me spawn karo

Player code **change nahi hoga**, kyunki wo sirf `set_driver()` + group `"vehicle"` pe
depend karta hai. Yahi "modular architecture" ka matlab hai.

---

### 4e. NPC ka naya behaviour (bhikhari, police, diler)

1. `npc.gd` copy → `npc_variant.gd`, ya `npc.gd` me `job: String` field add karo
2. `_routine_speed()` / `_routine_radius()` / `_physics_process()` me job ke hisaab se branch
3. Spawn karte waqt `npc.setup(index)` ke saath `npc.job = "police"` bhej do

---

## 5. "Living world" ka asli trick: Simulation LOD

Yeh **sabse important** architectural idea hai poore project ka.
Aaj 16 NPC hain — 200 ho jayenge — 1000 ho jayenge. Sabko full AI dena = FPS khatam.

Do modes:

```gdscript
# Player ke 60m ke andar: FULL SIMULATION
#   CharacterBody3D, navmesh, animation, collision, mesh ON

# Player se dur: STATISTICAL SIMULATION
#   koi mesh nahi, koi physics nahi. Bas ek Array:
#   npcs[i] = { "id": 12, "schedule": "work", "pos": Vector3, "speed": 1.6, "target": ... }
#   Har 0.5 sec me: pos += (target - pos).normalized() * speed * 0.5
#   Player 60m ke andar aaya -> node spawn karo, mesh on
```

Pseudo-code:

```gdscript
func _update_simulation(delta: float) -> void:
    for agent in _far_agents:                     # Array of Dictionary
        var to: Vector3 = agent["target"] - agent["pos"]
        if to.length() < 1.0:
            agent["target"] = _pick_from_schedule(agent["schedule"])
            continue
        agent["pos"] += to.normalized() * agent["speed"] * delta

    var near := _agents_within(60.0)
    for agent in near:
        if not agent["spawned"]:
            agent["node"] = NPC_SCENE.instantiate()
            agent["node"].position = agent["pos"]
            add_child(agent["node"])
            agent["spawned"] = true
```

Isi trick se GTA/RDR "1000 NPC" dikhate hain. Tu bhi karega — M4 me.
**Aur isi liye NPC data ko node me nahi, data me rakhna hai.**

---

## 6. Save format

`user://fallen_state_save.json` (Linux: `~/.local/share/godot/app_userdata/...`)

```json
{
  "version": 1,
  "money": 750, "hour": 14.3, "day": 3, "heat": 12.0,
  "flags": { "has_intel": true },
  "player_pos": [4.0, 0.4, 28.0],
  "car_pos": [6.0, 0.8, 28.0], "car_rot": 0.0
}
```

Rules aage ke liye:
- `version` field **kabhi mat hatao** (purana save naye build par crash na kare)
- Naya system save kare to apna key add kare, `version` badhao, load me migrate karo
- Save me **node references nahi**, sirf **ids/positions/flags**
- NPC simulation data bhi save karna hai (M4) → `"npc_agents": [...]`

---

## 7. Performance rules (is codebase ke liye)

| Rule | Kyun |
|---|---|
| Ek material = ek colour, cache me | `world_builder._wall_cache` — 100 buildings, ~6 materials |
| Omni lights max ~10, shadow off | har light = har object ka extra shader cost |
| Sidewalk/road pe collision nahi | visual boxes = free; collision = physics cost |
| Distant NPC mesh off | M4 me simulation LOD |
| `_process` me `get_nodes_in_group()` mat karo | O(n) har frame; cached list rakho (abhi 5-6 nodes hain, theek hai, 200 pe nahi) |
| Building me `BoxMesh` reuse karo | same `BoxMesh` resource multiple `MeshInstance3D` me share ho sakta hai |

**Check:** `Debugger → Monitors` → `FPS`, `Draw Calls`, `Physics Time`.

---

## 8. Godot gotchas jo is project me already handle kiye hain

1. **CharacterBody3D step-up nahi karta.** 12cm ka curb bhi player ko rok deta hai.
   Isliye sidewalk/floor pe **collision nahi** — sirf mesh. (Asli stair step-up ka
   solution: chhota invisible ramp collider, M5 me.)
2. **Typed `Node3D` variable se custom property access = compile error**
   (`Game.player.driving` ❌). Isliye cross-script refs `var player = null` (untyped)
   ya `player.set("velocity", ...)` use karte hain.
3. **`var x := dictionary["key"]` error deta hai** (Variant se type infer nahi hota).
   `var x: Vector3 = dictionary["key"]` likho.
4. **Input map code se banaya hai** (`game.gd::_setup_input_map`) taaki `project.godot`
   ka version-specific serialization na toote. Editor me dekhna hai to
   `Project Settings → Input Map` me runtime me nahi dikhega — wo normal hai.
5. **GL Compatibility renderer** me kuch (SDFGI, SSR, volumetric fog) nahi milta.
   Isliye lighting `set()` se apply hoti hai — property na ho to crash nahi.
6. **`.tscn` files me merge conflict** hota hai. Isliye scenes chhoti hain (root + script)
   aur saara structure **code me** hai. Gameplay me yeh boon hai, art me thoda weird.
7. **`await get_tree().create_timer().timeout`** ke baad node free ho sakta hai —
   lambi waits me `is_instance_valid()` check karo.

---

## 9. Git workflow (GitHub Desktop)

```
main            ← hamesha chalne wala build
  └─ feature/npc-schedules
  └─ feature/police-system
```

- Har feature = ek branch = ek PR (khud ka PR, khud merge — practice ke liye)
- Commit message: `M4: NPC schedule JSON + navmesh bake`
- Roz kam se kam 1 commit. `main` kabhi broken na ho.
- `.godot/` folder kabhi commit nahi hota (`.gitignore` me hai) — sahi hai, wo cache hai.

---

## 10. Debug karne ke tips

- `print()` sabse tez debugger hai. `[TAG] message` format rakho (`[World]`, `[Car]`).
- Godot me `F5` = run, `F6` = current scene run, `F8` = stop.
- Kisi node par ruk kar `Debugger → Remote` me uski live properties dekho.
- "Kuch nahi ho raha" 70% cases me: input action ka naam galat, ya node tree me
  `_process` band (`set_process(false)`), ya collision layer mismatch.
- Collision layers yahan: **1 = duniya, 2 = player, 3 = gaadi, 4 = NPC**.
  (Strictly: `layer 1`, `layer 2`, `layer 4`, `layer 8` — bits.)
