extends Area2D

@export var food_amount := 25.0

func _ready() -> void:
	add_to_group("berry_bush")

func consume() -> float:
	return food_amount
