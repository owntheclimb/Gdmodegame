extends Node2D
class_name ConstructionSite

@export var blueprint: Blueprint

var remaining_costs: Dictionary = {}
var remaining_build_time := 0.0
var _build_task_created := false
var _delivery_tasks: Dictionary = {}
var _use_loaded_state := false

# Visual construction stages
var _construction_stage := 0  # 0=foundation, 1=walls, 2=roof, 3=complete
var _stage_node: Node2D = null

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("construction_site")
	_setup_placeholder_sprite()
	_setup_construction_visuals()
	if _use_loaded_state:
		_apply_loaded_tasks()
		return
	if blueprint:
		_setup_from_blueprint()
		_create_resource_tasks()

func _process(_delta: float) -> void:
	_update_construction_visuals()

func apply_loaded_state(saved_blueprint: Blueprint, saved_costs: Dictionary, saved_time: float, build_task_created := false) -> void:
	_use_loaded_state = true
	blueprint = saved_blueprint
	remaining_costs = saved_costs.duplicate(true)
	remaining_build_time = saved_time
	_build_task_created = build_task_created

func _apply_loaded_tasks() -> void:
	if remaining_costs.is_empty() and not _build_task_created:
		_create_build_task()
	elif not remaining_costs.is_empty():
		_create_resource_tasks()

func assign_blueprint(new_blueprint: Blueprint) -> void:
	blueprint = new_blueprint
	_setup_from_blueprint()
	_create_resource_tasks()

func is_build_task_created() -> bool:
	return _build_task_created

func receive_delivery(resource: String, amount: int) -> void:
	if not remaining_costs.has(resource):
		return
	remaining_costs[resource] = maxi(int(remaining_costs[resource]) - amount, 0)
	if remaining_costs[resource] <= 0:
		remaining_costs.erase(resource)
	_sync_delivery_tasks()
	if remaining_costs.is_empty() and not _build_task_created:
		_create_build_task()

func perform_build_step(work_amount: float) -> void:
	if remaining_build_time <= 0.0:
		return
	remaining_build_time = maxf(remaining_build_time - work_amount, 0.0)
	_update_construction_stage()
	if remaining_build_time <= 0.0:
		_complete_construction()

func _setup_from_blueprint() -> void:
	remaining_costs = blueprint.costs.duplicate(true)
	remaining_build_time = blueprint.build_time
	_build_task_created = false
	_delivery_tasks.clear()
	_construction_stage = 0

func _create_resource_tasks() -> void:
	var task_board := _get_task_board()
	if not task_board:
		return
	for resource in remaining_costs.keys():
		var amount := int(remaining_costs[resource])
		_ensure_delivery_task(resource, amount, task_board)

func _create_build_task() -> void:
	var task_board := _get_task_board()
	if not task_board:
		return
	_build_task_created = true
	var task := Task.new()
	task.task_id = "%s_build" % str(get_instance_id())
	task.task_type = "build"
	task.priority = 3
	task.target_node_path = get_path()
	task.payload = {"work": remaining_build_time}
	task_board.add_task(task)

func _sync_delivery_tasks() -> void:
	var task_board := _get_task_board()
	if not task_board:
		return
	for resource in _delivery_tasks.keys().duplicate():
		if not remaining_costs.has(resource):
			_complete_delivery_task(resource, task_board)
	for resource in remaining_costs.keys():
		_ensure_delivery_task(resource, int(remaining_costs[resource]), task_board)

func _ensure_delivery_task(resource: String, amount: int, task_board: TaskBoard) -> void:
	if amount <= 0:
		_complete_delivery_task(resource, task_board)
		return
	if _delivery_tasks.has(resource):
		var task: Task = _delivery_tasks[resource] as Task
		if task:
			task.payload = {"resource": resource, "amount": amount}
			return
	var new_task := Task.new()
	new_task.task_id = "%s_%s" % [str(get_instance_id()), resource]
	new_task.task_type = "deliver_resource"
	new_task.priority = 5
	new_task.target_node_path = get_path()
	new_task.payload = {"resource": resource, "amount": amount}
	_delivery_tasks[resource] = new_task
	task_board.add_task(new_task)

func _complete_delivery_task(resource: String, task_board: TaskBoard) -> void:
	if not _delivery_tasks.has(resource):
		return
	var task: Task = _delivery_tasks[resource] as Task
	if task:
		task_board.complete_task(task)
	_delivery_tasks.erase(resource)

func _complete_construction() -> void:
	if not blueprint or not blueprint.building_scene:
		queue_free()
		return
	var building_instance := blueprint.building_scene.instantiate()
	if building_instance is Node2D:
		building_instance.global_position = global_position
	get_parent().add_child(building_instance)
	if building_instance.has_method("set_blueprint"):
		building_instance.set_blueprint(blueprint)
	queue_free()

func _get_task_board() -> TaskBoard:
	return get_tree().get_first_node_in_group("task_board")

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(24, 24, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.6, 0.45, 0.2))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _setup_construction_visuals() -> void:
	_stage_node = Node2D.new()
	_stage_node.name = "ConstructionVisuals"
	add_child(_stage_node)
	_update_construction_stage()

func _update_construction_stage() -> void:
	if not blueprint:
		return
	var total_time := blueprint.build_time
	var elapsed := total_time - remaining_build_time
	var progress := elapsed / total_time if total_time > 0 else 1.0
	
	var new_stage := 0
	if progress >= 0.75:
		new_stage = 3  # Nearly complete - roof
	elif progress >= 0.4:
		new_stage = 2  # Walls
	elif progress > 0:
		new_stage = 1  # Foundation started
	
	if new_stage != _construction_stage:
		_construction_stage = new_stage

func _update_construction_visuals() -> void:
	queue_redraw()

func _draw() -> void:
	# Draw construction stage visuals
	var base_color := Color(0.5, 0.35, 0.2)
	
	match _construction_stage:
		0:  # Just foundation outline
			draw_rect(Rect2(-12, -8, 24, 16), base_color, false, 2.0)
			# Draw resource piles if waiting for resources
			if not remaining_costs.is_empty():
				_draw_waiting_resources()
		1:  # Foundation filled
			draw_rect(Rect2(-12, -8, 24, 16), base_color)
			draw_rect(Rect2(-12, -8, 24, 16), Color.WHITE, false, 1.0)
		2:  # Walls going up
			draw_rect(Rect2(-12, -8, 24, 16), base_color)
			# Draw partial walls
			draw_rect(Rect2(-12, -16, 4, 8), Color(0.6, 0.45, 0.25))
			draw_rect(Rect2(8, -16, 4, 8), Color(0.6, 0.45, 0.25))
			# Scaffolding lines
			draw_line(Vector2(-14, -16), Vector2(14, -16), Color(0.4, 0.3, 0.2), 1.0)
		3:  # Nearly complete - roof frame
			draw_rect(Rect2(-12, -8, 24, 16), base_color)
			draw_rect(Rect2(-12, -20, 24, 12), Color(0.6, 0.45, 0.25))
			# Roof outline
			var roof_points: PackedVector2Array = [
				Vector2(0, -28),
				Vector2(-14, -18),
				Vector2(14, -18)
			]
			draw_polyline(roof_points, Color(0.5, 0.35, 0.15), 2.0)
	
	# Draw progress bar above
	if _build_task_created and blueprint:
		var progress := 1.0 - (remaining_build_time / blueprint.build_time)
		var bar_width := 20.0
		var bar_y := -32.0
		draw_rect(Rect2(-bar_width/2, bar_y, bar_width, 4), Color(0.2, 0.2, 0.2, 0.8))
		draw_rect(Rect2(-bar_width/2, bar_y, bar_width * progress, 4), Color(0.4, 0.7, 0.3))

func _draw_waiting_resources() -> void:
	var offset_x := -8.0
	for resource in remaining_costs.keys():
		var color := Color.WHITE
		match resource:
			"wood": color = Color(0.6, 0.4, 0.2)
			"stone": color = Color(0.5, 0.5, 0.6)
			"food": color = Color(0.8, 0.4, 0.4)
		draw_circle(Vector2(offset_x, -14), 4, color)
		offset_x += 10.0
