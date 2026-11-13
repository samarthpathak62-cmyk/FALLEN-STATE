extends CanvasLayer
##
## HUD — sab kuch code se bana hai (koi .tscn nahi), isliye copy-paste me
## kabhi node missing nahi hoga. Aage chaaho to isko scene me convert kar lo:
## right click node -> "Convert to scene"... ya poora UI theme se style karo.
##

var root: Control
var clock_label: Label
var money_label: Label
var objective_label: Label
var prompt_label: Label
var heat_label: Label
var hint_label: Label
var toast_box: VBoxContainer


func _ready() -> void:
	layer = 2

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	clock_label = _label(Vector2(20, 14), Vector2(460, 30), 20, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_LEFT)
	money_label = _label(Vector2(800, 14), Vector2(460, 30), 22, Color(0.55, 0.95, 0.6), HORIZONTAL_ALIGNMENT_RIGHT)
	heat_label = _label(Vector2(800, 46), Vector2(460, 22), 15, Color(1, 0.45, 0.4), HORIZONTAL_ALIGNMENT_RIGHT)
	hint_label = _label(Vector2(20, 44), Vector2(600, 22), 14, Color(0.75, 0.78, 0.85), HORIZONTAL_ALIGNMENT_LEFT)
	hint_label.text = "WASD chalna · Shift daudna · Space jump · E interact · F gaadi · F5/F9 save/load · Esc mouse"

	objective_label = _label(Vector2(20, 668), Vector2(900, 28), 18, Color(1.0, 0.85, 0.35), HORIZONTAL_ALIGNMENT_LEFT)
	prompt_label = _label(Vector2(390, 620), Vector2(500, 30), 20, Color(1, 1, 1), HORIZONTAL_ALIGNMENT_CENTER)

	toast_box = VBoxContainer.new()
	toast_box.position = Vector2(390, 90)
	toast_box.custom_minimum_size = Vector2(500, 0)
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
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(l)
	return l


func _process(_delta: float) -> void:
	var h := int(floor(Game.hour)) % 24
	var m := int((Game.hour - floor(Game.hour)) * 60.0)
	clock_label.text = "DAY %d    %02d:%02d" % [Game.day, h, m]
	money_label.text = "$%d" % Game.money

	var heat := int(Game.heat)
	heat_label.text = "POLICE HEAT %d%%" % heat
	heat_label.add_theme_color_override("font_color", Color(0.5, 0.9, 0.55) if heat < 30 else Color(1, 0.5, 0.35))

	objective_label.text = Game.objective

	var p = Game.player
	if p != null and is_instance_valid(p):
		prompt_label.text = p.get_prompt()
	else:
		prompt_label.text = ""


func _on_toast(text: String) -> void:
	# Purane toasts hatao (screen bhar na jaye)
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
	tween.tween_interval(2.6)
	tween.tween_property(l, "modulate:a", 0.0, 0.9)
	tween.tween_callback(l.queue_free)
