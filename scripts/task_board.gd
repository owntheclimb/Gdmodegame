extends Node
class_name TaskBoard

signal task_added(task: Task)
signal task_completed(task: Task)

var _tasks: Array[Task] = []

func add_task(task: Task) -> void:
	_tasks.append(task)
	task_added.emit(task)

func request_task(villager: Node) -> Task:
	var open_tasks := _tasks.filter(func(t: Task) -> bool:
		return t.status == Task.TaskStatus.OPEN
	)
	if open_tasks.is_empty():
		return null

	open_tasks.sort_custom(func(a: Task, b: Task) -> bool:
		return a.priority > b.priority
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
