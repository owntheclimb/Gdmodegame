extends Node
class_name ObjectiveManager

signal objectives_updated

var objectives := [
	{"id": "gather_food", "description": "Gather 20 food", "completed": false},
	{"id": "gather_wood", "description": "Stockpile 30 wood", "completed": false},
	{"id": "gather_stone", "description": "Stockpile 15 stone", "completed": false},
	{"id": "build_hut", "description": "Build 2 shelters", "completed": false},
	{"id": "survive_days", "description": "Survive 3 days", "completed": false},
	{"id": "unlock_farming", "description": "Unlock Farming", "completed": false},
	{"id": "complete_event", "description": "Complete 1 task", "completed": false},
	{"id": "grow_population", "description": "Reach a population of 3", "completed": false},
	{"id": "hunt_creature", "description": "Hunt 1 creature", "completed": false},
	{"id": "meet_nomads", "description": "Meet the nomads", "completed": false},
	{"id": "advance_story", "description": "Reach Chapter 2 of the story", "completed": false}
]

func _ready() -> void:
	add_to_group("objective_manager")

func _process(_delta: float) -> void:
	_update_objectives()

func _update_objectives() -> void:
	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if storage:
		_set_completed("gather_food", storage.get_amount("food") >= 20.0)
		_set_completed("gather_wood", storage.get_amount("wood") >= 30.0)
		_set_completed("gather_stone", storage.get_amount("stone") >= 15.0)

	var buildings := get_tree().get_nodes_in_group("building").size()
	_set_completed("build_hut", buildings >= 2)

	var game_state: GameState = get_tree().get_first_node_in_group("game_state")
	if game_state:
		_set_completed("survive_days", game_state.days_survived >= 3)
		_set_completed("complete_event", game_state.get_action_count("completed_task") >= 1)
		_set_completed("hunt_creature", game_state.get_action_count("hunted_creature") >= 1)
		_set_completed("meet_nomads", game_state.get_action_count("met_nomads") >= 1)

	_set_completed("unlock_farming", _has_tech("Farming"))

	var villagers := get_tree().get_nodes_in_group("villager").size()
	_set_completed("grow_population", villagers >= 3)

	var story_manager := get_tree().get_first_node_in_group("story_manager")
	if story_manager and story_manager.get_current_chapter_id() != "chapter_1":
		_set_completed("advance_story", true)

	objectives_updated.emit()

func _set_completed(objective_id: String, completed: bool) -> void:
	for objective in objectives:
		if objective["id"] == objective_id:
			objective["completed"] = completed
			return

func _has_tech(tech_name: String) -> bool:
	var tech_manager: TechManager = get_tree().get_first_node_in_group("tech_manager")
	if not tech_manager:
		return false
	return tech_name in tech_manager.tech_tree.unlocked

func get_objective_text() -> String:
	var lines := []
	for objective in objectives:
		var status := "[x]" if objective["completed"] else "[ ]"
		lines.append("%s %s" % [status, objective["description"]])
	return "\n".join(lines)
