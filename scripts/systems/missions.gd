extends Node
##
## MISSIONS (v0) — 3-step chapter, marker ke saath
##
## Abhi hardcoded hai (jaan-boojh kar). M6 me JSON-driven hoga:
##   { "id": "m02", "type": "goto", "point": [...], "reward": 300 }
## Tab mission *engine* likhna hai, mission *content* nahi.
##

var player = null
var info: Dictionary = {}
var index := -1
var check_timer := 0.0
var marker: Node3D
var beam: MeshInstance3D
var ring: MeshInstance3D


func setup(player_node, world_info: Dictionary) -> void:
	player = player_node
	info = world_info
	_build_marker()
	_start(0)


func _build_marker() -> void:
	marker = Node3D.new()
	marker.name = "ObjectiveMarker"
	add_child(marker)

	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(1.0, 0.8, 0.2, 0.28)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.emission_enabled = true
	mat.emission = Color(1.0, 0.72, 0.15)
	mat.emission_energy_multiplier = 1.2
	mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	beam = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.1
	cyl.bottom_radius = 1.1
	cyl.height = 11.0
	beam.mesh = cyl
	beam.position.y = 5.5
	beam.material_override = mat
	marker.add_child(beam)

	ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.8
	torus.outer_radius = 2.2
	ring.mesh = torus
	ring.position.y = 0.2
	ring.material_override = mat
	marker.add_child(ring)


func _process(delta: float) -> void:
	if marker != null and marker.visible:
		var t := Time.get_ticks_msec() / 1000.0
		var s: float = 1.0 + sin(t * 2.2) * 0.06
		beam.scale = Vector3(s, 1.0, s)
		ring.rotation.y += delta * 0.9

	check_timer -= delta
	if check_timer > 0.0:
		return
	check_timer = 0.25
	_check()


func _check() -> void:
	if player == null or not is_instance_valid(player):
		return

	match index:
		0:
			var point: Vector3 = info.get("contact_point", Vector3.ZERO)
			if player.global_position.distance_to(point) < 6.0:
				Game.add_money(250)
				Game.say("Contact mil gaya — 'Is city me sab bikta hai.' (+$250)")
				_start(1)
		1:
			if player.driving:
				Game.add_money(150)
				Game.say("Gaadi tumhari. Ab city bhi tumhari. (+$150)")
				_start(2)
		2:
			if Game.flags.get("has_intel", false) == true:
				Game.say("Intel mil gaya. CHAPTER 1 COMPLETE.")
				_start(3)


func _start(new_index: int) -> void:
	index = new_index
	match index:
		0:
			Game.objective = "MISSION 1/3 · Contact se milo — yellow marker follow karo"
			_place(info.get("contact_point", Vector3.ZERO))
		1:
			Game.objective = "MISSION 2/3 · Ek gaadi lo — kisi car ke paas F dabao"
			marker.visible = false
		2:
			Game.objective = "MISSION 3/3 · Corner Store se $200 ka intel kharido (E)"
			_place(info.get("shop_point", Vector3.ZERO))
		3:
			Game.objective = "CHAPTER 1 COMPLETE · ab docs/ROADMAP.md kholo aur M4 chuno"
			marker.visible = false


func _place(pos: Vector3) -> void:
	marker.global_position = Vector3(pos.x, Kits.GROUND_Y, pos.z)
	marker.visible = true
