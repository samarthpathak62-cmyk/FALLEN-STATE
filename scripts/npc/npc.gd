extends CharacterBody3D
##
## NPC — "living city" ka sabse chhota atom
##
## Abhi yeh simple state machine hai:
##   IDLE -> random point chuno -> WALK -> pahuncho -> IDLE ...
##   + din ke time ke hisaab se speed/radius badalta hai (routine layer)
##   + tez gaadi dekh kar bhaag jate hain (danger reaction)
##
## Aage (roadmap M4): in nodes ko NavigationAgent3D do, schedule data (JSON) do,
## aur player se door wale NPCs ko "statistical mode" me daal do.
##

const WALK_SPEED := 1.6
const RUSH_SPEED := 2.6
const FLEE_SPEED := 4.8
const GRAVITY := 20.0

var state := "idle"           # idle | walk | flee
var home: Vector3 = Vector3.ZERO
var target: Vector3 = Vector3.ZERO
var timer := 0.0
var flee_timer := 0.0
var move_speed := WALK_SPEED
var body_color: Color = Color(0.55, 0.57, 0.62)
var body_root: Node3D


func _ready() -> void:
	add_to_group("npc")
	collision_layer = 8
	collision_mask = 1
	_build()
	timer = randf_range(0.0, 2.0)


func setup(_index: int) -> void:
	home = global_position
	target = home
	body_color = _random_cloth_color()
	_repaint()
	timer = randf_range(0.0, 3.0)
	# thoda random offset taaki sab ek line me na chalein
	global_position += Vector3(randf_range(-1.5, 1.5), 0, randf_range(-1.5, 1.5))
	home = global_position


# ---------------------------------------------------------------------------
# VISUALS
# ---------------------------------------------------------------------------

var _body_mesh: MeshInstance3D = null
var _head_mesh: MeshInstance3D = null


func _build() -> void:
	var col := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.6
	col.shape = capsule
	col.position = Vector3(0, 0.8, 0)
	add_child(col)

	body_root = Node3D.new()
	add_child(body_root)

	_body_mesh = MeshInstance3D.new()
	var body := CapsuleMesh.new()
	body.radius = 0.3
	body.height = 1.6
	_body_mesh.mesh = body
	_body_mesh.position = Vector3(0, 0.8, 0)
	_body_mesh.material_override = _mat(body_color)
	body_root.add_child(_body_mesh)

	_head_mesh = MeshInstance3D.new()
	var head := SphereMesh.new()
	head.radius = 0.2
	head.height = 0.4
	_head_mesh.mesh = head
	_head_mesh.position = Vector3(0, 1.52, 0)
	_head_mesh.material_override = _mat(Color(0.72, 0.58, 0.48))
	body_root.add_child(_head_mesh)


func _mat(color: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.85
	return m


func _repaint() -> void:
	if _body_mesh != null:
		_body_mesh.material_override = _mat(body_color)


func _random_cloth_color() -> Color:
	var palette: Array = [
		Color(0.18, 0.2, 0.26), Color(0.32, 0.26, 0.2), Color(0.45, 0.18, 0.16),
		Color(0.15, 0.3, 0.28), Color(0.55, 0.5, 0.42), Color(0.25, 0.25, 0.3),
	]
	return palette[randi() % palette.size()]


# ---------------------------------------------------------------------------
# DAILY ROUTINE (time-based behaviour)
# ---------------------------------------------------------------------------

func _routine_speed() -> float:
	var h := Game.hour
	if h >= 7.0 and h <= 10.0:
		return RUSH_SPEED           # subah ka commute
	if h >= 17.0 and h <= 20.0:
		return RUSH_SPEED           # shaam ko ghar wapas
	if h >= 0.0 and h < 5.0:
		return RUSH_SPEED * 1.2     # raat me log jaldi chalte hain
	return WALK_SPEED


func _routine_radius() -> float:
	var h := Game.hour
	if h >= 0.0 and h < 6.0:
		return 8.0                  # raat: ghar ke paas
	if h >= 21.0 or h < 1.0:
		return 30.0                 # nightlife
	return 22.0


# ---------------------------------------------------------------------------
# BEHAVIOUR
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	timer -= delta
	flee_timer -= delta

	if flee_timer > 0.0:
		# Darr gaya — bhaagta hai
		state = "flee"
		_walk_to(target, FLEE_SPEED, delta)
	else:
		_check_danger()
		if flee_timer <= 0.0:
			move_speed = _routine_speed()
			if timer <= 0.0 or global_position.distance_to(target) < 0.8:
				_pick_target()
			if state == "walk":
				_walk_to(target, move_speed, delta)
			else:
				velocity.x = 0.0
				velocity.z = 0.0

	move_and_slide()

	# Deewar se takra gaye? Naya target lo (simple unstick)
	if state == "walk" and get_slide_collision_count() > 0:
		_pick_target()


func _walk_to(point: Vector3, speed: float, delta: float) -> void:
	var to_target := point - global_position
	to_target.y = 0.0
	if to_target.length() < 0.4:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var dir := to_target.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	# model -Z ki taraf face karta hai (Godot convention)
	var target_yaw := atan2(-dir.x, -dir.z)
	body_root.rotation.y = lerp_angle(body_root.rotation.y, target_yaw, 8.0 * delta)


func _pick_target() -> void:
	state = "walk"
	var radius := _routine_radius()
	target = home + Vector3(randf_range(-radius, radius), 0.0, randf_range(-radius, radius))
	timer = randf_range(4.0, 12.0)


func _check_danger() -> void:
	for car in get_tree().get_nodes_in_group("vehicle"):
		if not (car is Node3D):
			continue
		if global_position.distance_to(car.global_position) > 8.0:
			continue
		var car_speed = car.get("speed")
		if car_speed is float and abs(car_speed) > 8.0:
			_flee_from(car.global_position)


func _flee_from(danger: Vector3) -> void:
	state = "flee"
	flee_timer = 2.5
	var away := global_position - danger
	away.y = 0.0
	if away.length() < 0.1:
		away = Vector3(1, 0, 0)
	target = global_position + away.normalized() * 12.0
	_walk_to(target, FLEE_SPEED, 0.016)
