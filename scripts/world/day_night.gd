extends Node
##
## DAY / NIGHT — 24 ghante ka cycle + cinematic lighting
##
## 1 asli second = 1 game minute  (poora din 24 asli minute me)
## 6:00 sunrise, 12:00 noon, 18:00 sunset, 0:00 midnight.
##
## "Realistic" look ka sach: heavy tech (SSAO/SSR/GI) ki zaroorat nahi —
## sun ka angle, fog ka rang, aur sky ka gradient 80% kaam kar dete hain,
## aur yeh sab integrated GPU par bhi free chalte hain.
##

const MINUTES_PER_SECOND := 1.0

var sun: DirectionalLight3D = null
var env: Environment = null
var sky: ProceduralSkyMaterial = null
var running := true

var _shadow_on := true
var _last_hour := -1


func setup(sun_node: DirectionalLight3D, environment: Environment, sky_mat: ProceduralSkyMaterial) -> void:
	sun = sun_node
	env = environment
	sky = sky_mat
	_apply(Game.hour)


func _process(delta: float) -> void:
	if not running or sun == null:
		return
	Game.hour += delta * MINUTES_PER_SECOND / 60.0
	if Game.hour >= 24.0:
		Game.hour -= 24.0
		Game.day += 1
		Game.say("Day %d" % Game.day)

	var h := int(Game.hour)
	if h != _last_hour:
		_last_hour = h
		Game.hour_changed.emit(Game.hour)
	_apply(Game.hour)


func is_night() -> bool:
	return Game.hour < 6.5 or Game.hour > 19.5


func _apply(hour: float) -> void:
	# 6:00 = 0°, 12:00 = 90°, 18:00 = 180°
	var angle_deg: float = (hour - 6.0) / 12.0 * 180.0
	var altitude: float = sin(deg_to_rad(angle_deg))
	var daylight: float = clamp(altitude, 0.0, 1.0)
	var dusk: float = clamp(1.0 - abs(altitude) * 3.0, 0.0, 1.0)

	if sun != null:
		sun.rotation_degrees = Vector3(-angle_deg, 35.0, 0.0)
		sun.light_energy = clamp(altitude, 0.0, 1.0) * 1.5 + 0.03
		sun.light_color = Color(1.0, 0.96, 0.9).lerp(Color(1.0, 0.52, 0.26), dusk)
		var want := daylight > 0.05 and Game.quality > 0
		if want != _shadow_on:
			_shadow_on = want
			sun.shadow_enabled = want

	if sky != null:
		var night_top := Color(0.012, 0.018, 0.045)
		var day_top := Color(0.24, 0.44, 0.76)
		var night_hor := Color(0.05, 0.06, 0.10)
		var day_hor := Color(0.70, 0.78, 0.86)
		var dusk_col := Color(0.92, 0.42, 0.20)
		sky.sky_top_color = night_top.lerp(day_top, daylight).lerp(dusk_col, dusk * 0.40)
		sky.sky_horizon_color = night_hor.lerp(day_hor, daylight).lerp(dusk_col, dusk * 0.85)
		sky.ground_horizon_color = sky.sky_horizon_color
		sky.ground_bottom_color = Color(0.02, 0.02, 0.03)
		sky.sky_energy_multiplier = lerp(0.30, 1.0, daylight)

	if env != null:
		# Ambient: raat me neela, din me neutral
		env.ambient_light_color = Color(0.22, 0.28, 0.45).lerp(Color(0.62, 0.66, 0.72), daylight)
		env.ambient_light_energy = lerp(0.55, 0.95, daylight)
		env.set("fog_light_color", Color(0.07, 0.09, 0.15).lerp(Color(0.62, 0.68, 0.74), daylight))
		# Cinematic grade (built-in, free)
		env.set("adjustment_enabled", true)
		env.set("adjustment_brightness", 1.02)
		env.set("adjustment_contrast", 1.12)
		env.set("adjustment_saturation", lerp(0.85, 1.05, daylight))
