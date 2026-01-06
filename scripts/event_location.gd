extends Node2D
class_name EventLocation

@export var location_type := ""
@export var title := ""
@export var description := ""

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("event_location")
	_setup_sprite()

func _setup_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(18, 18, false, Image.FORMAT_RGBA8)
	image.fill(_color_for_type())
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _color_for_type() -> Color:
	match location_type:
		"ruins":
			return Color(0.5, 0.45, 0.4)
		"debris":
			return Color(0.4, 0.4, 0.45)
		"artifact":
			return Color(0.6, 0.2, 0.7)
		_:
			return Color(0.7, 0.7, 0.7)
