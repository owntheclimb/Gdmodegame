extends Node2D
class_name ConstructionSite

@export var required_resources := {"wood": 10.0}
@export var build_time := 10.0

var progress := 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("construction_site")
	_setup_placeholder_sprite()
	_register_task()

func apply_build(delta: float) -> void:
	progress = min(progress + delta, build_time)
	if progress >= build_time:
		_finish_construction()
	else:
		_register_task()

func _finish_construction() -> void:
	queue_free()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(20, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.8, 0.6, 0.2))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _register_task() -> void:
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	var task := Task.new()
	task.task_id = "build_%s" % get_instance_id()
	task.task_type = "build"
	task.priority = 8
	task.target_node_path = get_path()
	task_board.add_task(task)
