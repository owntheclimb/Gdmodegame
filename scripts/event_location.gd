extends Node2D
class_name EventLocation

@export var location_type := ""
@export var title := ""
@export var description := ""
@export var reward_resource := ""
@export var reward_amount := 0.0
@export var reward_action := ""

var resolved := false

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
		"camp":
			return Color(0.6, 0.5, 0.3)
		"grotto":
			return Color(0.2, 0.5, 0.6)
		"shrine":
			return Color(0.4, 0.6, 0.5)
		"outcrop":
			return Color(0.55, 0.55, 0.6)
		"cache":
			return Color(0.6, 0.4, 0.2)
		_:
			return Color(0.7, 0.7, 0.7)

func resolve(game_state: GameState, storage: Storage) -> bool:
	if resolved:
		return false
	resolved = true
	if reward_resource != "" and storage:
		storage.deposit(reward_resource, reward_amount)
	if reward_action != "" and game_state:
		game_state.record_action(reward_action)
	queue_free()
	return true
