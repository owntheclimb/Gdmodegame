extends CanvasLayer
class_name CharacterPanel

## Detailed character stats panel with 6 tabs:
## Identity, Needs, Skills, Relationships, Genetics, History

signal panel_closed
signal villager_action(action: String, villager: Villager)

enum Tab { IDENTITY, NEEDS, SKILLS, RELATIONSHIPS, GENETICS, HISTORY }

const TAB_NAMES: Array[String] = ["Identity", "Needs", "Skills", "Relations", "Genetics", "History"]

# UI References
var _panel: PanelContainer
var _close_button: Button
var _tab_bar: HBoxContainer
var _tab_content: Control
var _current_tab: Tab = Tab.IDENTITY
var _action_bar: HBoxContainer

# Currently displayed villager
var _villager: Villager = null

# Tab content containers
var _tab_containers: Dictionary = {}

# Need bars for real-time updates
var _need_bars: Dictionary = {}

func _ready() -> void:
	add_to_group("character_panel")
	layer = 15
	_build_ui()
	visible = false

func _build_ui() -> void:
	# Main panel
	_panel = PanelContainer.new()
	_panel.name = "CharacterPanel"
	_panel.set_anchors_preset(Control.PRESET_CENTER)
	_panel.offset_left = -250
	_panel.offset_right = 250
	_panel.offset_top = -200
	_panel.offset_bottom = 200
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	style.border_color = Color(0.5, 0.45, 0.35)
	style.set_border_width_all(3)
	style.set_corner_radius_all(8)
	_panel.add_theme_stylebox_override("panel", style)
	
	var main_vbox := VBoxContainer.new()
	main_vbox.add_theme_constant_override("separation", 8)
	_panel.add_child(main_vbox)
	
	# Header with close button
	var header := HBoxContainer.new()
	main_vbox.add_child(header)
	
	var title := Label.new()
	title.text = "Villager Details"
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	title.add_theme_font_size_override("font_size", 18)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	_close_button = Button.new()
	_close_button.text = "✕"
	_close_button.custom_minimum_size = Vector2(30, 30)
	_close_button.pressed.connect(_on_close_pressed)
	header.add_child(_close_button)
	
	# Tab bar
	_tab_bar = HBoxContainer.new()
	_tab_bar.add_theme_constant_override("separation", 4)
	main_vbox.add_child(_tab_bar)
	
	for i in range(TAB_NAMES.size()):
		var tab_btn := Button.new()
		tab_btn.text = TAB_NAMES[i]
		tab_btn.toggle_mode = true
		tab_btn.button_pressed = (i == 0)
		tab_btn.custom_minimum_size = Vector2(70, 28)
		tab_btn.pressed.connect(_on_tab_pressed.bind(i))
		_tab_bar.add_child(tab_btn)
	
	# Tab content area
	_tab_content = Control.new()
	_tab_content.custom_minimum_size = Vector2(480, 280)
	_tab_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(_tab_content)
	
	# Create all tab containers
	_create_identity_tab()
	_create_needs_tab()
	_create_skills_tab()
	_create_relationships_tab()
	_create_genetics_tab()
	_create_history_tab()
	
	# Action bar at bottom
	_action_bar = HBoxContainer.new()
	_action_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_action_bar.add_theme_constant_override("separation", 10)
	main_vbox.add_child(_action_bar)
	
	_add_action_button("Assign", "assign")
	_add_action_button("Follow", "follow")
	_add_action_button("Prioritize", "prioritize")
	
	add_child(_panel)
	
	# Show first tab
	_show_tab(Tab.IDENTITY)

func _create_identity_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "IdentityTab"
	container.add_theme_constant_override("separation", 6)
	_tab_content.add_child(container)
	_tab_containers[Tab.IDENTITY] = container
	
	# Portrait placeholder
	var portrait_row := HBoxContainer.new()
	container.add_child(portrait_row)
	
	var portrait := ColorRect.new()
	portrait.color = Color(0.3, 0.3, 0.35)
	portrait.custom_minimum_size = Vector2(64, 64)
	portrait_row.add_child(portrait)
	
	var identity_info := VBoxContainer.new()
	identity_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	portrait_row.add_child(identity_info)
	
	var name_label := Label.new()
	name_label.name = "NameLabel"
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.add_theme_color_override("font_color", Color(1, 0.95, 0.8))
	identity_info.add_child(name_label)
	
	var age_gender_label := Label.new()
	age_gender_label.name = "AgeGenderLabel"
	identity_info.add_child(age_gender_label)
	
	var life_stage_label := Label.new()
	life_stage_label.name = "LifeStageLabel"
	life_stage_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.8))
	identity_info.add_child(life_stage_label)
	
	# Backstory
	var backstory_label := Label.new()
	backstory_label.name = "BackstoryLabel"
	backstory_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	backstory_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	container.add_child(backstory_label)
	
	# Current mood
	var mood_label := Label.new()
	mood_label.name = "MoodLabel"
	mood_label.add_theme_color_override("font_color", Color(0.9, 0.8, 0.5))
	container.add_child(mood_label)
	
	# Traits
	var traits_label := Label.new()
	traits_label.name = "TraitsLabel"
	traits_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	container.add_child(traits_label)

func _create_needs_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "NeedsTab"
	container.add_theme_constant_override("separation", 8)
	_tab_content.add_child(container)
	_tab_containers[Tab.NEEDS] = container
	
	var needs := ["Health", "Hunger", "Energy", "Happiness", "Social", "Comfort", "Safety", "Purpose"]
	var colors := [
		Color(0.9, 0.3, 0.3),   # Health - red
		Color(0.9, 0.6, 0.3),   # Hunger - orange
		Color(0.3, 0.7, 0.9),   # Energy - cyan
		Color(0.9, 0.9, 0.3),   # Happiness - yellow
		Color(0.9, 0.5, 0.7),   # Social - pink
		Color(0.6, 0.5, 0.9),   # Comfort - purple
		Color(0.5, 0.9, 0.5),   # Safety - green
		Color(0.7, 0.7, 0.9),   # Purpose - light blue
	]
	
	for i in range(needs.size()):
		var row := HBoxContainer.new()
		container.add_child(row)
		
		var label := Label.new()
		label.text = needs[i] + ":"
		label.custom_minimum_size = Vector2(80, 0)
		label.add_theme_color_override("font_color", colors[i])
		row.add_child(label)
		
		var bar := ProgressBar.new()
		bar.name = needs[i] + "Bar"
		bar.max_value = 100.0
		bar.value = 50.0
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.custom_minimum_size = Vector2(0, 20)
		bar.show_percentage = false
		row.add_child(bar)
		
		var value_label := Label.new()
		value_label.name = needs[i] + "Value"
		value_label.custom_minimum_size = Vector2(40, 0)
		value_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		row.add_child(value_label)
		
		_need_bars[needs[i].to_lower()] = {"bar": bar, "label": value_label}

func _create_skills_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "SkillsTab"
	container.add_theme_constant_override("separation", 6)
	_tab_content.add_child(container)
	_tab_containers[Tab.SKILLS] = container
	
	var title := Label.new()
	title.text = "Skill System (Coming Soon)"
	title.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	container.add_child(title)
	
	var skills := ["Farming", "Building", "Research", "Combat", "Social", "Survival"]
	for skill in skills:
		var row := HBoxContainer.new()
		container.add_child(row)
		
		var label := Label.new()
		label.text = skill + ":"
		label.custom_minimum_size = Vector2(80, 0)
		row.add_child(label)
		
		var bar := ProgressBar.new()
		bar.name = skill + "SkillBar"
		bar.max_value = 100.0
		bar.value = randi_range(1, 30)  # Placeholder
		bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		bar.show_percentage = false
		row.add_child(bar)
		
		var level_label := Label.new()
		level_label.text = "Lv. %d" % int(bar.value / 10 + 1)
		level_label.custom_minimum_size = Vector2(50, 0)
		row.add_child(level_label)

func _create_relationships_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "RelationshipsTab"
	container.add_theme_constant_override("separation", 6)
	_tab_content.add_child(container)
	_tab_containers[Tab.RELATIONSHIPS] = container
	
	var title := Label.new()
	title.text = "Relationships"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	container.add_child(title)
	
	var relations_list := VBoxContainer.new()
	relations_list.name = "RelationsList"
	container.add_child(relations_list)

func _create_genetics_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "GeneticsTab"
	container.add_theme_constant_override("separation", 6)
	_tab_content.add_child(container)
	_tab_containers[Tab.GENETICS] = container
	
	var title := Label.new()
	title.text = "Genetics & Heredity"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	container.add_child(title)
	
	var traits_section := VBoxContainer.new()
	traits_section.name = "TraitsSection"
	container.add_child(traits_section)
	
	var traits_title := Label.new()
	traits_title.text = "Inherited Traits:"
	traits_section.add_child(traits_title)
	
	var traits_list := VBoxContainer.new()
	traits_list.name = "TraitsList"
	traits_section.add_child(traits_list)
	
	var mutations_title := Label.new()
	mutations_title.text = "\nMutations:"
	container.add_child(mutations_title)
	
	var mutations_list := VBoxContainer.new()
	mutations_list.name = "MutationsList"
	container.add_child(mutations_list)

func _create_history_tab() -> void:
	var container := VBoxContainer.new()
	container.name = "HistoryTab"
	container.add_theme_constant_override("separation", 6)
	_tab_content.add_child(container)
	_tab_containers[Tab.HISTORY] = container
	
	var title := Label.new()
	title.text = "Life Events"
	title.add_theme_font_size_override("font_size", 14)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	container.add_child(title)
	
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	container.add_child(scroll)
	
	var events_list := VBoxContainer.new()
	events_list.name = "EventsList"
	scroll.add_child(events_list)

func _add_action_button(text: String, action_id: String) -> void:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(80, 30)
	btn.pressed.connect(_on_action_pressed.bind(action_id))
	_action_bar.add_child(btn)

func _on_tab_pressed(tab_index: int) -> void:
	_show_tab(tab_index as Tab)
	
	# Update tab button states
	for i in range(_tab_bar.get_child_count()):
		var btn: Button = _tab_bar.get_child(i)
		btn.button_pressed = (i == tab_index)

func _show_tab(tab: Tab) -> void:
	_current_tab = tab
	
	for t in _tab_containers:
		_tab_containers[t].visible = (t == tab)

func _on_close_pressed() -> void:
	hide_panel()

func _on_action_pressed(action_id: String) -> void:
	if _villager:
		villager_action.emit(action_id, _villager)

func show_villager(villager: Villager) -> void:
	_villager = villager
	visible = true
	_update_all_tabs()

func hide_panel() -> void:
	visible = false
	_villager = null
	panel_closed.emit()

func _update_all_tabs() -> void:
	if not _villager:
		return
	
	_update_identity_tab()
	_update_needs_tab()
	_update_relationships_tab()
	_update_genetics_tab()
	_update_history_tab()

func _update_identity_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.IDENTITY]
	
	var name_label := container.get_node("HBoxContainer/VBoxContainer/NameLabel") if container.has_node("HBoxContainer/VBoxContainer/NameLabel") else null
	if not name_label:
		# Find labels by traversing
		for child in container.get_children():
			if child is HBoxContainer:
				for subchild in child.get_children():
					if subchild is VBoxContainer:
						for label in subchild.get_children():
							if label.name == "NameLabel":
								label.text = _villager.get_display_name()
							elif label.name == "AgeGenderLabel":
								label.text = "%s, Age %d" % [_villager.gender, _villager.age]
							elif label.name == "LifeStageLabel":
								label.text = _get_life_stage(_villager.age)
			elif child.name == "BackstoryLabel":
				child.text = _generate_backstory()
			elif child.name == "MoodLabel":
				var mood := _get_mood_text(_villager.happiness)
				child.text = "Mood: " + mood
			elif child.name == "TraitsLabel":
				var trait_text := "Traits: "
				if _villager.traits.size() > 0:
					var names: Array[String] = []
					for t in _villager.traits:
						if t and t.display_name:
							names.append(t.display_name)
					trait_text += ", ".join(names) if names.size() > 0 else "None"
				else:
					trait_text += "None"
				child.text = trait_text

func _update_needs_tab() -> void:
	if not _villager:
		return
	
	var needs := _villager.get_needs_summary() if _villager.has_method("get_needs_summary") else {}
	
	for need_name in _need_bars:
		var value: float = needs.get(need_name, 50.0)
		var bar_info: Dictionary = _need_bars[need_name]
		var bar: ProgressBar = bar_info.bar
		var label: Label = bar_info.label
		
		bar.value = value
		label.text = "%d%%" % int(value)
		
		# Color based on value
		if value < 20:
			bar.modulate = Color(1, 0.3, 0.3)
		elif value < 40:
			bar.modulate = Color(1, 0.7, 0.3)
		else:
			bar.modulate = Color.WHITE

func _update_relationships_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.RELATIONSHIPS]
	var relations_list := container.get_node_or_null("RelationsList")
	if not relations_list:
		return
	
	# Clear existing
	for child in relations_list.get_children():
		child.queue_free()
	
	# For now, show placeholder
	var placeholder := Label.new()
	placeholder.text = "No relationships yet..."
	placeholder.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	relations_list.add_child(placeholder)

func _update_genetics_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.GENETICS]
	var traits_list := container.get_node_or_null("TraitsSection/TraitsList")
	if traits_list:
		for child in traits_list.get_children():
			child.queue_free()
		
		if _villager.traits.size() > 0:
			for t in _villager.traits:
				if t:
					var label := Label.new()
					label.text = "• %s" % (t.display_name if t.display_name else "Unknown")
					traits_list.add_child(label)
		else:
			var label := Label.new()
			label.text = "No inherited traits"
			label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
			traits_list.add_child(label)

func _update_history_tab() -> void:
	var container: VBoxContainer = _tab_containers[Tab.HISTORY]
	var events_list := container.get_node_or_null("ScrollContainer/EventsList")
	if not events_list:
		return
	
	for child in events_list.get_children():
		child.queue_free()
	
	# Placeholder events
	var events := [
		"Born on Day 1",
		"Joined the village",
	]
	
	for event_text in events:
		var label := Label.new()
		label.text = "• " + event_text
		events_list.add_child(label)

func _get_life_stage(villager_age: int) -> String:
	if villager_age < 5:
		return "Baby"
	elif villager_age < 13:
		return "Child"
	elif villager_age < 18:
		return "Teenager"
	elif villager_age < 40:
		return "Adult"
	elif villager_age < 60:
		return "Middle-aged"
	else:
		return "Elder"

func _get_mood_text(happiness: float) -> String:
	if happiness >= 90:
		return "Ecstatic 😄"
	elif happiness >= 70:
		return "Happy 🙂"
	elif happiness >= 50:
		return "Content 😐"
	elif happiness >= 30:
		return "Unhappy 😕"
	else:
		return "Miserable 😢"

func _generate_backstory() -> String:
	var backstories := [
		"A survivor from the shipwreck, determined to build a new life.",
		"Found wandering the island, with no memory of the past.",
		"Born in the village, full of hope for the future.",
		"A skilled worker who dreams of a peaceful settlement.",
	]
	return backstories[_villager.get_instance_id() % backstories.size()]

func _process(_delta: float) -> void:
	# Real-time need updates when visible
	if visible and _villager and _current_tab == Tab.NEEDS:
		_update_needs_tab()

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		hide_panel()
		get_viewport().set_input_as_handled()
