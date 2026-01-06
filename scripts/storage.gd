extends Node2D
class_name Storage

signal storage_changed

@export var food := 0.0
@export var wood := 0.0
@export var stone := 0.0
var resources: Dictionary:
	get = _get_resources,
	set = _set_resources

func _ready() -> void:
	add_to_group("storage")

func deposit(resource_type: String, amount: float) -> void:
	if amount <= 0.0:
		return
	match resource_type:
		"food":
			food += amount
		"wood":
			wood += amount
		"stone":
			stone += amount
		_:
			return
	storage_changed.emit()

func consume(resource_type: String, amount: float) -> float:
	if amount <= 0.0:
		return 0.0
	var available := get_amount(resource_type)
	var consumed := minf(amount, available)
	if consumed <= 0.0:
		return 0.0
	match resource_type:
		"food":
			food -= consumed
		"wood":
			wood -= consumed
		"stone":
			stone -= consumed
		_:
			return 0.0
	storage_changed.emit()
	return consumed

func get_amount(resource_type: String) -> float:
	match resource_type:
		"food":
			return food
		"wood":
			return wood
		"stone":
			return stone
		_:
			return 0.0

func _get_resources() -> Dictionary:
	return {
		"food": food,
		"wood": wood,
		"stone": stone
	}

func _set_resources(data: Dictionary) -> void:
	food = float(data.get("food", 0.0))
	wood = float(data.get("wood", 0.0))
	stone = float(data.get("stone", 0.0))
	storage_changed.emit()
