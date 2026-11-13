extends Node3D
##
## MAIN — assembly line
##
## Order important hai:
##   lighting -> day/night -> city -> player -> vehicles -> NPC -> UI -> systems
## Player ke baad hi HUD/missions bante hain kyunki unko player chahiye.
##

const CITY_SCRIPT := preload("res://scripts/world/city.gd")
const DAY_NIGHT_SCRIPT := preload("res://scripts/world/day_night.gd")
const WEATHER_SCRIPT := preload("res://scripts/world/weather.gd")
const KIOSK_SCRIPT := preload("res://scripts/world/kiosk.gd")
const HUD_SCRIPT := preload("res://scripts/ui/hud.gd")
const PAUSE_SCRIPT := preload("res://scripts/ui/pause_menu.gd")
const MISSION_SCRIPT := preload("res://scripts/systems/missions.gd")
const EVENTS_SCRIPT := preload("res://scripts/systems/events.gd")

const PLAYER_SCENE := preload("res://scenes/player.tscn")
const CAR_SCENE := preload("res://scenes/car.tscn")
const NPC_SCENE := preload("res://scenes/npc.tscn")

const VIGNETTE_SHADER := preload("res://shaders/post_vignette.gdshader")
const GRAIN_SHADER := preload("res://shaders/post_grain.gdshader")

const NPC_COUNTS := [8, 14, 22]
const CAR_KINDS := ["car_sedan", "car_hatchback", "car_taxi", "car_stationwagon", "car_police"]

var sun: DirectionalLight3D
var environment: Environment


func _ready() -> void:
	var env_data := _setup_environment()
	sun = env_data["sun"]
	environment = env_data["environment"]

	var day_night = Node.new()
	day_night.name = "DayNight"
	day_night.set_script(DAY_NIGHT_SCRIPT)
	add_child(day_night)
	day_night.setup(sun, environment, env_data["sky"])

	# --- City ---
	var city = Node3D.new()
	city.name = "District"
	city.set_script(CITY_SCRIPT)
	add_child(city)
	var info: Dictionary = city.build({})

	# --- Player ---
	var player = PLAYER_SCENE.instantiate()
	player.position = info["spawn"]
	add_child(player)
	Game.player = player

	# --- Vehicles ---
	var car_spawns: Array = info.get("car_spawns", [])
	for i in range(car_spawns.size()):
		var car = CAR_SCENE.instantiate()
		car.position = car_spawns[i]
		car.rotation_degrees.y = 90.0 * float(i % 4)
		car.configure(CAR_KINDS[i % CAR_KINDS.size()])   # add_child se PEHLE
		add_child(car)
		if i == 0:
			Game.car = car

	# --- NPCs ---
	var npc_spawns: Array = info.get("npc_spawns", [])
	var npc_count: int = min(NPC_COUNTS[Game.quality], npc_spawns.size())
	for i in range(npc_count):
		var npc = NPC_SCENE.instantiate()
		npc.position = npc_spawns[i]
		add_child(npc)
		npc.setup(i, i % 2 == 0)

	# --- Corner store (interaction point) ---
	if info.has("shop_point"):
		var kiosk = Node3D.new()
		kiosk.name = "CornerStore"
		kiosk.set_script(KIOSK_SCRIPT)
		kiosk.position = info["shop_point"]
		add_child(kiosk)

	# --- Weather ---
	var weather = Node.new()
	weather.name = "Weather"
	weather.set_script(WEATHER_SCRIPT)
	add_child(weather)
	weather.setup(player, environment)

	# --- UI ---
	var hud = CanvasLayer.new()
	hud.name = "HUD"
	hud.set_script(HUD_SCRIPT)
	add_child(hud)

	var pause = CanvasLayer.new()
	pause.name = "PauseMenu"
	pause.set_script(PAUSE_SCRIPT)
	add_child(pause)

	_setup_post_fx()

	# --- Systems ---
	var missions = Node.new()
	missions.name = "Missions"
	missions.set_script(MISSION_SCRIPT)
	add_child(missions)
	missions.setup(player, info)

	var events = Node.new()
	events.name = "WorldEvents"
	events.set_script(EVENTS_SCRIPT)
	add_child(events)
	events.setup(player, info)

	# --- Quality ---
	Game.quality_changed.connect(_apply_quality)
	_apply_quality()

	Game.say("FALLEN STATE — district me welcome")
	await get_tree().create_timer(2.2).timeout
	Game.say("Ek dukaan, ek contact, ek gaadi. Baaki city khud batayegi.")
	await get_tree().create_timer(3.0).timeout
	Game.say("F10 se graphics badlo — purane laptop par LOW rakho")
	print("[Main] ready — NPCs: %d, cars: %d" % [npc_count, car_spawns.size()])


# ---------------------------------------------------------------------------
# ENVIRONMENT / LIGHTING
# ---------------------------------------------------------------------------

func _setup_environment() -> Dictionary:
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"

	var env := Environment.new()
	env.background_mode = Environment.BG_SKY

	var sky := Sky.new()
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_curve = 0.12
	sky_mat.sun_angle_max = 25.0
	sky_mat.sun_curve = 0.12
	sky.sky_material = sky_mat
	env.sky = sky

	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.52, 0.66)
	env.ambient_light_energy = 0.8

	# set() use kar rahe hain taaki property na hone par crash na ho
	env.set("tonemap_mode", Environment.TONE_MAPPER_ACES)
	env.set("tonemap_exposure", 1.0)
	env.set("tonemap_white", 6.0)
	env.set("fog_enabled", true)
	env.set("fog_light_color", Color(0.45, 0.52, 0.62))
	env.set("fog_density", 0.0018)
	env.set("fog_sun_scatter", 0.35)
	env.set("fog_aerial_perspective", 0.4)
	env.set("glow_enabled", true)
	env.set("glow_intensity", 0.55)
	env.set("glow_bloom", 0.08)
	env.set("glow_hdr_threshold", 1.05)

	world_env.environment = env
	add_child(world_env)
	world_env.add_to_group("world_environment")

	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.shadow_enabled = true
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
	sun.directional_shadow_max_distance = 90.0
	sun.light_energy = 1.4
	sun.light_angular_distance = 0.6
	sun.rotation_degrees = Vector3(-45.0, 35.0, 0.0)
	add_child(sun)

	return {"sun": sun, "environment": env, "sky": sky_mat}


# ---------------------------------------------------------------------------
# POST-PROCESSING (sasta cinematic look — bina GPU bhi chalega)
# ---------------------------------------------------------------------------

func _setup_post_fx() -> void:
	# 1) Vignette (kinare gehra + thanda tint)
	var vig_layer := CanvasLayer.new()
	vig_layer.layer = 1
	add_child(vig_layer)
	var vig := ColorRect.new()
	vig.set_anchors_preset(Control.PRESET_FULL_RECT)
	vig.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vig_mat := ShaderMaterial.new()
	vig_mat.shader = VIGNETTE_SHADER
	vig.material = vig_mat
	vig_layer.add_child(vig)

	# 2) Film grain (additive, bahut halka)
	var grain_layer := CanvasLayer.new()
	grain_layer.layer = 1
	add_child(grain_layer)
	var grain := ColorRect.new()
	grain.set_anchors_preset(Control.PRESET_FULL_RECT)
	grain.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var grain_mat := ShaderMaterial.new()
	grain_mat.shader = GRAIN_SHADER
	grain.material = grain_mat
	grain_layer.add_child(grain)


# ---------------------------------------------------------------------------
# QUALITY
# ---------------------------------------------------------------------------

func _apply_quality() -> void:
	var vp := get_viewport()
	match Game.quality:
		0:
			vp.msaa_3d = Viewport.MSAA_DISABLED
			vp.positional_shadow_atlas_size = 1024
			if sun != null:
				sun.directional_shadow_max_distance = 55.0
				sun.shadow_enabled = false
			if environment != null:
				environment.set("glow_enabled", false)
				environment.set("fog_density", 0.0012)
		1:
			vp.msaa_3d = Viewport.MSAA_2X
			vp.positional_shadow_atlas_size = 2048
			if sun != null:
				sun.directional_shadow_max_distance = 90.0
				sun.shadow_enabled = true
			if environment != null:
				environment.set("glow_enabled", true)
				environment.set("fog_density", 0.0018)
		_:
			vp.msaa_3d = Viewport.MSAA_4X
			vp.positional_shadow_atlas_size = 4096
			if sun != null:
				sun.directional_shadow_max_distance = 140.0
				sun.shadow_enabled = true
			if environment != null:
				environment.set("glow_enabled", true)
				environment.set("fog_density", 0.0022)
