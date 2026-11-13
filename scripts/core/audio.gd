extends Node
##
## SOUND — audio manager (autoload "Sound")
##
## Buses: Master -> Music / SFX / Ambience / Engine
## Sab kuch code se: koi bus layout file nahi, isliye project kabhi corrupt nahi hoga.
##
## Audio files:
##   assets/audio/ambience.ogg      Kenney city ambience (CC0)   [loop]
##   assets/audio/footsteps.ogg     Kenney walking loop         [loop]
##   assets/audio/engine_loop.wav   synthesized engine          [loop]
##   assets/audio/siren_loop.wav    synthesized police siren    [loop]
##   assets/audio/rain_loop.wav     synthesized rain            [loop]
##   assets/music/ambient_night.wav synthesized dark ambient    [loop]
##

const AMB_PATH := "res://assets/audio/ambience.ogg"
const MUSIC_PATH := "res://assets/music/ambient_night.wav"
const RAIN_PATH := "res://assets/audio/rain_loop.wav"
const ENGINE_PATH := "res://assets/audio/engine_loop.wav"
const SIREN_PATH := "res://assets/audio/siren_loop.wav"
const FOOT_PATH := "res://assets/audio/footsteps.ogg"
const JUMP_PATH := "res://assets/audio/jump.ogg"
const LAND_PATH := "res://assets/audio/land.ogg"
const CLICK_PATH := "res://assets/audio/ui_click.ogg"

var ambience: AudioStreamPlayer
var music: AudioStreamPlayer
var rain: AudioStreamPlayer

var _cache: Dictionary = {}


func _ready() -> void:
	_ensure_bus("Music", -6.0)
	_ensure_bus("SFX", -3.0)
	_ensure_bus("Ambience", -12.0)
	_ensure_bus("Engine", -14.0)

	ambience = _make_player("Ambience", -8.0)
	music = _make_player("Music", -10.0)
	rain = _make_player("Ambience", -20.0)

	_start_loop(ambience, AMB_PATH)
	_start_loop(music, MUSIC_PATH)


func _ensure_bus(bus_name: String, volume_db: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		AudioServer.add_bus()
		idx = AudioServer.bus_count - 1
		AudioServer.set_bus_name(idx, bus_name)
		AudioServer.set_bus_send(idx, "Master")
	AudioServer.set_bus_volume_db(idx, volume_db)


func _make_player(bus_name: String, volume_db: float) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = bus_name
	p.volume_db = volume_db
	add_child(p)
	return p


## Stream lo + loop on karo (WAV aur OGG dono ke liye).
func stream(path: String, looping: bool = false):
	if _cache.has(path):
		return _cache[path]
	var s: Resource = load(path)
	if s == null:
		push_warning("[Sound] file nahi mili: " + path)
		return null
	if looping:
		if s is AudioStreamWAV:
			var wav := s as AudioStreamWAV
			wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
			wav.loop_begin = 0
			wav.loop_end = int(wav.get_length() * wav.mix_rate)
		elif s.get("loop") != null:
			s.set("loop", true)
	_cache[path] = s
	return s


func _start_loop(player: AudioStreamPlayer, path: String) -> void:
	var s = stream(path, true)
	if s == null:
		return
	player.stream = s
	player.play()


# ---------------------------------------------------------------------------
# PUBLIC API
# ---------------------------------------------------------------------------

func play_3d(path: String, pos: Vector3, volume_db: float = -6.0, pitch: float = 1.0) -> void:
	var s = stream(path, false)
	if s == null:
		return
	var p := AudioStreamPlayer3D.new()
	p.stream = s
	p.bus = "SFX"
	p.volume_db = volume_db
	p.pitch_scale = pitch
	p.unit_size = 6.0
	p.max_distance = 70.0
	add_child(p)
	p.global_position = pos
	p.play()
	p.finished.connect(p.queue_free)


func play_ui(path: String = CLICK_PATH) -> void:
	var s = stream(path, false)
	if s == null:
		return
	var p := AudioStreamPlayer.new()
	p.stream = s
	p.bus = "SFX"
	p.volume_db = -8.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)


func set_rain(active: bool) -> void:
	if active:
		if rain.playing:
			return
		var s = stream(RAIN_PATH, true)
		if s != null:
			rain.stream = s
			rain.play()
	elif rain.playing:
		rain.stop()


func footstep() -> void:
	play_3d(FOOT_PATH, _listener_pos(), -16.0, randf_range(0.9, 1.1))


func _listener_pos() -> Vector3:
	var vp := get_viewport()
	if vp != null:
		var cam := vp.get_camera_3d()
		if cam != null:
			return cam.global_position
	return Vector3.ZERO
