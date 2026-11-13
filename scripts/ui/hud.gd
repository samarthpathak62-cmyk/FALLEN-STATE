extends CanvasLayer
##
## HUD — sab kuch code se (koi .tscn nahi, isliye node kabhi missing nahi hota)
##

var root: Control
var clock_label: Label
var money_label: Label
var heat_label: Label
var objective_label: Label
var prompt_label: Label
var hint_label: Label
var speed_label: Label
var toast_box: VBoxContainer


func _ready() -> void:
	layer = 2
	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	clock_label = _label(Vector2(22, 14), Vector2(460, 30), 20, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_LEFT)
	money_label = _label(Vector2(796, 14), Vector2(462, 30), 22, Color(0.6, 0.95, 0.62), HORIZONTAL_ALIGNMENT_RIGHT)
	heat_label = _label(Vector2(796, 46), Vector2(462, 22), 15, Color(1, 0.5, 0.42), HORIZONTAL_ALIGNMENT_RIGHT)
	hint_label = _label(Vector2(22, 46), Vector2(700, 22), 13, Color(0.72, 0.76, 0.84), HORIZONTAL_ALIGNMENT_LEFT)
	hint_label.text = "WASD chalo · Shift daud · Alt dheere · E interact · F gaadi · F5/F9 save · F10 graphics · Esc menu"

	objective_label = _label(Vector2(22, 664), Vector2(960, 30), 18, Color(1.0, 0.85, 0.35), HORIZONTAL_ALIGNMENT_LEFT)
	prompt_label = _label(Vector2(390, 612), Vector2(500, 30), 20, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER)
	speed_label = _label(Vector2(796, 630), Vector2(462, 40), 26, Color(0.9, 0.93, 1.0), HORIZONTAL_ALIGNMENT_RIGHT)

	toast_box = VBoxContainer.new()
	toast_box.position = Vector2(390, 92)
	toast_box.size = Vector2(500, 300)
	toast_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_box.add_theme_constant_override("separation", 6)
	root.add_child(toast_box)

	Game.toast_requested.connect(_on_toast)


func _label(pos: Vector2, size: Vector2, font_size: int, color: Color, align: int) -> Label:
	var l := Label.new()
	l.position = pos
	l.size = size
	l.add_theme_font_size_override("font_size", font_size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_constant_override("outline_size", 6)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.92))
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(l)
	return l


func _process(_delta: float) -> void:
	var h := int(floor(Game.hour)) % 24
	var m := int((Game.hour - floor(Game.hour)) * 60.0)
	clock_label.text = "DAY %d   %02d:%02d   ·   %s" % [Game.day, h, m, Game.quality_names[Game.quality]]
	money_label.text = "$%d" % Game.money

	var heat := int(Game.heat)
	heat_label.text = "POLICE HEAT %d%%" % heat
	heat_label.add_theme_color_override("font_color",
		Color(0.55, 0.9, 0.58) if heat < 30 else Color(1.0, 0.5, 0.35))

	objective_label.text = Game.objective

	var p = Game.player
	if p != null and is_instance_valid(p):
		prompt_label.text = p.get_prompt()
		if p.driving:
			speed_label.text = "%d km/h" % int(abs(float(p.current_car.get("speed"))) * 3.6)
		else:
			speed_label.text = ""
	else:
		prompt_label.text = ""


func _on_toast(text: String) -> void:
	while toast_box.get_child_count() >= 5:
		var old := toast_box.get_child(0)
		toast_box.remove_child(old)
		old.queue_free()

	var l := Label.new()
	l.text = text
	l.custom_minimum_size = Vector2(500, 0)
	l.add_theme_font_size_override("font_size", 19)
	l.add_theme_color_override("font_color", Color(1, 1, 1))
	l.add_theme_constant_override("outline_size", 7)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	toast_box.add_child(l)

	var tween := create_tween()
	tween.tween_interval(2.8)
	tween.tween_property(l, "modulate:a", 0.0, 0.9)
	tween.tween_callback(l.queue_free)
