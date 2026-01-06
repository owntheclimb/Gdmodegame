extends Node
class_name EventSystem

@export var spawn_interval_seconds := 30.0

var _timer := 0.0

@onready var marker_scene: PackedScene = preload("res://scenes/EventMarker.tscn")

func _ready() -> void:
	add_to_group("event_system")

func _process(delta: float) -> void:
	_timer += delta
	if _timer < spawn_interval_seconds:
		return
	_timer = 0.0
	_spawn_event()

func _spawn_event() -> void:
	var world := get_tree().get_first_node_in_group("world")
	if not world:
		return
	var position := world.get_random_walkable_position()
	var marker := marker_scene.instantiate()
	marker.global_position = position
	if marker.has_method("set_event_type"):
		marker.set_event_type(world.get_biome_at(position))
	add_child(marker)
