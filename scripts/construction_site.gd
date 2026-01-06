extends Node2D
class_name ConstructionSite

@export var required_resources := {"wood": 10.0}
@export var build_time := 10.0
@export var building_scene: PackedScene

var progress := 0.0
var _task_registered := false
var remaining_resources := {}

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("construction_site")
	_setup_placeholder_sprite()
	_initialize_remaining_resources()
	_register_task()

func apply_build(delta: float) -> bool:
	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if not _can_consume_step(storage, delta):
		return false
	_consume_step(storage, delta)
	progress = min(progress + delta, build_time)
	if progress >= build_time:
		_finish_construction()
	else:
		_task_registered = false
		_register_task()
	return true

func _finish_construction() -> void:
	if building_scene:
		var building := building_scene.instantiate()
		building.global_position = global_position
		get_parent().add_child(building)
	_task_registered = false
	queue_free()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.2))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _register_task() -> void:
	if _task_registered:
		return
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	var task := Task.new()
	task.task_id = "build_%s" % get_instance_id()
	task.task_type = "build"
	task.priority = 8
	task.target_node_path = get_path()
	task_board.add_task(task)
	_task_registered = true

func configure(blueprint: BuildingBlueprint) -> void:
	if not blueprint:
		return
	required_resources = blueprint.required_resources
	build_time = blueprint.build_time
	building_scene = blueprint.building_scene
	_initialize_remaining_resources()

func _can_consume_step(storage: Storage, delta: float) -> bool:
	if not storage:
		return false
	var step_fraction := delta / max(build_time, 0.01)
	for resource_type in required_resources.keys():
		var required_step := required_resources[resource_type] * step_fraction
		if required_step > 0.0 and storage.get_amount(resource_type) < required_step:
			return false
	return true

func _consume_step(storage: Storage, delta: float) -> void:
	if not storage:
		return
	var step_fraction := delta / max(build_time, 0.01)
	for resource_type in required_resources.keys():
		var required_step := required_resources[resource_type] * step_fraction
		if required_step <= 0.0:
			continue
		var taken := storage.withdraw(resource_type, required_step)
		remaining_resources[resource_type] = max(remaining_resources.get(resource_type, 0.0) - taken, 0.0)

func _initialize_remaining_resources() -> void:
	remaining_resources = required_resources.duplicate(true)
