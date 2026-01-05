extends CharacterBody2D

enum State { IDLE, WANDER, WORKING, DRAGGED, ROMANCE, EAT, COLLECT, DEPOSIT }

@export var max_speed := 60.0
@export var health := 100.0
@export var hunger := 100.0
@export var age := 18
@export var gender := "Female"

var state: State = State.IDLE
var target_position: Vector2
var current_task := ""

var carried_resource_type := ""
var carried_amount := 0.0
var target_resource: ResourceNode

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
		State.WANDER, State.WORKING, State.EAT, State.ROMANCE, State.COLLECT, State.DEPOSIT:
			_move_toward_target(delta)

func _update_needs(delta: float) -> void:
	hunger = max(hunger - delta * 0.5, 0.0)

func _handle_idle(delta: float) -> void:
	_idle_timer += delta
	if _idle_timer < _idle_interval:
		return

	_idle_timer = 0.0
	if carried_amount > 0.0:
		var storage := _get_storage()
		if storage:
			current_task = "Deposit"
			state = State.DEPOSIT
			target_position = storage.global_position
			return

	if hunger < 30.0:
		var storage := _get_storage()
		if storage and storage.get_amount("food") > 0.0:
			current_task = "Eat"
			state = State.EAT
			target_position = storage.global_position
			return
		var food_node := _find_nearest_resource("food")
		if food_node:
			_start_collect(food_node)
			return

	var resource := _find_nearest_resource("")
	if resource:
		_start_collect(resource)
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
			var storage := _get_storage()
			if storage:
				var consumed := storage.consume("food", 20.0)
				hunger = min(hunger + consumed, 100.0)
		State.COLLECT:
			if target_resource and target_resource.is_inside_tree():
				if target_resource.global_position.distance_to(global_position) < 10.0:
					var amount := target_resource.harvest()
					if amount > 0.0:
						carried_resource_type = target_resource.resource_type
						carried_amount = amount
				target_resource = null
				if carried_amount > 0.0:
					var storage := _get_storage()
					if storage:
						current_task = "Deposit"
						state = State.DEPOSIT
						target_position = storage.global_position
						return
		State.DEPOSIT:
			var storage := _get_storage()
			if storage:
				storage.deposit(carried_resource_type, carried_amount)
			carried_resource_type = ""
			carried_amount = 0.0
		State.ROMANCE:
			current_task = ""
	state = State.IDLE

func _find_nearest_resource(resource_type: String) -> ResourceNode:
	var resources := get_tree().get_nodes_in_group("resource")
	var nearest: ResourceNode = null
	var nearest_distance := INF
	for resource in resources:
		if not (resource is ResourceNode):
			continue
		if resource.resource_amount <= 0.0:
			continue
		if resource_type != "" and resource.resource_type != resource_type:
			continue
		var distance := global_position.distance_to(resource.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = resource
	return nearest

func _start_collect(resource: ResourceNode) -> void:
	if not resource:
		return
	current_task = "Collect %s" % resource.resource_type.capitalize()
	state = State.COLLECT
	target_resource = resource
	target_position = resource.global_position

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

func _get_storage() -> Storage:
	return get_tree().get_first_node_in_group("storage") as Storage

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.8, 0.6))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture
