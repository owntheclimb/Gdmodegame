extends Node
class_name TaskBoard

signal task_added(task: Task)
signal task_completed(task: Task)

var _tasks: Array[Task] = []

func _ready() -> void:
	add_to_group("task_board")

func add_task(task: Task) -> void:
	_tasks.append(task)
	task_added.emit(task)

func request_task(villager: Node2D) -> Task:
	var open_tasks := _tasks.filter(func(t: Task) -> bool:
		return t.status == Task.TaskStatus.OPEN
	)
	if open_tasks.is_empty():
		return null

	open_tasks.sort_custom(func(a: Task, b: Task) -> bool:
		return _score_task(a, villager) > _score_task(b, villager)
	)

	var task := open_tasks[0]
	task.assign_to(villager)
	return task

func complete_task(task: Task) -> void:
	if not task:
		return
	task.mark_complete()
	task_completed.emit(task)

func get_open_tasks() -> Array[Task]:
	return _tasks.filter(func(t: Task) -> bool:
		return t.status == Task.TaskStatus.OPEN
	)

func _score_task(task: Task, villager: Node2D) -> float:
	var target_position := task.get_target_position(get_tree())
	var distance := villager.global_position.distance_to(target_position)
	return task.priority * 1000.0 - distance
