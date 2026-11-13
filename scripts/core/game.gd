extends Node
##
## FALLEN STATE — Global Game State (Autoload: "Game")
##
## Yeh node poore game me har jagah available hota hai (Game.money, Game.hour, ...).
## Yahan rakha hai: paisa, time, police heat, story flags, save/load, input keys.
##
## Rule: gameplay logic alag scripts me rakho, yahan sirf "shared duniya ki state".
##

signal toast_requested(text: String)
signal money_changed(amount: int)
signal hour_changed(hour: float)
signal heat_changed(value: float)

const SAVE_PATH := "user://fallen_state_save.json"

# ---- Duniya ki state -------------------------------------------------------
var money: int = 500
var hour: float = 8.0          # 0.0 - 24.0 (game clock)
var day: int = 1
var heat: float = 0.0          # 0-100 police attention (crime karoge to badhega)
var flags: Dictionary = {}     # story/consequence flags, e.g. flags["has_intel"]
var objective: String = ""     # HUD ke neeche dikhne wala current mission text

# ---- Runtime references (main.gd inhe set karta hai) -----------------------
var player = null
var car = null

# Jab koi UI khula ho (shop, pause) to player/car input band ho jaye
var ui_open: bool = false


func _ready() -> void:
	randomize()
	_setup_input_map()
	print("[Game] FALLEN STATE booted — world state ready")


# ---------------------------------------------------------------------------
# MESSAGES
# ---------------------------------------------------------------------------

## Screen par chhota message dikhao (HUD isse sunta hai).
func say(text: String) -> void:
	print("[Game] ", text)
	toast_requested.emit(text)


# ---------------------------------------------------------------------------
# MONEY / HEAT
# ---------------------------------------------------------------------------

func add_money(amount: int) -> void:
	money = max(0, money + amount)
	money_changed.emit(money)


## Paisa kharch karo. Agar paisa kam hai to false return.
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
# SAVE / LOAD  (F5 = save, F9 = load)
# ---------------------------------------------------------------------------

func save_game() -> void:
	var data: Dictionary = {
		"version": 1,
		"money": money,
		"hour": hour,
		"day": day,
		"heat": heat,
		"flags": flags,
	}
	if player != null:
		data["player_pos"] = _vec_to_array(player.global_position)
	if car != null:
		data["car_pos"] = _vec_to_array(car.global_position)
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
		var pp: Array = data["player_pos"]
		if pp.size() == 3:
			player.global_position = Vector3(float(pp[0]), float(pp[1]) + 0.3, float(pp[2]))
			player.set("velocity", Vector3.ZERO)
	if car != null and data.has("car_pos"):
		var cp: Array = data["car_pos"]
		if cp.size() == 3:
			car.global_position = Vector3(float(cp[0]), float(cp[1]), float(cp[2]))
			car.rotation.y = float(data.get("car_rot", 0.0))

	hour_changed.emit(hour)
	money_changed.emit(money)
	heat_changed.emit(heat)
	say("Game loaded — welcome back")


func _vec_to_array(v: Vector3) -> Array:
	return [v.x, v.y, v.z]


# ---------------------------------------------------------------------------
# INPUT  (project.godot me input map nahi likha — yahan code se banti hai,
#         isse har Godot version par kaam karega)
# ---------------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()
	elif event.is_action_pressed("load_game"):
		load_game()


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


func _bind(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for key in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = key
		if not InputMap.action_has_event(action, ev):
			InputMap.action_add_event(action, ev)
