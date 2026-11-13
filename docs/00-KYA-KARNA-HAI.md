# KYA KARNA HAI — seedhi baat, no bakwaas

> Bhai, tu poochh raha hai "kya karna hai, kaise karna hai, kya use karna hai".
> Yeh file usi ka jawab hai. 15 minute me padh le, phir 1 saal ka confusion khatam.

---

## 1. Seedhi baat (TL;DR)

1. **Godot 4 use kar. Unity 6.6 abhi band kar de.** Is project ke liye aur tere liye.
2. **Poora game nahi banega. Ek district banega.** Woh district itna accha banega ki log poochhein "aur kab aayega?" — GTA-jaisa map kabhi mat banao.
3. **Yeh repo already tera foundation hai.** Isme player, gaadi, 16 NPC, day/night, dukaan, mission, save — sab chal raha hai. Aage isi ke upar 5% kaam roz karna hai.
4. **Pehle mahine me art nahi, FEEL banega.** Boxes se map banao. Jis din tumhare boxes me driving + NPCs "alive" lagein, us din tumhare paas game hai. Art baad me lagti hai.
5. **Roz 2 ghante, 6 din hafte me.** 6 mahine me ek aisa vertical slice banega jise tum YouTube par dikha sakte ho (*"I'm building a GTA-style game alone"* — uski shortfilm hi marketing hai).

---

## 2. Reality check (yeh padhna zaroori hai)

| Game | Team | Time | Budget (public reports) |
|---|---|---|---|
| GTA V (2013) | 1000+ log | ~5 saal | ~$265M |
| RDR 2 (2018) | 2000+ log | ~8 saal | ~$500M+ |
| Cyberpunk 2077 | 500+ log | ~8 saal | ~$300M+ |

Tu ek banda hai. Matlab tere paas **GTA ka 0.0001%** resources hain. Isliye:

> **"Don't make a giant map. Make a world that feels alive."**
> Ye tumhare doc ka sabse sach line hai — aur iska practical matlab hai:
> **1 district × 5 buildings × 15 NPC × 20 log jo unhe yaad rakhein** >> **100 km² khali map**.

Jo solo devs is genre me succeed karte hain (Stardew Valley, Kenshi, Dwarf Fortress,
Cloudpunk, Shady Lewd Kart type projects), wo **depth** bechte hain, **size** nahi.
Tera product yahi hoga: **ek gali, jo sach me zinda lagti hai.**

**Target jo realistic hai:**
- 6 mahine → 15-20 min ka vertical slice (1 district, 1 chapter, 3 side events)
- 18 mahine → 3-4 ghante ka "Chapter 1" — paid demo / Early Access
- Poore game (GTA-jaisa) → **solo me possible nahi**. 3 ghante ka premium story game possible hai.

---

## 3. Engine: Godot, not Unity (is project ke liye)

Tere paas dono hain. Dono me noob hai. Phir bhi Godot:

| Cheez | Godot 4 | Unity 6.6 |
|---|---|---|
| Install / project size | 100 MB zip, project 5 MB | 10+ GB, account, licensing |
| Compile time | **zero** (GDScript instant) | 20-60s+ har change |
| Language | GDScript (Python jaisa, 1 hafte me aa jata hai) | C# (structured, but boilerplate zyada) |
| Iteration speed (game dev me sabse important) | 10 min me 10 baar test | 5 baar |
| Open world ke liye | built-in streaming, `WorldEnvironment`, easy | bhi accha, but heavier setup |
| Kitne cheezein "built-in" | zyada (CharacterBody3D, SpringArm, Label3D, NavigationAgent3D) | zyada par marketplace pe depend |
| Source code | poora open, MIT | closed |
| Career/jobs | kam (industry me Unity/Unreal chalta hai) | **zyada** |
| Free assets/tutorials | theek | **bahut zyada** |
| Crashing / licensing drama | nahi | runtime fee drama dekh chuka hai |

**Verdict:** Solo dev, pehla bada project, 3D open world, jaldi-jaldi seekhna →
**Godot 4**. Reason simple hai: **GDScript me tu 10x zyada baar code chala kar seekhega**,
aur beginners ko game dev nahi, *iteration speed* sikhata hai.

**Unity kab use karo?** Sirf do case me:
1. Tu Unity me job karna chahta hai (studio jobs 90% Unity/Unreal).
2. Tere ko C# + koi Unity-expert dost already hai.

Warna aaj se Unity ke tutorials band. Do engines ek saath = dono me noob reh jayega.

> **Ek engine. Ek project. Ek saal.** Yeh mantra hai.

---

## 4. Kya use karna hai (tool stack — sab free)

| Kaam | Tool | Note |
|---|---|---|
| Engine | **Godot 4.4+** (standard, NOT .NET) | zip extract, install nahi |
| Code editor | Godot ka built-in editor (shuru me) | baad me VS Code + godot-tools |
| 3D models | **Blender 4.x** | buildings/props ke liye; character baad me |
| Character animation | **Mixamo** (free, Adobe) | humanoid walk/run/idle drag-drop |
| Free 3D assets | **Kenney, Quaternius, Poly Haven, Sketchfab (CC0)** | graybox ke baad art ke liye |
| Textures | **Poly Haven (HDRIs + materials)**, ambientCG | PBR ready |
| Audio (SFX) | **Freesound, Pixabay, Sonniss GDC bundles** | city ambience, sirens |
| Music | Suno/Beatoven (AI) ya YouTube Audio Library | commercial license check karna |
| 2D/UI art | Krita / GIMP / Figma | HUD, icons |
| Version control | **Git + GitHub Desktop** | ⚠️ non-negotiable |
| Task list | Notion / Trello / GitHub Projects | milestone-wise |
| Recording | OBS Studio | apne playtest record karo |
| Notes | ek `NOTES.md` file repo me | bhoolna mat |

**Kya NAHI use karna (abhi):**
- Unreal Engine (hardware + 3 mahine waste)
- Unity (upar reason)
- Blender me detailed character modelling (yeh rabbit hole hai — Mixamo use karo)
- Paid asset packs (jab tak prototype ko koi "fun" nahi bolta)
- AI-generated code bina padhe (tujhe samajh nahi aayega, aur bug fix nahi hoga)

**Seekhne ke resources (priority order):**
1. Godot official docs → "Your first 3D game" (2 din)
2. GDQuest — free "Learn GDScript from Zero" interactive course (3 din)
3. Godot ke built-in "Node demos" (`CharacterBody3D`, `NavigationAgent3D`)
4. Brackeys/Godot YouTube — sirf specific problem ke liye, tutorial marathon mat karo

---

## 5. Aaj se 30 din (exact plan)

### Din 1 (aaj) — 2 ghante
- [ ] Godot 4.4 download + import `project.godot` (README dekh)
- [ ] Game chalao: ghumo, gaadi chalao, shop kholo, accident me help karo
- [ ] `scripts/world/main.gd` kholo → `NPC_COUNT` 16 → 40 karo → dobara chalao
- [ ] `scripts/world/day_night.gd` me `MINUTES_PER_SECOND` `1.0` → `6.0` karo (din tez chalega)

### Din 2-7 — GDScript basics (roz 1.5 ghante)
- [ ] Variables, `if`, `for`, `while`, functions
- [ ] Arrays, Dictionaries, `Vector3`
- [ ] Nodes vs Scenes, `_ready()` / `_process()` / `_physics_process()`
- [ ] Signals (`emit`, `connect`)
- **Goal:** bina tutorial dekhe ek script likhna jo 5 boxes ko ghumaye

### Din 8-14 — pehla apna feature
- [ ] Naya NPC type: "shopkeeper" jo apni jagah khada rahe
- [ ] Ya: naya random event (chori) `world_events.gd` me
- [ ] Ya: ek nayi enterable dukaan (pattern `shop_counter.gd` me hai)
- **Goal:** repo me apna naam commit karna, apna feature

### Din 15-21 — apna art touch
- [ ] Kenney/Quaternius se ek building model download → Blender me check → Godot me import
- [ ] `world_builder.gd` me usko `BoxMesh` ki jagah lagana (`PackedScene.instantiate()`)
- **Goal:** 1 block me box ki jagah real building

### Din 22-30 — feel tuning (yeh sabse important hai)
- [ ] Camera ki `spring_length`, `WALK_SPEED`, `RUN_SPEED` tune karo
- [ ] Gaadi ki `MAX_SPEED`, `TURN_RATE` tune karo — 20 baar khelo
- [ ] Ek dost ko 10 min khela do, **kuch mat batao**, sirf dekhna wo kahan confuse hai
- [ ] Uske feedback ki list `docs/ROADMAP.md` ke "playtest notes" me likho

> 30 din baad: tu Godot me noob nahi rahega. Tu "beginner" hoga — jo bilkul theek hai.

---

## 6. Roz ka routine (yeh discipline hi game banayegi)

- **2 ghante**: 30 min padhna/inspiration + 90 min code
- Har session ke baad **commit** (GitHub Desktop → Commit → Push). Message: `M4: NPC schedule JSON added`
- Har hafte **1 feature** complete, 5 half-features nahi
- Har hafte **playtest** (khud ya koi aur) aur 3 cheezein likho: kya maza aaya, kya boring tha, kya toota
- Mahine me ek baar **YouTube devlog** (2 min) — accountability + future marketing
- **Kabhi bhi** "aaj mood nahi" wale din file delete nahi karni. Chhodo, agli baar kholo.

---

## 7. Woh 10 galtiyan jo har noob karta hai (tu na kar)

1. **Poora map pehle banana** — 6 mahine khali map, koi gameplay nahi. Ulta karo: 1 gali pehle.
2. **Character controller khud likhne me 3 mahine** — Godot ka `CharacterBody3D` + `SpringArm3D` kaafi hai. (Is repo me already hai.)
3. **Photorealistic graphics ka sapna** — lighting + fog + color palette se "realistic *feel*" aata hai, 4K textures se nahi.
4. **Multiplayer pehle** — multiplayer *baad me* add karne se architecture kharab hota hai, *pehle* add karne se game kabhi complete nahi hota. Isko M10 rakha hai.
5. **Engine badalna** — "Unity me better hota" trap. 1 saal me 1 engine.
6. **Tutorial hell** — 100 video dekhna, 0 code likhna. Rule: 1 tutorial → turant apne project me apply.
7. **Scope creep** — har hafte naya idea ("bhai plane bhi add karein?"). Idea pad do `docs/IDEAS-BACKLOG.md` me, M-list me nahi.
8. **Save system last me** — save/load architecture **pehle din** ka kaam hai (is repo me hai). Baad me retrofit karna 3x kaam hai.
9. **No version control** — `main_final_final_v3.rar`. Git use kar, warna ek corrupt file 6 mahine kha jayegi.
10. **Kisi ko na dikhana** — 6 mahine secretly banaoge, phir pata chalega "koi khelega hi nahi". Har mahine dikhao.

---

## 8. Hardware / performance (laptop walon ke liye)

Is repo me renderer **GL Compatibility** set hai (purane/iGPU laptops ke liye best).

- **Target:** 60 FPS, 1080p, GTX 1050 / Iris Xe class
- **Budget:** 1 frame = 16.6 ms. Draw calls < 1500, visible triangles < 1.5M
- **Rules:**
  - Buildings/props: **MultiMesh** ya shared materials (is repo me material cache hai)
  - Lights: **Omni lights mehange hain** — 6-10 max, shadows sirf sun ke
  - Player ke 60m ke bahar NPC simulate mat karo (roadmap M4)
  - Textures: 1K se zyada mat socho; normal maps > 4K bekaar
  - `VisibilityRange` / LOD + occlusion culling, M7 me
- **Test karne ka tarika:** Godot me `Debugger → Monitors` — FPS, draw calls, `Process` time dekho

---

## 9. Legal / paisa (jaldi pata kar lo)

- **Is repo ka LICENSE AGPL-3.0 hai.** Agar game bechna hai → AGPL nahi chalega. `LICENSE` ko **MIT** (open source) ya **proprietary** ("All rights reserved") se replace karna hoga. Godot engine khud MIT hai — usme koi condition nahi.
- Free assets use karne se pehle **license** padho (CC0 = safe, "non-commercial" = nahi).
- Mixamo animations: Adobe ke terms me commercial use allowed hai, but redistribution as-is nahi.
- Music: AI-generated music ke license terms check karo (platform-wise different).
- Steam page banane me paisa lagta hai (~$100), itch.io free hai — **demo itch.io par, announcement Steam par**.

---

## 10. Aaj raat ka homework

1. Game chalao, 15 min khelo. **Ek cheez likho** jo sabse zyada annoying thi.
2. `docs/ROADMAP.md` kholo → M4 me se **ek** task choose karo.
3. GitHub Desktop se repo clone karo (agar local me nahi hai), Godot se open karo.
4. Woh ek task kal ke liye tod do (30 min ka chunk banao).

Kal se tum "sapna dekhne wale" nahi, "banane wale" ho. 🚬
