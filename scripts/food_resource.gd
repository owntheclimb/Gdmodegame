extends ResourceNode
class_name FoodResource

@export var default_amount := 25.0

func _ready() -> void:
	resource_type = "food"
	if resource_amount <= 0.0 or resource_amount == 10.0:
		resource_amount = default_amount
	super._ready()
