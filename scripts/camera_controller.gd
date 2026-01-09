extends Camera2D
class_name CameraController

@export var move_speed := 400.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.3
@export var max_zoom := 3.0
@export var edge_scroll_margin := 20
@export var edge_scroll_enabled := true

# Camera bounds (will be set by world generator)
var bounds_min := Vector2(-500, -500)
var bounds_max := Vector2(2500, 2500)

# Middle mouse drag
var _is_dragging := false
var _drag_start := Vector2.ZERO

func _ready() -> void:
	# Try to get bounds from world
	var world := get_tree().get_first_node_in_group("world")
	if world and world.has_method("get_map_bounds"):
		var bounds: Rect2 = world.get_map_bounds()
		bounds_min = bounds.position
		bounds_max = bounds.position + bounds.size

func _process(delta: float) -> void:
	var input_vector := Vector2.ZERO
	
	# WASD / Arrow key movement
	if Input.is_action_pressed("camera_up"):
		input_vector.y -= 1
	if Input.is_action_pressed("camera_down"):
		input_vector.y += 1
	if Input.is_action_pressed("camera_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("camera_right"):
		input_vector.x += 1
	
	# Edge scrolling
	if edge_scroll_enabled and not _is_dragging:
		var mouse_pos := get_viewport().get_mouse_position()
		var viewport_size := get_viewport_rect().size
		
		if mouse_pos.x < edge_scroll_margin:
			input_vector.x -= 1
		elif mouse_pos.x > viewport_size.x - edge_scroll_margin:
			input_vector.x += 1
		
		if mouse_pos.y < edge_scroll_margin:
			input_vector.y -= 1
		elif mouse_pos.y > viewport_size.y - edge_scroll_margin:
			input_vector.y += 1
	
	# Apply movement (faster when zoomed out)
	var speed_multiplier := 1.0 / zoom.x
	position += input_vector.normalized() * move_speed * speed_multiplier * delta
	
	# Clamp to bounds
	position.x = clamp(position.x, bounds_min.x, bounds_max.x)
	position.y = clamp(position.y, bounds_min.y, bounds_max.y)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse wheel zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_zoom_at_point(zoom_speed, get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_zoom_at_point(-zoom_speed, get_global_mouse_position())
		# Middle mouse drag
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			if event.pressed:
				_is_dragging = true
				_drag_start = event.position
			else:
				_is_dragging = false
	
	# Middle mouse drag movement
	if event is InputEventMouseMotion and _is_dragging:
		var drag_delta: Vector2 = event.relative / zoom.x
		position -= drag_delta

func _zoom_at_point(zoom_change: float, target: Vector2) -> void:
	var old_zoom := zoom.x
	var new_zoom_value: float = clamp(zoom.x + zoom_change, min_zoom, max_zoom)
	
	if new_zoom_value == old_zoom:
		return
	
	# Zoom toward mouse position
	var mouse_offset := target - global_position
	var zoom_ratio := new_zoom_value / old_zoom
	position = target - mouse_offset * zoom_ratio
	
	zoom = Vector2(new_zoom_value, new_zoom_value)

func set_bounds(min_pos: Vector2, max_pos: Vector2) -> void:
	bounds_min = min_pos
	bounds_max = max_pos
