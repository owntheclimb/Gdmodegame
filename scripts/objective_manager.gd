extends Node
class_name ObjectiveManager

signal objectives_updated

var objectives := [
	{"id": "gather_food", "description": "Gather 20 food", "completed": false},
	{"id": "build_hut", "description": "Build 1 hut", "completed": false}
]

func _ready() -> void:
	add_to_group("objective_manager")

func _process(_delta: float) -> void:
	_update_objectives()

func _update_objectives() -> void:
	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if storage:
		_set_completed("gather_food", storage.get_amount("food") >= 20.0)

	var buildings := get_tree().get_nodes_in_group("building").size()
	_set_completed("build_hut", buildings >= 1)

	objectives_updated.emit()

func _set_completed(objective_id: String, completed: bool) -> void:
	for objective in objectives:
		if objective["id"] == objective_id:
			objective["completed"] = completed
			return

func get_objective_text() -> String:
	var lines := []
	for objective in objectives:
		var status := "[x]" if objective["completed"] else "[ ]"
		lines.append("%s %s" % [status, objective["description"]])
	return "\n".join(lines)
