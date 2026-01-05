extends CharacterBody2D

enum State { IDLE, WANDER, WORKING, DRAGGED, ROMANCE, EAT }

@export var max_speed := 60.0
@export var health := 100.0
@export var hunger := 100.0
@export var age := 18
@export var gender := "Female"

var state: State = State.IDLE
var target_position: Vector2
var current_task := ""

var _idle_timer := 0.0
var _idle_interval := 2.0

@onready var drop_detector: Area2D = $DropDetector
@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	randomize()
	add_to_group("villager")
	_setup_placeholder_sprite()
	state = State.IDLE

func _physics_process(delta: float) -> void:
	if state == State.DRAGGED:
		global_position = get_global_mouse_position()
		velocity = Vector2.ZERO
		move_and_slide()
		return

	_update_needs(delta)

	match state:
		State.IDLE:
			_handle_idle(delta)
		State.WANDER, State.WORKING, State.EAT, State.ROMANCE:
			_move_toward_target(delta)

func _update_needs(delta: float) -> void:
	hunger = max(hunger - delta * 0.5, 0.0)

func _handle_idle(delta: float) -> void:
	_idle_timer += delta
	if _idle_timer < _idle_interval:
		return

	_idle_timer = 0.0
	if hunger < 30.0:
		var bush := _find_nearest_berry_bush()
		if bush:
			current_task = "Eat"
			state = State.EAT
			target_position = bush.global_position
			return

	var world := _get_world()
	if not world:
		return

	for _i in 8:
		var candidate := global_position + Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
		if world.is_walkable_world(candidate):
			state = State.WANDER
			target_position = candidate
			return

func _move_toward_target(delta: float) -> void:
	var distance := global_position.distance_to(target_position)
	if distance < 4.0:
		_finish_task_on_arrival()
		return

	velocity = (target_position - global_position).normalized() * max_speed
	move_and_slide()

func _finish_task_on_arrival() -> void:
	match state:
		State.EAT:
			var bush := _find_nearest_berry_bush()
			if bush and bush.global_position.distance_to(global_position) < 10.0:
				hunger = min(hunger + bush.consume(), 100.0)
		State.ROMANCE:
			current_task = ""
	state = State.IDLE

func _find_nearest_berry_bush() -> Node2D:
	var bushes := get_tree().get_nodes_in_group("berry_bush")
	var nearest: Node2D = null
	var nearest_distance := INF
	for bush in bushes:
		var distance := global_position.distance_to(bush.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = bush
	return nearest

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			state = State.DRAGGED
		else:
			var drop_handled := _handle_drop()
			if not drop_handled:
				state = State.IDLE

func _handle_drop() -> bool:
	var overlapping_areas := drop_detector.get_overlapping_areas()
	var overlapping_bodies := drop_detector.get_overlapping_bodies()

	for area in overlapping_areas:
		if area.is_in_group("rock"):
			current_task = "Clearing Rubble"
			state = State.WORKING
			target_position = area.global_position
			return true

	for body in overlapping_bodies:
		if body == self:
			continue
		if body.is_in_group("villager"):
			if _can_romance_with(body):
				start_romance(body)
				return true

	return false

func _can_romance_with(other: Node) -> bool:
	if not other:
		return false
	if not (other is CharacterBody2D):
		return false
	if age < 18:
		return false
	if other.age < 18:
		return false
	return gender != other.gender

func start_romance(partner: Node2D) -> void:
	current_task = "Romance"
	state = State.ROMANCE
	target_position = partner.global_position
	if partner.has_method("receive_romance"):
		partner.receive_romance(global_position)

func receive_romance(partner_position: Vector2) -> void:
	current_task = "Romance"
	state = State.ROMANCE
	target_position = partner_position

func _get_world() -> Node:
	return get_tree().get_first_node_in_group("world")

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.8, 0.6))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
