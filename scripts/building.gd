extends Node2D
class_name Building

@export var building_name := ""
@export var required_resources := {"wood": 10.0}

func _ready() -> void:
	add_to_group("building")
