extends Node3D
##
## MAIN — poore game ka "assembly line"
##
## Yahan sirf itna hota hai: lighting banao -> world banao -> player/cars/NPCs
## spawn karo -> HUD + mission + events attach karo.
##
## Koi bhi naya system add karna ho to YAHI file ek jagah hai jahan usko
## instantiate karna hai. Isliye yeh file chhoti rakhna important hai.
##

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const CAR_SCENE := preload("res://scenes/car.tscn")
const NPC_SCENE := preload("res://scenes/npc.tscn")

const WORLD_SCRIPT := preload("res://scripts/world/world_builder.gd")
const DAY_NIGHT_SCRIPT := preload("res://scripts/world/day_night.gd")
const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")
const MISSION_SCRIPT := preload("res://scripts/systems/mission_system.gd")
const EVENTS_SCRIPT := preload("res://scripts/systems/world_events.gd")

const NPC_COUNT := 16


func _ready() -> void:
	var env_data := _setup_lighting()
	var sun: DirectionalLight3D = env_data["sun"]
	var environment: Environment = env_data["environment"]
	var sky_material: ProceduralSkyMaterial = env_data["sky"]

	# --- Day/night controller ---
	var day_night = Node.new()
	day_night.name = "DayNight"
	day_night.set_script(DAY_NIGHT_SCRIPT)
	add_child(day_night)
	day_night.setup(sun, environment, sky_material)

	# --- World ---
	var world = Node3D.new()
	world.name = "District"
	world.set_script(WORLD_SCRIPT)
	add_child(world)
	var info: Dictionary = world.build()

	# --- Player ---
	var player = PLAYER_SCENE.instantiate()
	player.position = info["spawn"]
	add_child(player)
	Game.player = player

	# --- Vehicles ---
	var main_car = CAR_SCENE.instantiate()
	main_car.position = info["car_spawn"]
	add_child(main_car)
	main_car.setup_color(Color(0.62, 0.11, 0.12))
	Game.car = main_car

	var car_colors: Array = [
		Color(0.15, 0.2, 0.38), Color(0.55, 0.56, 0.6), Color(0.1, 0.34, 0.24),
	]
	var extra_car_spawns: Array = info["extra_car_spawns"]
	var color_index := 0
	for spawn_pos in extra_car_spawns:
		var extra_car = CAR_SCENE.instantiate()
		extra_car.position = spawn_pos
		add_child(extra_car)
		extra_car.setup_color(car_colors[color_index % car_colors.size()])
		color_index += 1

	# --- NPCs ---
	# NPC_COUNT badal kar dekho: 16 -> 40. City kitni zyada zinda lagti hai.
	var spawns: Array = info["npc_spawns"]
	var npc_count: int = min(NPC_COUNT, spawns.size())
	for npc_index in range(npc_count):
		var npc = NPC_SCENE.instantiate()
		npc.position = spawns[npc_index]
		add_child(npc)
		npc.setup(npc_index)

	# --- UI ---
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.set_script(HUD_SCRIPT)
	add_child(hud)

	# --- Missions ---
	var missions = Node.new()
	missions.name = "Missions"
	missions.set_script(MISSION_SCRIPT)
	add_child(missions)
	missions.setup(player, info)

	# --- Random world events ---
	var events = Node.new()
	events.name = "WorldEvents"
	events.set_script(EVENTS_SCRIPT)
	add_child(events)
	events.setup(player, info)

	# --- Welcome ---
	Game.say("FALLEN STATE — district me welcome")
	await get_tree().create_timer(2.5).timeout
	Game.say("WASD chalna · Shift daudna · F gaadi · E interact · F5 save")
	print("[Main] world ready — NPCs: %d, cars: %d" % [npc_count, 1 + extra_car_spawns.size()])


# ---------------------------------------------------------------------------
# LIGHTING / ATMOSPHERE
# ---------------------------------------------------------------------------

func _setup_lighting() -> Dictionary:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_curve = 0.15
	sky.sky_material = sky_material
	environment.sky = sky

	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(0.5, 0.55, 0.65)
	environment.ambient_light_energy = 0.6

	# set() use kiya hai taaki property na hone par bhi game crash na ho
	environment.set("tonemap_mode", Environment.TONE_MAPPER_FILMIC)
	environment.set("fog_enabled", true)
	environment.set("fog_light_color", Color(0.6, 0.65, 0.72))
	environment.set("fog_density", 0.0018)
	environment.set("fog_sun_scatter", 0.4)
	environment.set("glow_enabled", true)
	environment.set("glow_intensity", 0.5)

	world_env.environment = environment
	add_child(world_env)

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 150.0
	sun.light_energy = 1.2
	sun.rotation_degrees = Vector3(-45.0, 15.0, 0.0)
	add_child(sun)

	return {"sun": sun, "environment": environment, "sky": sky_material}
