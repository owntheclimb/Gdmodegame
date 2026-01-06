extends Node
class_name AudioManager

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
@export var settings := AudioSettings.new()
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

func _ready() -> void:
	add_to_group("audio_manager")
	settings = _load_settings()
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	player.stream = generator
	add_child(player)
	player.play()
	playback = player.get_stream_playback()
	music_player.volume_db = linear_to_db(settings.music_volume)
	player.volume_db = linear_to_db(settings.sfx_volume)
	add_child(music_player)
	_play_music()

	var task_board := get_tree().get_first_node_in_group("task_board")
	if task_board:
		task_board.task_completed.connect(_on_task_completed)

	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		day_night.day_started.connect(func(): _beep(660.0))
		day_night.night_started.connect(func(): _beep(440.0))

func _on_task_completed(_task: Task) -> void:
	_beep(520.0)

func _beep(freq: float) -> void:
	if not playback:
		return
	var length := 0.1
	var frames := int(generator.mix_rate * length)
	for i in frames:
		var t := float(i) / generator.mix_rate
		var sample := sin(PI * 2.0 * freq * t) * 0.2
		playback.push_frame(Vector2(sample, sample))

func _play_music() -> void:
	if music_player.playing:
		return
	var generator_music := AudioStreamGenerator.new()
	generator_music.mix_rate = 44100
	music_player.stream = generator_music
	music_player.play()
	var music_playback := music_player.get_stream_playback()
	var length := 1.0
	var frames := int(generator_music.mix_rate * length)
	for i in frames:
		var t := float(i) / generator_music.mix_rate
		var sample := sin(PI * 2.0 * 220.0 * t) * 0.05
		music_playback.push_frame(Vector2(sample, sample))

func _load_settings() -> AudioSettings:
	var node := get_tree().get_first_node_in_group("audio_settings")
	if node and node.settings:
		return node.settings
	return settings
