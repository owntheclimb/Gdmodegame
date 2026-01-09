extends CanvasLayer
class_name TechTreeUI

## Visual Tech Tree UI with era columns and research progress

signal tech_selected(tech_id: String)
signal research_started(tech_id: String)

const ERA_COLORS: Dictionary = {
	0: Color(0.6, 0.4, 0.2),      # Survival - Brown
	1: Color(0.4, 0.6, 0.3),      # Settlement - Green
	2: Color(0.3, 0.5, 0.7),      # Development - Blue
	3: Color(0.6, 0.4, 0.7),      # Advancement - Purple
	4: Color(0.8, 0.7, 0.3),      # Civilization - Gold
}

const ERA_NAMES: Array[String] = ["Survival", "Settlement", "Development", "Advancement", "Civilization"]

var _panel: PanelContainer
var _close_button: Button
var _era_columns: Array[VBoxContainer] = []
var _tech_buttons: Dictionary = {}  # tech_id -> Button
var _selected_tech: String = ""
var _info_panel: PanelContainer

func _ready() -> void:
	add_to_group("tech_tree_ui")
	layer = 20
	_build_ui()
	visible = false

func _build_ui() -> void:
	# Main panel covering most of screen
	_panel = PanelContainer.new()
	_panel.name = "TechTreePanel"
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 50
	_panel.offset_right = -50
	_panel.offset_top = 50
	_panel.offset_bottom = -50
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.08, 0.08, 0.1, 0.95)
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
	title.text = "📚 Technology Tree"
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	title.add_theme_font_size_override("font_size", 24)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	_close_button = Button.new()
	_close_button.text = "✕ Close"
	_close_button.custom_minimum_size = Vector2(80, 30)
	_close_button.pressed.connect(hide_tree)
	header.add_child(_close_button)
	
	# Era progress bar
	var era_progress := HBoxContainer.new()
	era_progress.add_theme_constant_override("separation", 4)
	main_vbox.add_child(era_progress)
	
	for i in range(5):
		var era_box := VBoxContainer.new()
		era_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		era_progress.add_child(era_box)
		
		var era_label := Label.new()
		era_label.text = ERA_NAMES[i]
		era_label.add_theme_color_override("font_color", ERA_COLORS[i])
		era_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		era_box.add_child(era_label)
		
		var era_bar := ProgressBar.new()
		era_bar.name = "Era%dBar" % i
		era_bar.max_value = 1.0
		era_bar.value = 0.0
		era_bar.custom_minimum_size = Vector2(0, 8)
		era_bar.show_percentage = false
		era_box.add_child(era_bar)
	
	# Scroll container for tech columns
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	main_vbox.add_child(scroll)
	
	var columns_container := HBoxContainer.new()
	columns_container.add_theme_constant_override("separation", 20)
	scroll.add_child(columns_container)
	
	# Create era columns
	for i in range(5):
		var column := _create_era_column(i)
		columns_container.add_child(column)
		_era_columns.append(column)
	
	# Info panel at bottom
	_info_panel = PanelContainer.new()
	_info_panel.custom_minimum_size = Vector2(0, 100)
	main_vbox.add_child(_info_panel)
	
	var info_style := StyleBoxFlat.new()
	info_style.bg_color = Color(0.12, 0.12, 0.15, 0.9)
	info_style.set_border_width_all(1)
	info_style.border_color = Color(0.3, 0.3, 0.35)
	_info_panel.add_theme_stylebox_override("panel", info_style)
	
	var info_content := VBoxContainer.new()
	info_content.name = "InfoContent"
	_info_panel.add_child(info_content)
	
	var info_title := Label.new()
	info_title.name = "InfoTitle"
	info_title.text = "Select a technology to see details"
	info_title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	info_content.add_child(info_title)
	
	var info_desc := Label.new()
	info_desc.name = "InfoDesc"
	info_desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	info_content.add_child(info_desc)
	
	var research_btn := Button.new()
	research_btn.name = "ResearchButton"
	research_btn.text = "Begin Research"
	research_btn.visible = false
	research_btn.pressed.connect(_on_research_pressed)
	info_content.add_child(research_btn)
	
	add_child(_panel)

func _create_era_column(era: int) -> VBoxContainer:
	var column := VBoxContainer.new()
	column.name = "Era%dColumn" % era
	column.custom_minimum_size = Vector2(180, 0)
	column.add_theme_constant_override("separation", 8)
	
	# Era header
	var header := PanelContainer.new()
	var header_style := StyleBoxFlat.new()
	header_style.bg_color = ERA_COLORS[era].darkened(0.5)
	header_style.set_corner_radius_all(4)
	header.add_theme_stylebox_override("panel", header_style)
	column.add_child(header)
	
	var header_label := Label.new()
	header_label.text = ERA_NAMES[era]
	header_label.add_theme_color_override("font_color", ERA_COLORS[era].lightened(0.3))
	header_label.add_theme_font_size_override("font_size", 16)
	header_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	header.add_child(header_label)
	
	return column

func show_tree() -> void:
	visible = true
	_refresh_techs()

func hide_tree() -> void:
	visible = false

func _refresh_techs() -> void:
	var tech_tree := get_tree().get_first_node_in_group("tech_tree")
	if not tech_tree:
		return
	
	# Clear existing tech buttons
	for button in _tech_buttons.values():
		button.queue_free()
	_tech_buttons.clear()
	
	# Add techs to columns
	for tech in tech_tree.get_all_techs().values():
		var column := _era_columns[tech.era]
		var btn := _create_tech_button(tech, tech_tree)
		column.add_child(btn)
		_tech_buttons[tech.id] = btn
	
	# Update era progress
	for i in range(5):
		var bar: ProgressBar = _panel.get_node_or_null("VBoxContainer/HBoxContainer/VBoxContainer%d/Era%dBar" % [i, i])
		# Progress bars would be updated here

func _create_tech_button(tech, tech_tree) -> Button:
	var btn := Button.new()
	btn.text = tech.name
	btn.custom_minimum_size = Vector2(160, 40)
	btn.tooltip_text = tech.description
	
	# Style based on state
	var style := StyleBoxFlat.new()
	style.set_corner_radius_all(4)
	style.set_border_width_all(2)
	
	if tech.researched:
		style.bg_color = ERA_COLORS[tech.era].darkened(0.2)
		style.border_color = ERA_COLORS[tech.era]
		btn.modulate = Color(1, 1, 1, 1)
	elif tech_tree.is_tech_available(tech.id):
		style.bg_color = Color(0.2, 0.2, 0.25)
		style.border_color = ERA_COLORS[tech.era].darkened(0.3)
		btn.modulate = Color(1, 1, 1, 1)
	else:
		style.bg_color = Color(0.15, 0.15, 0.18)
		style.border_color = Color(0.3, 0.3, 0.35)
		btn.modulate = Color(0.6, 0.6, 0.6, 0.8)
	
	btn.add_theme_stylebox_override("normal", style)
	btn.pressed.connect(_on_tech_selected.bind(tech.id))
	
	return btn

func _on_tech_selected(tech_id: String) -> void:
	_selected_tech = tech_id
	tech_selected.emit(tech_id)
	_update_info_panel(tech_id)

func _update_info_panel(tech_id: String) -> void:
	var tech_tree := get_tree().get_first_node_in_group("tech_tree")
	if not tech_tree:
		return
	
	var tech = tech_tree.get_tech(tech_id)
	if not tech:
		return
	
	var info_content := _info_panel.get_node_or_null("InfoContent")
	if not info_content:
		return
	
	var title: Label = info_content.get_node_or_null("InfoTitle")
	var desc: Label = info_content.get_node_or_null("InfoDesc")
	var btn: Button = info_content.get_node_or_null("ResearchButton")
	
	if title:
		title.text = tech.name
		title.add_theme_color_override("font_color", ERA_COLORS[tech.era])
	
	if desc:
		var text := tech.description + "\n"
		text += "Cost: %d research points\n" % tech.research_cost
		if tech.prerequisites.size() > 0:
			text += "Requires: %s\n" % ", ".join(tech.prerequisites)
		if tech.unlocks_buildings.size() > 0:
			text += "Unlocks: %s\n" % ", ".join(tech.unlocks_buildings)
		desc.text = text
	
	if btn:
		btn.visible = tech_tree.is_tech_available(tech_id) and not tech.researched
		btn.disabled = not tech_tree.is_tech_available(tech_id)

func _on_research_pressed() -> void:
	if _selected_tech.is_empty():
		return
	
	var tech_tree := get_tree().get_first_node_in_group("tech_tree")
	if tech_tree and tech_tree.start_research(_selected_tech):
		research_started.emit(_selected_tech)
		_refresh_techs()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_tree()
		get_viewport().set_input_as_handled()
