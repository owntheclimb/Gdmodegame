extends Node2D
class_name Building

@export var blueprint: Blueprint

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	_setup_placeholder_sprite()

func set_blueprint(new_blueprint: Blueprint) -> void:
	blueprint = new_blueprint

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.4, 0.4, 0.5))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
