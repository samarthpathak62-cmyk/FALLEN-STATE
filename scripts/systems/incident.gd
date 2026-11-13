extends Node3D
##
## INCIDENT — dynamic world event (abhi: sadak durghatna)
##
## Player ignore kar sakta hai (75s me gayab) ya E se madad kar sakta hai.
## Yeh chhoti si choice hi "living world" ka asli ehsaas deti hai.
##

const LIFETIME := 75.0

var resolved := false
var life := LIFETIME
var fire_light: OmniLight3D
var fire: MeshInstance3D
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
	flicker += delta * 13.0
	if fire_light != null:
		fire_light.light_energy = 2.4 + sin(flicker) * 0.6 + randf() * 0.4
	if fire != null:
		var s: float = 1.0 + sin(flicker * 0.8) * 0.14
		fire.scale = Vector3(s, s, s)


func get_prompt_text() -> String:
	return "Accident victims ki madad karo"


func interact(_player) -> void:
	if resolved:
		return
	resolved = true
	Game.add_money(120)
	Game.add_heat(-12.0)
	Game.say("Tumne madad ki. +$120, police heat kam. Log yaad rakhenge.")
	queue_free()


func _build() -> void:
	# Tuti hui gaadi (kit ka model, tedha khada)
	var wreck := Kits.spawn_city("car_hatchback", self, Vector3(0.0, 1.15, 0.0), 28.0, false, 1.1)
	if wreck != null:
		var box := Kits.local_aabb(wreck)
		wreck.position.y = -box.position.y * wreck.scale.y + 0.15

	# Aag
	fire = MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.7
	sph.height = 1.5
	fire.mesh = sph
	fire.position = Vector3(0.6, 0.9, 0.4)
	var fmat := StandardMaterial3D.new()
	fmat.albedo_color = Color(1.0, 0.45, 0.1, 0.85)
	fmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fmat.emission_enabled = true
	fmat.emission = Color(1.0, 0.5, 0.12)
	fmat.emission_energy_multiplier = 4.0
	fire.material_override = fmat
	add_child(fire)

	fire_light = OmniLight3D.new()
	fire_light.position = Vector3(0.6, 1.4, 0.4)
	fire_light.light_color = Color(1.0, 0.5, 0.2)
	fire_light.light_energy = 3.0
	fire_light.omni_range = 14.0
	fire_light.shadow_enabled = false
	add_child(fire_light)

	# Upar ka marker (dur se dikhe)
	var beam := MeshInstance3D.new()
	var cyl := CylinderMesh.new()
	cyl.top_radius = 1.1
	cyl.bottom_radius = 1.1
	cyl.height = 14.0
	beam.mesh = cyl
	beam.position.y = 7.0
	var bmat := StandardMaterial3D.new()
	bmat.albedo_color = Color(1.0, 0.35, 0.12, 0.22)
	bmat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	bmat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	bmat.cull_mode = BaseMaterial3D.CULL_DISABLED
	beam.material_override = bmat
	add_child(beam)
