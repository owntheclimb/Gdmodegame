extends Node2D
class_name ConstructionSite

@export var required_resources := {"wood": 10.0}
@export var build_time := 10.0
@export var building_scene: PackedScene

var progress := 0.0
var _task_registered := false

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("construction_site")
	_setup_placeholder_sprite()
	_register_task()

func apply_build(delta: float) -> bool:
	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if not _has_required_resources(storage):
		return false
	_consume_resources(storage)
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

func _has_required_resources(storage: Storage) -> bool:
	if not storage:
		return false
	for resource_type in required_resources.keys():
		if storage.get_amount(resource_type) < required_resources[resource_type]:
			return false
	return true

func _consume_resources(storage: Storage) -> void:
	if not storage:
		return
	for resource_type in required_resources.keys():
		storage.withdraw(resource_type, required_resources[resource_type])
