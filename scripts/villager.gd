extends CharacterBody2D

enum State { IDLE, WANDER, WORKING, DRAGGED, ROMANCE, EAT }

@export var max_speed := 60.0
@export var health := 100.0
@export var hunger := 100.0
@export var energy := 100.0
@export var age := 18
@export var gender := "Female"

var state: State = State.IDLE
var target_position: Vector2
var current_task := ""
var assigned_task: Task
var traits: Array[Trait] = []

var _speed_multiplier := 1.0
var _hunger_multiplier := 1.0
var _prefers_events := false
var _avoids_beach := false

var _idle_timer := 0.0
var _idle_interval := 2.0

@onready var drop_detector: Area2D = $DropDetector
@onready var sprite: Sprite2D = $Sprite
@onready var task_board: TaskBoard = _get_task_board()
@onready var day_night: DayNightCycle = _get_day_night()
@onready var storage: Storage = _get_storage()
@onready var traits_db: TraitsDB = _get_traits_db()
@onready var population_manager: PopulationManager = _get_population_manager()

func _ready() -> void:
	randomize()
	add_to_group("villager")
	_setup_placeholder_sprite()
	_assign_traits()
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
	var hunger_rate := 0.5 * _hunger_multiplier
	if day_night and day_night.is_night:
		hunger_rate *= 1.1
	hunger = max(hunger - delta * hunger_rate, 0.0)
	energy = max(energy - delta * 0.3, 0.0)
	if hunger <= 0.0:
		health = max(health - delta * 1.0, 0.0)
		if health <= 0.0:
			queue_free()
			var game_state: GameState = get_tree().get_first_node_in_group("game_state")
			if game_state:
				game_state.check_population()
	elif energy > 80.0 and hunger > 50.0:
		health = min(health + delta * 0.4, 100.0)

func _handle_idle(delta: float) -> void:
	_idle_timer += delta
	if _idle_timer < _idle_interval:
		return

	_idle_timer = 0.0
	if energy < 20.0 and day_night and day_night.is_night:
		current_task = "Resting"
		state = State.IDLE
		energy = min(energy + 20.0, 100.0)
		return
	if hunger < 30.0:
		if storage and storage.get_amount("food") > 0.0:
			hunger = min(hunger + storage.withdraw("food", 20.0), 100.0)
			return
		var bush := _find_nearest_berry_bush()
		if bush:
			current_task = "Eat"
			state = State.EAT
			target_position = bush.global_position
			return
		if task_board:
			var food_task := task_board.request_task_by_type(self, "gather_food")
			if food_task:
				assigned_task = food_task
				current_task = food_task.task_type
				target_position = food_task.get_target_position(get_tree())
				assigned_task.start()
				state = State.WORKING
				return
	elif storage and storage.get_amount("food") < 30.0 and task_board:
		var stock_task := task_board.request_task_by_type(self, "gather_food")
		if stock_task:
			assigned_task = stock_task
			current_task = stock_task.task_type
			target_position = stock_task.get_target_position(get_tree())
			assigned_task.start()
			state = State.WORKING
			return

	if assigned_task == null:
		var task: Task = null
		if task_board and _prefers_events:
			task = task_board.request_task_by_type(self, "investigate_event")
		if task_board and not task:
			task = task_board.request_task(self)
		if task:
			assigned_task = task
			current_task = task.task_type
			target_position = task.get_target_position(get_tree())
			assigned_task.start()
			state = State.WORKING
			return

	var world := _get_world()
	if not world:
		return

	for _i in 8:
		var candidate := global_position + Vector2(randf_range(-100.0, 100.0), randf_range(-100.0, 100.0))
		if _avoids_beach and world.get_biome_at(candidate) == "beach":
			continue
		if world.is_walkable_world(candidate):
			state = State.WANDER
			target_position = candidate
			return

func _move_toward_target(delta: float) -> void:
	var distance := global_position.distance_to(target_position)
	if distance < 4.0:
		_finish_task_on_arrival()
		return

	velocity = (target_position - global_position).normalized() * max_speed * _speed_multiplier
	move_and_slide()

func _finish_task_on_arrival() -> void:
	match state:
		State.EAT:
			var bush := _find_nearest_berry_bush()
			if bush and bush.global_position.distance_to(global_position) < 10.0:
				hunger = min(hunger + bush.consume(), 100.0)
		State.WORKING:
			if assigned_task:
				if assigned_task.task_type == "clear_rubble":
					var target := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if target and target.is_in_group("rock"):
						target.queue_free()
				if assigned_task.task_type == "gather_food":
					var target_node := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if target_node and target_node is ResourceNode:
						var gathered := target_node.harvest()
						if storage:
							storage.deposit("food", gathered)
						target_node.deplete()
				if assigned_task.task_type == "gather_wood":
					var wood_node := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if wood_node and wood_node is ResourceNode:
						var gathered_wood := wood_node.harvest()
						if storage:
							storage.deposit("wood", gathered_wood)
						wood_node.deplete()
				if assigned_task.task_type == "gather_stone":
					var stone_node := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if stone_node and stone_node is ResourceNode:
						var gathered_stone := stone_node.harvest()
						if storage:
							storage.deposit("stone", gathered_stone)
						stone_node.deplete()
				if assigned_task.task_type == "build":
					var site := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if site and site is ConstructionSite:
						var progressed := site.apply_build(1.0)
						if not progressed and task_board:
							task_board.release_task(assigned_task)
							assigned_task = null
							state = State.IDLE
							return
				if assigned_task.task_type == "deliver_resource":
					var site := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					var resource_type := assigned_task.metadata.get("resource_type", "")
					if site and site is ConstructionSite and storage and resource_type != "":
						var delivered := storage.withdraw(resource_type, 2.0)
						if delivered > 0.0:
							site.deliver_resource(resource_type, delivered)
						else:
							if task_board:
								task_board.release_task(assigned_task)
							assigned_task = null
							state = State.IDLE
							return
				if assigned_task.task_type == "investigate_event":
					var event_marker := get_tree().get_root().get_node_or_null(assigned_task.target_node_path)
					if event_marker:
						event_marker.queue_free()
					if storage and assigned_task.metadata.has("reward_food"):
						storage.deposit("food", assigned_task.metadata["reward_food"])
				if task_board:
					task_board.complete_task(assigned_task)
				assigned_task = null
		State.ROMANCE:
			current_task = ""
			if population_manager:
				population_manager.queue_birth(global_position + Vector2(10, 0))
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

func _get_task_board() -> TaskBoard:
	return get_tree().get_first_node_in_group("task_board")

func _get_day_night() -> DayNightCycle:
	return get_tree().get_first_node_in_group("day_night")

func _get_storage() -> Storage:
	return get_tree().get_first_node_in_group("storage")

func _get_traits_db() -> TraitsDB:
	return get_tree().get_first_node_in_group("traits_db")

func _get_population_manager() -> PopulationManager:
	return get_tree().get_first_node_in_group("population_manager")

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(16, 20, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.9, 0.8, 0.6))
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func set_selected(is_selected: bool) -> void:
	sprite.modulate = Color(1, 0.9, 0.6) if is_selected else Color(1, 1, 1)

func _assign_traits() -> void:
	if not traits_db:
		return
	traits = traits_db.get_random_traits(1)
	_speed_multiplier = 1.0
	_hunger_multiplier = 1.0
	_prefers_events = false
	_avoids_beach = false
	for trait in traits:
		_speed_multiplier *= trait.speed_multiplier
		_hunger_multiplier *= trait.hunger_multiplier
		_prefers_events = _prefers_events or trait.prefers_events
		_avoids_beach = _avoids_beach or trait.avoids_beach
