extends Node
class_name GameState

signal action_recorded(action: String)

@export var current_biome := "grassland"
@export var days_survived := 0

const MAX_RECENT_ACTIONS := 6

var _action_counts: Dictionary = {}
var _recent_actions: Array[String] = []

func _ready() -> void:
	add_to_group("game_state")
	get_tree().node_added.connect(_on_node_added)
	_try_connect_day_night()

func _on_node_added(node: Node) -> void:
	if node.is_in_group("day_night"):
		_connect_day_night(node)

func _try_connect_day_night() -> void:
	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		_connect_day_night(day_night)

func _connect_day_night(day_night: Node) -> void:
	if not day_night or not day_night.has_signal("day_started"):
		return
	if day_night.day_started.is_connected(_on_day_started):
		return
	day_night.day_started.connect(_on_day_started)

func _on_day_started() -> void:
	days_survived += 1
	record_action("day_survived")

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
