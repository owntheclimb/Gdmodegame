extends Resource
class_name Quest

@export var quest_id := ""
@export var title := ""
@export var description := ""
@export var requirements: Dictionary = {}
@export var reward_resources: Dictionary = {}
@export var reward_actions: Array[String] = []
@export var completed := false

func is_ready(game_state: GameState) -> bool:
	if completed:
		return false
	if not game_state:
		return false
	for key in requirements.keys():
		var needed := int(requirements[key])
		if game_state.get_action_count(key) < needed:
			return false
	return true

func apply_rewards(storage: Storage, game_state: GameState) -> void:
	for resource in reward_resources.keys():
		var amount := float(reward_resources[resource])
		if storage:
			storage.deposit(resource, amount)
	for action in reward_actions:
		if game_state:
			game_state.record_action(action)
	completed = true
