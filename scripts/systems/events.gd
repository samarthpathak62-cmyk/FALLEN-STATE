extends Node
##
## WORLD EVENTS — "duniya tumhe dekhe bina bhi chalti rehti hai"
##
## Pattern: timer -> random road point -> event node -> player decide kare.
## M5 me isi file me 6-8 event types aayenge (fire, mugging, protest, chase...).
##

const INCIDENT_SCRIPT := preload("res://scripts/systems/incident.gd")
const MIN_DELAY := 55.0
const MAX_DELAY := 110.0

var player = null
var info: Dictionary = {}
var timer := 40.0


func setup(player_node, world_info: Dictionary) -> void:
	player = player_node
	info = world_info
	timer = 35.0


func _process(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	timer = randf_range(MIN_DELAY, MAX_DELAY)
	_spawn()


func _spawn() -> void:
	if get_tree().get_nodes_in_group("interactable").size() > 5:
		return
	var pos := Vector3(randf_range(-44.0, 44.0), Kits.GROUND_Y, 0.0)
	# Sadak par hi rakho (line = road line)
	var lane: float = float([0, 4, 8, 12][randi() % 4] - 6) * Kits.TILE
	if randf() < 0.5:
		pos.z = lane
	else:
		pos.x = lane

	var incident := Node3D.new()
	incident.set_script(INCIDENT_SCRIPT)
	incident.position = pos
	get_parent().add_child(incident)
	Game.say("RANDOM EVENT: sadak par accident! Madad karoge? (E dabao)")
