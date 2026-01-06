extends Node
class_name Storage

var resources := {}
signal resources_changed

func _ready() -> void:
	add_to_group("storage")
	resources["food"] = resources.get("food", 0.0)
	resources["wood"] = resources.get("wood", 0.0)
	resources["stone"] = resources.get("stone", 0.0)

func deposit(resource_type: String, amount: float) -> void:
	resources[resource_type] = resources.get(resource_type, 0.0) + amount
	resources_changed.emit()

func withdraw(resource_type: String, amount: float) -> float:
	var available := resources.get(resource_type, 0.0)
	var taken := min(available, amount)
	resources[resource_type] = available - taken
	resources_changed.emit()
	return taken

func get_amount(resource_type: String) -> float:
	return resources.get(resource_type, 0.0)
