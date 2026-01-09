extends Node
class_name AudioSystem

## Audio System for ambient sounds, action sounds, UI sounds, and music

# Audio buses (set up in Godot project settings)
const BUS_MASTER := "Master"
const BUS_MUSIC := "Music"
const BUS_SFX := "SFX"
const BUS_AMBIENT := "Ambient"
const BUS_UI := "UI"

# Sound categories
enum SoundType { AMBIENT, ACTION, UI, MUSIC }

# Current state
var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _ui_player: AudioStreamPlayer

# Volume levels (0-1)
var master_volume := 1.0
var music_volume := 0.7
var sfx_volume := 0.8
var ambient_volume := 0.5
var ui_volume := 0.6

# Current playing
var _current_music: String = ""
var _current_ambient: String = ""

func _ready() -> void:
	add_to_group("audio_system")
	_setup_players()

func _setup_players() -> void:
	# Music player
	_music_player = AudioStreamPlayer.new()
	_music_player.name = "MusicPlayer"
	add_child(_music_player)
	
	# Ambient player
	_ambient_player = AudioStreamPlayer.new()
	_ambient_player.name = "AmbientPlayer"
	add_child(_ambient_player)
	
	# SFX pool (multiple for overlapping sounds)
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.name = "SFXPlayer%d" % i
		add_child(player)
		_sfx_players.append(player)
	
	# UI player
	_ui_player = AudioStreamPlayer.new()
	_ui_player.name = "UIPlayer"
	add_child(_ui_player)

# Play ambient sound (loops)
func play_ambient(sound_id: String) -> void:
	if _current_ambient == sound_id:
		return
	
	_current_ambient = sound_id
	var path := _get_ambient_path(sound_id)
	if path.is_empty():
		return
	
	var stream := load(path)
	if stream:
		_ambient_player.stream = stream
		_ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)
		_ambient_player.play()

func _get_ambient_path(sound_id: String) -> String:
	var paths: Dictionary = {
		"forest": "res://assets/audio/ambient/forest.ogg",
		"village": "res://assets/audio/ambient/village.ogg",
		"night": "res://assets/audio/ambient/night.ogg",
		"rain": "res://assets/audio/ambient/rain.ogg",
		"wind": "res://assets/audio/ambient/wind.ogg",
	}
	return paths.get(sound_id, "")

# Play music (loops, with crossfade)
func play_music(track_id: String) -> void:
	if _current_music == track_id:
		return
	
	_current_music = track_id
	var path := _get_music_path(track_id)
	if path.is_empty():
		return
	
	var stream := load(path)
	if stream:
		# Crossfade would be nice but keep it simple
		_music_player.stream = stream
		_music_player.volume_db = linear_to_db(music_volume * master_volume)
		_music_player.play()

func _get_music_path(track_id: String) -> String:
	var paths: Dictionary = {
		"main_theme": "res://assets/audio/music/main_theme.ogg",
		"peaceful": "res://assets/audio/music/peaceful.ogg",
		"adventure": "res://assets/audio/music/adventure.ogg",
		"danger": "res://assets/audio/music/danger.ogg",
		"victory": "res://assets/audio/music/victory.ogg",
	}
	return paths.get(track_id, "")

# Play SFX (one-shot)
func play_sfx(sound_id: String) -> void:
	var path := _get_sfx_path(sound_id)
	if path.is_empty():
		return
	
	var stream := load(path)
	if not stream:
		return
	
	# Find available player
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume * master_volume)
			player.play()
			return
	
	# All busy, use first one
	_sfx_players[0].stream = stream
	_sfx_players[0].play()

func _get_sfx_path(sound_id: String) -> String:
	var paths: Dictionary = {
		# Action sounds
		"chop": "res://assets/audio/sfx/chop.wav",
		"mine": "res://assets/audio/sfx/mine.wav",
		"build": "res://assets/audio/sfx/build.wav",
		"harvest": "res://assets/audio/sfx/harvest.wav",
		"footstep": "res://assets/audio/sfx/footstep.wav",
		# Event sounds
		"notification": "res://assets/audio/sfx/notification.wav",
		"level_up": "res://assets/audio/sfx/level_up.wav",
		"complete": "res://assets/audio/sfx/complete.wav",
		"error": "res://assets/audio/sfx/error.wav",
		# Combat sounds
		"hit": "res://assets/audio/sfx/hit.wav",
		"death": "res://assets/audio/sfx/death.wav",
	}
	return paths.get(sound_id, "")

# Play UI sound
func play_ui(sound_id: String) -> void:
	var path := _get_ui_path(sound_id)
	if path.is_empty():
		return
	
	var stream := load(path)
	if stream:
		_ui_player.stream = stream
		_ui_player.volume_db = linear_to_db(ui_volume * master_volume)
		_ui_player.play()

func _get_ui_path(sound_id: String) -> String:
	var paths: Dictionary = {
		"click": "res://assets/audio/ui/click.wav",
		"hover": "res://assets/audio/ui/hover.wav",
		"open": "res://assets/audio/ui/open.wav",
		"close": "res://assets/audio/ui/close.wav",
		"confirm": "res://assets/audio/ui/confirm.wav",
		"cancel": "res://assets/audio/ui/cancel.wav",
	}
	return paths.get(sound_id, "")

# Volume controls
func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_update_all_volumes()

func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_music_player.volume_db = linear_to_db(music_volume * master_volume)

func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)

func set_ambient_volume(value: float) -> void:
	ambient_volume = clampf(value, 0.0, 1.0)
	_ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)

func set_ui_volume(value: float) -> void:
	ui_volume = clampf(value, 0.0, 1.0)

func _update_all_volumes() -> void:
	_music_player.volume_db = linear_to_db(music_volume * master_volume)
	_ambient_player.volume_db = linear_to_db(ambient_volume * master_volume)

# Stop functions
func stop_music() -> void:
	_music_player.stop()
	_current_music = ""

func stop_ambient() -> void:
	_ambient_player.stop()
	_current_ambient = ""

func stop_all() -> void:
	stop_music()
	stop_ambient()
	for player in _sfx_players:
		player.stop()
	_ui_player.stop()

# Pause/Resume
func pause_music() -> void:
	_music_player.stream_paused = true

func resume_music() -> void:
	_music_player.stream_paused = false
