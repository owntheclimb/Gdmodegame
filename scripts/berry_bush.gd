extends ResourceNode

@export var food_amount := 10.0

func _ready() -> void:
	resource_type = "food"
	resource_amount = food_amount
	max_resource_amount = food_amount
	super._ready()
	add_to_group("berry_bush")
	_setup_placeholder_sprite()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.7, 0.4))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
