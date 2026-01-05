extends Area2D
class_name ResourceNode

signal harvested(resource_type: String, amount: float)

@export var resource_type := ""
@export var resource_amount := 10.0

func _ready() -> void:
	add_to_group("resource")
	if resource_type != "":
		add_to_group("resource_%s" % resource_type)

func harvest() -> float:
	if resource_amount <= 0.0:
		return 0.0
	var amount := resource_amount
	resource_amount = 0.0
	harvested.emit(resource_type, amount)
	return amount
