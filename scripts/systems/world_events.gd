extends Node
##
## DYNAMIC WORLD EVENTS — "duniya tumhe dekhe bina bhi chalti rehti hai"
##
## Abhi ek hi event type hai (accident), lekin pattern general hai:
##   timer -> random jagah chuno -> event node spawn karo -> player decide kare.
##
## Roadmap M5 me isi file me 6-8 event types daalna: fire, mugging, protest,
## police chase, lost person, gang fight...
##

const INCIDENT_SCRIPT := preload("res://scripts/systems/incident.gd")
const MIN_DELAY := 45.0
const MAX_DELAY := 95.0
const MAX_ACTIVE := 2

var player = null
var info: Dictionary = {}
var timer := 35.0


func setup(player_node, world_info: Dictionary) -> void:
	player = player_node
	info = world_info
	timer = 30.0


func _process(delta: float) -> void:
	timer -= delta
	if timer > 0.0:
		return
	timer = randf_range(MIN_DELAY, MAX_DELAY)
	_spawn_incident()


func _spawn_incident() -> void:
	if get_tree().get_nodes_in_group("interactable").size() > 6:
		return   # bahut zyada events ek saath nahi

	var lines: Array = info.get("road_lines", [0.0])
	if lines.is_empty():
		return

	var lx: float = lines[randi() % lines.size()]
	var lz: float = lines[randi() % lines.size()]
	var pos := Vector3(lx, 0.2, lz + randf_range(-18.0, 18.0))

	var incident := Node3D.new()
	incident.set_script(INCIDENT_SCRIPT)
	incident.position = pos
	get_parent().add_child(incident)

	Game.say("RANDOM EVENT: sadak par accident hua hai. Madad karoge? (E dabao)")
