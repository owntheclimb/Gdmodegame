extends Area2D
class_name ResourceNode

@export var resource_type := ""
@export var amount := 25.0

func harvest() -> float:
	return amount
