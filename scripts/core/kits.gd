extends Node
##
## KITS — asset pipeline (autoload "Kits")
##
## Saara 3D asset loading ek hi jagah. Gameplay code kabhi file path nahi jaanta,
## sirf "building_A", "car_sedan", "human" bolta hai.
##
## Assets (sab CC0):
##   assets/city/       KayKit City Builder Bits  — 2x2 units ka modular kit
##   assets/characters/ Quaternius Universal Base Characters + 86 animations
##
## Kit ki unit chhoti hai (building = 2m), isliye CITY_SCALE se 4x karte hain:
##   tile = 8m, building = 8x8m aur 6-12m unchi. Character = 1.82m (asli sketch).
##

const CITY_DIR := "res://assets/city/"
const CHAR_MALE := "res://assets/characters/human_male.glb"
const CHAR_FEMALE := "res://assets/characters/human_female.glb"

const TILE := 8.0            # ek city tile kitne metre ka
const CITY_SCALE := 4.0      # kit 2 units -> 8m
const GROUND_Y := 0.1        # player/gaadi ka floor level
const BUILDING_Y := -0.3     # building ka plinth ground ke andar

var _cache: Dictionary = {}


# ---------------------------------------------------------------------------
# CITY KIT
# ---------------------------------------------------------------------------

func city_model(model_name: String) -> PackedScene:
	if _cache.has(model_name):
		return _cache[model_name]
	var path := CITY_DIR + model_name + ".gltf"
	var res: Resource = load(path)
	if res == null:
		push_error("[Kits] model nahi mila: " + path)
		return null
	var scene: PackedScene = res as PackedScene
	if scene == null:
		push_error("[Kits] PackedScene nahi hai: " + path)
		return null
	_cache[model_name] = scene
	return scene


## Ek tile/prop spawn karo. flat = true -> Y squash (road tiles ke liye,
## taaki curb ka 30cm step player ko na roke).
func spawn_city(model_name: String, parent: Node3D, pos: Vector3, yaw_deg: float = 0.0,
		flat: bool = false, extra_scale: float = 1.0) -> Node3D:
	var scene := city_model(model_name)
	if scene == null:
		return null
	var inst: Node3D = scene.instantiate()
	inst.position = pos
	inst.rotation_degrees.y = yaw_deg
	var s := CITY_SCALE * extra_scale
	if flat:
		# Road/pavement tiles: Y squash -> tile 10cm patla ho jata hai, curb ka
		# 40cm step nahi banta (warna player har sidewalk par atak jayega)
		inst.scale = Vector3(s, 1.0, s)
	else:
		inst.scale = Vector3(s, s, s)
	parent.add_child(inst)
	return inst


## Model ke MeshInstance3D children ka combined AABB (root ke local space me).
func local_aabb(root: Node3D) -> AABB:
	var out := AABB()
	var first := true
	for child in root.find_children("*", "MeshInstance3D", true, false):
		var mi := child as MeshInstance3D
		if mi.mesh == null:
			continue
		var t: Transform3D = root.global_transform.affine_inverse() * mi.global_transform
		var box := _transform_aabb(mi.mesh.get_aabb(), t)
		if first:
			out = box
			first = false
		else:
			out = out.merge(box)
	return out


func _transform_aabb(box: AABB, t: Transform3D) -> AABB:
	var mn := Vector3(1e9, 1e9, 1e9)
	var mx := Vector3(-1e9, -1e9, -1e9)
	for i in range(8):
		var p := box.position + Vector3(
			box.size.x * float(i & 1),
			box.size.y * float((i >> 1) & 1),
			box.size.z * float((i >> 2) & 1))
		var w: Vector3 = t * p
		mn = mn.min(w)
		mx = mx.max(w)
	return AABB(mn, mx - mn)


## Model ke liye box collision banao (trimesh se sasta aur kaafi).
func add_box_collision(inst: Node3D, shrink: float = 0.02) -> StaticBody3D:
	var box := local_aabb(inst)
	if box.size == Vector3.ZERO:
		return null
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(
		max(0.2, box.size.x - shrink),
		max(0.2, box.size.y),
		max(0.2, box.size.z - shrink))
	cs.shape = shape
	cs.position = box.position + box.size * 0.5
	body.add_child(cs)
	inst.add_child(body)
	return body


# ---------------------------------------------------------------------------
# CHARACTERS
# ---------------------------------------------------------------------------

## Rigged human. 86 animations built-in (Idle_Loop, Jog_Fwd_Loop, Sprint_Loop, ...)
func spawn_character(parent: Node3D, is_male: bool = true) -> Node3D:
	var path: String = CHAR_MALE if is_male else CHAR_FEMALE
	var res: Resource = load(path)
	if res == null:
		push_error("[Kits] character nahi mila: " + path)
		return null
	var scene: PackedScene = res as PackedScene
	if scene == null:
		return null
	var inst: Node3D = scene.instantiate()
	parent.add_child(inst)
	return inst


func find_animation_player(root: Node) -> AnimationPlayer:
	var arr: Array = root.find_children("*", "AnimationPlayer", true, false)
	if arr.is_empty():
		return null
	return arr[0] as AnimationPlayer


## Animation ka naam substring se dhoondo. Godot import ke waqt naam ke aage
## scene ka naam laga sakta hai ("Armature|Idle_Loop"), isliye partial match.
func find_anim(ap: AnimationPlayer, key: String) -> StringName:
	if ap == null:
		return &""
	var k := key.to_lower()
	for anim_name in ap.get_animation_list():
		if String(anim_name).to_lower().contains(k):
			return anim_name
	return &""


func play_anim(ap: AnimationPlayer, key: String, blend: float = 0.2) -> bool:
	var found := find_anim(ap, key)
	if found == &"":
		return false
	if ap.current_animation == found:
		return true
	ap.play(found, blend)
	return true
