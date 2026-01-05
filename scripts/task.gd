extends Resource
class_name Task

enum TaskStatus { OPEN, CLAIMED, COMPLETE }

@export var task_id := ""
@export var task_type := ""
@export var priority := 0
@export var target_world_position := Vector2.ZERO
@export var target_node_path: NodePath
@export var status := TaskStatus.OPEN
@export var assigned_villager_path: NodePath

func assign_to(villager: Node) -> void:
	status = TaskStatus.CLAIMED
	assigned_villager_path = villager.get_path()

func mark_complete() -> void:
	status = TaskStatus.COMPLETE

func get_target_position(tree: SceneTree) -> Vector2:
	if target_node_path != NodePath():
		var node := tree.get_root().get_node_or_null(target_node_path)
		if node and node is Node2D:
			return node.global_position
	return target_world_position
