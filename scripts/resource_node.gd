extends Area2D
class_name ResourceNode

@export var resource_type := ""
@export var amount := 25.0

func harvest() -> float:
	var harvested := amount
	amount = 0.0
	return harvested

func take(requested: float) -> float:
	var taken := min(amount, requested)
	amount -= taken
	return taken
