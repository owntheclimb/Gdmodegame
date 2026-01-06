extends ResourceNode

@export var wood_amount := 20.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	super._ready()
	add_to_group("tree")
	resource_type = "wood"
	amount = wood_amount
	respawn_scene = preload("res://scenes/Tree.tscn")
	_setup_placeholder_sprite()
	_register_task()

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(14, 18, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.2, 0.6, 0.2))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _register_task() -> void:
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	var task := Task.new()
	task.task_id = "wood_%s" % get_instance_id()
	task.task_type = "gather_wood"
	task.priority = 4
	task.target_node_path = get_path()
	task_board.add_task(task)
