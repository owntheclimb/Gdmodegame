extends Node2D
class_name SelectionManager

var selected: Villager = null
var hovered: Villager = null
var _dragging: Villager = null

func _ready() -> void:
	add_to_group("selection_manager")
	set_process_unhandled_input(true)

func _process(_delta: float) -> void:
	_update_hover()

func _update_hover() -> void:
	var mouse_pos := get_global_mouse_position()
	var new_hovered := _get_villager_at_position(mouse_pos)
	
	if new_hovered != hovered:
		if hovered and is_instance_valid(hovered):
			hovered.set_hovered(false)
		hovered = new_hovered
		if hovered:
			hovered.set_hovered(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			var villager := _get_villager_at_position(get_global_mouse_position())
			if villager:
				_select(villager)
				villager.start_drag()
				_dragging = villager
			else:
				_deselect()
		else:
			if _dragging and is_instance_valid(_dragging):
				_dragging.end_drag()
				_dragging = null
	
	# Right-click to deselect
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		_deselect()

func _get_villager_at_position(pos: Vector2) -> Villager:
	var space := get_world_2d()
	if not space:
		return null
	var direct_space := space.direct_space_state
	if not direct_space:
		return null
	
	var query := PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 0x7fffffff
	
	var results := direct_space.intersect_point(query, 10)
	for result in results:
		var collider = result.collider
		if collider is Villager:
			return collider as Villager
	return null

func _select(villager: Villager) -> void:
	if selected == villager:
		return
	_deselect()
	selected = villager
	if selected:
		selected.set_selected(true)

func _deselect() -> void:
	if selected and is_instance_valid(selected):
		selected.set_selected(false)
	selected = null

func get_selected() -> Villager:
	return selected
