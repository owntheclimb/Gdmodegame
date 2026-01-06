extends Node
class_name GameState

signal action_recorded(action: String)

@export var current_biome := "grassland"

const MAX_RECENT_ACTIONS := 6

var _action_counts: Dictionary = {}
var _recent_actions: Array[String] = []

func _ready() -> void:
	add_to_group("game_state")

func record_action(action: String) -> void:
	if action.is_empty():
		return
	_action_counts[action] = get_action_count(action) + 1
	_recent_actions.append(action)
	if _recent_actions.size() > MAX_RECENT_ACTIONS:
		_recent_actions.remove_at(0)
	action_recorded.emit(action)

func get_action_count(action: String) -> int:
	return int(_action_counts.get(action, 0))

func has_recent_action(action: String) -> bool:
	return _recent_actions.has(action)

func get_recent_actions() -> Array[String]:
	return _recent_actions.duplicate()
