extends Area2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("rock")
	_setup_placeholder_sprite()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(20, 14, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.45, 0.45, 0.5))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
