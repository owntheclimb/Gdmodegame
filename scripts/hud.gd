extends CanvasLayer

# References to HUD elements
@onready var resource_panel: PanelContainer = $ResourcePanel
@onready var food_label: Label = $ResourcePanel/VBox/FoodRow/Value
@onready var wood_label: Label = $ResourcePanel/VBox/WoodRow/Value
@onready var stone_label: Label = $ResourcePanel/VBox/StoneRow/Value
@onready var population_label: Label = $ResourcePanel/VBox/PopRow/Value

@onready var time_panel: PanelContainer = $TimePanel
@onready var day_label: Label = $TimePanel/VBox/DayLabel
@onready var time_label: Label = $TimePanel/VBox/TimeLabel

@onready var villager_panel: PanelContainer = $VillagerPanel
@onready var villager_name_label: Label = $VillagerPanel/VBox/NameLabel
@onready var villager_info_label: Label = $VillagerPanel/VBox/InfoLabel
@onready var villager_task_label: Label = $VillagerPanel/VBox/TaskLabel
@onready var health_bar: ProgressBar = $VillagerPanel/VBox/HealthBar
@onready var hunger_bar: ProgressBar = $VillagerPanel/VBox/HungerBar

@onready var controls_panel: PanelContainer = $ControlsPanel
@onready var minimap: SubViewportContainer = $MinimapContainer

var _selected_villager: Villager = null
var _controls_visible := true
var _controls_timer := 0.0

func _ready() -> void:
	add_to_group("hud")
	villager_panel.visible = false
	_setup_controls_fade()

func _process(delta: float) -> void:
	_update_resources()
	_update_time()
	_update_selected_villager()
	_update_controls_fade(delta)

func _update_resources() -> void:
	var storage := get_tree().get_first_node_in_group("storage")
	if storage:
		food_label.text = str(int(storage.get_amount("food")))
		wood_label.text = str(int(storage.get_amount("wood")))
		stone_label.text = str(int(storage.get_amount("stone")))
	else:
		food_label.text = "--"
		wood_label.text = "--"
		stone_label.text = "--"
	
	var villagers := get_tree().get_nodes_in_group("villager")
	population_label.text = str(villagers.size())

func _update_time() -> void:
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state:
		day_label.text = "Day %d" % game_state.days_survived
	else:
		day_label.text = "Day 1"
	
	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		var ratio: float = day_night.get_time_ratio()
		var hours := int(6 + ratio * 18) % 24
		var period := "AM" if hours < 12 else "PM"
		var display_hours := hours if hours <= 12 else hours - 12
		if display_hours == 0:
			display_hours = 12
		time_label.text = "%d:00 %s" % [display_hours, period]
	else:
		time_label.text = "12:00 PM"

func _update_selected_villager() -> void:
	var selection_manager := get_tree().get_first_node_in_group("selection_manager")
	if selection_manager and selection_manager.has_method("get_selected"):
		_selected_villager = selection_manager.get_selected()
	
	if _selected_villager and is_instance_valid(_selected_villager):
		villager_panel.visible = true
		villager_name_label.text = _selected_villager.get_display_name()
		villager_info_label.text = "%s, Age %d" % [_selected_villager.gender, _selected_villager.age]
		villager_task_label.text = "Task: %s" % [_selected_villager.current_task if _selected_villager.current_task else "Idle"]
		health_bar.value = _selected_villager.health
		hunger_bar.value = _selected_villager.hunger
	else:
		villager_panel.visible = false

func show_villager_info(villager: Villager) -> void:
	_selected_villager = villager

func _setup_controls_fade() -> void:
	_controls_timer = 8.0  # Show controls for 8 seconds initially

func _update_controls_fade(delta: float) -> void:
	if _controls_timer > 0:
		_controls_timer -= delta
		if _controls_timer <= 2.0:
			controls_panel.modulate.a = _controls_timer / 2.0
		if _controls_timer <= 0:
			controls_panel.visible = false

func _input(event: InputEvent) -> void:
	# Show controls again on F1
	if event.is_action_pressed("ui_help") or (event is InputEventKey and event.keycode == KEY_F1 and event.pressed):
		controls_panel.visible = true
		controls_panel.modulate.a = 1.0
		_controls_timer = 8.0
