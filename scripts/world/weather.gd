extends Node
##
## WEATHER — clear / rain / fog
##
## Sirf 3 states abhi, lekin structure ready hai. CPUParticles3D use kiya hai
## (GPU particles har driver par theek nahi chalte, aur 600 particles CPU par bhi saste hain).
##
## Weather sirf "dekhne" ki cheez nahi — grip kam hoti hai, fog badhti hai,
## NPC jaldi ghar bhagte hain, aur rain sound on ho jata hai.
##

enum State { CLEAR, RAIN, FOG }

var state: int = State.CLEAR
var timer: float = 90.0
var rain_particles: CPUParticles3D
var target: Node3D          # player — particles iske saath chalte hain
var env_ref: Environment = null

var _fog_density := 0.0015


func setup(follow_target: Node3D, environment: Environment) -> void:
	target = follow_target
	env_ref = environment
	_build_rain()
	if env_ref != null:
		_fog_density = float(env_ref.get("fog_density"))
	_apply(State.CLEAR)


func _build_rain() -> void:
	rain_particles = CPUParticles3D.new()
	rain_particles.emitting = false
	rain_particles.amount = 700 if Game.quality > 0 else 350
	rain_particles.lifetime = 1.1
	rain_particles.preprocess = 0.5
	rain_particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
	rain_particles.emission_box_extents = Vector3(28.0, 2.0, 28.0)
	rain_particles.direction = Vector3(0.12, -1.0, 0.06)
	rain_particles.spread = 3.0
	rain_particles.gravity = Vector3(0.0, -32.0, 0.0)
	rain_particles.initial_velocity_min = 12.0
	rain_particles.initial_velocity_max = 18.0
	rain_particles.scale_amount_min = 0.7
	rain_particles.scale_amount_max = 1.3

	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.02, 0.55, 0.02)
	rain_particles.mesh = mesh

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color(0.72, 0.80, 0.95, 0.55)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mesh.material = mat

	add_child(rain_particles)


func _process(delta: float) -> void:
	if target != null and is_instance_valid(target):
		rain_particles.global_position = target.global_position + Vector3(0.0, 18.0, 0.0)

	timer -= delta
	if timer > 0.0:
		return
	timer = randf_range(120.0, 260.0)
	var roll := randf()
	if roll < 0.6:
		_apply(State.CLEAR)
	elif roll < 0.9:
		_apply(State.RAIN)
	else:
		_apply(State.FOG)


func _apply(new_state: int) -> void:
	state = new_state
	var env := env_ref
	match state:
		State.CLEAR:
			rain_particles.emitting = false
			Sound.set_rain(false)
			if env != null:
				env.set("fog_density", _fog_density)
		State.RAIN:
			rain_particles.emitting = true
			Sound.set_rain(true)
			if env != null:
				env.set("fog_density", _fog_density * 2.4)
			Game.say("Baarish shuru — sadkein fisal rahi hain")
		State.FOG:
			rain_particles.emitting = false
			Sound.set_rain(false)
			if env != null:
				env.set("fog_density", _fog_density * 5.0)
			Game.say("Dhundh chha gayi — dheere chalao")


## Road grip: rain me kam (car.gd isse padhta hai)
func grip_multiplier() -> float:
	if state == State.RAIN:
		return 0.72
	return 1.0
