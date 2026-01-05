extends Node
class_name Storage

var resources := {}

func _ready() -> void:
	add_to_group("storage")

func deposit(resource_type: String, amount: float) -> void:
	resources[resource_type] = resources.get(resource_type, 0.0) + amount

func withdraw(resource_type: String, amount: float) -> float:
	var available := resources.get(resource_type, 0.0)
	var taken := min(available, amount)
	resources[resource_type] = available - taken
	return taken

func get_amount(resource_type: String) -> float:
	return resources.get(resource_type, 0.0)
