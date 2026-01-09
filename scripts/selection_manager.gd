extends Node2D
class_name SelectionManager

var selected: Villager = null
var hovered: Villager = null
var _dragging: Villager = null
var _last_click_time := 0.0
var _last_clicked_villager: Villager = null
const DOUBLE_CLICK_TIME := 0.3

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
				# Check for double-click
				var current_time := Time.get_ticks_msec() / 1000.0
				if _last_clicked_villager == villager and (current_time - _last_click_time) < DOUBLE_CLICK_TIME:
					_open_character_panel(villager)
					_last_clicked_villager = null
				else:
					_last_click_time = current_time
					_last_clicked_villager = villager
					_select(villager)
					villager.start_drag()
					_dragging = villager
			else:
				_deselect()
				_last_clicked_villager = null
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

func _open_character_panel(villager: Villager) -> void:
	var panel := get_tree().get_first_node_in_group("character_panel")
	if panel and panel.has_method("show_villager"):
		panel.show_villager(villager)
	else:
		# Try to create one if it doesn't exist
		var CharacterPanelScene := load("res://scenes/ui/CharacterPanel.tscn")
		if CharacterPanelScene:
			var new_panel := CharacterPanelScene.instantiate()
			get_tree().root.add_child(new_panel)
			if new_panel.has_method("show_villager"):
				new_panel.show_villager(villager)
