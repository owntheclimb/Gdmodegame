extends Node
class_name EventManager

signal event_created(event_info: Dictionary)

@export var spawn_interval := 12.0
@export var max_active_events := 3
@export var event_location_scene: PackedScene

var _templates: Array[EventTemplate] = []
var _active_events: Array[Dictionary] = []

@onready var _timer := Timer.new()

func _ready() -> void:
	add_to_group("event_manager")
	randomize()
	_templates = EventTemplate.default_templates()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.one_shot = false
	_timer.timeout.connect(_on_spawn_timer)
	add_child(_timer)

	var task_board := _get_task_board()
	if task_board:
		task_board.task_completed.connect(_on_task_completed)

	var game_state := _get_game_state()
	if game_state:
		game_state.action_recorded.connect(_on_action_recorded)

func _on_spawn_timer() -> void:
	_generate_event()

func _on_task_completed(_task: Task) -> void:
	var game_state := _get_game_state()
	if game_state:
		game_state.record_action("completed_task")

func _on_action_recorded(_action: String) -> void:
	if _active_events.size() < max_active_events and randf() < 0.3:
		_generate_event()

func _generate_event() -> void:
	if _active_events.size() >= max_active_events:
		return
	var template := _choose_template()
	if not template:
		return

	var world := _get_world()
	if not world:
		return

	var location := _spawn_location(template, world)
	if not location:
		return

	var task_board := _get_task_board()
	if not task_board:
		return

	var task := Task.new()
	task.task_id = "%s_%s" % [template.template_id, str(Time.get_ticks_msec())]
	task.task_type = template.task_type
	task.priority = template.priority
	task.target_node_path = location.get_path()
	task_board.add_task(task)

	var event_info := {
		"template": template,
		"location": location,
		"task": task,
	}
	_active_events.append(event_info)
	event_created.emit(event_info)

func _choose_template() -> EventTemplate:
	if _templates.is_empty():
		return null

	var game_state := _get_game_state()
	var biome := "grassland"
	if game_state:
		biome = game_state.current_biome

	var biome_templates := _templates.filter(func(t: EventTemplate) -> bool:
		return t.biome == biome
	)
	if biome_templates.is_empty():
		biome_templates = _templates.duplicate()

	var action_templates := biome_templates.filter(func(t: EventTemplate) -> bool:
		if t.related_action.is_empty():
			return true
		if game_state:
			return game_state.has_recent_action(t.related_action)
		return false
	)
	if not action_templates.is_empty():
		return action_templates[randi() % action_templates.size()]
	return biome_templates[randi() % biome_templates.size()]

func _spawn_location(template: EventTemplate, world: Node) -> Node2D:
	if not event_location_scene:
		return null
	var location := event_location_scene.instantiate()
	if not (location is Node2D):
		location.queue_free()
		return null
	location.location_type = template.location_type
	location.title = template.title
	location.description = template.description
	location.reward_resource = template.reward_resource
	location.reward_amount = template.reward_amount
	location.reward_action = template.reward_action
	var position := world.get_random_walkable_position()
	location.global_position = position
	get_tree().current_scene.add_child(location)
	return location

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state")

func _get_task_board() -> TaskBoard:
	return get_tree().get_first_node_in_group("task_board")

func _get_world() -> Node:
	return get_tree().get_first_node_in_group("world")
