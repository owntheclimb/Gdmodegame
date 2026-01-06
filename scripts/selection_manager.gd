extends Node2D
class_name SelectionManager

var selected: Node2D

func _ready() -> void:
	add_to_group("selection_manager")
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_select_at_position(get_global_mouse_position())

func _select_at_position(position: Vector2) -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = position
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 0x7fffffff
	var results := space.intersect_point(query, 10)
	var candidate: Node2D = null
	for result in results:
		var collider := result.collider
		if collider and (collider.is_in_group("villager") or collider.is_in_group("construction_site")):
			candidate = collider
			break
	_set_selected(candidate)

func _set_selected(node: Node2D) -> void:
	if selected and selected.has_method("set_selected"):
		selected.set_selected(false)
	selected = node
	if selected and selected.has_method("set_selected"):
		selected.set_selected(true)
