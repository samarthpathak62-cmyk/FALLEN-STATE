extends Node3D
##
## CITY — KayKit modular kit se district build karta hai
##
## Grid: 13 x 13 tiles, ek tile = 8m  ->  ~104 x 104m ka chhota par dense district.
## Har 4th tile par sadak. Blocks 3x3 tiles ke hote hain.
##
## Kyun tile-based? Kyunki modular kit tiling ke liye bana hai — isse layout
## hamesha clean rahega, aur baad me naye kit pieces add karna 1 line ka kaam hai.
##

const GRID := 13
const ROAD_STEP := 4
const PAVEMENT_Y := 0.0

var buildings: Array = []
var lights: Array = []


func build(info: Dictionary) -> Dictionary:
	info["spawn"] = tile_pos(6, 4) + Vector3(0.0, Kits.GROUND_Y + 0.4, 0.0)
	info["contact_point"] = tile_pos(8, 6) + Vector3(0.0, Kits.GROUND_Y, 0.0)
	info["car_spawns"] = [
		tile_pos(5, 4) + Vector3(0.0, Kits.GROUND_Y + 0.25, 0.0),
		tile_pos(9, 8) + Vector3(0.0, Kits.GROUND_Y + 0.25, 0.0),
		tile_pos(4, 8) + Vector3(0.0, Kits.GROUND_Y + 0.25, 0.0),
		tile_pos(12, 4) + Vector3(0.0, Kits.GROUND_Y + 0.25, 0.0),
	]
	info["npc_spawns"] = _make_npc_spawns(40)

	_build_ground()
	for i in range(GRID):
		for j in range(GRID):
			var pos := tile_pos(i, j)
			var road_i := i % ROAD_STEP == 0
			var road_j := j % ROAD_STEP == 0
			if road_i and road_j:
				Kits.spawn_city("road_junction", self, pos, 0.0, true)
			elif road_i:
				Kits.spawn_city("road_straight", self, pos, 0.0, true)
			elif road_j:
				Kits.spawn_city("road_straight", self, pos, 90.0, true)
			else:
				_build_block_tile(i, j, pos, info)

	_place_streetlights(info)
	print("[City] district ready — buildings: %d" % buildings.size())
	return info


func _make_npc_spawns(count: int) -> Array:
	var out: Array = []
	for n in range(count):
		var along_x := randf() < 0.5
		var line := (randi() % (GRID / ROAD_STEP + 1)) * ROAD_STEP
		var t := randf_range(-46.0, 46.0)
		var side := 3.0 if randf() < 0.5 else -3.0
		var pos: Vector3
		if along_x:
			pos = Vector3(t, Kits.GROUND_Y + 0.2, (line - (GRID - 1) * 0.5) * Kits.TILE + side)
		else:
			pos = Vector3((line - (GRID - 1) * 0.5) * Kits.TILE + side, Kits.GROUND_Y + 0.2, t)
		out.append(pos)
	return out


func tile_pos(i: int, j: int) -> Vector3:
	var half := (GRID - 1) * 0.5
	return Vector3((i - half) * Kits.TILE, PAVEMENT_Y, (j - half) * Kits.TILE)


func is_road(i: int, j: int) -> bool:
	return i % ROAD_STEP == 0 or j % ROAD_STEP == 0


# ---------------------------------------------------------------------------
# GROUND
# ---------------------------------------------------------------------------

func _build_ground() -> void:
	# Badi flat ground (city ke bahar bhi) — ek hi collision plane, sabse sasta.
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(600.0, 1.0, 600.0)
	cs.shape = shape
	cs.position = Vector3(0.0, Kits.GROUND_Y - 0.5, 0.0)
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var mesh := PlaneMesh.new()
	mesh.size = Vector2(600.0, 600.0)
	mi.mesh = mesh
	mi.position.y = Kits.GROUND_Y - 0.01
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.16, 0.16, 0.17)
	mat.roughness = 0.95
	mi.material_override = mat
	add_child(mi)


# ---------------------------------------------------------------------------
# BLOCKS
# ---------------------------------------------------------------------------

func _build_block_tile(i: int, j: int, pos: Vector3, info: Dictionary) -> void:
	# Neeche pavement tile
	Kits.spawn_city("base", self, pos, 0.0, true)

	# Shop wala tile — yahan building + street-side interaction
	if i == 5 and j == 3:
		var yaw: float = 0.0 if randf() < 0.5 else 180.0
		var b := Kits.spawn_city("building_C", self, pos + Vector3(0.0, Kits.BUILDING_Y, 0.0), yaw)
		if b != null:
			Kits.add_box_collision(b)
			buildings.append(b)
		info["shop_point"] = pos + Vector3(0.0, Kits.GROUND_Y, Kits.TILE * 0.5 + 1.2)
		return

	var roll := randf()
	if roll < 0.60:
		_building(pos)
	elif roll < 0.78:
		_park(pos)
	else:
		_sidewalk_props(pos)


func _building(pos: Vector3) -> void:
	var names: Array = ["building_A", "building_B", "building_C", "building_D",
		"building_E", "building_F", "building_G", "building_H"]
	var pick: String = names[randi() % names.size()]
	var yaw: float = [0.0, 90.0, 180.0, 270.0][randi() % 4]
	var inst := Kits.spawn_city(pick, self, pos + Vector3(0.0, Kits.BUILDING_Y, 0.0), yaw)
	if inst == null:
		return
	Kits.add_box_collision(inst)
	buildings.append(inst)


func _park(pos: Vector3) -> void:
	# Ped, bench, bushes — city ka "saans lene wali" jagah
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	_prop("bench", pos + Vector3(rng.randf_range(-2.0, 2.0), Kits.GROUND_Y, rng.randf_range(-2.0, 2.0)), rng.randf_range(0, 360))
	for n in range(3):
		_prop("bush", pos + Vector3(rng.randf_range(-3.2, 3.2), Kits.GROUND_Y, rng.randf_range(-3.2, 3.2)), rng.randf_range(0, 360))
	for n in range(2):
		_prop("box_A", pos + Vector3(rng.randf_range(-3.0, 3.0), Kits.GROUND_Y, rng.randf_range(-3.0, 3.0)), rng.randf_range(0, 360))


func _sidewalk_props(pos: Vector3) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var choices: Array = ["dumpster", "firehydrant", "trash_A", "box_B", "bench"]
	for n in range(3):
		var p: String = choices[rng.randi() % choices.size()]
		_prop(p, pos + Vector3(rng.randf_range(-3.0, 3.0), Kits.GROUND_Y, rng.randf_range(-3.0, 3.0)), rng.randf_range(0, 360))


func _prop(prop_name: String, pos: Vector3, yaw: float) -> void:
	Kits.spawn_city(prop_name, self, pos, yaw, false)


# ---------------------------------------------------------------------------
# STREETLIGHTS
# ---------------------------------------------------------------------------

func _place_streetlights(info: Dictionary) -> void:
	var spots: Array = []
	for i in range(0, GRID, ROAD_STEP):
		for j in range(0, GRID, ROAD_STEP):
			# junction ke char corners
			for ox in [-1.0, 1.0]:
				for oz in [-1.0, 1.0]:
					spots.append(tile_pos(i, j) + Vector3(ox * Kits.TILE * 0.45, 0.0, oz * Kits.TILE * 0.45))

	for n in range(spots.size()):
		var p: Vector3 = spots[n]
		var lamp := Kits.spawn_city("streetlight", self, p + Vector3(0.0, Kits.GROUND_Y, 0.0), 0.0, false, 1.5)
		if lamp == null:
			continue
		# Har pole par light NAHI — sirf kuch. Omni lights mehange hote hain.
		var max_lights := [3, 6, 12][Game.quality]
		if n < max_lights:
			var light := OmniLight3D.new()
			light.position = p + Vector3(0.5, Kits.GROUND_Y + 7.2, 0.0)
			light.light_color = Color(1.0, 0.82, 0.55)
			light.light_energy = 3.2
			light.omni_range = 22.0
			light.shadow_enabled = false
			add_child(light)
			lights.append(light)
