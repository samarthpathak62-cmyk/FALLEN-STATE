extends Node3D
##
## SHOP COUNTER — "enterable building" ka proof
##
## Player paas aake E dabata hai -> chhoti shop UI khulti hai -> paisa
## kharch hota hai -> story flag set hota hai (mission 3 isi par depend karti hai).
##
## Yeh pattern hi aage poora economy chalayega: har dukaan ek "interactable"
## node + apna UI + apna data. Naya shop = naya script, koi core change nahi.
##

var panel: PanelContainer
var is_open := false


func _ready() -> void:
	add_to_group("interactable")
	_build_ui()


func get_prompt_text() -> String:
	return "Corner Store kholo"


func interact(_player) -> void:
	if is_open:
		close_shop()
	else:
		open_shop()


# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)

	panel = PanelContainer.new()
	panel.position = Vector2(430, 170)
	panel.custom_minimum_size = Vector2(420, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.visible = false
	layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 20)
	margin.add_theme_constant_override("margin_right", 20)
	margin.add_theme_constant_override("margin_top", 16)
	margin.add_theme_constant_override("margin_bottom", 16)
	panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "CORNER STORE — 24/7"
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.4))
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "Chhoti dukaan, badi duniya."
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.75, 0.78, 0.85))
	vb.add_child(sub)

	vb.add_child(_button("Intel kharido  —  $200", _buy_intel))
	vb.add_child(_button("Coffee  —  $5", _buy_coffee))
	vb.add_child(_button("Band karo  (Esc)", close_shop))


func _button(text: String, callback: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(380, 40)
	b.pressed.connect(callback)
	return b


# ---------------------------------------------------------------------------
# OPEN / CLOSE
# ---------------------------------------------------------------------------

func open_shop() -> void:
	is_open = true
	panel.visible = true
	Game.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func close_shop() -> void:
	is_open = false
	panel.visible = false
	Game.ui_open = false
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("release_mouse") or event.is_action_pressed("interact"):
		close_shop()
		get_viewport().set_input_as_handled()


# ---------------------------------------------------------------------------
# PURCHASES
# ---------------------------------------------------------------------------

func _buy_intel() -> void:
	if Game.flags.get("has_intel", false) == true:
		Game.say("Intel already tumhare paas hai.")
		return
	if Game.spend(200):
		Game.flags["has_intel"] = true
		Game.say("Intel mila: docks par shipment raat 12 baje aayegi.")
		close_shop()
	else:
		Game.say("$200 chahiye — tumhare paas $%d hai." % Game.money)


func _buy_coffee() -> void:
	if Game.spend(5):
		Game.say("Coffee li. Aankhein khul gayi. (-$5)")
	else:
		Game.say("$5 bhi nahi hai bhai.")
