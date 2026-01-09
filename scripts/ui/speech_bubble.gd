extends Node2D
class_name SpeechBubble

## Floating speech/thought bubble system for villagers
## Shows needs, thoughts, alerts, social messages, and requests

enum BubbleType { NEED, THOUGHT, ALERT, SOCIAL, REQUEST }

const BUBBLE_COLORS: Dictionary = {
	BubbleType.NEED: Color(1.0, 0.5, 0.5),     # Red for urgent needs
	BubbleType.THOUGHT: Color(0.8, 0.8, 0.9),  # Light gray for thoughts
	BubbleType.ALERT: Color(1.0, 0.8, 0.2),    # Yellow for alerts
	BubbleType.SOCIAL: Color(1.0, 0.6, 0.8),   # Pink for social
	BubbleType.REQUEST: Color(0.6, 0.8, 1.0),  # Blue for requests
}

const BUBBLE_ICONS: Dictionary = {
	BubbleType.NEED: "❗",
	BubbleType.THOUGHT: "💭",
	BubbleType.ALERT: "⚠️",
	BubbleType.SOCIAL: "💕",
	BubbleType.REQUEST: "❓",
}

# Duration bubbles stay visible
const DEFAULT_DURATION := 5.0
const URGENT_DURATION := 8.0

# Queue of pending messages
var _message_queue: Array = []  # Array of {type, text, priority, duration}
var _current_bubble: Control = null
var _display_timer := 0.0
var _is_displaying := false

# Visual elements
var _panel: PanelContainer
var _icon_label: Label
var _text_label: Label
var _click_area: Control

# Parent villager reference
var _villager: Node2D = null

# Offset above villager head
const BUBBLE_OFFSET := Vector2(0, -40)

signal bubble_clicked(bubble_type: BubbleType, message: String)

func _ready() -> void:
	_build_bubble_ui()
	visible = false

func _build_bubble_ui() -> void:
	# Create panel container for the bubble
	_panel = PanelContainer.new()
	_panel.name = "BubblePanel"
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.18, 0.9)
	style.border_color = Color(0.4, 0.4, 0.45)
	style.set_border_width_all(1)
	style.set_corner_radius_all(8)
	style.content_margin_left = 6
	style.content_margin_right = 6
	style.content_margin_top = 3
	style.content_margin_bottom = 3
	_panel.add_theme_stylebox_override("panel", style)
	
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 4)
	_panel.add_child(hbox)
	
	# Icon
	_icon_label = Label.new()
	_icon_label.add_theme_font_size_override("font_size", 14)
	hbox.add_child(_icon_label)
	
	# Text
	_text_label = Label.new()
	_text_label.add_theme_font_size_override("font_size", 11)
	_text_label.custom_minimum_size = Vector2(0, 0)
	hbox.add_child(_text_label)
	
	add_child(_panel)
	
	# Click detection
	_click_area = Control.new()
	_click_area.mouse_filter = Control.MOUSE_FILTER_STOP
	_click_area.gui_input.connect(_on_bubble_input)
	_panel.add_child(_click_area)

func setup(villager: Node2D) -> void:
	_villager = villager

func _process(delta: float) -> void:
	if _is_displaying:
		_display_timer -= delta
		
		# Fade out in last second
		if _display_timer <= 1.0:
			_panel.modulate.a = _display_timer
		
		if _display_timer <= 0:
			_hide_current_bubble()
			_try_show_next()
	elif not _message_queue.is_empty():
		_try_show_next()
	
	# Update position relative to villager
	if _villager and is_instance_valid(_villager):
		global_position = _villager.global_position + BUBBLE_OFFSET
	
	# Center the panel above the position
	if _panel:
		_panel.position = -_panel.size / 2

func show_bubble(type: BubbleType, message: String, priority: int = 0, duration: float = -1.0) -> void:
	var actual_duration := duration if duration > 0 else DEFAULT_DURATION
	if type == BubbleType.NEED or type == BubbleType.ALERT:
		actual_duration = URGENT_DURATION
	
	var entry := {
		"type": type,
		"text": message,
		"priority": priority,
		"duration": actual_duration
	}
	
	# Insert based on priority (higher priority first)
	var inserted := false
	for i in range(_message_queue.size()):
		if _message_queue[i].priority < priority:
			_message_queue.insert(i, entry)
			inserted = true
			break
	
	if not inserted:
		_message_queue.append(entry)
	
	# If nothing is displaying, show immediately
	if not _is_displaying:
		_try_show_next()

func _try_show_next() -> void:
	if _message_queue.is_empty():
		return
	
	var entry: Dictionary = _message_queue.pop_front()
	_display_bubble(entry.type, entry.text, entry.duration)

func _display_bubble(type: BubbleType, message: String, duration: float) -> void:
	_is_displaying = true
	_display_timer = duration
	
	# Update visuals
	_icon_label.text = BUBBLE_ICONS[type]
	_text_label.text = message
	_text_label.add_theme_color_override("font_color", BUBBLE_COLORS[type])
	
	# Update panel border color
	var style: StyleBoxFlat = _panel.get_theme_stylebox("panel").duplicate()
	style.border_color = BUBBLE_COLORS[type]
	_panel.add_theme_stylebox_override("panel", style)
	
	# Reset alpha and show
	_panel.modulate.a = 1.0
	visible = true
	
	# Animate entrance
	_panel.scale = Vector2(0.8, 0.8)
	var tween := create_tween()
	tween.tween_property(_panel, "scale", Vector2.ONE, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _hide_current_bubble() -> void:
	_is_displaying = false
	visible = false

func _on_bubble_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Emit clicked signal with current bubble info
		if _is_displaying:
			bubble_clicked.emit(BubbleType.NEED, _text_label.text)  # Simplified for now
		get_viewport().set_input_as_handled()

func clear_all() -> void:
	_message_queue.clear()
	_hide_current_bubble()

# Convenience methods for common bubble types
func show_need(message: String) -> void:
	show_bubble(BubbleType.NEED, message, 100)

func show_thought(message: String) -> void:
	show_bubble(BubbleType.THOUGHT, message, 10)

func show_alert(message: String) -> void:
	show_bubble(BubbleType.ALERT, message, 90)

func show_social(message: String) -> void:
	show_bubble(BubbleType.SOCIAL, message, 50)

func show_request(message: String) -> void:
	show_bubble(BubbleType.REQUEST, message, 60)

# Static factory for creating a bubble for a villager
static func create_for_villager(villager: Node2D) -> SpeechBubble:
	var bubble := SpeechBubble.new()
	bubble.setup(villager)
	villager.add_child(bubble)
	return bubble
