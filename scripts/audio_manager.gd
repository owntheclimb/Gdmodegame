extends Node
class_name AudioManager

@onready var player: AudioStreamPlayer = AudioStreamPlayer.new()
var generator: AudioStreamGenerator
var playback: AudioStreamGeneratorPlayback

func _ready() -> void:
	add_to_group("audio_manager")
	generator = AudioStreamGenerator.new()
	generator.mix_rate = 44100
	player.stream = generator
	add_child(player)
	player.play()
	playback = player.get_stream_playback()

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
