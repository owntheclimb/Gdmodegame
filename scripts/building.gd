extends Node2D
class_name Building

@export var building_name := ""
@export var required_resources := {"wood": 10.0}

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("building")
	_setup_placeholder_sprite()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(24, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.6, 0.4, 0.2))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
