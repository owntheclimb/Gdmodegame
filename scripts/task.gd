extends Resource
class_name Task

enum TaskStatus { OPEN, CLAIMED, COMPLETE }

@export var task_id := ""
@export var task_type := ""
@export var priority := 0
@export var target_world_position := Vector2.ZERO
@export var required_tags: Array[String] = []
@export var expires_at := -1.0
@export var claim_cooldown := 0.0
@export var target_node_path: NodePath
@export var status := TaskStatus.OPEN
@export var assigned_villager_path: NodePath
var last_claimed_at := -INF

func assign_to(villager: Node) -> void:
	status = TaskStatus.CLAIMED
	assigned_villager_path = villager.get_path()
	last_claimed_at = Time.get_ticks_msec() / 1000.0

func mark_complete() -> void:
	status = TaskStatus.COMPLETE
