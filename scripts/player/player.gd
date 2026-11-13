extends CharacterBody3D
##
## PLAYER — third-person controller + gaadi me baithna/utarna
##
## Controls:
##   WASD  = chalna,  Shift = daudna,  Space = jump
##   Mouse = camera,  Esc = mouse free
##   E     = interact (dukaan counter, random events)
##   F     = gaadi me baitho / gaadi se utro
##
## Learning note: character ke liye CharacterBody3D best hai — isme
## move_and_slide() gravity, slope aur collision sambhal leta hai.
##

const WALK_SPEED := 5.2
const RUN_SPEED := 8.6
const JUMP_VELOCITY := 7.0
const GRAVITY := 20.0
const MOUSE_SENSITIVITY := 0.0022
const INTERACT_RANGE := 3.2
const VEHICLE_RANGE := 4.5

var yaw := 0.0
var pitch := -0.10
var driving := false
var current_car = null
var camera_pivot: Node3D
var spring: SpringArm3D
var camera: Camera3D
var body_root: Node3D


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2      # layer 2 = player
	collision_mask = 1       # sirf duniya (buildings/ground) se takraye
	_build_visuals()
	_build_camera()
	Game.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# ---------------------------------------------------------------------------
# BUILD (scene ko code se banana — designer baad me .tscn me badal sakta hai)
# ---------------------------------------------------------------------------

func _build_visuals() -> void:
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.32
	capsule.height = 1.7
	col.shape = capsule
	col.position = Vector3(0, 0.85, 0)
	add_child(col)

	body_root = Node3D.new()
	add_child(body_root)

	var body := MeshInstance3D.new()
	var body_mesh := CapsuleMesh.new()
	body_mesh.radius = 0.32
	body_mesh.height = 1.7
	body.mesh = body_mesh
	body.position = Vector3(0, 0.85, 0)
	body.material_override = _make_material(Color(0.13, 0.15, 0.2), 0.85)
	body_root.add_child(body)

	# kandhe/head ka hint — isse third person me direction samajh aati hai
	var head := MeshInstance3D.new()
	var sphere := SphereMesh.new()
	sphere.radius = 0.21
	sphere.height = 0.42
	head.mesh = sphere
	head.position = Vector3(0, 1.62, 0)
	head.material_override = _make_material(Color(0.72, 0.58, 0.48), 0.6)
	body_root.add_child(head)

	var backpack := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.34, 0.42, 0.18)
	backpack.mesh = box
	backpack.position = Vector3(0, 1.15, 0.26)
	backpack.material_override = _make_material(Color(0.2, 0.18, 0.16), 0.9)
	body_root.add_child(backpack)


func _build_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0, 1.5, 0)
	add_child(camera_pivot)

	spring = SpringArm3D.new()
	spring.spring_length = 4.2
	spring.margin = 0.3
	spring.collision_mask = 1     # deewar ke andar camera na jaye
	camera_pivot.add_child(spring)

	camera = Camera3D.new()
	camera.fov = 72.0
	camera.current = true
	spring.add_child(camera)


func _make_material(color: Color, roughness: float) -> StandardMaterial3D:
	var mat := StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	return mat


# ---------------------------------------------------------------------------
# INPUT
# ---------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Game.ui_open:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if driving:
			return
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch = clamp(pitch - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-70.0), deg_to_rad(40.0))
		_apply_camera_rotation()
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _apply_camera_rotation() -> void:
	camera_pivot.rotation.y = yaw
	camera_pivot.rotation.x = pitch


# ---------------------------------------------------------------------------
# MOVEMENT
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if Game.ui_open or driving:
		return

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

	# Input.get_vector: left/right aur forward/back ko -1..1 me badal deta hai
	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")

	# Camera ke hisaab se chalna (yaw ghumne par direction bhi ghumni chahiye)
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var dir := right * input.x + forward * -input.y
	if dir.length() > 1.0:
		dir = dir.normalized()

	var speed := RUN_SPEED if Input.is_key_pressed(KEY_SHIFT) else WALK_SPEED
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	move_and_slide()

	# Sharir ko chalne ki direction me ghumao
	if dir.length() > 0.1:
		# model -Z ki taraf face karta hai (Godot convention)
		var target_yaw := atan2(-dir.x, -dir.z)
		body_root.rotation.y = lerp_angle(body_root.rotation.y, target_yaw, 12.0 * delta)


func _process(delta: float) -> void:
	if driving and current_car != null:
		# Gaadi me hain: camera gaadi ko follow kare
		global_position = current_car.global_position + Vector3(0, 1.1, 0)
		yaw = lerp_angle(yaw, current_car.rotation.y, 8.0 * delta)
		_apply_camera_rotation()
		return

	_apply_camera_rotation()

	if not Game.ui_open:
		if Input.is_action_just_pressed("interact"):
			_try_interact()
		if Input.is_action_just_pressed("enter_vehicle"):
			_try_enter_vehicle()


# ---------------------------------------------------------------------------
# INTERACTION
# ---------------------------------------------------------------------------

func _try_interact() -> void:
	var target = _nearest_interactable()
	if target != null and target.has_method("interact"):
		target.interact(self)


func _try_enter_vehicle() -> void:
	var car = _nearest_vehicle()
	if car != null and car.has_method("set_driver"):
		car.set_driver(self)


func _nearest_interactable():
	var best = null
	var best_dist := INTERACT_RANGE
	for node in get_tree().get_nodes_in_group("interactable"):
		if node is Node3D:
			var d: float = global_position.distance_to(node.global_position)
			if d < best_dist:
				best_dist = d
				best = node
	return best


func _nearest_vehicle():
	var best = null
	var best_dist := VEHICLE_RANGE
	for node in get_tree().get_nodes_in_group("vehicle"):
		if node is Node3D:
			var d: float = global_position.distance_to(node.global_position)
			if d < best_dist:
				best_dist = d
				best = node
	return best


## HUD isse har frame poochta hai: "kya likhna hai screen par?"
func get_prompt() -> String:
	if driving:
		return "F — gaadi se utro"
	if Game.ui_open:
		return ""
	var car = _nearest_vehicle()
	if car != null:
		return "F — gaadi me baitho"
	var target = _nearest_interactable()
	if target != null:
		if target.has_method("get_prompt_text"):
			return "E — " + str(target.get_prompt_text())
		return "E — use karo"
	return ""


# ---------------------------------------------------------------------------
# VEHICLE HOOKS (car.gd inhe call karta hai)
# ---------------------------------------------------------------------------

func enter_vehicle(car) -> void:
	driving = true
	current_car = car
	body_root.visible = false
	velocity = Vector3.ZERO


func exit_vehicle(at_position: Vector3) -> void:
	driving = false
	current_car = null
	body_root.visible = true
	global_position = at_position
	velocity = Vector3.ZERO
