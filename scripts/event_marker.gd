extends Area2D

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("event_marker")
	_setup_placeholder_sprite()
	_register_task()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(12, 12, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.4, 0.9))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _register_task() -> void:
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	var task := Task.new()
	task.task_id = "event_%s" % get_instance_id()
	task.task_type = "investigate_event"
	task.priority = 5
	task.target_node_path = get_path()
	task_board.add_task(task)
