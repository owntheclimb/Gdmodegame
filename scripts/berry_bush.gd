extends ResourceNode

@export var food_amount := 25.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	super._ready()
	add_to_group("berry_bush")
	resource_type = "food"
	amount = food_amount
	respawn_scene = preload("res://scenes/BerryBush.tscn")
	_setup_placeholder_sprite()
	_register_task()

func consume() -> float:
	var eaten := take(10.0)
	if amount <= 0.0:
		deplete()
	return eaten

func _register_task() -> void:
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	var task := Task.new()
	task.task_id = "food_%s" % get_instance_id()
	task.task_type = "gather_food"
	task.priority = 3
	task.target_node_path = get_path()
	task_board.add_task(task)

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.3, 0.7, 0.4))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
