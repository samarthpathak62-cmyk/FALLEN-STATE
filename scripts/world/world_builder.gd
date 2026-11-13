extends Node3D
##
## WORLD BUILDER — "Graybox District" procedurally banata hai
##
## Philosophy: pehle grey boxes se map banao, feel test karo, PHIR art lagao.
## Har building baad me apne .glb model se replace ho sakti hai — layout,
## collision aur gameplay points same rahenge.
##
## Layout: 4x4 city blocks, har block ke beech 16m chaudi sadak.
##         4 blocks me se 1 block me enterable "Corner Store" hai.
##

const CELL := 56.0          # ek block + ek sadak
const ROAD_WIDTH := 16.0
const BLOCK_SIZE := 40.0
const GRID := 4

const SHOP_SCRIPT := preload("res://scripts/world/shop_counter.gd")

var mat_ground: StandardMaterial3D
var mat_road: StandardMaterial3D
var mat_line: StandardMaterial3D
var mat_sidewalk: StandardMaterial3D
var mat_floor: StandardMaterial3D
var mat_window: StandardMaterial3D

var _wall_cache: Dictionary = {}


func _ready() -> void:
	_prepare_materials()


func _prepare_materials() -> void:
	mat_ground = _simple(Color(0.17, 0.17, 0.16), 0.95)
	mat_road = _simple(Color(0.085, 0.085, 0.095), 0.9)
	mat_sidewalk = _simple(Color(0.34, 0.34, 0.35), 0.9)
	mat_floor = _simple(Color(0.24, 0.22, 0.2), 0.85)

	mat_line = StandardMaterial3D.new()
	mat_line.albedo_color = Color(0.85, 0.8, 0.55)
	mat_line.emission_enabled = true
	mat_line.emission = Color(0.6, 0.55, 0.35)
	mat_line.emission_energy_multiplier = 0.4

	mat_window = StandardMaterial3D.new()
	mat_window.albedo_color = Color(0.12, 0.16, 0.22)
	mat_window.metallic = 0.6
	mat_window.roughness = 0.15
	mat_window.emission_enabled = true
	mat_window.emission = Color(0.95, 0.8, 0.5)
	mat_window.emission_energy_multiplier = 0.8


func _simple(color: Color, roughness: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = roughness
	return m


# ===========================================================================
# MAIN ENTRY
# ===========================================================================

func build() -> Dictionary:
	var info: Dictionary = {
		"spawn": Vector3(0.0, 0.4, 28.0),
		"car_spawn": Vector3(6.0, 0.8, 28.0),
		"contact_point": Vector3(-56.0, 0.4, 20.0),
		"shop_door": Vector3.ZERO,
		"road_lines": [],
		"npc_spawns": [],
		"extra_car_spawns": [],
	}

	_build_ground()

	# --- Roads (grid) ---
	var lines: Array = []
	for k in range(GRID + 1):
		var p: float = (k - GRID * 0.5) * CELL
		lines.append(p)
		_road(Vector3(p, 0.04, 0.0), Vector3(ROAD_WIDTH, 0.08, GRID * CELL + ROAD_WIDTH))
		_road(Vector3(0.0, 0.04, p), Vector3(GRID * CELL + ROAD_WIDTH, 0.08, ROAD_WIDTH))
		_lane_line(Vector3(p, 0.09, 0.0), Vector3(0.3, 0.04, GRID * CELL))
		_lane_line(Vector3(0.0, 0.09, p), Vector3(GRID * CELL, 0.04, 0.3))
	info["road_lines"] = lines

	# --- Blocks ---
	for i in range(GRID):
		for j in range(GRID):
			var center := Vector3((i - (GRID - 1) * 0.5) * CELL, 0.0, (j - (GRID - 1) * 0.5) * CELL)
			_sidewalk(center)
			if i == 1 and j == 2:
				info["shop_door"] = _build_shop(center)
			elif (i + j) % 3 == 0:
				_build_park(center)
			else:
				_build_block(center)

	# --- Streetlights (sirf kuch, kyunki har light ka cost hota hai) ---
	var light_spots: Array = [
		Vector3(9.0, 0.0, 9.0), Vector3(-9.0, 0.0, 9.0),
		Vector3(9.0, 0.0, -9.0), Vector3(-9.0, 0.0, -9.0),
		Vector3(65.0, 0.0, 28.0), Vector3(-56.0, 0.0, 37.0),
	]
	for spot in light_spots:
		_streetlight(spot)

	# --- NPC spawn points (sadak ke kinare, sirf andar wali roads) ---
	var walk_lines: Array = []
	for li in range(1, lines.size() - 1):
		walk_lines.append(lines[li])
	# 40 spawn points banao — main.gd me NPC_COUNT decide karta hai kitne zinda honge
	for n in range(40):
		var line: float = walk_lines[randi() % walk_lines.size()]
		var along := randf_range(-70.0, 70.0)
		var side := 1.0 if randf() > 0.5 else -1.0
		var offset: float = ROAD_WIDTH * 0.5 + 2.0
		var pos := Vector3(line + side * offset, 0.4, along)
		info["npc_spawns"].append(pos)

	# --- Extra parked/idle cars ---
	info["extra_car_spawns"].append(Vector3(-56.0, 0.8, -40.0))
	info["extra_car_spawns"].append(Vector3(56.0, 0.8, 60.0))
	info["extra_car_spawns"].append(Vector3(-8.0, 0.8, -56.0))

	print("[World] district built — blocks: %d x %d" % [GRID, GRID])
	return info


# ===========================================================================
# GROUND / ROADS
# ===========================================================================

func _build_ground() -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(600.0, 1.0, 600.0)
	cs.shape = shape
	cs.position = Vector3(0.0, -0.5, 0.0)
	body.add_child(cs)
	add_child(body)

	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(600.0, 1.0, 600.0)
	mi.mesh = mesh
	mi.position = Vector3(0.0, -0.5, 0.0)
	mi.material_override = mat_ground
	add_child(mi)


func _road(pos: Vector3, size: Vector3) -> void:
	_add_box(pos, size, mat_road, false)


func _lane_line(pos: Vector3, size: Vector3) -> void:
	_add_box(pos, size, mat_line, false)


func _sidewalk(center: Vector3) -> void:
	_add_box(center + Vector3(0.0, 0.06, 0.0), Vector3(BLOCK_SIZE + 2.0, 0.12, BLOCK_SIZE + 2.0), mat_sidewalk, false)


# ===========================================================================
# BUILDINGS
# ===========================================================================

func _build_block(center: Vector3) -> void:
	var count := randi_range(1, 3)
	for n in range(count):
		var fw := randf_range(12.0, 19.0)
		var fd := randf_range(12.0, 19.0)
		var height := randf_range(7.0, 20.0)
		if randf() < 0.18:
			height = randf_range(26.0, 42.0)   # kabhi kabhi tower

		var pos := center + Vector3(randf_range(-10.0, 10.0), 0.0, randf_range(-10.0, 10.0))
		# 4m inset: building kabhi bhi sadak ke kinare na aaye, sidewalk khula rahe
		var half_block: float = BLOCK_SIZE * 0.5 - 4.0
		pos.x = clamp(pos.x, center.x - half_block + fw * 0.5, center.x + half_block - fw * 0.5)
		pos.z = clamp(pos.z, center.z - half_block + fd * 0.5, center.z + half_block - fd * 0.5)

		_building(pos, Vector2(fw, fd), height, _random_building_color())


func _building(center: Vector3, footprint: Vector2, height: float, color: Color) -> void:
	var body := StaticBody3D.new()
	body.collision_layer = 1
	body.collision_mask = 0
	body.position = Vector3(center.x, 0.0, center.z)
	add_child(body)

	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(footprint.x, height, footprint.y)
	cs.shape = shape
	cs.position = Vector3(0.0, height * 0.5, 0.0)
	body.add_child(cs)

	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(footprint.x, height, footprint.y)
	mi.mesh = mesh
	mi.position = Vector3(0.0, height * 0.5, 0.0)
	mi.material_override = _wall(color)
	body.add_child(mi)

	# Roof slab
	_add_box(
		Vector3(center.x, height + 0.2, center.z),
		Vector3(footprint.x + 0.7, 0.4, footprint.y + 0.7),
		_wall(color.darkened(0.3)),
		false
	)

	# Window band (front face) — box city me bhi "building" jaisa lage
	var band_height: float = height * 0.5
	_add_box(
		Vector3(center.x, height * 0.55, center.z + footprint.y * 0.5 + 0.03),
		Vector3(footprint.x * 0.8, band_height, 0.06),
		mat_window,
		false
	)


func _wall(color: Color) -> StandardMaterial3D:
	var key := color.to_html(false)
	if _wall_cache.has(key):
		return _wall_cache[key]
	var m := _simple(color, 0.85)
	m.metallic = 0.1
	_wall_cache[key] = m
	return m


func _random_building_color() -> Color:
	var palette: Array = [
		Color(0.4, 0.38, 0.35), Color(0.32, 0.32, 0.35), Color(0.46, 0.42, 0.36),
		Color(0.28, 0.26, 0.24), Color(0.38, 0.34, 0.3), Color(0.24, 0.27, 0.3),
	]
	return palette[randi() % palette.size()]


# ===========================================================================
# PARK
# ===========================================================================

func _build_park(center: Vector3) -> void:
	_add_box(center + Vector3(0.0, 0.06, 0.0), Vector3(BLOCK_SIZE, 0.12, BLOCK_SIZE), _simple(Color(0.17, 0.26, 0.14), 0.95), false)
	for n in range(4):
		var pos := center + Vector3(randf_range(-14.0, 14.0), 0.0, randf_range(-14.0, 14.0))
		_tree(pos)
	# Bench-ish block
	_add_box(center + Vector3(0.0, 0.55, 0.0), Vector3(3.0, 0.15, 0.7), _simple(Color(0.32, 0.22, 0.14), 0.9), false)


func _tree(pos: Vector3) -> void:
	var trunk := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.17
	cyl.bottom_radius = 0.24
	cyl.height = 2.6
	trunk.mesh = cyl
	trunk.position = pos + Vector3(0.0, 1.3, 0.0)
	trunk.material_override = _simple(Color(0.24, 0.17, 0.11), 0.95)
	add_child(trunk)

	var leaves := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 1.6
	sphere.height = 3.2
	leaves.mesh = sphere
	leaves.position = pos + Vector3(0.0, 3.4, 0.0)
	leaves.material_override = _simple(Color(0.15, 0.29, 0.13), 0.95)
	add_child(leaves)


# ===========================================================================
# STREETLIGHT
# ===========================================================================

func _streetlight(pos: Vector3) -> void:
	var pole := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 0.09
	cyl.bottom_radius = 0.13
	cyl.height = 6.0
	pole.mesh = cyl
	pole.position = pos + Vector3(0.0, 3.0, 0.0)
	pole.material_override = _simple(Color(0.12, 0.12, 0.13), 0.7)
	add_child(pole)

	var head := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.1, 0.16, 0.3)
	head.mesh = box
	head.position = pos + Vector3(0.45, 6.05, 0.0)
	var head_mat := StandardMaterial3D.new()
	head_mat.albedo_color = Color(1.0, 0.92, 0.7)
	head_mat.emission_enabled = true
	head_mat.emission = Color(1.0, 0.85, 0.55)
	head_mat.emission_energy_multiplier = 1.5
	head.material_override = head_mat
	add_child(head)

	var light := OmniLight3D.new()
	light.position = pos + Vector3(0.45, 5.8, 0.0)
	light.light_color = Color(1.0, 0.87, 0.62)
	light.light_energy = 2.2
	light.omni_range = 16.0
	add_child(light)


# ===========================================================================
# ENTERABLE SHOP  (building with a working door + interior)
# ===========================================================================

func _build_shop(center: Vector3) -> Vector3:
	var w := 13.0
	var d := 10.0
	var h := 4.2
	var wall := 0.4
	var door_w := 3.2
	var door_h := 2.9
	var base := Vector3(center.x, 0.0, center.z)

	# Floor (collision nahi — ground hi chalna hai, warna chhota step player ko rok dega).
	# Top 0.14 rakha hai taaki sidewalk (0.12) ke upar dikhe.
	_add_box(base + Vector3(0.0, 0.11, 0.0), Vector3(w, 0.06, d), mat_floor, false)

	var wall_mat := _wall(Color(0.42, 0.36, 0.3))
	var half_w := w * 0.5
	var half_d := d * 0.5

	# Back + side walls
	_add_box(base + Vector3(0.0, h * 0.5, -half_d), Vector3(w, h, wall), wall_mat, true)
	_add_box(base + Vector3(-half_w, h * 0.5, 0.0), Vector3(wall, h, d), wall_mat, true)
	_add_box(base + Vector3(half_w, h * 0.5, 0.0), Vector3(wall, h, d), wall_mat, true)

	# Front wall with a door gap
	var seg_w: float = (w - door_w) * 0.5
	var seg_x: float = door_w * 0.5 + seg_w * 0.5
	_add_box(base + Vector3(-seg_x, h * 0.5, half_d), Vector3(seg_w, h, wall), wall_mat, true)
	_add_box(base + Vector3(seg_x, h * 0.5, half_d), Vector3(seg_w, h, wall), wall_mat, true)
	# Lintel above the door
	_add_box(base + Vector3(0.0, door_h + (h - door_h) * 0.5, half_d), Vector3(door_w, h - door_h, wall), wall_mat, true)

	# Roof
	_add_box(base + Vector3(0.0, h + 0.2, 0.0), Vector3(w + 1.0, 0.4, d + 1.0), _wall(Color(0.22, 0.2, 0.19)), false)

	# Sign
	_add_box(base + Vector3(0.0, door_h + 0.65, half_d + 0.35), Vector3(4.6, 1.0, 0.3), _simple(Color(0.1, 0.1, 0.12), 0.7), false)
	var sign_label := Label3D.new()
	sign_label.text = "CORNER STORE"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.006
	sign_label.modulate = Color(1.0, 0.85, 0.4)
	sign_label.outline_size = 10
	sign_label.position = base + Vector3(0.0, door_h + 0.65, half_d + 0.55)
	add_child(sign_label)

	# Interior: counter + shelves
	_add_box(base + Vector3(0.0, 0.55, -half_d + 2.0), Vector3(5.0, 1.1, 0.9), _simple(Color(0.3, 0.24, 0.18), 0.85), true)
	_add_box(base + Vector3(-half_w + 1.2, 1.6, 0.0), Vector3(0.7, 2.2, d - 3.0), _simple(Color(0.26, 0.22, 0.18), 0.85), true)
	_add_box(base + Vector3(half_w - 1.2, 1.6, 0.0), Vector3(0.7, 2.2, d - 3.0), _simple(Color(0.26, 0.22, 0.18), 0.85), true)

	# Interior light
	var lamp := OmniLight3D.new()
	lamp.position = base + Vector3(0.0, h - 0.5, 0.0)
	lamp.light_color = Color(1.0, 0.9, 0.72)
	lamp.light_energy = 2.6
	lamp.omni_range = 14.0
	add_child(lamp)

	# Interaction point (shop UI yahan se khulta hai)
	var counter := Node3D.new()
	counter.set_script(SHOP_SCRIPT)
	counter.position = base + Vector3(0.0, 0.0, -half_d + 3.4)
	counter.name = "ShopCounter"
	add_child(counter)

	# Door ke bahar ka point (mission marker isi par jata hai)
	return base + Vector3(0.0, 0.0, half_d + 3.5)


# ===========================================================================
# SMALL HELPERS
# ===========================================================================

## Ek box mesh banao, aur chahe to uske saath ek static collision body.
func _add_box(pos: Vector3, size: Vector3, mat: Material, with_collision: bool) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	mi.mesh = mesh
	mi.material_override = mat
	mi.position = pos
	add_child(mi)

	if with_collision:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		body.position = pos
		var cs := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = size
		cs.shape = shape
		body.add_child(cs)
		add_child(body)

	return mi
