extends CanvasLayer

@onready var stats_label: Label = $MarginContainer/VBoxContainer/Stats
@onready var storage_label: Label = $MarginContainer/VBoxContainer/Storage
@onready var time_label: Label = $MarginContainer/VBoxContainer/Time
@onready var story_label: Label = $MarginContainer/VBoxContainer/Story
@onready var quest_label: Label = $MarginContainer/VBoxContainer/Quests
@onready var faction_label: Label = $MarginContainer/VBoxContainer/Factions
@onready var world_label: Label = $MarginContainer/VBoxContainer/World

func _process(_delta: float) -> void:
	var villager := get_tree().get_first_node_in_group("villager")
	if villager:
		stats_label.text = "Health: %.0f  Hunger: %.0f  Task: %s" % [
			villager.health,
			villager.hunger,
			villager.current_task
		]
	else:
		stats_label.text = "Health: --  Hunger: --  Task: --"

	var storage := get_tree().get_first_node_in_group("storage")
	if storage:
		storage_label.text = "Storage Food: %.0f" % storage.get_amount("food")
	else:
		storage_label.text = "Storage Food: --"

	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		var ratio: float = day_night.get_time_ratio()
		time_label.text = "Time: %.0f%% %s" % [ratio * 100.0, "Night" if day_night.is_night else "Day"]
	else:
		time_label.text = "Time: --"

	var story_manager := get_tree().get_first_node_in_group("story_manager")
	if story_manager:
		story_label.text = story_manager.get_current_chapter_text()
	else:
		story_label.text = "Story: --"

	var quest_manager := get_tree().get_first_node_in_group("quest_manager")
	if quest_manager:
		quest_label.text = quest_manager.get_active_quests_text()
	else:
		quest_label.text = "Quests: --"

	var faction_manager := get_tree().get_first_node_in_group("faction_manager")
	if faction_manager:
		faction_label.text = faction_manager.get_summary_text()
	else:
		faction_label.text = "Factions: --"

	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state:
		world_label.text = "Biome: %s  Days: %d" % [game_state.current_biome.capitalize(), game_state.days_survived]
	else:
		world_label.text = "Biome: --"
