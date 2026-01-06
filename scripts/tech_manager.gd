extends Node
class_name TechManager

@export var tech_tree := TechTree.new()

func _ready() -> void:
	add_to_group("tech_manager")

func _process(_delta: float) -> void:
	var game_state: GameState = get_tree().get_first_node_in_group("game_state")
	if game_state and game_state.days_survived >= 3:
		tech_tree.unlock("Farming")

	var buildings := get_tree().get_nodes_in_group("building").size()
	if buildings >= 1:
		tech_tree.unlock("Stoneworking")
