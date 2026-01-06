extends Node
class_name AudioSettingsNode

@export var settings := AudioSettings.new()

func _ready() -> void:
	add_to_group("audio_settings")
