extends ResourceNode
class_name WoodResource

@export var default_amount := 20.0

func _ready() -> void:
	resource_type = "wood"
	if resource_amount <= 0.0 or resource_amount == 10.0:
		resource_amount = default_amount
	super._ready()
