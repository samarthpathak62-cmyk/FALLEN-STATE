extends Node
##
## DAY / NIGHT CYCLE + LIGHTING
##
## 1 real second = 1 game minute  (poora din = 24 real minutes)
## Suraj 6 baje ugta hai, 12 baje sar par, 18 baje doobta hai.
##
## Yeh sabse sasta "wow" feature hai — aur poore game ka mood badal deta hai.
##

const MINUTES_PER_SECOND := 1.0

var sun: DirectionalLight3D = null
var env: Environment = null
var sky_material: ProceduralSkyMaterial = null
var running := true

var _shadow_on := true
var _last_hour_int := -1


func setup(sun_node: DirectionalLight3D, environment: Environment, sky: ProceduralSkyMaterial) -> void:
	sun = sun_node
	env = environment
	sky_material = sky
	_apply(Game.hour)


func _process(delta: float) -> void:
	if not running or sun == null:
		return

	Game.hour += delta * MINUTES_PER_SECOND / 60.0
	if Game.hour >= 24.0:
		Game.hour -= 24.0
		Game.day += 1
		Game.say("Day %d shuru" % Game.day)

	var hour_int := int(Game.hour)
	if hour_int != _last_hour_int:
		_last_hour_int = hour_int
		Game.hour_changed.emit(Game.hour)

	_apply(Game.hour)


func _apply(hour: float) -> void:
	# 6 baje = 0 degree, 12 baje = 90 degree, 18 baje = 180 degree
	var angle_deg: float = (hour - 6.0) / 12.0 * 180.0
	if sun != null:
		sun.rotation_degrees = Vector3(-angle_deg, 15.0, 0.0)

	var altitude: float = sin(deg_to_rad(angle_deg))
	var daylight: float = clamp(altitude, 0.0, 1.0)
	var dusk: float = clamp(1.0 - abs(altitude) * 3.0, 0.0, 1.0)

	if sun != null:
		sun.light_energy = clamp(altitude, 0.0, 1.0) * 1.3 + 0.04
		sun.light_color = Color(1.0, 0.96, 0.9).lerp(Color(1.0, 0.55, 0.28), dusk)

		# Raat me shadow compute karna waste hai
		var want_shadow := daylight > 0.06
		if want_shadow != _shadow_on:
			_shadow_on = want_shadow
			sun.shadow_enabled = want_shadow

	if sky_material != null:
		var night_top := Color(0.015, 0.025, 0.06)
		var day_top := Color(0.27, 0.47, 0.78)
		var night_horizon := Color(0.05, 0.06, 0.11)
		var day_horizon := Color(0.7, 0.78, 0.86)
		var dusk_color := Color(0.85, 0.4, 0.22)

		sky_material.sky_top_color = night_top.lerp(day_top, daylight).lerp(dusk_color, dusk * 0.35)
		sky_material.sky_horizon_color = night_horizon.lerp(day_horizon, daylight).lerp(dusk_color, dusk * 0.75)
		sky_material.ground_horizon_color = sky_material.sky_horizon_color
		sky_material.ground_bottom_color = Color(0.03, 0.03, 0.04)
		sky_material.sky_energy_multiplier = lerp(0.35, 1.0, daylight)

	if env != null:
		env.ambient_light_color = Color(0.35, 0.42, 0.6).lerp(Color(0.6, 0.65, 0.72), daylight)
		env.ambient_light_energy = lerp(0.32, 0.85, daylight)
		env.set("fog_light_color", Color(0.1, 0.12, 0.18).lerp(Color(0.62, 0.66, 0.72), daylight))


func get_clock_text() -> String:
	var h := int(floor(Game.hour)) % 24
	var m := int((Game.hour - floor(Game.hour)) * 60.0)
	return "%02d:%02d" % [h, m]
