extends CanvasLayer
class_name ManagementPanel

## Management Screens for population, resources, tasks, and diplomacy

signal tab_changed(tab: int)

enum Tab { POPULATION, RESOURCES, TASKS, DIPLOMACY, SETTINGS }

const TAB_NAMES: Array[String] = ["Population", "Resources", "Tasks", "Diplomacy", "Settings"]
const TAB_ICONS: Array[String] = ["👥", "📦", "📋", "🤝", "⚙️"]

var _panel: PanelContainer
var _close_button: Button
var _tab_bar: HBoxContainer
var _tab_content: Control
var _current_tab: Tab = Tab.POPULATION
var _tab_containers: Dictionary = {}

func _ready() -> void:
	add_to_group("management_panel")
	layer = 18
	_build_ui()
	visible = false

func _build_ui() -> void:
	_panel = PanelContainer.new()
	_panel.name = "ManagementPanel"
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 80
	_panel.offset_right = -80
	_panel.offset_top = 60
	_panel.offset_bottom = -60
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	style.border_color = Color(0.5, 0.45, 0.35)
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 10)
	_panel.add_child(main_vbox)
	
	# Header
	var header := HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title := Label.new()
	title.text = "📊 Village Management"
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	title.add_theme_font_size_override("font_size", 22)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	_close_button = Button.new()
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(30, 30)
	_close_button.pressed.connect(hide_panel)
	header.add_child(_close_button)
	
	# Tab bar
	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 8)
	main_vbox.add_child(_tab_bar)
	
	for i in range(TAB_NAMES.size()):
		var tab_btn := Button.new()
		tab_btn.text = "%s %s" % [TAB_ICONS[i], TAB_NAMES[i]]
		tab_btn.toggle_mode = true
		tab_btn.button_pressed = (i == 0)
		tab_btn.custom_minimum_size = Vector2(100, 35)
		tab_btn.pressed.connect(_on_tab_pressed.bind(i))
		_tab_bar.add_child(tab_btn)
	
	# Tab content
	_tab_content = Control.new()
	_tab_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_tab_content)
	
	# Create all tabs
	_create_population_tab()
	_create_resources_tab()
	_create_tasks_tab()
	_create_diplomacy_tab()
	_create_settings_tab()
	
	add_child(_panel)
	_show_tab(Tab.POPULATION)

func _create_population_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "PopulationTab"
	container.add_theme_constant_override("separation", 8)
	_tab_content.add_child(container)
	_tab_containers[Tab.POPULATION] = container
	
	# Stats header
	var stats := HBoxContainer.new()
	container.add_child(stats)
	
	var pop_label := Label.new()
	pop_label.name = "PopulationCount"
	pop_label.add_theme_font_size_override("font_size", 16)
	stats.add_child(pop_label)
	
	# Scroll for villager list
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)
	
	var list := VBoxContainer.new()
	list.name = "VillagerList"
	list.add_theme_constant_override("separation", 4)
	scroll.add_child(list)

func _create_resources_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "ResourcesTab"
	container.add_theme_constant_override("separation", 8)
	_tab_content.add_child(container)
	_tab_containers[Tab.RESOURCES] = container
	
	# Resource summary
	var title := Label.new()
	title.text = "Resource Inventory"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	var grid := GridContainer.new()
	grid.name = "ResourceGrid"
	grid.columns = 4
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 8)
	container.add_child(grid)
	
	# Production rates
	var prod_title := Label.new()
	prod_title.text = "\nProduction Rates"
	prod_title.add_theme_font_size_override("font_size", 16)
	container.add_child(prod_title)
	
	var prod_grid := GridContainer.new()
	prod_grid.name = "ProductionGrid"
	prod_grid.columns = 3
	container.add_child(prod_grid)

func _create_tasks_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "TasksTab"
	container.add_theme_constant_override("separation", 8)
	_tab_content.add_child(container)
	_tab_containers[Tab.TASKS] = container
	
	var title := Label.new()
	title.text = "Task Queue"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)
	
	var list := VBoxContainer.new()
	list.name = "TaskList"
	scroll.add_child(list)

func _create_diplomacy_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "DiplomacyTab"
	container.add_theme_constant_override("separation", 8)
	_tab_content.add_child(container)
	_tab_containers[Tab.DIPLOMACY] = container
	
	var title := Label.new()
	title.text = "Faction Relations"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	var factions_list := VBoxContainer.new()
	factions_list.name = "FactionsList"
	container.add_child(factions_list)

func _create_settings_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "SettingsTab"
	container.add_theme_constant_override("separation", 12)
	_tab_content.add_child(container)
	_tab_containers[Tab.SETTINGS] = container
	
	var title := Label.new()
	title.text = "Game Settings"
	title.add_theme_font_size_override("font_size", 16)
	container.add_child(title)
	
	# Game speed
	var speed_row := HBoxContainer.new()
	container.add_child(speed_row)
	var speed_label := Label.new()
	speed_label.text = "Game Speed:"
	speed_row.add_child(speed_label)
	var speed_slider := HSlider.new()
	speed_slider.min_value = 0.5
	speed_slider.max_value = 3.0
	speed_slider.value = 1.0
	speed_slider.custom_minimum_size = Vector2(200, 0)
	speed_row.add_child(speed_slider)
	
	# Auto-save toggle
	var autosave_row := HBoxContainer.new()
	container.add_child(autosave_row)
	var autosave_label := Label.new()
	autosave_label.text = "Auto-Save:"
	autosave_row.add_child(autosave_label)
	var autosave_check := CheckBox.new()
	autosave_check.button_pressed = true
	autosave_row.add_child(autosave_check)
	
	# Buttons
	var button_row := HBoxContainer.new()
	button_row.add_theme_constant_override("separation", 10)
	container.add_child(button_row)
	
	var save_btn := Button.new()
	save_btn.text = "Save Game"
	save_btn.custom_minimum_size = Vector2(120, 35)
	button_row.add_child(save_btn)
	
	var load_btn := Button.new()
	load_btn.text = "Load Game"
	load_btn.custom_minimum_size = Vector2(120, 35)
	button_row.add_child(load_btn)

func _on_tab_pressed(tab_index: int) -> void:
	_show_tab(tab_index as Tab)
	
	for i in range(_tab_bar.get_child_count()):
		var btn: Button = _tab_bar.get_child(i)
		btn.button_pressed = (i == tab_index)

func _show_tab(tab: Tab) -> void:
	_current_tab = tab
	tab_changed.emit(tab)
	
	for t in _tab_containers:
		_tab_containers[t].visible = (t == tab)
	
	# Refresh current tab
	match tab:
		Tab.POPULATION:
			_refresh_population_tab()
		Tab.RESOURCES:
			_refresh_resources_tab()
		Tab.TASKS:
			_refresh_tasks_tab()
		Tab.DIPLOMACY:
			_refresh_diplomacy_tab()

func _refresh_population_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.POPULATION]
	var pop_label: Label = container.get_node_or_null("HBoxContainer/PopulationCount")
	var list: VBoxContainer = container.get_node_or_null("ScrollContainer/VillagerList")
	
	var villagers := get_tree().get_nodes_in_group("villager")
	
	if pop_label:
		pop_label.text = "Total Population: %d" % villagers.size()
	
	if list:
		for child in list.get_children():
			child.queue_free()
		
		for villager in villagers:
			var row := HBoxContainer.new()
			list.add_child(row)
			
			var name_label := Label.new()
			name_label.text = villager.get_display_name() if villager.has_method("get_display_name") else "Villager"
			name_label.custom_minimum_size = Vector2(150, 0)
			row.add_child(name_label)
			
			var info_label := Label.new()
			info_label.text = "%s, Age %d" % [villager.gender, villager.age]
			info_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
			row.add_child(info_label)

func _refresh_resources_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.RESOURCES]
	var grid: GridContainer = container.get_node_or_null("ResourceGrid")
	
	if not grid:
		return
	
	for child in grid.get_children():
		child.queue_free()
	
	var storage := get_tree().get_first_node_in_group("storage")
	if not storage:
		return
	
	var resources := ["food", "wood", "stone", "gold"]
	for resource in resources:
		var label := Label.new()
		label.text = "%s:" % resource.capitalize()
		grid.add_child(label)
		
		var value := Label.new()
		var amount: float = storage.get_amount(resource) if storage.has_method("get_amount") else 0.0
		value.text = str(int(amount))
		grid.add_child(value)

func _refresh_tasks_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.TASKS]
	var list: VBoxContainer = container.get_node_or_null("ScrollContainer/TaskList")
	
	if not list:
		return
	
	for child in list.get_children():
		child.queue_free()
	
	var task_board := get_tree().get_first_node_in_group("task_board")
	if not task_board:
		var no_tasks := Label.new()
		no_tasks.text = "No pending tasks"
		list.add_child(no_tasks)
		return

func _refresh_diplomacy_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.DIPLOMACY]
	var factions_list: VBoxContainer = container.get_node_or_null("FactionsList")
	
	if not factions_list:
		return
	
	for child in factions_list.get_children():
		child.queue_free()
	
	# Placeholder factions
	var factions := [
		{"name": "Golden Nomads", "relation": 50, "stance": "Neutral"},
		{"name": "Forest Guardians", "relation": 30, "stance": "Wary"},
		{"name": "Mountain Clans", "relation": 20, "stance": "Hostile"},
	]
	
	for faction in factions:
		var row := HBoxContainer.new()
		factions_list.add_child(row)
		
		var name_label := Label.new()
		name_label.text = faction.name
		name_label.custom_minimum_size = Vector2(150, 0)
		row.add_child(name_label)
		
		var bar := ProgressBar.new()
		bar.max_value = 100
		bar.value = faction.relation
		bar.custom_minimum_size = Vector2(100, 15)
		bar.show_percentage = false
		row.add_child(bar)
		
		var stance_label := Label.new()
		stance_label.text = faction.stance
		stance_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		row.add_child(stance_label)

func show_panel() -> void:
	visible = true
	_refresh_population_tab()

func hide_panel() -> void:
	visible = false

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_panel()
		get_viewport().set_input_as_handled()
	
	# M key to toggle
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if visible:
			hide_panel()
		else:
			show_panel()
