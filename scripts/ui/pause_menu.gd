extends CanvasLayer
##
## PAUSE / SETTINGS MENU  (Esc)
##
## Graphics presets yahin se badalte hain — F10 se bhi cycle ho jate hain.
## LOW = bina GPU wale laptop ke liye. HIGH = dedicated GPU.
##

var panel: PanelContainer
var is_open := false
var quality_label: Label


func _ready() -> void:
	layer = 6
	_build()


func _build() -> void:
	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.02, 0.03, 0.05, 0.72)
	bg.mouse_filter = Control.MOUSE_FILTER_STOP
	bg.visible = false
	add_child(bg)
	bg.name = "Dim"

	panel = PanelContainer.new()
	panel.position = Vector2(400, 130)
	panel.custom_minimum_size = Vector2(480, 0)
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.visible = false
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 26)
	margin.add_theme_constant_override("margin_right", 26)
	margin.add_theme_constant_override("margin_top", 22)
	margin.add_theme_constant_override("margin_bottom", 22)
	panel.add_child(margin)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 10)
	margin.add_child(vb)

	var title := Label.new()
	title.text = "FALLEN STATE"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(0.95, 0.35, 0.28))
	vb.add_child(title)

	var sub := Label.new()
	sub.text = "paused — a city that never sleeps"
	sub.add_theme_font_size_override("font_size", 14)
	sub.add_theme_color_override("font_color", Color(0.7, 0.74, 0.8))
	vb.add_child(sub)

	vb.add_child(_spacer(8))

	quality_label = Label.new()
	quality_label.add_theme_font_size_override("font_size", 17)
	quality_label.add_theme_color_override("font_color", Color(0.85, 0.9, 1.0))
	vb.add_child(quality_label)

	var qrow := HBoxContainer.new()
	qrow.add_theme_constant_override("separation", 8)
	qrow.add_child(_btn("LOW", func(): Game.set_quality(0)))
	qrow.add_child(_btn("MEDIUM", func(): Game.set_quality(1)))
	qrow.add_child(_btn("HIGH", func(): Game.set_quality(2)))
	vb.add_child(qrow)

	vb.add_child(_spacer(8))

	var controls := Label.new()
	controls.text = "WASD chalo · Shift daud · Space jump\nE interact · F gaadi · H horn\nF5 save · F9 load · Esc menu"
	controls.add_theme_font_size_override("font_size", 14)
	controls.add_theme_color_override("font_color", Color(0.68, 0.72, 0.78))
	vb.add_child(controls)

	vb.add_child(_spacer(8))
	vb.add_child(_btn("RESUME  (Esc)", close_menu))
	vb.add_child(_btn("QUIT", func(): get_tree().quit()))

	Game.quality_changed.connect(_refresh)


func _spacer(h: int) -> Control:
	var c := Control.new()
	c.custom_minimum_size = Vector2(0, h)
	return c


func _btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(420, 38)
	b.pressed.connect(cb)
	return b


func _refresh(_level: int = 0) -> void:
	if quality_label != null:
		quality_label.text = "Graphics preset:  " + Game.quality_names[Game.quality]


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("release_mouse"):
		if is_open:
			close_menu()
		else:
			open_menu()
		get_viewport().set_input_as_handled()


func open_menu() -> void:
	is_open = true
	panel.visible = true
	get_node("Dim").visible = true
	Game.ui_open = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_refresh()
	Sound.play_ui()


func close_menu() -> void:
	is_open = false
	panel.visible = false
	get_node("Dim").visible = false
	Game.ui_open = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	Sound.play_ui()
