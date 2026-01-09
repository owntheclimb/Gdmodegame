extends Node
class_name TaskBoard

signal task_added(task: Task)
signal task_completed(task: Task)

@export var villager_claim_cooldown := 1.5

var _tasks: Array = []
var _tasks_by_target: Dictionary = {}
var _villager_last_claim: Dictionary = {}

func _ready() -> void:
	add_to_group("task_board")
	get_tree().node_added.connect(_on_node_added)
	_register_existing_world_tasks()

func add_task(task: Task) -> void:
	_tasks.append(task)
	task_added.emit(task)

func add_task_from_world_object(world_object: Node2D, task_type: String, priority: int = 0, required_tags: Array[String] = [], expires_at: float = -1.0, claim_cooldown: float = 0.0) -> Task:
	if not world_object:
		return null
	var target_path := world_object.get_path()
	if _tasks_by_target.has(target_path):
		return _tasks_by_target[target_path]

	var task := Task.new()
	task.task_id = "%s:%s" % [task_type, str(target_path)]
	task.task_type = task_type
	task.priority = priority
	task.target_node_path = target_path
	task.target_world_position = world_object.global_position
	task.required_tags = required_tags
	task.expires_at = expires_at
	task.claim_cooldown = claim_cooldown
	_tasks_by_target[target_path] = task
	add_task(task)
	return task

func request_task(villager: Node) -> Task:
	if not villager:
		return null
	var now := _now()
	if _is_villager_on_cooldown(villager, now):
		return null

	var task := get_best_task_for(villager)
	if not task:
		return null

	if not claim_task(task, villager):
		return null
	return task

func claim_task(task: Task, villager: Node) -> bool:
	if not task or not villager:
		return false
	var now := _now()
	if _is_villager_on_cooldown(villager, now):
		return false
	if not _is_task_available(task, villager, now):
		return false
	task.assign_to(villager)
	_villager_last_claim[villager.get_path()] = now
	return true

func get_best_task_for(villager: Node) -> Task:
	if not villager:
		return null
	var now := _now()
	var villager_position := _get_villager_position(villager)
	var best_task: Task = null
	var best_score := -INF

	for task in _tasks:
		if not _is_task_available(task, villager, now):
			continue
		var target_position := _get_task_target_position(task)
		var distance := villager_position.distance_to(target_position)
		var score := float(task.priority) - distance
		if score > best_score:
			best_score = score
			best_task = task

	return best_task

func complete_task(task: Task) -> void:
	if not task:
		return
	task.mark_complete()
	task_completed.emit(task)
	_tasks.erase(task)
	if task.target_node_path != NodePath() and _tasks_by_target.has(task.target_node_path):
		_tasks_by_target.erase(task.target_node_path)

func get_open_tasks() -> Array:
	return _tasks.filter(func(t: Task) -> bool:
		return t.status == Task.TaskStatus.OPEN
	)

func _register_existing_world_tasks() -> void:
	for rock in get_tree().get_nodes_in_group("rock"):
		_try_register_world_task(rock)
	for tree in get_tree().get_nodes_in_group("tree"):
		_try_register_world_task(tree)
	for bush in get_tree().get_nodes_in_group("berry_bush"):
		_try_register_world_task(bush)
	for creature in get_tree().get_nodes_in_group("creature"):
		_try_register_world_task(creature)
	for building in get_tree().get_nodes_in_group("building"):
		_try_register_world_task(building)

func _on_node_added(node: Node) -> void:
	_try_register_world_task(node)

func _try_register_world_task(node: Node) -> void:
	if not (node is Node2D):
		return
	if node.is_in_group("rock"):
		add_task_from_world_object(node, "clear_rock", 6)
	elif node.is_in_group("tree"):
		add_task_from_world_object(node, "gather_wood", 5)
	elif node.is_in_group("berry_bush"):
		add_task_from_world_object(node, "harvest_berries", 4)
	elif node.is_in_group("creature"):
		add_task_from_world_object(node, "hunt_creature", 6)
	elif node.is_in_group("building"):
		add_task_from_world_object(node, "maintain_building", 5)

func _get_task_target_position(task: Task) -> Vector2:
	if task.target_node_path != NodePath():
		var target_node := _get_target_node(task.target_node_path)
		if target_node:
			return target_node.global_position
	return task.target_world_position

func _get_target_node(path: NodePath) -> Node2D:
	if path == NodePath():
		return null
	return get_tree().root.get_node_or_null(path) as Node2D

func _is_task_available(task: Task, villager: Node, now: float) -> bool:
	if task.status != Task.TaskStatus.OPEN:
		return false
	if task.expires_at > 0.0 and now >= task.expires_at:
		return false
	if not _villager_meets_tags(villager, task.required_tags):
		return false
	if task.claim_cooldown > 0.0 and (now - task.last_claimed_at) < task.claim_cooldown:
		return false
	return true

func _villager_meets_tags(villager: Node, tags: Array[String]) -> bool:
	if tags.is_empty():
		return true
	for tag in tags:
		if not villager.is_in_group(tag):
			return false
	return true

func _get_villager_position(villager: Node) -> Vector2:
	if villager is Node2D:
		return villager.global_position
	return Vector2.ZERO

func _is_villager_on_cooldown(villager: Node, now: float) -> bool:
	var path := villager.get_path()
	if not _villager_last_claim.has(path):
		return false
	return (now - _villager_last_claim[path]) < villager_claim_cooldown

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
