extends Node3D
##
## CORNER STORE (street kiosk) — interaction + shop UI
##
## Interiors abhi nahi hain (kit me interiors nahi hote) — isliye dukaan
## street-side counter hai. M5 me asli interior scene aayega; tab sirf yeh
## node interior ke andar shift hoga, baaki code same rahega.
##

var panel: PanelContainer
var is_open := false


func _ready() -> void:
	add_to_group("interactable")
	_build_visual()
	_build_ui()


func get_prompt_text() -> String:
	return "Corner Store kholo"


func interact(_player) -> void:
	if is_open:
		close_shop()
	else:
		open_shop()


# ---------------------------------------------------------------------------
# VISUAL
# ---------------------------------------------------------------------------

func _build_visual() -> void:
	var counter := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(2.6, 1.05, 0.8)
	counter.mesh = box
	counter.position.y = 0.52
	var counter_mat := StandardMaterial3D.new()
	counter_mat.albedo_color = Color(0.24, 0.19, 0.15)
	counter_mat.roughness = 0.8
	counter.material_override = counter_mat
	add_child(counter)

	# Awning (chhota shade) — dukaan jaisi dikhe
	var awning := MeshInstance3D.new()
	var abox := BoxMesh.new()
	abox.size = Vector3(3.0, 0.12, 1.6)
	awning.mesh = abox
	awning.position = Vector3(0.0, 2.6, -0.2)
	awning.rotation_degrees.x = -12.0
	var aw_mat := StandardMaterial3D.new()
	aw_mat.albedo_color = Color(0.55, 0.12, 0.1)
	aw_mat.roughness = 0.7
	awning.material_override = aw_mat
	add_child(awning)

	for sx in [-1.4, 1.4]:
		var pole := MeshInstance3D.new()
		var pbox := BoxMesh.new()
		pbox.size = Vector3(0.08, 2.6, 0.08)
		pole.mesh = pbox
		pole.position = Vector3(sx, 1.3, -0.6)
		pole.material_override = counter_mat
		add_child(pole)

	var sign_label := Label3D.new()
	sign_label.text = "24/7  CORNER STORE"
	sign_label.font_size = 72
	sign_label.pixel_size = 0.0075
	sign_label.modulate = Color(1.0, 0.85, 0.35)
	sign_label.outline_size = 12
	sign_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sign_label.position = Vector3(0.0, 3.15, 0.0)
	add_child(sign_label)


# ---------------------------------------------------------------------------
# UI
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 4
	add_child(layer)

	panel = PanelContainer.new()
	panel.position = Vector2(420, 170)
	panel.custom_minimum_size = Vector2(440, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.visible = false
	layer.add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 22)
	margin.add_theme_constant_override("margin_right", 22)
	margin.add_theme_constant_override("margin_top", 18)
	margin.add_theme_constant_override("margin_bottom", 18)
	panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "CORNER STORE"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.86, 0.4))
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "Chhoti dukaan. Badi duniya."
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.72, 0.76, 0.82))
	vb.add_child(sub)

	vb.add_child(_btn("Intel kharido  —  $200", _buy_intel))
	vb.add_child(_btn("Coffee  —  $5", _buy_coffee))
	vb.add_child(_btn("Band karo  (Esc)", close_shop))


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(396, 40)
	b.pressed.connect(cb)
	return b


func open_shop() -> void:
	is_open = true
	panel.visible = true
	Game.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Sound.play_ui()


func close_shop() -> void:
	is_open = false
	panel.visible = false
	Game.ui_open = false
	Sound.play_ui()
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _unhandled_input(event: InputEvent) -> void:
	if not is_open:
		return
	if event.is_action_pressed("release_mouse") or event.is_action_pressed("interact"):
		close_shop()
		get_viewport().set_input_as_handled()


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
