extends CharacterBody3D
##
## CAR — arcade driving with real kit model
##
## Physics: CharacterBody3D (arcade). Kyun? Kyunki VehicleBody3D ki suspension
## tune karna naye dev ke liye 90% cases me "flippy/undriveable" ban jata hai.
## Yahan feel turant accha aata hai, aur baad me swap karna easy hai.
##
## Model: KayKit car_sedan / hatchback / taxi / police / stationwagon
## Agar gaadi ulti chalti dikhe -> CAR_MODEL_YAW = 180.0
##

const ACCEL := 11.0
const MAX_SPEED := 30.0
const MAX_REVERSE := 9.0
const BRAKE_FORCE := 22.0
const ROLL_FRICTION := 4.5
const TURN_RATE := 1.9
const GRAVITY := 18.0
const CAR_MODEL_YAW := 0.0

var speed := 0.0
var driver = null
var exit_cooldown := 0.0
var kind := "car_sedan"
var model: Node3D
var headlights: Array = []
var engine_audio: AudioStreamPlayer3D
var _night := false


func _ready() -> void:
	add_to_group("vehicle")
	collision_layer = 4
	collision_mask = 1
	_build()
	if Game.car == null:
		Game.car = self


func configure(car_kind: String) -> void:
	kind = car_kind


func _build() -> void:
	var cs := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.8, 1.25, 4.0)
	cs.shape = shape
	cs.position = Vector3(0.0, 0.66, 0.0)
	add_child(cs)

	model = Kits.spawn_city(kind, self, Vector3.ZERO, 0.0, false, 1.1)
	if model != null:
		model.rotation_degrees.y = CAR_MODEL_YAW
		var box := Kits.local_aabb(model)
		model.position.y = -box.position.y * model.scale.y

	# Headlight glows (sasta, hamesha on)
	var lamp_mat := StandardMaterial3D.new()
	lamp_mat.albedo_color = Color(1.0, 0.95, 0.82)
	lamp_mat.emission_enabled = true
	lamp_mat.emission = Color(1.0, 0.9, 0.7)
	lamp_mat.emission_energy_multiplier = 3.0

	for sx in [-0.62, 0.62]:
		var lamp := MeshInstance3D.new()
		var quad := BoxMesh.new()
		quad.size = Vector3(0.32, 0.16, 0.06)
		lamp.mesh = quad
		lamp.material_override = lamp_mat
		lamp.position = Vector3(sx, 0.75, -1.95)
		add_child(lamp)
		headlights.append(lamp)

	# Asli roshni: sirf 1 spotlight (jab raat ho aur koi chala raha ho)
	var spot := SpotLight3D.new()
	spot.position = Vector3(0.0, 0.8, -1.9)
	spot.rotation_degrees = Vector3(-4.0, 0.0, 0.0)
	spot.spot_range = 34.0
	spot.spot_angle = 38.0
	spot.light_energy = 3.0
	spot.shadow_enabled = false
	spot.visible = false
	spot.name = "HeadlightSpot"
	add_child(spot)

	engine_audio = AudioStreamPlayer3D.new()
	engine_audio.bus = "Engine"
	engine_audio.volume_db = -6.0
	engine_audio.unit_size = 10.0
	engine_audio.max_distance = 45.0
	add_child(engine_audio)
	var s = Sound.stream(Sound.ENGINE_PATH, true)
	if s != null:
		engine_audio.stream = s


# ---------------------------------------------------------------------------
# DRIVING
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if Game.ui_open:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = 0.0

	var grip := 1.0
	var weather := get_tree().get_first_node_in_group("weather")
	if weather != null:
		grip = weather.grip_multiplier()

	if driver == null:
		speed = move_toward(speed, 0.0, ROLL_FRICTION * delta)
		_apply_velocity()
		move_and_slide()
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var max_speed := MAX_SPEED * grip

	if throttle > 0.05:
		speed = move_toward(speed, max_speed, ACCEL * grip * delta)
	elif throttle < -0.05:
		if speed > 0.2:
			speed = move_toward(speed, 0.0, BRAKE_FORCE * delta)
		else:
			speed = move_toward(speed, -MAX_REVERSE, ACCEL * delta)
	else:
		speed = move_toward(speed, 0.0, ROLL_FRICTION * delta)

	if abs(speed) > 0.4:
		var steering_grip: float = clamp(abs(speed) / 8.0, 0.15, 1.0) * grip
		rotation.y -= steer * TURN_RATE * steering_grip * delta * sign(speed)

	_apply_velocity()
	move_and_slide()

	# Reckless driving -> police heat
	if abs(speed) > 20.0:
		Game.add_heat(2.5 * delta)


func _apply_velocity() -> void:
	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed


func _process(delta: float) -> void:
	_night = Game.hour < 6.8 or Game.hour > 19.2
	var spot := get_node_or_null("HeadlightSpot")
	if spot != null:
		spot.visible = _night and driver != null

	if engine_audio != null:
		if driver != null:
			if not engine_audio.playing:
				engine_audio.play()
			engine_audio.pitch_scale = 0.72 + clamp(abs(speed) / MAX_SPEED, 0.0, 1.0) * 1.35
			engine_audio.volume_db = -8.0 + clamp(abs(speed) / MAX_SPEED, 0.0, 1.0) * 5.0
		elif engine_audio.playing:
			engine_audio.stop()

	exit_cooldown = max(0.0, exit_cooldown - delta)
	if driver == null:
		return
	if exit_cooldown <= 0.0 and Input.is_action_just_pressed("enter_vehicle"):
		release_driver()
	elif Input.is_action_just_pressed("horn"):
		Game.say("HONK! HONK!")


# ---------------------------------------------------------------------------
# DRIVER
# ---------------------------------------------------------------------------

func set_driver(player) -> void:
	if driver != null:
		return
	driver = player
	exit_cooldown = 0.4
	player.enter_vehicle(self)
	Game.say("Gaadi start — WASD chalao, Shift tez, F utro")


func release_driver() -> void:
	if driver == null:
		return
	var player = driver
	driver = null
	speed = 0.0
	velocity = Vector3.ZERO
	if engine_audio != null and engine_audio.playing:
		engine_audio.stop()
	var exit_pos: Vector3 = global_position + global_transform.basis.x * -2.4 + Vector3(0.0, 0.5, 0.0)
	player.exit_vehicle(exit_pos)
