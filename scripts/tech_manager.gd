extends Node
class_name TechManager

@export var tech_tree := TechTree.new()

func _ready() -> void:
	add_to_group("tech_manager")

func _process(_delta: float) -> void:
	var game_state: GameState = get_tree().get_first_node_in_group("game_state")
	var storage: Storage = get_tree().get_first_node_in_group("storage")
	var buildings := get_tree().get_nodes_in_group("building").size()
	var villagers := get_tree().get_nodes_in_group("villager").size()

	if game_state and game_state.days_survived >= 2:
		tech_tree.unlock("Farming")
	if game_state and game_state.days_survived >= 4:
		tech_tree.unlock("Husbandry")

	if storage and storage.get_amount("wood") >= 25.0:
		tech_tree.unlock("Carpentry")
	if storage and storage.get_amount("stone") >= 15.0:
		tech_tree.unlock("Masonry")
	if storage and storage.get_amount("food") >= 40.0:
		tech_tree.unlock("Preservation")

	if buildings >= 1:
		tech_tree.unlock("Stoneworking")
	if buildings >= 3:
		tech_tree.unlock("Settlement Planning")

	if villagers >= 3:
		tech_tree.unlock("Community")

	if game_state and game_state.get_action_count("completed_task") >= 1:
		tech_tree.unlock("Exploration")
	if game_state and game_state.get_action_count("scouted_area") >= 3:
		tech_tree.unlock("Cartography")
