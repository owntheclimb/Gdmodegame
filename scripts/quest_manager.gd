extends Node
class_name QuestManager

signal quest_completed(quest: Quest)

var quests: Array[Quest] = []

func _ready() -> void:
	add_to_group("quest_manager")
	_initialize_quests()
	var game_state := _get_game_state()
	if game_state:
		game_state.action_recorded.connect(_on_action_recorded)

func _initialize_quests() -> void:
	quests = []
	quests.append(_make_quest(
		"forager_trail",
		"Follow the Forager Trail",
		"Gather food and learn the safe paths.",
		{"gathered_food": 2, "scouted_area": 1},
		{"food": 10.0},
		["forager_trail_complete"]
	))
	quests.append(_make_quest(
		"timberline",
		"Timberline Stockpile",
		"Secure enough timber to expand the village.",
		{"gathered_wood": 2},
		{"wood": 12.0},
		["timberline_complete"]
	))
	quests.append(_make_quest(
		"stonewatch",
		"Stonewatch Cache",
		"Recover sturdy stone for fortifications.",
		{"gathered_stone": 2},
		{"stone": 10.0},
		["stonewatch_complete"]
	))
	quests.append(_make_quest(
		"ally_nomads",
		"Reach the Nomads",
		"Open dialogue with the Golden Nomads.",
		{"met_nomads": 1},
		{"food": 8.0, "wood": 6.0},
		["allied_nomads"]
	))
	quests.append(_make_quest(
		"forest_pact",
		"The Forest Pact",
		"Cleanse the shrine and earn the forest's trust.",
		{"cleansed_shrine": 1},
		{"food": 6.0, "wood": 4.0},
		["forest_pact"]
	))
	quests.append(_make_quest(
		"highland_vow",
		"Highland Vow",
		"Recover the mountain cache for the clans.",
		{"recovered_cache": 1},
		{"stone": 8.0},
		["highland_vow"]
	))

func _make_quest(quest_id: String, title: String, description: String, requirements: Dictionary, rewards: Dictionary, reward_actions: Array[String]) -> Quest:
	var quest := Quest.new()
	quest.quest_id = quest_id
	quest.title = title
	quest.description = description
	quest.requirements = requirements
	quest.reward_resources = rewards
	quest.reward_actions = reward_actions
	return quest

func _on_action_recorded(_action: String) -> void:
	_check_quest_completion()

func _check_quest_completion() -> void:
	var storage := _get_storage()
	var game_state := _get_game_state()
	for quest in quests:
		if quest.is_ready(game_state):
			quest.apply_rewards(storage, game_state)
			quest_completed.emit(quest)

func get_active_quests_text() -> String:
	var lines := ["Quests:"]
	for quest in quests:
		if quest.completed:
			continue
		lines.append("%s - %s" % [quest.title, quest.description])
	if lines.size() == 1:
		lines.append("No active quests.")
	return "\n".join(lines)

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state") as GameState

func _get_storage() -> Storage:
	return get_tree().get_first_node_in_group("storage") as Storage
