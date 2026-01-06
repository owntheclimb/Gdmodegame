extends CanvasLayer

@onready var stats_label: Label = $MarginContainer/VBoxContainer/Stats
@onready var storage_label: Label = $MarginContainer/VBoxContainer/Storage
@onready var time_label: Label = $MarginContainer/VBoxContainer/Time

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
		var ratio := day_night.get_time_ratio()
		time_label.text = "Time: %.0f%% %s" % [ratio * 100.0, "Night" if day_night.is_night else "Day"]
	else:
		time_label.text = "Time: --"
