extends Camera2D
class_name CameraController

@export var move_speed := 300.0
@export var zoom_speed := 0.1
@export var min_zoom := 0.5
@export var max_zoom := 2.0

func _process(delta: float) -> void:
	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	position += input_vector * move_speed * delta
	_handle_edge_scroll(delta)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var new_zoom := clamp(zoom.x - zoom_speed, min_zoom, max_zoom)
			zoom = Vector2(new_zoom, new_zoom)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var new_zoom := clamp(zoom.x + zoom_speed, min_zoom, max_zoom)
			zoom = Vector2(new_zoom, new_zoom)

func _handle_edge_scroll(delta: float) -> void:
	var viewport := get_viewport()
	if not viewport:
		return
	var mouse := viewport.get_mouse_position()
	var size := viewport.get_visible_rect().size
	var edge := 20.0
	var direction := Vector2.ZERO
	if mouse.x < edge:
		direction.x -= 1.0
	elif mouse.x > size.x - edge:
		direction.x += 1.0
	if mouse.y < edge:
		direction.y -= 1.0
	elif mouse.y > size.y - edge:
		direction.y += 1.0
	if direction != Vector2.ZERO:
		position += direction.normalized() * move_speed * 0.6 * delta
