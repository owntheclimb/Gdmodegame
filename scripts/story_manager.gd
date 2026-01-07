extends Node
class_name StoryManager

signal chapter_changed(chapter_id: String)

const STORY_CHAPTERS := [
	{
		"id": "chapter_1",
		"title": "Ashes and Shelter",
		"description": "Stabilize the camp and secure food for the survivors.",
		"requirements": {
			"gathered_food": 2,
			"day_survived": 1
		}
	},
	{
		"id": "chapter_2",
		"title": "Roots of a Settlement",
		"description": "Stockpile supplies and establish permanent shelter.",
		"requirements": {
			"gathered_wood": 2,
			"gathered_stone": 1,
			"completed_task": 1
		}
	},
	{
		"id": "chapter_3",
		"title": "Echoes Beyond the Plains",
		"description": "Seek out distant camps and learn the lay of the land.",
		"requirements": {
			"scouted_area": 3,
			"met_nomads": 1
		}
	},
	{
		"id": "chapter_4",
		"title": "The Wild Courts",
		"description": "Navigate alliances with the forest and highland tribes.",
		"requirements": {
			"cleansed_shrine": 1,
			"recovered_cache": 1
		}
	},
	{
		"id": "chapter_5",
		"title": "The Great Convergence",
		"description": "Unite the factions and prepare for the coming storm.",
		"requirements": {
			"community_ready": 1
		}
	}
]

var current_chapter_index := 0

func _ready() -> void:
	add_to_group("story_manager")
	var game_state := _get_game_state()
	if game_state:
		game_state.action_recorded.connect(_on_action_recorded)
	_update_chapter_if_ready()

func _on_action_recorded(_action: String) -> void:
	_update_chapter_if_ready()

func _update_chapter_if_ready() -> void:
	var chapter := get_current_chapter()
	if not chapter:
		return
	if _requirements_met(chapter.get("requirements", {})):
		_advance_chapter()

func _requirements_met(requirements: Dictionary) -> bool:
	var game_state := _get_game_state()
	if not game_state:
		return false
	for key in requirements.keys():
		var needed := int(requirements[key])
		if game_state.get_action_count(key) < needed:
			return false
	return true

func _advance_chapter() -> void:
	if current_chapter_index < STORY_CHAPTERS.size() - 1:
		current_chapter_index += 1
		chapter_changed.emit(get_current_chapter_id())
		var game_state := _get_game_state()
		if game_state and current_chapter_index == STORY_CHAPTERS.size() - 1:
			game_state.record_action("community_ready")

func get_current_chapter() -> Dictionary:
	if STORY_CHAPTERS.is_empty():
		return {}
	return STORY_CHAPTERS[current_chapter_index]

func get_current_chapter_id() -> String:
	var chapter := get_current_chapter()
	return str(chapter.get("id", ""))

func get_current_chapter_text() -> String:
	var chapter := get_current_chapter()
	if chapter.is_empty():
		return "Story: --"
	return "Story: %s - %s" % [chapter.get("title", "Unknown"), chapter.get("description", "")]

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state") as GameState
