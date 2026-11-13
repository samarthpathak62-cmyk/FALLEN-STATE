extends CharacterBody3D
##
## NPC — living city ka atom
##
## Abhi: routine (time-based) + danger reaction + distance LOD.
## Aage (M4): NavigationAgent3D + schedule JSON + "statistical mode" (player se dur).
##
## LOD: 58m se dur NPC ka model chhup jata hai — skinning (sabse mehanga hissa)
## band ho jata hai. Isi trick se 100 NPC bhi integrated GPU par chal jate hain.
##

const WALK_SPEED := 1.5
const RUSH_SPEED := 2.6
const FLEE_SPEED := 4.6
const GRAVITY := 18.0
const MODEL_FACING_OFFSET := 0.0
const HIDE_DISTANCE := 58.0

var home: Vector3 = Vector3.ZERO
var target: Vector3 = Vector3.ZERO
var state := "walk"
var timer := 0.0
var flee_timer := 0.0
var move_speed := WALK_SPEED
var model_root: Node3D
var anim: AnimationPlayer
var is_male := true


func _ready() -> void:
	add_to_group("npc")
	collision_layer = 8
	collision_mask = 1

	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.32
	cap.height = 1.7
	cs.shape = cap
	cs.position = Vector3(0.0, 0.85, 0.0)
	add_child(cs)

	timer = randf_range(0.5, 3.0)


## main.gd add_child ke baad isko call karta hai (gender + identity yahan set hoti hai)
func setup(_index: int, male: bool) -> void:
	is_male = male
	global_position += Vector3(randf_range(-2.0, 2.0), 0.0, randf_range(-2.0, 2.0))
	home = global_position
	target = home
	_spawn_model()
	timer = randf_range(0.0, 3.0)


func _spawn_model() -> void:
	model_root = Node3D.new()
	add_child(model_root)
	var body := Kits.spawn_character(model_root, is_male)
	if body == null:
		return
	anim = Kits.find_animation_player(body)
	if anim != null:
		Kits.play_anim(anim, "idle", 0.0)
		# har NPC ka animation phase alag — sab robot jaise sync na chalein
		anim.seek(randf_range(0.0, 1.4), true)


# ---------------------------------------------------------------------------
# ROUTINE (time of day -> speed + area)
# ---------------------------------------------------------------------------

func _routine_speed() -> float:
	var h := Game.hour
	if h >= 7.0 and h <= 10.0:
		return RUSH_SPEED            # subah commute
	if h >= 16.5 and h <= 20.0:
		return RUSH_SPEED            # shaam ghar wapas
	if h >= 0.0 and h < 5.0:
		return RUSH_SPEED * 1.1
	return WALK_SPEED


func _routine_radius() -> float:
	var h := Game.hour
	if h >= 0.0 and h < 6.0:
		return 8.0                   # raat: ghar ke paas
	if h >= 20.0 or h < 1.0:
		return 26.0                  # nightlife
	return 18.0


# ---------------------------------------------------------------------------
# BEHAVIOUR
# ---------------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_update_lod()

	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	timer -= delta
	flee_timer -= delta

	if flee_timer > 0.0:
		state = "flee"
		_walk_to(target, FLEE_SPEED, delta)
	else:
		_check_danger()
		if flee_timer <= 0.0:
			move_speed = _routine_speed()
			if timer <= 0.0 or global_position.distance_to(target) < 0.9:
				_pick_target()
			if state == "walk":
				_walk_to(target, move_speed, delta)
			else:
				velocity.x = 0.0
				velocity.z = 0.0

	move_and_slide()

	if state == "walk" and get_slide_collision_count() > 0:
		_pick_target()

	_update_anim()


func _update_lod() -> void:
	var player = Game.player
	if player == null or not is_instance_valid(player) or model_root == null:
		return
	var d: float = global_position.distance_to(player.global_position)
	var should_show := d <= HIDE_DISTANCE
	if model_root.visible != should_show:
		model_root.visible = should_show


func _walk_to(point: Vector3, spd: float, delta: float) -> void:
	var to_target := point - global_position
	to_target.y = 0.0
	if to_target.length() < 0.45:
		velocity.x = 0.0
		velocity.z = 0.0
		return
	var dir := to_target.normalized()
	velocity.x = dir.x * spd
	velocity.z = dir.z * spd
	var want_yaw := atan2(dir.x, dir.z) + deg_to_rad(MODEL_FACING_OFFSET)
	if model_root != null:
		model_root.rotation.y = lerp_angle(model_root.rotation.y, want_yaw, 7.0 * delta)


func _pick_target() -> void:
	state = "walk"
	var radius := _routine_radius()
	target = home + Vector3(randf_range(-radius, radius), 0.0, randf_range(-radius, radius))
	timer = randf_range(4.0, 11.0)


func _check_danger() -> void:
	for car in get_tree().get_nodes_in_group("vehicle"):
		if not (car is Node3D):
			continue
		if global_position.distance_to(car.global_position) > 7.0:
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
		away = Vector3(1.0, 0.0, 0.0)
	target = global_position + away.normalized() * 11.0


func _update_anim() -> void:
	if anim == null:
		return
	var planar := Vector2(velocity.x, velocity.z).length()
	if flee_timer > 0.0:
		Kits.play_anim(anim, "sprint", 0.25)
		anim.speed_scale = 0.9
	elif planar < 0.2:
		Kits.play_anim(anim, "idle", 0.3)
		anim.speed_scale = 1.0
	elif planar < 2.0:
		Kits.play_anim(anim, "jog", 0.3)
		anim.speed_scale = clamp(planar / 2.6, 0.55, 1.0)
	else:
		Kits.play_anim(anim, "jog", 0.3)
		anim.speed_scale = clamp(planar / 4.0, 0.9, 1.3)
