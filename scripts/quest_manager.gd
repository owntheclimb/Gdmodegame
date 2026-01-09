extends Node
class_name QuestManager

## Expanded Quest System with 4 types:
## - Main Quests: Story progression, always available
## - Side Quests: Optional, discovered through exploration
## - Daily Quests: Repeatable resource/skill challenges
## - Legendary Quests: Rare, epic rewards, multi-session

signal quest_started(quest: Quest)
signal quest_completed(quest: Quest)
signal quest_progress(quest: Quest, progress: float)

enum QuestType { MAIN, SIDE, DAILY, LEGENDARY }

const QUEST_TYPE_NAMES: Dictionary = {
	QuestType.MAIN: "Main",
	QuestType.SIDE: "Side",
	QuestType.DAILY: "Daily",
	QuestType.LEGENDARY: "Legendary",
}

const QUEST_TYPE_COLORS: Dictionary = {
	QuestType.MAIN: Color(1.0, 0.85, 0.3),      # Gold
	QuestType.SIDE: Color(0.5, 0.8, 1.0),       # Blue
	QuestType.DAILY: Color(0.6, 0.9, 0.6),      # Green
	QuestType.LEGENDARY: Color(0.9, 0.4, 0.9),  # Purple
}

# All quests organized by type
var _quests: Dictionary = {
	QuestType.MAIN: [],
	QuestType.SIDE: [],
	QuestType.DAILY: [],
	QuestType.LEGENDARY: [],
}

# Currently active quests
var _active_quests: Array = []

# Completed quest IDs
var _completed_quest_ids: Array[String] = []

# Daily quest refresh timer
var _daily_refresh_timer := 0.0
const DAILY_REFRESH_INTERVAL := 300.0  # 5 minutes game time

func _ready() -> void:
	add_to_group("quest_manager")
	_initialize_all_quests()
	_start_initial_quests()
	
	var game_state := _get_game_state()
	if game_state:
		game_state.action_recorded.connect(_on_action_recorded)

func _process(delta: float) -> void:
	# Refresh daily quests periodically
	_daily_refresh_timer += delta
	if _daily_refresh_timer >= DAILY_REFRESH_INTERVAL:
		_daily_refresh_timer = 0.0
		_refresh_daily_quests()
	
	# Check progress on all active quests
	_update_quest_progress()

func _initialize_all_quests() -> void:
	# MAIN QUESTS - Story progression
	_add_quest(QuestType.MAIN, _make_quest(
		"ch1_first_shelter",
		"First Shelter",
		"Build your first shelter to protect the villagers.",
		{"buildings_built": 1},
		{"wood": 20},
		1
	))
	
	_add_quest(QuestType.MAIN, _make_quest(
		"ch1_gather_supplies",
		"Gather Supplies",
		"Collect 50 food to ensure survival.",
		{"food_gathered": 50},
		{"research_points": 5},
		1
	))
	
	_add_quest(QuestType.MAIN, _make_quest(
		"ch1_find_ruins",
		"The First Ruin",
		"Explore the island and find the ancient ruins.",
		{"ruins_discovered": 1},
		{"wood": 30, "stone": 20},
		1
	))
	
	_add_quest(QuestType.MAIN, _make_quest(
		"ch2_population_10",
		"Growing Village",
		"Reach a population of 10 villagers.",
		{"population": 10},
		{"food": 50, "research_points": 10},
		2
	))
	
	_add_quest(QuestType.MAIN, _make_quest(
		"ch2_survive_winter",
		"First Winter",
		"Survive your first winter season.",
		{"winters_survived": 1},
		{"wood": 100, "stone": 50},
		2
	))
	
	_add_quest(QuestType.MAIN, _make_quest(
		"ch2_ancient_tech",
		"Ancient Technology",
		"Research basic tools from the ancient cache.",
		{"techs_researched": 1},
		{"research_points": 20},
		2
	))
	
	# SIDE QUESTS - Optional discoveries
	_add_quest(QuestType.SIDE, _make_quest(
		"find_lost_scholar",
		"The Lost Scholar",
		"Find and recruit the wandering scholar.",
		{"scholar_found": 1},
		{"research_points": 30},
		0
	))
	
	_add_quest(QuestType.SIDE, _make_quest(
		"tame_first_animal",
		"Animal Companion",
		"Tame your first wild animal.",
		{"animals_tamed": 1},
		{"food": 40},
		0
	))
	
	_add_quest(QuestType.SIDE, _make_quest(
		"build_shrine",
		"Sacred Ground",
		"Build a shrine to earn divine favor.",
		{"shrine_built": 1},
		{"divine_favor": 20},
		0
	))
	
	_add_quest(QuestType.SIDE, _make_quest(
		"ally_nomads",
		"Reach the Nomads",
		"Open dialogue with the Golden Nomads tribe.",
		{"met_nomads": 1},
		{"food": 30, "wood": 20},
		0
	))
	
	_add_quest(QuestType.SIDE, _make_quest(
		"explore_cave",
		"Crystal Cave",
		"Discover and explore the crystal cave.",
		{"cave_explored": 1},
		{"stone": 50, "gold": 10},
		0
	))
	
	# DAILY QUESTS - Repeatable
	_add_quest(QuestType.DAILY, _make_quest(
		"daily_gather_wood",
		"Timber Collection",
		"Gather 20 wood today.",
		{"wood_gathered": 20},
		{"food": 10},
		0
	))
	
	_add_quest(QuestType.DAILY, _make_quest(
		"daily_gather_food",
		"Food Foraging",
		"Gather 30 food today.",
		{"food_gathered": 30},
		{"wood": 10},
		0
	))
	
	_add_quest(QuestType.DAILY, _make_quest(
		"daily_gather_stone",
		"Stone Mining",
		"Gather 15 stone today.",
		{"stone_gathered": 15},
		{"food": 15},
		0
	))
	
	_add_quest(QuestType.DAILY, _make_quest(
		"daily_build_something",
		"Construction Day",
		"Complete any construction project.",
		{"buildings_built": 1},
		{"research_points": 5},
		0
	))
	
	# LEGENDARY QUESTS - Epic challenges
	_add_quest(QuestType.LEGENDARY, _make_quest(
		"slay_dragon",
		"The Mountain Dragon",
		"Defeat the legendary dragon atop the mountain.",
		{"dragon_slain": 1},
		{"gold": 100, "divine_favor": 50, "legendary_weapon": 1},
		0
	))
	
	_add_quest(QuestType.LEGENDARY, _make_quest(
		"unite_tribes",
		"Unity of Isola",
		"Form alliances with all three island tribes.",
		{"tribes_allied": 3},
		{"gold": 50, "research_points": 100},
		0
	))
	
	_add_quest(QuestType.LEGENDARY, _make_quest(
		"build_wonder",
		"The Great Wonder",
		"Construct a legendary monument.",
		{"wonder_built": 1},
		{"divine_favor": 100, "reputation": 50},
		0
	))
	
	_add_quest(QuestType.LEGENDARY, _make_quest(
		"discover_secret",
		"Island's Secret",
		"Uncover the true mystery of the island.",
		{"secrets_discovered": 5},
		{"ending_unlock": 1},
		0
	))

func _add_quest(type: QuestType, quest: Quest) -> void:
	quest.quest_type = type
	_quests[type].append(quest)

func _make_quest(quest_id: String, title: String, description: String, requirements: Dictionary, rewards: Dictionary, chapter: int) -> Quest:
	var quest := Quest.new()
	quest.quest_id = quest_id
	quest.title = title
	quest.description = description
	quest.requirements = requirements
	quest.reward_resources = rewards
	quest.chapter = chapter
	quest.completed = false
	quest.active = false
	quest.progress = {}
	for req in requirements:
		quest.progress[req] = 0
	return quest

func _start_initial_quests() -> void:
	# Start Chapter 1 main quests
	for quest in _quests[QuestType.MAIN]:
		if quest.chapter == 1:
			start_quest(quest)
	
	# Start first daily quest
	if _quests[QuestType.DAILY].size() > 0:
		start_quest(_quests[QuestType.DAILY][0])

func start_quest(quest: Quest) -> void:
	if quest.active or quest.completed:
		return
	
	quest.active = true
	if not _active_quests.has(quest):
		_active_quests.append(quest)
	
	quest_started.emit(quest)
	_show_notification("New Quest: " + quest.title)

func complete_quest(quest: Quest) -> void:
	if quest.completed:
		return
	
	quest.completed = true
	quest.active = false
	_completed_quest_ids.append(quest.quest_id)
	_active_quests.erase(quest)
	
	# Apply rewards
	var storage := _get_storage()
	if storage:
		for resource in quest.reward_resources:
			var amount: float = quest.reward_resources[resource]
			storage.deposit(resource, amount)
	
	quest_completed.emit(quest)
	_show_notification("Quest Complete: " + quest.title + "!")
	
	# Check if we should unlock next chapter quests
	_check_chapter_unlock()

func _check_chapter_unlock() -> void:
	var game_state := _get_game_state()
	if not game_state:
		return
	
	var current_chapter := game_state.get("current_chapter") if game_state.get("current_chapter") else 1
	
	# Check if all chapter quests are complete
	var chapter_complete := true
	for quest in _quests[QuestType.MAIN]:
		if quest.chapter == current_chapter and not quest.completed:
			chapter_complete = false
			break
	
	if chapter_complete:
		var next_chapter := current_chapter + 1
		if game_state.has_method("set_chapter"):
			game_state.set_chapter(next_chapter)
		
		# Start next chapter quests
		for quest in _quests[QuestType.MAIN]:
			if quest.chapter == next_chapter:
				start_quest(quest)
		
		_show_notification("Chapter %d Complete! Starting Chapter %d..." % [current_chapter, next_chapter])

func _refresh_daily_quests() -> void:
	# Reset daily quests
	for quest in _quests[QuestType.DAILY]:
		if quest.completed:
			quest.completed = false
			quest.active = false
			for key in quest.progress:
				quest.progress[key] = 0
	
	# Start a random daily quest
	var available_dailies: Array = []
	for quest in _quests[QuestType.DAILY]:
		if not quest.active:
			available_dailies.append(quest)
	
	if available_dailies.size() > 0:
		start_quest(available_dailies.pick_random())

func _on_action_recorded(action: String) -> void:
	# Map actions to quest progress
	var progress_map: Dictionary = {
		"gathered_food": ["food_gathered"],
		"gathered_wood": ["wood_gathered"],
		"gathered_stone": ["stone_gathered"],
		"built_building": ["buildings_built"],
		"researched_tech": ["techs_researched"],
		"discovered_ruins": ["ruins_discovered"],
		"tamed_animal": ["animals_tamed"],
		"met_tribe": ["met_nomads"],
		"explored_cave": ["cave_explored"],
		"slain_dragon": ["dragon_slain"],
		"allied_tribe": ["tribes_allied"],
		"built_wonder": ["wonder_built"],
		"discovered_secret": ["secrets_discovered"],
	}
	
	var progress_keys: Array = progress_map.get(action, [])
	for key in progress_keys:
		_increment_quest_progress(key, 1)

func _increment_quest_progress(key: String, amount: int) -> void:
	for quest in _active_quests:
		if quest.progress.has(key):
			quest.progress[key] += amount
			var max_val: int = quest.requirements.get(key, 1)
			var progress := float(quest.progress[key]) / float(max_val)
			quest_progress.emit(quest, clampf(progress, 0.0, 1.0))

func _update_quest_progress() -> void:
	var game_state := _get_game_state()
	var storage := _get_storage()
	
	for quest in _active_quests.duplicate():  # Duplicate to avoid modification during iteration
		if _check_quest_requirements(quest, game_state, storage):
			complete_quest(quest)

func _check_quest_requirements(quest: Quest, game_state: GameState, storage: Storage) -> bool:
	for req_key in quest.requirements:
		var required: int = quest.requirements[req_key]
		var current: int = 0
		
		# Check different requirement sources
		if req_key == "population":
			current = get_tree().get_nodes_in_group("villager").size()
		elif req_key.ends_with("_gathered") and storage:
			var resource_type := req_key.replace("_gathered", "")
			current = int(storage.get_amount(resource_type))
		elif quest.progress.has(req_key):
			current = quest.progress[req_key]
		elif game_state and game_state.has_method("get_stat"):
			current = game_state.get_stat(req_key)
		
		if current < required:
			return false
	
	return true

func _show_notification(text: String) -> void:
	var action_menu := get_tree().get_first_node_in_group("action_menu")
	if action_menu and action_menu.has_method("_show_notification"):
		action_menu._show_notification(text)

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state") as GameState

func _get_storage() -> Storage:
	return get_tree().get_first_node_in_group("storage") as Storage

# Public API
func get_active_quests() -> Array:
	return _active_quests.duplicate()

func get_quests_by_type(type: QuestType) -> Array:
	return _quests[type].duplicate()

func get_active_quests_text() -> String:
	var lines: Array[String] = ["Active Quests:"]
	
	for quest in _active_quests:
		var type_name: String = QUEST_TYPE_NAMES[quest.quest_type]
		var progress_text := _get_quest_progress_text(quest)
		lines.append("[%s] %s - %s" % [type_name, quest.title, progress_text])
	
	if lines.size() == 1:
		lines.append("No active quests.")
	
	return "\n".join(lines)

func _get_quest_progress_text(quest: Quest) -> String:
	var parts: Array[String] = []
	for req_key in quest.requirements:
		var required: int = quest.requirements[req_key]
		var current: int = quest.progress.get(req_key, 0)
		parts.append("%s: %d/%d" % [req_key.capitalize(), current, required])
	return ", ".join(parts) if parts.size() > 0 else quest.description

func is_quest_complete(quest_id: String) -> bool:
	return quest_id in _completed_quest_ids

func get_completed_count() -> int:
	return _completed_quest_ids.size()
