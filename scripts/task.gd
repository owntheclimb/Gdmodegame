extends Resource
class_name Task

enum TaskStatus { OPEN, CLAIMED, IN_PROGRESS, COMPLETE, EXPIRED }

@export var task_id := ""
@export var task_type := ""
@export var priority := 0
@export var target_world_position := Vector2.ZERO
@export var target_node_path: NodePath
@export var status := TaskStatus.OPEN
@export var assigned_villager_path: NodePath
@export var created_at := 0.0
@export var ttl_seconds := 120.0

func assign_to(villager: Node) -> void:
	status = TaskStatus.CLAIMED
	assigned_villager_path = villager.get_path()

func start() -> void:
	status = TaskStatus.IN_PROGRESS

func mark_complete() -> void:
	status = TaskStatus.COMPLETE

func release() -> void:
	status = TaskStatus.OPEN
	assigned_villager_path = NodePath()

func mark_expired() -> void:
	status = TaskStatus.EXPIRED

func is_expired(now: float) -> bool:
	return status == TaskStatus.OPEN and now - created_at > ttl_seconds

func get_target_position(tree: SceneTree) -> Vector2:
	if target_node_path != NodePath():
		var node := tree.get_root().get_node_or_null(target_node_path)
		if node and node is Node2D:
			return node.global_position
	return target_world_position
