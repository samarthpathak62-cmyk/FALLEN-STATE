extends Node3D
##
## INCIDENT — ek "dynamic world event" (abhi ke liye: sadak durghatna)
##
## Player ignore kar sakta hai (event khud gayab ho jayega) ya E dabakar
## madad kar sakta hai (paisa + police heat kam). Yeh CHOICE hi living world hai.
##

const LIFETIME := 75.0

var resolved := false
var life := LIFETIME
var fire_light: OmniLight3D
var fire_mesh: MeshInstance3D
var flicker := 0.0


func _ready() -> void:
	add_to_group("interactable")
	_build()


func _process(delta: float) -> void:
	if resolved:
		return

	life -= delta
	if life <= 0.0:
		Game.say("Accident scene clear ho gaya — koi madad karne nahi aaya.")
		queue_free()
		return

	# Aag ka flicker (sasta illusion, bada effect)
	flicker += delta * 12.0
	if fire_light != null:
		fire_light.light_energy = 2.0 + sin(flicker) * 0.5 + randf() * 0.3
	if fire_mesh != null:
		var s: float = 1.0 + sin(flicker * 0.7) * 0.12
		fire_mesh.scale = Vector3(s, s, s)


func get_prompt_text() -> String:
	return "Accident victims ki madad karo"


func interact(_player) -> void:
	if resolved:
		return
	resolved = true
	Game.add_money(120)
	Game.add_heat(-12.0)
	Game.say("Tumne madad ki. +$120, police heat kam hui. Log tumhe yaad rakhenge.")
	queue_free()


func _build() -> void:
	# Tuta hua car
	var wreck := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.9, 0.75, 4.2)
	wreck.mesh = box
	wreck.position = Vector3(0.0, 0.5, 0.0)
	wreck.rotation.y = 0.55
	wreck.material_override = _mat(Color(0.32, 0.29, 0.27))
	add_child(wreck)

	# Cabin
	var cabin := MeshInstance3D.new()
	var cbox := BoxMesh.new()
	cbox.size = Vector3(1.6, 0.5, 2.0)
	cabin.mesh = cbox
	cabin.position = Vector3(0.1, 1.02, -0.1)
	cabin.rotation.y = 0.55
	cabin.material_override = _mat(Color(0.08, 0.08, 0.09))
	add_child(cabin)

	# Aag
	fire_mesh = MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.65
	sphere.height = 1.3
	fire_mesh.mesh = sphere
	fire_mesh.position = Vector3(0.5, 0.95, 0.6)
	var fire_mat := StandardMaterial3D.new()
	fire_mat.albedo_color = Color(1.0, 0.45, 0.1, 0.8)
	fire_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fire_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fire_mat.emission_enabled = true
	fire_mat.emission = Color(1.0, 0.5, 0.12)
	fire_mat.emission_energy_multiplier = 3.5
	fire_mesh.material_override = fire_mat
	add_child(fire_mesh)

	fire_light = OmniLight3D.new()
	fire_light.position = Vector3(0.5, 1.3, 0.6)
	fire_light.light_color = Color(1.0, 0.5, 0.2)
	fire_light.light_energy = 2.5
	fire_light.omni_range = 12.0
	add_child(fire_light)

	# Upar ka marker (door se dikh jaye)
	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.0
	cyl.bottom_radius = 1.0
	cyl.height = 12.0
	beam.mesh = cyl
	beam.position = Vector3(0.0, 6.0, 0.0)
	var beam_mat := StandardMaterial3D.new()
	beam_mat.albedo_color = Color(1.0, 0.35, 0.15, 0.25)
	beam_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	beam_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	beam_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam.material_override = beam_mat
	add_child(beam)


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.9
	return m
