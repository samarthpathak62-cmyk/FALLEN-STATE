extends CharacterBody3D
##
## CAR — arcade driving (CharacterBody3D based)
##
## Kyun VehicleBody3D nahi? Kyunki real vehicle physics (wheels, suspension)
## naye developers ke liye 90% cases me "flippy, undriveable" ban jati hai.
## Arcade model turant fun deta hai — aur baad me swap karna easy hai,
## kyunki baaki game sirf set_driver()/release_driver() call karta hai.
##

const ACCEL := 13.0
const MAX_SPEED := 26.0
const MAX_REVERSE := 9.0
const BRAKE_FORCE := 24.0
const ROLL_FRICTION := 5.5
const TURN_RATE := 2.0
const GRAVITY := 20.0

var speed := 0.0
var driver = null
var exit_cooldown := 0.0
var headlights: Array = []
var body_color: Color = Color(0.62, 0.11, 0.12)


func _ready() -> void:
	add_to_group("vehicle")
	collision_layer = 4       # layer 3 = vehicles
	collision_mask = 1        # buildings/ground se takraye
	_build()
	if Game.car == null:
		Game.car = self


func setup_color(color: Color) -> void:
	body_color = color
	_paint()


# ---------------------------------------------------------------------------
# BUILD
# ---------------------------------------------------------------------------

var _body_mesh: MeshInstance3D = null


func _build() -> void:
	var col := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(1.9, 1.3, 4.4)
	col.shape = shape
	col.position = Vector3(0, 0.72, 0)
	add_child(col)

	_body_mesh = MeshInstance3D.new()
	var chassis := BoxMesh.new()
	chassis.size = Vector3(1.9, 0.62, 4.4)
	_body_mesh.mesh = chassis
	_body_mesh.position = Vector3(0, 0.62, 0)
	_body_mesh.material_override = _car_material(body_color)
	add_child(_body_mesh)

	var cabin := MeshInstance3D.new()
	var cabin_mesh := BoxMesh.new()
	cabin_mesh.size = Vector3(1.66, 0.6, 2.1)
	cabin.mesh = cabin_mesh
	cabin.position = Vector3(0, 1.2, -0.15)
	cabin.material_override = _car_material(Color(0.08, 0.09, 0.11))
	add_child(cabin)

	# 4 wheels
	for sx in [-1.0, 1.0]:
		for sz in [-1.0, 1.0]:
			var wheel := MeshInstance3D.new()
			var cyl := CylinderMesh.new()
			cyl.top_radius = 0.36
			cyl.bottom_radius = 0.36
			cyl.height = 0.26
			wheel.mesh = cyl
			wheel.rotation.z = PI * 0.5
			wheel.position = Vector3(sx * 0.86, 0.36, sz * 1.45)
			wheel.material_override = _car_material(Color(0.05, 0.05, 0.05))
			add_child(wheel)

	# headlights
	for sx in [-1.0, 1.0]:
		var light := MeshInstance3D.new()
		var lamp := BoxMesh.new()
		lamp.size = Vector3(0.42, 0.18, 0.1)
		light.mesh = lamp
		light.position = Vector3(sx * 0.6, 0.72, -2.22)
		var lamp_mat := StandardMaterial3D.new()
		lamp_mat.albedo_color = Color(1.0, 0.95, 0.8)
		lamp_mat.emission_enabled = true
		lamp_mat.emission = Color(1.0, 0.92, 0.75)
		lamp_mat.emission_energy_multiplier = 2.0
		light.material_override = lamp_mat
		add_child(light)
		headlights.append(light)

	# brake/tail lights
	for sx in [-1.0, 1.0]:
		var tail := MeshInstance3D.new()
		var lamp2 := BoxMesh.new()
		lamp2.size = Vector3(0.4, 0.16, 0.1)
		tail.mesh = lamp2
		tail.position = Vector3(sx * 0.6, 0.72, 2.22)
		tail.material_override = _car_material(Color(0.45, 0.05, 0.05))
		add_child(tail)


func _car_material(color: Color) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = 0.35
	mat.metallic = 0.4
	return mat


func _paint() -> void:
	if _body_mesh != null:
		_body_mesh.material_override = _car_material(body_color)


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

	if driver == null:
		speed = move_toward(speed, 0.0, ROLL_FRICTION * delta)
		_apply_forward_velocity()
		move_and_slide()
		return

	var throttle := Input.get_action_strength("move_forward") - Input.get_action_strength("move_back")
	var steer := Input.get_action_strength("move_right") - Input.get_action_strength("move_left")

	if throttle > 0.05:
		speed = move_toward(speed, MAX_SPEED, ACCEL * delta)
	elif throttle < -0.05:
		if speed > 0.2:
			speed = move_toward(speed, 0.0, BRAKE_FORCE * delta)   # brake
		else:
			speed = move_toward(speed, -MAX_REVERSE, ACCEL * delta)  # reverse
	else:
		speed = move_toward(speed, 0.0, ROLL_FRICTION * delta)

	# Steering: speed ke hisaab se hi ghumo (khadi gaadi ghum nahi sakti)
	if abs(speed) > 0.4:
		var grip: float = clamp(abs(speed) / 8.0, 0.15, 1.0)
		rotation.y -= steer * TURN_RATE * grip * delta * sign(speed)

	_apply_forward_velocity()
	move_and_slide()

	# Reckless driving = police attention (crime/consequence system ka hint)
	if abs(speed) > 18.0:
		Game.add_heat(2.0 * delta)


func _apply_forward_velocity() -> void:
	var forward := -global_transform.basis.z
	velocity.x = forward.x * speed
	velocity.z = forward.z * speed


func _process(delta: float) -> void:
	# Raat me headlights on
	var night := Game.hour < 7.0 or Game.hour > 19.0
	for light in headlights:
		light.visible = night

	exit_cooldown = max(0.0, exit_cooldown - delta)

	if driver == null:
		return

	if exit_cooldown <= 0.0 and Input.is_action_just_pressed("enter_vehicle"):
		release_driver()
	elif Input.is_action_just_pressed("horn"):
		Game.say("HONK! HONK!")


# ---------------------------------------------------------------------------
# DRIVER HOOKS
# ---------------------------------------------------------------------------

func set_driver(player) -> void:
	if driver != null:
		return
	driver = player
	exit_cooldown = 0.35   # warna usi frame me F dobara lag kar gaadi se utar jayega
	player.enter_vehicle(self)
	Game.say("Gaadi start — WASD chalao, F se utro")


func release_driver() -> void:
	if driver == null:
		return
	var player = driver
	driver = null
	speed = 0.0
	velocity = Vector3.ZERO

	# Driver side me (gaadi ke left) utaro
	var exit_pos: Vector3 = global_position + global_transform.basis.x * -2.3 + Vector3(0, 0.6, 0)
	player.exit_vehicle(exit_pos)
