extends CanvasLayer
class_name ActionMenu

## Expandable Action Menu with 6 categories: Explore, Decree, Build, Research, Trade, Special
## Actions unlock via tech tree, achievements, and story progress

signal action_triggered(action_id: String, action_data: Dictionary)

# Category definitions
enum Category { EXPLORE, DECREE, BUILD, RESEARCH, TRADE, SPECIAL }

# Action structure
class ActionDef:
	var id: String
	var name: String
	var description: String
	var icon_path: String
	var category: Category
	var unlocked: bool
	var cooldown: float
	var cooldown_remaining: float
	var cost: Dictionary  # resource_type -> amount
	var hotkey: int  # KEY_* constant or -1

	func _init(p_id: String, p_name: String, p_desc: String, p_cat: Category) -> void:
		id = p_id
		name = p_name
		description = p_desc
		category = p_cat
		unlocked = false
		cooldown = 0.0
		cooldown_remaining = 0.0
		cost = {}
		hotkey = -1
		icon_path = ""

# All registered actions
var _actions: Dictionary = {}  # action_id -> ActionDef
var _category_actions: Dictionary = {}  # Category -> Array[ActionDef]

# UI Elements
var _menu_bar: HBoxContainer
var _category_buttons: Dictionary = {}  # Category -> Button
var _expanded_category: Category = -1
var _action_popup: PanelContainer
var _action_list: VBoxContainer
var _tooltip_panel: PanelContainer
var _tooltip_label: RichTextLabel

# Styling
const CATEGORY_COLORS: Dictionary = {
	Category.EXPLORE: Color(0.3, 0.7, 0.4),   # Green
	Category.DECREE: Color(0.8, 0.6, 0.2),    # Gold
	Category.BUILD: Color(0.6, 0.4, 0.2),     # Brown
	Category.RESEARCH: Color(0.3, 0.5, 0.8),  # Blue
	Category.TRADE: Color(0.7, 0.5, 0.7),     # Purple
	Category.SPECIAL: Color(0.9, 0.3, 0.3),   # Red
}

const CATEGORY_NAMES: Dictionary = {
	Category.EXPLORE: "Explore",
	Category.DECREE: "Decree",
	Category.BUILD: "Build",
	Category.RESEARCH: "Research",
	Category.TRADE: "Trade",
	Category.SPECIAL: "Special",
}

const CATEGORY_ICONS: Dictionary = {
	Category.EXPLORE: "🧭",
	Category.DECREE: "📜",
	Category.BUILD: "🔨",
	Category.RESEARCH: "📚",
	Category.TRADE: "💰",
	Category.SPECIAL: "✨",
}

func _ready() -> void:
	add_to_group("action_menu")
	_init_categories()
	_register_default_actions()
	_build_ui()
	_unlock_starting_actions()

func _init_categories() -> void:
	for cat in Category.values():
		_category_actions[cat] = []

func _register_default_actions() -> void:
	# EXPLORE actions
	_register_action("scout_area", "Scout Area", "Send a villager to reveal fog of war", Category.EXPLORE)
	_register_action("explore_ruins", "Explore Ruins", "Search ruins for artifacts and lore", Category.EXPLORE)
	_register_action("search_survivors", "Search for Survivors", "Look for shipwreck survivors to recruit", Category.EXPLORE)
	_register_action("hunt_legendary", "Hunt Legendary Creature", "High risk, high reward hunt", Category.EXPLORE)
	
	# DECREE actions
	_register_action("declare_festival", "Declare Festival", "Boost happiness, costs 20 food", Category.DECREE).cost = {"food": 20}
	_register_action("ration_food", "Ration Food", "Survive crisis, lower happiness", Category.DECREE)
	_register_action("work_day", "Work Day", "Boost production, drain energy", Category.DECREE)
	_register_action("rest_day", "Rest Day", "Recover energy, no production", Category.DECREE)
	_register_action("training_focus", "Training Focus", "Boost skill gain for all villagers", Category.DECREE)
	_register_action("defense_alert", "Defense Alert", "Villagers arm themselves", Category.DECREE)
	
	# BUILD actions (will be populated from BuildingDefinition)
	_register_action("build_menu", "Open Build Menu", "View available buildings", Category.BUILD)
	_register_action("upgrade_building", "Upgrade Building", "Upgrade selected building", Category.BUILD)
	_register_action("demolish", "Demolish", "Remove a structure", Category.BUILD)
	
	# RESEARCH actions
	_register_action("open_tech_tree", "Open Tech Tree", "View and research technologies", Category.RESEARCH)
	_register_action("assign_scholars", "Assign Scholars", "Speed up current research", Category.RESEARCH)
	_register_action("view_blueprints", "View Blueprints", "See unlocked building designs", Category.RESEARCH)
	
	# TRADE actions
	_register_action("send_traders", "Send Traders", "Trade with distant lands", Category.TRADE)
	_register_action("establish_route", "Establish Trade Route", "Create recurring trade", Category.TRADE)
	_register_action("barter", "Barter", "Trade with visiting merchants", Category.TRADE)
	
	# SPECIAL actions (late-game divine powers)
	_register_action("miracle_heal", "Miracle: Heal All", "Heal all villagers (costs 50 favor)", Category.SPECIAL).cost = {"divine_favor": 50}
	_register_action("blessing", "Blessing", "Buff all villagers temporarily", Category.SPECIAL).cost = {"divine_favor": 25}
	_register_action("prophecy", "Prophecy", "Reveal upcoming events", Category.SPECIAL).cost = {"divine_favor": 30}

func _register_action(id: String, name_str: String, desc: String, cat: Category) -> ActionDef:
	var action := ActionDef.new(id, name_str, desc, cat)
	_actions[id] = action
	_category_actions[cat].append(action)
	return action

func _build_ui() -> void:
	# Create the menu bar at bottom of screen
	_menu_bar = HBoxContainer.new()
	_menu_bar.name = "ActionMenuBar"
	_menu_bar.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_menu_bar.offset_top = -60
	_menu_bar.offset_bottom = -10
	_menu_bar.offset_left = 10
	_menu_bar.offset_right = -10
	_menu_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	_menu_bar.add_theme_constant_override("separation", 8)
	
	# Create category buttons
	for cat in Category.values():
		var btn := _create_category_button(cat)
		_menu_bar.add_child(btn)
		_category_buttons[cat] = btn
	
	add_child(_menu_bar)
	
	# Create action popup (initially hidden)
	_action_popup = PanelContainer.new()
	_action_popup.name = "ActionPopup"
	_action_popup.visible = false
	_action_popup.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	_action_popup.offset_top = -300
	_action_popup.offset_bottom = -70
	_action_popup.offset_left = -150
	_action_popup.offset_right = 150
	
	var popup_style := StyleBoxFlat.new()
	popup_style.bg_color = Color(0.12, 0.12, 0.15, 0.95)
	popup_style.border_color = Color(0.4, 0.35, 0.25)
	popup_style.set_border_width_all(2)
	popup_style.set_corner_radius_all(6)
	_action_popup.add_theme_stylebox_override("panel", popup_style)
	
	var scroll := ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_action_popup.add_child(scroll)
	
	_action_list = VBoxContainer.new()
	_action_list.add_theme_constant_override("separation", 4)
	scroll.add_child(_action_list)
	
	add_child(_action_popup)
	
	# Create tooltip
	_tooltip_panel = PanelContainer.new()
	_tooltip_panel.name = "Tooltip"
	_tooltip_panel.visible = false
	_tooltip_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var tooltip_style := StyleBoxFlat.new()
	tooltip_style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
	tooltip_style.border_color = Color(0.5, 0.5, 0.5)
	tooltip_style.set_border_width_all(1)
	tooltip_style.set_corner_radius_all(4)
	_tooltip_panel.add_theme_stylebox_override("panel", tooltip_style)
	
	_tooltip_label = RichTextLabel.new()
	_tooltip_label.bbcode_enabled = true
	_tooltip_label.fit_content = true
	_tooltip_label.custom_minimum_size = Vector2(200, 0)
	_tooltip_panel.add_child(_tooltip_label)
	
	add_child(_tooltip_panel)

func _create_category_button(cat: Category) -> Button:
	var btn := Button.new()
	btn.text = "%s %s" % [CATEGORY_ICONS[cat], CATEGORY_NAMES[cat]]
	btn.custom_minimum_size = Vector2(100, 40)
	btn.tooltip_text = CATEGORY_NAMES[cat]
	
	var style_normal := StyleBoxFlat.new()
	style_normal.bg_color = CATEGORY_COLORS[cat].darkened(0.3)
	style_normal.set_border_width_all(2)
	style_normal.border_color = CATEGORY_COLORS[cat]
	style_normal.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("normal", style_normal)
	
	var style_hover := StyleBoxFlat.new()
	style_hover.bg_color = CATEGORY_COLORS[cat].darkened(0.1)
	style_hover.set_border_width_all(2)
	style_hover.border_color = CATEGORY_COLORS[cat].lightened(0.2)
	style_hover.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("hover", style_hover)
	
	var style_pressed := StyleBoxFlat.new()
	style_pressed.bg_color = CATEGORY_COLORS[cat]
	style_pressed.set_border_width_all(2)
	style_pressed.border_color = Color.WHITE
	style_pressed.set_corner_radius_all(6)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	
	btn.pressed.connect(_on_category_pressed.bind(cat))
	
	return btn

func _on_category_pressed(cat: Category) -> void:
	if _expanded_category == cat:
		_collapse_menu()
	else:
		_expand_category(cat)

func _expand_category(cat: Category) -> void:
	_expanded_category = cat
	_action_popup.visible = true
	
	# Clear existing actions
	for child in _action_list.get_children():
		child.queue_free()
	
	# Add category header
	var header := Label.new()
	header.text = "%s %s" % [CATEGORY_ICONS[cat], CATEGORY_NAMES[cat]]
	header.add_theme_color_override("font_color", CATEGORY_COLORS[cat])
	header.add_theme_font_size_override("font_size", 18)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_action_list.add_child(header)
	
	var sep := HSeparator.new()
	_action_list.add_child(sep)
	
	# Add actions for this category
	var actions: Array = _category_actions[cat]
	var has_unlocked := false
	
	for action in actions:
		if action.unlocked:
			has_unlocked = true
			var action_btn := _create_action_button(action)
			_action_list.add_child(action_btn)
	
	if not has_unlocked:
		var no_actions := Label.new()
		no_actions.text = "No actions unlocked yet"
		no_actions.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		no_actions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_action_list.add_child(no_actions)
	
	# Update button highlight
	for cat_key in _category_buttons:
		var btn: Button = _category_buttons[cat_key]
		btn.button_pressed = (cat_key == cat)

func _collapse_menu() -> void:
	_expanded_category = -1
	_action_popup.visible = false
	
	for cat_key in _category_buttons:
		var btn: Button = _category_buttons[cat_key]
		btn.button_pressed = false

func _create_action_button(action: ActionDef) -> Button:
	var btn := Button.new()
	btn.text = action.name
	btn.tooltip_text = action.description
	btn.custom_minimum_size = Vector2(0, 32)
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	# Check if action is on cooldown
	if action.cooldown_remaining > 0:
		btn.disabled = true
		btn.text += " (%.1fs)" % action.cooldown_remaining
	
	# Check if we can afford the cost
	if not _can_afford_action(action):
		btn.disabled = true
		btn.modulate = Color(0.6, 0.6, 0.6)
	
	btn.pressed.connect(_on_action_pressed.bind(action))
	btn.mouse_entered.connect(_show_action_tooltip.bind(action, btn))
	btn.mouse_exited.connect(_hide_tooltip)
	
	return btn

func _on_action_pressed(action: ActionDef) -> void:
	if action.cooldown_remaining > 0:
		return
	
	if not _can_afford_action(action):
		_show_notification("Cannot afford: " + action.name)
		return
	
	# Deduct costs
	_pay_action_cost(action)
	
	# Start cooldown
	if action.cooldown > 0:
		action.cooldown_remaining = action.cooldown
	
	# Emit signal for game systems to handle
	action_triggered.emit(action.id, {"action": action})
	
	# Handle built-in actions
	_handle_action(action.id)
	
	# Collapse menu after action
	_collapse_menu()

func _handle_action(action_id: String) -> void:
	match action_id:
		"declare_festival":
			_trigger_festival()
		"work_day":
			_trigger_work_day()
		"rest_day":
			_trigger_rest_day()
		"training_focus":
			_trigger_training_focus()
		"defense_alert":
			_trigger_defense_alert()
		"open_tech_tree":
			_open_tech_tree()
		"build_menu":
			_open_build_menu()

func _trigger_festival() -> void:
	var villagers := get_tree().get_nodes_in_group("villager")
	for v in villagers:
		if v.has_method("modify_happiness"):
			v.modify_happiness(30)
	_show_notification("Festival declared! Villagers are happy!")

func _trigger_work_day() -> void:
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state and game_state.has_method("set_work_day_bonus"):
		game_state.set_work_day_bonus(true)
	_show_notification("Work Day: Production boosted!")

func _trigger_rest_day() -> void:
	var villagers := get_tree().get_nodes_in_group("villager")
	for v in villagers:
		if v.has_method("recover_energy"):
			v.recover_energy(50)
	_show_notification("Rest Day: Villagers recovering...")

func _trigger_training_focus() -> void:
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state and game_state.has_method("set_training_bonus"):
		game_state.set_training_bonus(true)
	_show_notification("Training Focus: Skill gains boosted!")

func _trigger_defense_alert() -> void:
	var villagers := get_tree().get_nodes_in_group("villager")
	for v in villagers:
		if v.has_method("arm_for_defense"):
			v.arm_for_defense()
	_show_notification("Defense Alert: Villagers armed!")

func _open_tech_tree() -> void:
	var tech_ui := get_tree().get_first_node_in_group("tech_tree_ui")
	if tech_ui and tech_ui.has_method("show_tree"):
		tech_ui.show_tree()
	else:
		_show_notification("Tech Tree not yet available")

func _open_build_menu() -> void:
	var build_ui := get_tree().get_first_node_in_group("build_menu")
	if build_ui and build_ui.has_method("show_menu"):
		build_ui.show_menu()
	else:
		_show_notification("Build Menu not yet available")

func _can_afford_action(action: ActionDef) -> bool:
	if action.cost.is_empty():
		return true
	
	var storage := get_tree().get_first_node_in_group("storage")
	if not storage:
		return false
	
	for resource_type in action.cost:
		var required: int = action.cost[resource_type]
		var available: float = storage.get_amount(resource_type) if storage.has_method("get_amount") else 0.0
		if available < required:
			return false
	
	return true

func _pay_action_cost(action: ActionDef) -> void:
	if action.cost.is_empty():
		return
	
	var storage := get_tree().get_first_node_in_group("storage")
	if not storage:
		return
	
	for resource_type in action.cost:
		var amount: int = action.cost[resource_type]
		if storage.has_method("remove_resource"):
			storage.remove_resource(resource_type, amount)

func _show_action_tooltip(action: ActionDef, btn: Button) -> void:
	var text := "[b]%s[/b]\n%s" % [action.name, action.description]
	
	if not action.cost.is_empty():
		text += "\n\n[color=#ffcc66]Cost:[/color]"
		for resource_type in action.cost:
			text += "\n  %s: %d" % [resource_type.capitalize(), action.cost[resource_type]]
	
	if action.cooldown > 0:
		text += "\n\n[color=#66ccff]Cooldown:[/color] %.1fs" % action.cooldown
	
	_tooltip_label.text = text
	_tooltip_panel.visible = true
	
	# Position tooltip above the button
	var btn_global := btn.get_global_rect()
	_tooltip_panel.position = Vector2(btn_global.position.x, btn_global.position.y - _tooltip_panel.size.y - 10)

func _hide_tooltip() -> void:
	_tooltip_panel.visible = false

func _show_notification(text: String) -> void:
	# Create floating notification
	var notif := Label.new()
	notif.text = text
	notif.add_theme_color_override("font_color", Color(1, 0.9, 0.6))
	notif.add_theme_font_size_override("font_size", 16)
	notif.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notif.set_anchors_preset(Control.PRESET_CENTER_TOP)
	notif.offset_top = 80
	add_child(notif)
	
	# Animate and remove
	var tween := create_tween()
	tween.tween_property(notif, "modulate:a", 0.0, 2.0).set_delay(1.0)
	tween.tween_callback(notif.queue_free)

func _process(delta: float) -> void:
	# Update cooldowns
	for action_id in _actions:
		var action: ActionDef = _actions[action_id]
		if action.cooldown_remaining > 0:
			action.cooldown_remaining -= delta
			if action.cooldown_remaining < 0:
				action.cooldown_remaining = 0.0

func _input(event: InputEvent) -> void:
	# Close menu on Escape
	if event.is_action_pressed("ui_cancel") and _action_popup.visible:
		_collapse_menu()
		get_viewport().set_input_as_handled()
	
	# Hotkey support (1-6 for categories)
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_1:
				_expand_category(Category.EXPLORE)
			KEY_2:
				_expand_category(Category.DECREE)
			KEY_3:
				_expand_category(Category.BUILD)
			KEY_4:
				_expand_category(Category.RESEARCH)
			KEY_5:
				_expand_category(Category.TRADE)
			KEY_6:
				_expand_category(Category.SPECIAL)

func _unlock_starting_actions() -> void:
	# Unlock basic actions available from the start
	unlock_action("build_menu")
	unlock_action("open_tech_tree")
	unlock_action("view_blueprints")
	unlock_action("declare_festival")
	unlock_action("work_day")
	unlock_action("rest_day")
	unlock_action("scout_area")

# Public API
func unlock_action(action_id: String) -> void:
	if _actions.has(action_id):
		_actions[action_id].unlocked = true

func lock_action(action_id: String) -> void:
	if _actions.has(action_id):
		_actions[action_id].unlocked = false

func is_action_unlocked(action_id: String) -> bool:
	if _actions.has(action_id):
		return _actions[action_id].unlocked
	return false

func set_action_cooldown(action_id: String, cooldown: float) -> void:
	if _actions.has(action_id):
		_actions[action_id].cooldown = cooldown

func get_action(action_id: String) -> ActionDef:
	return _actions.get(action_id)

func get_unlocked_action_count() -> int:
	var count := 0
	for action_id in _actions:
		if _actions[action_id].unlocked:
			count += 1
	return count
