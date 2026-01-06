extends CanvasLayer

@onready var stats_label: Label = $MarginContainer/VBoxContainer/Stats
@onready var storage_label: Label = $MarginContainer/VBoxContainer/Storage
@onready var time_label: Label = $MarginContainer/VBoxContainer/Time
@onready var status_label: Label = $MarginContainer/VBoxContainer/Status
@onready var hint_label: Label = $MarginContainer/VBoxContainer/Hint
@onready var objectives_label: Label = $MarginContainer/VBoxContainer/Objectives
@onready var tech_label: Label = $MarginContainer/VBoxContainer/Tech
@onready var selected_label: Label = $MarginContainer/VBoxContainer/Selected

func _process(_delta: float) -> void:
	var villager := get_tree().get_first_node_in_group("villager")
	if villager:
		stats_label.text = "Health: %.0f  Hunger: %.0f  Energy: %.0f  Task: %s" % [
			villager.health,
			villager.hunger,
			villager.energy,
			villager.current_task
		]
	else:
		stats_label.text = "Health: --  Hunger: --  Energy: --  Task: --"

	var storage := get_tree().get_first_node_in_group("storage")
	if storage:
		storage_label.text = "Storage Food: %.0f  Wood: %.0f  Stone: %.0f" % [
			storage.get_amount("food"),
			storage.get_amount("wood"),
			storage.get_amount("stone")
		]
	else:
		storage_label.text = "Storage Food: --  Wood: --  Stone: --"

	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		var ratio := day_night.get_time_ratio()
		time_label.text = "Time: %.0f%% %s" % [ratio * 100.0, "Night" if day_night.is_night else "Day"]
	else:
		time_label.text = "Time: --"

	hint_label.text = "Right-click: Place building  |  Ctrl+S: Save  Ctrl+L: Load"

	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state:
		var population := get_tree().get_nodes_in_group("villager").size()
		var task_board := get_tree().get_first_node_in_group("task_board")
		var open_tasks := task_board.get_open_tasks().size() if task_board else 0
		if game_state.is_game_over:
			status_label.text = "Game Over - Survived %d days" % game_state.days_survived
		else:
			status_label.text = "Day: %d  Population: %d  Tasks: %d" % [game_state.days_survived, population, open_tasks]
	else:
		status_label.text = "Day: --  Population: --  Tasks: --"

	var objectives := get_tree().get_first_node_in_group("objective_manager")
	if objectives:
		objectives_label.text = "Objectives:\n%s" % objectives.get_objective_text()
	else:
		objectives_label.text = "Objectives:\n--"

	var tech_manager := get_tree().get_first_node_in_group("tech_manager")
	if tech_manager:
		tech_label.text = "Tech: %s" % ", ".join(tech_manager.tech_tree.unlocked)
	else:
		tech_label.text = "Tech: --"

	var selection_manager := get_tree().get_first_node_in_group("selection_manager")
	if selection_manager and selection_manager.selected:
		var selected := selection_manager.selected
		selected_label.text = "Selected: %s (H %.0f | Hu %.0f)" % [
			selected.name,
			selected.health,
			selected.hunger
		]
	else:
		selected_label.text = "Selected: --"
