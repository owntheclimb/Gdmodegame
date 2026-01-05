extends ResourceNode

@export var food_amount := 25.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("berry_bush")
	resource_type = "food"
	amount = food_amount
	_setup_placeholder_sprite()

func consume() -> float:
	return food_amount

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.7, 0.4))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
