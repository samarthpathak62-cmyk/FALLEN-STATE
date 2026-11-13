extends CharacterBody3D
##
## PLAYER — third person, rigged character + real animations
##
## WASD chalna · Shift daudna · Space jump · E interact · F gaadi · Esc mouse free
##
## Character model: Quaternius Universal Base Character (14k tris, 65 bones)
## Animations: Idle_Loop / Jog_Fwd_Loop / Sprint_Loop / Jump_* / Driving_Loop
##

const WALK_SPEED := 2.3
const JOG_SPEED := 4.9
const SPRINT_SPEED := 7.8
const ACCEL := 26.0
const JUMP_VELOCITY := 5.4
const GRAVITY := 18.0
const MOUSE_SENSITIVITY := 0.0022
const INTERACT_RANGE := 3.2
const VEHICLE_RANGE := 3.8

## Agar character aage ki jagah peeche chalta dikhe to isko 180.0 kar do
const MODEL_FACING_OFFSET := 0.0

var yaw := 0.0
var pitch := -0.12
var driving := false
var current_car = null
var model_root: Node3D
var anim: AnimationPlayer
var camera_pivot: Node3D
var spring: SpringArm3D
var camera: Camera3D
var speed := 0.0
var _step_timer := 0.0


func _ready() -> void:
	add_to_group("player")
	collision_layer = 2
	collision_mask = 1
	_build_collision()
	_build_model()
	_build_camera()
	Game.player = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Kits.play_anim(anim, "idle", 0.0)


# ---------------------------------------------------------------------------
# BUILD
# ---------------------------------------------------------------------------

func _build_collision() -> void:
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.34
	cap.height = 1.75
	cs.shape = cap
	cs.position = Vector3(0.0, 0.875, 0.0)
	add_child(cs)


func _build_model() -> void:
	model_root = Node3D.new()
	add_child(model_root)

	var body := Kits.spawn_character(model_root, true)
	if body == null:
		return
	anim = Kits.find_animation_player(body)
	if anim != null:
		print("[Player] animations: %d clips mil gaye" % anim.get_animation_list().size())


func _build_camera() -> void:
	camera_pivot = Node3D.new()
	camera_pivot.position = Vector3(0.0, 1.62, 0.0)
	add_child(camera_pivot)

	spring = SpringArm3D.new()
	spring.spring_length = 4.4
	spring.margin = 0.35
	spring.collision_mask = 1
	camera_pivot.add_child(spring)

	camera = Camera3D.new()
	camera.fov = 68.0
	camera.far = 400.0
	camera.current = true
	spring.add_child(camera)


# ---------------------------------------------------------------------------
# INPUT
# ---------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse") and not Game.ui_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if Game.ui_open:
		return

	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if driving:
			return
		yaw -= event.relative.x * MOUSE_SENSITIVITY
		pitch = clamp(pitch - event.relative.y * MOUSE_SENSITIVITY, deg_to_rad(-65.0), deg_to_rad(35.0))
	elif event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


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
		Sound.play_3d(Sound.JUMP_PATH, global_position, -14.0)

	var input := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := Vector3(-sin(yaw), 0.0, -cos(yaw))
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var dir := right * input.x + forward * -input.y
	if dir.length() > 1.0:
		dir = dir.normalized()

	var target_speed := 0.0
	if dir.length() > 0.1:
		if Input.is_key_pressed(KEY_ALT):
			target_speed = WALK_SPEED        # Alt = dheere chalo (city dekhne ke liye)
		elif Input.is_key_pressed(KEY_SHIFT):
			target_speed = SPRINT_SPEED
		else:
			target_speed = JOG_SPEED

	var target_vel := dir * target_speed
	velocity.x = move_toward(velocity.x, target_vel.x, ACCEL * delta)
	velocity.z = move_toward(velocity.z, target_vel.z, ACCEL * delta)

	move_and_slide()
	speed = Vector2(velocity.x, velocity.z).length()

	if dir.length() > 0.1:
		var want_yaw := atan2(dir.x, dir.z) + deg_to_rad(MODEL_FACING_OFFSET)
		model_root.rotation.y = lerp_angle(model_root.rotation.y, want_yaw, 10.0 * delta)

	_update_animation(delta)


func _update_animation(delta: float) -> void:
	if anim == null:
		return

	if not is_on_floor():
		if velocity.y > 0.5:
			Kits.play_anim(anim, "jump_start", 0.12)
		else:
			Kits.play_anim(anim, "jump_loop", 0.15)
	elif speed < 0.35:
		Kits.play_anim(anim, "idle", 0.25)
	elif speed < (JOG_SPEED + SPRINT_SPEED) * 0.62:
		Kits.play_anim(anim, "jog", 0.2)
		anim.speed_scale = clamp(speed / JOG_SPEED, 0.8, 1.3)
	else:
		Kits.play_anim(anim, "sprint", 0.2)
		anim.speed_scale = clamp(speed / SPRINT_SPEED, 0.85, 1.2)

	# Kadam ki awaaz
	if is_on_floor() and speed > 0.6:
		_step_timer -= delta * (0.8 + speed * 0.35)
		if _step_timer <= 0.0:
			_step_timer = 1.0
			Sound.play_3d(Sound.FOOT_PATH, global_position, -18.0, randf_range(0.95, 1.12))


func _process(delta: float) -> void:
	if driving and current_car != null:
		global_position = current_car.global_position + Vector3(0.0, 1.15, 0.0)
		yaw = lerp_angle(yaw, current_car.rotation.y, 6.0 * delta)
		camera_pivot.rotation.y = yaw
		camera_pivot.rotation.x = pitch
		return

	camera_pivot.rotation.y = yaw
	camera_pivot.rotation.x = pitch

	if Game.ui_open:
		return
	if Input.is_action_just_pressed("interact"):
		_try_interact()
	if Input.is_action_just_pressed("enter_vehicle"):
		_try_enter_vehicle()


# ---------------------------------------------------------------------------
# INTERACTION
# ---------------------------------------------------------------------------

func _try_interact() -> void:
	var target = _nearest_in_group("interactable", INTERACT_RANGE)
	if target != null and target.has_method("interact"):
		target.interact(self)


func _try_enter_vehicle() -> void:
	var car = _nearest_in_group("vehicle", VEHICLE_RANGE)
	if car != null and car.has_method("set_driver"):
		car.set_driver(self)


func _nearest_in_group(group: String, max_dist: float):
	var best = null
	var best_d := max_dist
	for node in get_tree().get_nodes_in_group(group):
		if node is Node3D:
			var d: float = global_position.distance_to(node.global_position)
			if d < best_d:
				best_d = d
				best = node
	return best


func get_prompt() -> String:
	if driving:
		return "F — gaadi se utro"
	if Game.ui_open:
		return ""
	var car = _nearest_in_group("vehicle", VEHICLE_RANGE)
	if car != null:
		return "F — gaadi me baitho"
	var target = _nearest_in_group("interactable", INTERACT_RANGE)
	if target != null:
		if target.has_method("get_prompt_text"):
			return "E — " + str(target.get_prompt_text())
		return "E — use karo"
	return ""


# ---------------------------------------------------------------------------
# VEHICLE HOOKS
# ---------------------------------------------------------------------------

func enter_vehicle(car) -> void:
	driving = true
	current_car = car
	if model_root != null:
		model_root.visible = false
	velocity = Vector3.ZERO


func exit_vehicle(at_position: Vector3) -> void:
	driving = false
	current_car = null
	if model_root != null:
		model_root.visible = true
	global_position = at_position
	velocity = Vector3.ZERO
