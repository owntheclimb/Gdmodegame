extends Node2D
class_name TaskIndicator

@export var offset_y := -24.0
@export var bar_width := 20.0
@export var bar_height := 4.0

var _current_task := ""
var _progress := 0.0
var _show_progress := false

# Task colors
const TASK_COLORS := {
	"gather_wood": Color(0.6, 0.4, 0.2),
	"clear_rock": Color(0.5, 0.5, 0.6),
	"harvest_berries": Color(0.8, 0.3, 0.4),
	"build": Color(0.4, 0.6, 0.8),
	"deliver_resource": Color(0.6, 0.8, 0.4),
	"Collect": Color(0.5, 0.7, 0.3),
	"Deposit": Color(0.7, 0.7, 0.3),
	"Eat": Color(0.9, 0.5, 0.5),
	"default": Color(0.7, 0.7, 0.7)
}

# Task icons (simple shapes for now, will be replaced with Kenney icons)
const TASK_ICONS := {
	"gather_wood": "axe",
	"clear_rock": "pickaxe",
	"harvest_berries": "basket",
	"build": "hammer",
	"deliver_resource": "box",
	"Collect": "hand",
	"Deposit": "chest",
	"Eat": "food",
}

func _process(_delta: float) -> void:
	# Always face camera (billboard effect not needed for 2D)
	queue_redraw()

func set_task(task_name: String, progress: float = 0.0, show_progress: bool = false) -> void:
	_current_task = task_name
	_progress = clamp(progress, 0.0, 1.0)
	_show_progress = show_progress
	visible = task_name != "" and task_name != "Idle"

func clear_task() -> void:
	_current_task = ""
	_progress = 0.0
	_show_progress = false
	visible = false

func _draw() -> void:
	if _current_task == "" or _current_task == "Idle":
		return
	
	var color := _get_task_color()
	var pos := Vector2(0, offset_y)
	
	# Draw background circle
	draw_circle(pos, 8, Color(0.1, 0.1, 0.1, 0.7))
	
	# Draw task icon (simple shapes for now)
	_draw_task_icon(pos, color)
	
	# Draw progress bar if needed
	if _show_progress and _progress > 0:
		var bar_pos := pos + Vector2(-bar_width / 2, 12)
		# Background
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color(0.2, 0.2, 0.2, 0.8))
		# Fill
		draw_rect(Rect2(bar_pos, Vector2(bar_width * _progress, bar_height)), color)
		# Border
		draw_rect(Rect2(bar_pos, Vector2(bar_width, bar_height)), Color.WHITE, false, 1.0)

func _get_task_color() -> Color:
	for key in TASK_COLORS.keys():
		if _current_task.to_lower().contains(key.to_lower()):
			return TASK_COLORS[key]
	return TASK_COLORS["default"]

func _draw_task_icon(pos: Vector2, color: Color) -> void:
	# Simple geometric icons - will be replaced with Kenney sprites
	var icon_type := "default"
	for key in TASK_ICONS.keys():
		if _current_task.to_lower().contains(key.to_lower()):
			icon_type = TASK_ICONS[key]
			break
	
	match icon_type:
		"axe":
			# Draw axe shape
			draw_line(pos + Vector2(-4, -4), pos + Vector2(4, 4), color, 2.0)
			draw_line(pos + Vector2(-2, 2), pos + Vector2(4, -4), color, 2.0)
		"pickaxe":
			# Draw pickaxe shape
			draw_line(pos + Vector2(-4, 4), pos + Vector2(4, -4), color, 2.0)
			draw_line(pos + Vector2(0, -4), pos + Vector2(4, 0), color, 2.0)
		"hammer":
			# Draw hammer shape
			draw_line(pos + Vector2(0, -4), pos + Vector2(0, 4), color, 2.0)
			draw_rect(Rect2(pos + Vector2(-4, -6), Vector2(8, 4)), color)
		"basket", "hand", "food":
			# Draw circle
			draw_circle(pos, 4, color)
		"box", "chest":
			# Draw box
			draw_rect(Rect2(pos + Vector2(-4, -3), Vector2(8, 6)), color)
		_:
			# Default dot
			draw_circle(pos, 3, color)
