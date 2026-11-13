extends Node
##
## MISSION SYSTEM (v0) — linear 3-step chapter
##
## Abhi ke liye hardcoded sequence hai — jaan-boojh kar. Pehle yeh chalao,
## phir roadmap M6 me isko data-driven banao (JSON/Resource me missions likho)
## taaki 50 missions add karna code likhne se na ho, file edit karne se ho.
##

var player = null
var info: Dictionary = {}
var index := -1
var check_timer := 0.0
var marker: Node3D
var beam: MeshInstance3D
var ring: MeshInstance3D
var label3d: Label3D


func setup(player_node, world_info: Dictionary) -> void:
	player = player_node
	info = world_info
	_build_marker()
	_start(0)


# ---------------------------------------------------------------------------
# MARKER (duniya me objective ka visual)
# ---------------------------------------------------------------------------

func _build_marker() -> void:
	marker = Node3D.new()
	marker.name = "ObjectiveMarker"
	add_child(marker)

	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.82, 0.2, 0.3)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam_mat.emission_enabled = true
	beam_mat.emission = Color(1.0, 0.75, 0.15)
	beam_mat.emission_energy_multiplier = 0.8
	beam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED

	beam = MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 10.0
	beam.mesh = cyl
	beam.position = Vector3(0.0, 5.0, 0.0)
	beam.material_override = beam_mat
	marker.add_child(beam)

	ring = MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.7
	torus.outer_radius = 2.1
	ring.mesh = torus
	ring.position = Vector3(0.0, 0.15, 0.0)
	ring.material_override = beam_mat
	marker.add_child(ring)

	label3d = Label3D.new()
	label3d.text = "OBJECTIVE"
	label3d.font_size = 64
	label3d.pixel_size = 0.01
	label3d.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label3d.modulate = Color(1.0, 0.85, 0.3)
	label3d.outline_size = 14
	label3d.position = Vector3(0.0, 10.5, 0.0)
	marker.add_child(label3d)


func _process(delta: float) -> void:
	if marker != null and marker.visible:
		var t := Time.get_ticks_msec() / 1000.0
		var s: float = 1.0 + sin(t * 2.0) * 0.06
		beam.scale = Vector3(s, 1.0, s)
		ring.rotation.y += delta * 0.8

	check_timer -= delta
	if check_timer > 0.0:
		return
	check_timer = 0.25
	_check_objective()


func _check_objective() -> void:
	if player == null or not is_instance_valid(player):
		return

	match index:
		0:
			var point: Vector3 = info["contact_point"]
			if player.global_position.distance_to(point) < 5.0:
				Game.add_money(250)
				Game.say("Contact mil gaya — usne bola: 'City ke andar sab bikta hai.' (+$250)")
				_start(1)
		1:
			if player.driving:
				Game.add_money(150)
				Game.say("Gaadi tumhari. Ab city tumhari. (+$150)")
				_start(2)
		2:
			if Game.flags.get("has_intel", false) == true:
				Game.say("Intel mil gaya. CHAPTER 1 COMPLETE.")
				_start(3)


func _start(new_index: int) -> void:
	index = new_index
	match index:
		0:
			Game.objective = "MISSION 1/3 · Meet the Contact — yellow marker follow karo"
			_place_marker(info["contact_point"])
		1:
			Game.objective = "MISSION 2/3 · Ek gaadi lo — kisi car ke paas jaake F dabao"
			marker.visible = false
		2:
			Game.objective = "MISSION 3/3 · Corner Store jaake $200 ka intel kharido (E)"
			_place_marker(info["shop_door"])
		3:
			Game.objective = "CHAPTER 1 COMPLETE · ab docs/ROADMAP.md kholo aur apna M4 chuno"
			marker.visible = false


func _place_marker(pos: Vector3) -> void:
	marker.global_position = Vector3(pos.x, 0.0, pos.z)
	marker.visible = true
