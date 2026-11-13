# TECH NOTES — code kaise chalta hai, naya feature kaise jodta hai

Sab kuch **code se** banta hai — `.tscn` files minimal hain (root + script).
Isse merge conflicts nahi hote, aur tum ek file padh kar poora system samajh sakte ho.

---

## 1. File map

```
scripts/core/game.gd      autoload "Game"   — money, heat, time, save/load, quality, signals
scripts/core/kits.gd      autoload "Kits"   — GLTF load + spawn + AABB + collision + anim
scripts/core/audio.gd     autoload "Sound"  — music/ambience/3D sfx + rain layer
scripts/world/main.gd     _ready() me poora scene assemble karta hai
scripts/world/city.gd     tiles, buildings, props, spawn points
scripts/world/day_night.gd sun + sky + fog + ambient, raat/ din
scripts/world/weather.gd  clear/rain/fog + grip multiplier
scripts/world/kiosk.gd    Corner Store ki counter + panel (E)
scripts/player/player.gd  movement, camera, interactions, car enter/exit
scripts/vehicles/car.gd   arcade car, engine audio, lights
scripts/npc/npc.gd        routine, walk, flee, LOD
scripts/systems/*.gd      missions, random events, incident
scripts/ui/*.gd           HUD (code-built), pause menu
```

## 2. Launch sequence (`main.gd::_ready`)

```
_setup_environment()   WorldEnvironment + Sun (DirectionalLight3D)
add DayNight           clock + sun angles + colors
add District           city.build({}) -> spawn/npcs/cars/shop
add Player             spawn par
add Cars               configure() PEHLE, phir add_child
add NPCs               setup(i, male)
add Kiosk
add Weather            (player, env) — rain particles
add HUD, PauseMenu
_setup_post()          CanvasLayer + vignette/grain ColorRects (shader shaders/)
add Missions
add WorldEvents
_apply_quality()       preset apply + Game.quality_changed.connect()
```

## 3. Signals (Game)

| Signal | Kab | Kaun sunta hai |
|---|---|---|
| `money_changed(amount)` | paisa badla | HUD |
| `mission_changed(text)` | objective badla | HUD |
| `notification(text)` | toast | HUD |
| `quality_changed(level)` | F10 / menu | main (apply karo) |
| `heat_changed(level)` | crime | HUD |

Naya system banao → `Game.notification.emit("...")` se HUD par message bhej do.

---

## 4. Recipes

### Naya building type
1. `.gltf` + `.bin` `assets/city/` me (2×2 tile grid, ground se upar)
2. `city.gd` → `_building()` ke `names` array me naam
3. Done. Collision `Kits.add_box_collision()` khud bana dega.

### Naya prop
`city.gd` → `_park()` / `_sidewalk_props()` me `_prop("naam", pos + offset, yaw)`

### Naya gaadi
1. model `assets/city/car_*.gltf`
2. `main.gd` → `CAR_KINDS` me add
3. Speed/handling alag chahiye → `car.gd::configure()` me kind ke hisaab se values

### NPC ka naya behaviour
`npc.gd` me ek state add karo (`Routine` / `Flee` / `Talk`), `_tick()` me branch.
Agar 60m se dur ho to `_update_lod()` use kar raha hai — wahan kaam mat karo.

### Naya random event
1. `scripts/systems/incident.gd` copy karo → `robbery.gd`
2. `events.gd` → `SCENES` array me add
3. `Game.say(...)` se player ko batao, `E` se interaction, `Game.add_money()`

### Naya mission step
`missions.gd` → `STEPS` array (Dictionary): `{"title": "", "target": Vector3, "type": "goto", "reward": 250}`
`_check()` me type ke hisaab se complete karo (`goto` abhi implemented).

### Naya weather type
`weather.gd` → `enum State` me add → `_apply()` me fog density/rain/sun dim + `grip_multiplier()`

---

## 5. Gotchas (yeh bhoolne par bug aayega)

| Cheez | Detail |
|---|---|
| **Kit scale** | city kit me 1 tile = 2 units. `Kits.CITY_SCALE = 4` → 8m tile. Square scale. |
| **Kit Y** | `flat=true` tile ka Y squash karta hai (curb step se bachne ke liye) |
| **Building plinth** | buildings ka base 0.1 niche hai → `BUILDING_Y = -0.3` |
| **Animation names** | substring match (`idle` → `Idle_Loop`). `Kits.find_anim("juggle")` = null → T-pose |
| **Model facing** | model peeche chalta lage to `player.gd::MODEL_FACING_OFFSET` ya `car.gd::CAR_MODEL_YAW` |
| **`configure()` timing** | car kind `add_child()` se **pehle** set karo (`_ready` usi par build karta hai) |
| **add_to_group** | node tree me aane ke **baad** karo, warna error |
| **GDScript ternary** | `? :` nahi hota — `x if cond else y` |
| **Variant typing** | `var x := something_variant` error de sakta hai — `var x = ...` |
| **Environment props** | Godot version ke hisaab se kuch props na ho → `env.set("prop", v)` use karo |
| **LOD** | NPC 58m se dur = mesh hidden. Us par logic mat chalao jo player ko dikhna chahiye |
| **Physics layers** | 1 = world/player/npc/car, 2 = interactables (raycast) |

---

## 6. Save format (`user://fallen_state_save.json`)

```json
{ "version": 2, "money": 1200, "hour": 9.5, "day": 1, "heat": 0,
  "flags": { "met_contact": true },
  "player_pos": [0, 0.5, -16], "car_pos": [-8, 0.4, -16], "car_rot": 90 }
```
Settings: `user://fallen_state_settings.json` → `{"quality": 1}`

Naya data save karna ho → `game.gd::save_game()` me key add + `_load_*` me restore.

---

## 7. Code style

- **Tabs** (Godot default), `snake_case` vars, `PascalCase` classes
- Comment **Hinglish** me — kyunki ye tumhara akela project hai
- Magic number ko `const` banao (top par)
- `_process` me `get_node` mat karo — `_ready` me `@onready`/local me cache karo
- Har feature ke baad: **Run → 0 error → commit**
