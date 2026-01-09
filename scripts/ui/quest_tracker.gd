extends CanvasLayer
class_name QuestTracker

## Quest Tracker UI - Shows active quests in a collapsible panel

var _panel: PanelContainer
var _toggle_button: Button
var _quest_list: VBoxContainer
var _is_collapsed := false

# Quest type colors
const TYPE_COLORS: Dictionary = {
	0: Color(1.0, 0.85, 0.3),      # Main - Gold
	1: Color(0.5, 0.8, 1.0),       # Side - Blue
	2: Color(0.6, 0.9, 0.6),       # Daily - Green
	3: Color(0.9, 0.4, 0.9),       # Legendary - Purple
}

const TYPE_ICONS: Dictionary = {
	0: "📜",  # Main
	1: "📋",  # Side
	2: "📆",  # Daily
	3: "⭐",  # Legendary
}

func _ready() -> void:
	add_to_group("quest_tracker")
	layer = 8
	_build_ui()
	
	# Connect to quest manager
	var quest_manager := get_tree().get_first_node_in_group("quest_manager")
	if quest_manager:
		if quest_manager.has_signal("quest_started"):
			quest_manager.quest_started.connect(_on_quest_started)
		if quest_manager.has_signal("quest_completed"):
			quest_manager.quest_completed.connect(_on_quest_completed)
		if quest_manager.has_signal("quest_progress"):
			quest_manager.quest_progress.connect(_on_quest_progress)

func _build_ui() -> void:
	# Toggle button in top-right
	_toggle_button = Button.new()
	_toggle_button.text = "📋 Quests"
	_toggle_button.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_toggle_button.offset_left = -100
	_toggle_button.offset_top = 80
	_toggle_button.offset_right = -10
	_toggle_button.offset_bottom = 110
	_toggle_button.pressed.connect(_toggle_panel)
	add_child(_toggle_button)
	
	# Quest panel
	_panel = PanelContainer.new()
	_panel.name = "QuestPanel"
	_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_panel.offset_left = -280
	_panel.offset_top = 80
	_panel.offset_right = -10
	_panel.offset_bottom = 350
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.92)
	style.border_color = Color(0.5, 0.45, 0.35)
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	_panel.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	_panel.add_child(vbox)
	
	# Header
	var header := HBoxContainer.new()
	vbox.add_child(header)
	
	var title := Label.new()
	title.text = "📋 Active Quests"
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	title.add_theme_font_size_override("font_size", 14)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	var collapse_btn := Button.new()
	collapse_btn.text = "−"
	collapse_btn.custom_minimum_size = Vector2(24, 24)
	collapse_btn.pressed.connect(_toggle_panel)
	header.add_child(collapse_btn)
	
	# Scroll container for quests
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	vbox.add_child(scroll)
	
	_quest_list = VBoxContainer.new()
	_quest_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_quest_list)
	
	add_child(_panel)
	
	# Initially show toggle, hide panel
	_panel.visible = false
	_is_collapsed = true

func _toggle_panel() -> void:
	_is_collapsed = not _is_collapsed
	_panel.visible = not _is_collapsed
	_toggle_button.visible = _is_collapsed
	
	if not _is_collapsed:
		_refresh_quest_list()

func _refresh_quest_list() -> void:
	# Clear existing
	for child in _quest_list.get_children():
		child.queue_free()
	
	var quest_manager := get_tree().get_first_node_in_group("quest_manager")
	if not quest_manager:
		_add_no_quests_label()
		return
	
	var active_quests: Array = quest_manager.get_active_quests() if quest_manager.has_method("get_active_quests") else []
	
	if active_quests.is_empty():
		_add_no_quests_label()
		return
	
	for quest in active_quests:
		_add_quest_entry(quest)

func _add_no_quests_label() -> void:
	var label := Label.new()
	label.text = "No active quests"
	label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_quest_list.add_child(label)

func _add_quest_entry(quest: Quest) -> void:
	var entry := VBoxContainer.new()
	entry.name = "Quest_" + quest.quest_id
	
	# Quest header with type icon and title
	var header := HBoxContainer.new()
	entry.add_child(header)
	
	var icon := Label.new()
	icon.text = TYPE_ICONS.get(quest.quest_type, "📋")
	header.add_child(icon)
	
	var title := Label.new()
	title.text = quest.title
	title.add_theme_color_override("font_color", TYPE_COLORS.get(quest.quest_type, Color.WHITE))
	title.add_theme_font_size_override("font_size", 13)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	
	# Description
	var desc := Label.new()
	desc.text = quest.description
	desc.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	desc.add_theme_font_size_override("font_size", 11)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD
	entry.add_child(desc)
	
	# Progress bar
	var progress_bar := ProgressBar.new()
	progress_bar.max_value = 1.0
	progress_bar.value = quest.get_progress_percent() if quest.has_method("get_progress_percent") else 0.0
	progress_bar.custom_minimum_size = Vector2(0, 12)
	progress_bar.show_percentage = false
	entry.add_child(progress_bar)
	
	# Requirements text
	var req_text := Label.new()
	req_text.text = quest.get_requirement_text() if quest.has_method("get_requirement_text") else ""
	req_text.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	req_text.add_theme_font_size_override("font_size", 10)
	entry.add_child(req_text)
	
	# Separator
	var sep := HSeparator.new()
	sep.modulate = Color(0.3, 0.3, 0.35)
	entry.add_child(sep)
	
	_quest_list.add_child(entry)

func _on_quest_started(quest: Quest) -> void:
	if not _is_collapsed:
		_refresh_quest_list()
	
	# Flash the toggle button
	var tween := create_tween()
	tween.tween_property(_toggle_button, "modulate", Color(1.5, 1.5, 0.5), 0.2)
	tween.tween_property(_toggle_button, "modulate", Color.WHITE, 0.3)

func _on_quest_completed(_quest: Quest) -> void:
	if not _is_collapsed:
		_refresh_quest_list()

func _on_quest_progress(_quest: Quest, _progress: float) -> void:
	if not _is_collapsed:
		_refresh_quest_list()

func _input(event: InputEvent) -> void:
	# Toggle with Q key
	if event is InputEventKey and event.pressed and event.keycode == KEY_Q:
		_toggle_panel()
