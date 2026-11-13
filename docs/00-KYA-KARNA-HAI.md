# KYA KARNA HAI — plan

> v0.2 update: ab repo me **asli assets** hain (rigged humans, city kit, audio, shaders).
> Engine choice same hai. Neeche plan hai — 15 min me padh lo.

---

## 1. Seedhi baat

1. **Godot 4** — Unity 6.6 abhi band. Reason: GDScript instant compile, project 5MB,
   aur tum 10x zyada baar code chala kar seekhoge. (Unity sirf tab jab Unity me job chahiye.)
2. **Poora game nahi banega — ek district banega**, jo itna accha ho ki log poochhein "aage kab?"
3. **Art pehle nahi, FEEL pehle.** Is repo me abhi city + log + gaadi + audio hai.
   Agla kaam: unhe "alive" banana (M4), naye models jodna nahi.
4. **Roz 2 ghante, 6 din.** 6 mahine me vertical slice + trailer.
5. **Photoreal ka sapna chhodo** — iGPU par 60 FPS + photoreal dono possible nahi.
   "Stylized-realistic + lighting + sound" 90% player ko impress kar deta hai.
   (Detail: `docs/ASSETS.md` section 1.)

---

## 2. Engine: Godot (final)

| | Godot 4 | Unity 6.6 |
|---|---|---|
| Compile | zero | 20-60s har change |
| Size | 5MB project | 10GB+ editor |
| Language | GDScript (Python jaisa) | C# |
| Noob ke liye | 1-2 hafte | 1-2 mahine |
| Is project me already | sab chal raha hai | kuch nahi |

**Ek engine. Ek project. Ek saal.**

---

## 3. Abhi repo me kya hai (jo tumne maanga)

| Tumne kaha | Status |
|---|---|
| "characters chahiye" | ✅ Rigged humans, 86 animations (idle/jog/sprint/jump/drive) |
| "models, map chahiye" | ✅ 8 building types + roads + props + 5 gaadiyan (KayKit kit) |
| "assets" | ✅ PBR textures (characters), atlas texture (city) |
| "music, audio" | ✅ City ambience, footsteps, engine, siren, rain + 69s ambient music |
| "realistic shaders" | ✅ ACES tonemap + fog + sun shadows + vignette + film grain |
| "bina GPU wale laptop par chale" | ✅ LOW/MEDIUM/HIGH presets + character LOD (F10) |
| "realistic mechanics" | ✅ Animation-driven movement, arcade car with weather grip, NPC routines |

Baaki (M4+): interiors, police AI, missions data-driven, weather types, properties.

---

## 4. Aaj se 30 din

### Din 1 (aaj, 2 ghante)
- [ ] Game chalao — Godot → Import → `project.godot` → ▶
  (pehli baar 1-3 min import hoga, rukna)
- [ ] Shaam ke time city me ghumo, gaadi chalao, Corner Store se intel kharido
- [ ] `F10` dabao — LOW vs HIGH difference dekho
- [ ] `scripts/world/main.gd` → `NPC_COUNTS` ko `[8, 14, 22]` se `[20, 30, 40]` karo
- [ ] `scripts/world/day_night.gd` → `MINUTES_PER_SECOND = 6.0` (din tez)

### Din 2-7 — GDScript basics
Variables, if/for/while, functions, Array/Dictionary, Vector3, Node vs Scene,
`_ready/_process/_physics_process`, signals. (GDQuest ka free course + Godot docs)

### Din 8-14 — apna pehla feature
Teen me se ek chuno:
- [ ] Naya prop/building kit se add karo (`city.gd`)
- [ ] Naya random event (`events.gd` + `incident.gd` copy)
- [ ] NPC ko "yaad" karwao: agar player ne accident me help ki, wahi NPC baad me mile aur thank kare

### Din 15-21 — apna asset
- [ ] Mixamo se 1 character + walk/run download → `assets/characters/` → `kits.gd` me path
- [ ] Ya Poly Haven se 1 HDRI → sky me lagao → **difference feel karo**
- [ ] Ya Poly Haven/ambientCG se asphalt texture → road par lagao

### Din 22-30 — feel tuning
- [ ] `player.gd` me speeds (`WALK/JOG/SPRINT`) 20 baar khel ke tune karo
- [ ] `car.gd` me `MAX_SPEED`, `TURN_RATE`, `ACCEL`
- [ ] Camera `spring_length` 3.5 → 5.5 try karo
- [ ] Ek dost ko 10 min khela do, kuch mat batao, dekhna kahan confuse hai
- [ ] Feedback `docs/ROADMAP.md` ke playtest table me likho

---

## 5. Woh 10 galtiyan jo sab karte hain

1. **Poora map pehle** — 6 mahine khali map. Ulta: 1 gali, max depth.
2. **Hyper-realistic asset pack pe paisa** — pehle gameplay fun karo.
3. **Character controller khud likhne me 3 mahine** — `CharacterBody3D` + SpringArm kaafi hai.
4. **Multiplayer pehle** — M10, sirf jab single player complete ho.
5. **Engine badalna** ("Unity me better hota") — 1 saal, 1 engine.
6. **Tutorial hell** — 1 tutorial dekho → turant apne project me lagao.
7. **Scope creep** — naya idea `IDEAS-BACKLOG.md` me, roadmap me nahi.
8. **Save system last me** — already hai (`core/game.gd`), usse todo mat.
9. **No version control** — `main_final_v3.rar` culture chhodo. Git + GitHub Desktop.
10. **Kisi ko na dikhana** — har mahine devlog. Motivation bhi milega, marketing bhi.

---

## 6. Roz ka routine

- **2 ghante** = 25 min padhna/inspiration + 80 min code + 15 min test/commit
- Har session ke baad commit (GitHub Desktop): `M4: NPC schedule JSON`
- Har hafte **1 feature complete** (5 half-features nahi)
- Har hafte **playtest** — 3 cheezein likho: kya maza aaya / kya boring / kya toota
- Har mahine 1 devlog (2 min video)

---

## 7. Hardware

- Is repo ka default **GL Compatibility** renderer hai — 2016+ ke iGPU par chalta hai
- `F10` = LOW/MEDIUM/HIGH. Default MEDIUM. 30fps se neeche → LOW.
- Detail: `docs/PERFORMANCE.md`

---

## 8. Legal

- Repo code: **AGPL-3.0** → game bechna hai to MIT/proprietary karna padega.
- Assets: **CC0** (commercial OK) — source list `assets/licenses/SOURCES.md`
- Naya asset laao to uski license + URL wahin note karo.

---

## 9. Aaj raat ka homework

1. Game chalao. 15 min khelo. **Ek cheez likho** jo sabse zyada annoying thi.
2. `docs/ROADMAP.md` → M4 me se **ek** task chuno.
3. Us task ko 3 chunks me todo (kal, parso, agle din).

Kal se tum "sapna dekhne wale" nahi, "banane wale" ho.
