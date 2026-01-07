extends Node2D
class_name ConstructionSite

@export var blueprint: Blueprint

var remaining_costs: Dictionary = {}
var remaining_build_time := 0.0
var _build_task_created := false
var _delivery_tasks: Dictionary = {}

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("construction_site")
	_setup_placeholder_sprite()
	if blueprint:
		_setup_from_blueprint()
		_create_resource_tasks()

func assign_blueprint(new_blueprint: Blueprint) -> void:
	blueprint = new_blueprint
	_setup_from_blueprint()
	_create_resource_tasks()

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
	if remaining_build_time <= 0.0:
		_complete_construction()

func _setup_from_blueprint() -> void:
	remaining_costs = blueprint.costs.duplicate(true)
	remaining_build_time = blueprint.build_time
	_build_task_created = false
	_delivery_tasks.clear()

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
		var task := _delivery_tasks[resource]
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
	var task := _delivery_tasks[resource]
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
