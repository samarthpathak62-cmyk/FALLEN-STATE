extends Node
##
## GAME — global state (autoload "Game")
##
## Yahan sirf "duniya ki yaad-daasht" rehti hai: paisa, time, crime heat,
## story flags, quality settings aur save/load. Gameplay logic alag files me.
##

signal toast_requested(text: String)
signal money_changed(amount: int)
signal hour_changed(hour: float)
signal heat_changed(value: float)
signal quality_changed(level: int)

const SAVE_PATH := "user://fallen_state_save.json"
const SETTINGS_PATH := "user://fallen_state_settings.json"

# --- Duniya ---------------------------------------------------------------
var money: int = 750
var hour: float = 19.5        # shaam se shuru — city sabse alive tab lagti hai
var day: int = 1
var heat: float = 0.0         # 0-100 police attention
var flags: Dictionary = {}
var objective: String = ""

# --- Runtime refs ---------------------------------------------------------
var player = null
var car = null
var ui_open: bool = false

# --- Quality --------------------------------------------------------------
# 0 = Low (integrated GPU / 5 saal purana laptop)
# 1 = Medium (default — GTX 1050 / Iris Xe)
# 2 = High (dedicated GPU)
var quality: int = 1
var quality_names: Array = ["LOW", "MEDIUM", "HIGH"]


func _ready() -> void:
	randomize()
	_setup_input_map()
	load_settings()
	print("[Game] FALLEN STATE booted — quality: %s" % quality_names[quality])


# ---------------------------------------------------------------------------
# MESSAGES
# ---------------------------------------------------------------------------

func say(text: String) -> void:
	print("[Game] ", text)
	toast_requested.emit(text)


# ---------------------------------------------------------------------------
# MONEY / HEAT
# ---------------------------------------------------------------------------

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_changed.emit(money)


func spend(amount: int) -> bool:
	if money < amount:
		return false
	money -= amount
	money_changed.emit(money)
	return true


func add_heat(amount: float) -> void:
	heat = clamp(heat + amount, 0.0, 100.0)
	heat_changed.emit(heat)


# ---------------------------------------------------------------------------
# QUALITY (bina GPU wale laptop ke liye — yahi sabse zaroori setting hai)
# ---------------------------------------------------------------------------

func set_quality(level: int) -> void:
	quality = clamp(level, 0, 2)
	quality_changed.emit(quality)
	save_settings()
	say("Graphics: %s" % quality_names[quality])


func cycle_quality() -> void:
	set_quality((quality + 1) % 3)


func save_settings() -> void:
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify({"quality": quality}, "\t"))
	f.close()


func load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var f := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	f.close()
	if typeof(parsed) == TYPE_DICTIONARY:
		quality = int(parsed.get("quality", quality))
	quality = clamp(quality, 0, 2)


# ---------------------------------------------------------------------------
# SAVE / LOAD  (F5 / F9)
# ---------------------------------------------------------------------------

func save_game() -> void:
	var data: Dictionary = {
		"version": 2,
		"money": money,
		"hour": hour,
		"day": day,
		"heat": heat,
		"flags": flags,
	}
	if player != null:
		data["player_pos"] = _vec(player.global_position)
	if car != null:
		data["car_pos"] = _vec(car.global_position)
		data["car_rot"] = car.rotation.y

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		say("Save fail hua (error %d)" % FileAccess.get_open_error())
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	say("Game saved — F9 se load karo")


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		say("Abhi koi save nahi hai — pehle F5 dabao")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		say("Save file khul nahi rahi")
		return
	var raw := file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(raw)
	if typeof(parsed) != TYPE_DICTIONARY:
		say("Save file corrupt hai")
		return
	var data: Dictionary = parsed

	money = int(data.get("money", money))
	hour = float(data.get("hour", hour))
	day = int(data.get("day", day))
	heat = float(data.get("heat", heat))
	var stored_flags: Variant = data.get("flags", {})
	if typeof(stored_flags) == TYPE_DICTIONARY:
		flags = stored_flags

	if player != null and data.has("player_pos"):
		var p: Array = data["player_pos"]
		if p.size() == 3:
			player.global_position = Vector3(float(p[0]), float(p[1]) + 0.2, float(p[2]))
			player.set("velocity", Vector3.ZERO)
	if car != null and data.has("car_pos"):
		var c: Array = data["car_pos"]
		if c.size() == 3:
			car.global_position = Vector3(float(c[0]), float(c[1]), float(c[2]))
			car.rotation.y = float(data.get("car_rot", 0.0))

	hour_changed.emit(hour)
	money_changed.emit(money)
	heat_changed.emit(heat)
	say("Game loaded — welcome back")


func _vec(v: Vector3) -> Array:
	return [v.x, v.y, v.z]


# ---------------------------------------------------------------------------
# INPUT (project.godot me nahi — code se, taaki version-proof rahe)
# ---------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()
	elif event.is_action_pressed("toggle_quality"):
		cycle_quality()


func _setup_input_map() -> void:
	_bind("move_forward", [KEY_W, KEY_UP])
	_bind("move_back", [KEY_S, KEY_DOWN])
	_bind("move_left", [KEY_A, KEY_LEFT])
	_bind("move_right", [KEY_D, KEY_RIGHT])
	_bind("jump", [KEY_SPACE])
	_bind("interact", [KEY_E])
	_bind("enter_vehicle", [KEY_F])
	_bind("horn", [KEY_H])
	_bind("save_game", [KEY_F5])
	_bind("load_game", [KEY_F9])
	_bind("release_mouse", [KEY_ESCAPE])
	_bind("toggle_quality", [KEY_F10])


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
