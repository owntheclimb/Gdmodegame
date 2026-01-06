extends Area2D
class_name ResourceNode

@export var resource_type := ""
@export var amount := 25.0
@export var respawn_time := 30.0
@export var respawn_scene: PackedScene

func harvest() -> float:
	var harvested := amount
	amount = 0.0
	return harvested

func take(requested: float) -> float:
	var taken := min(amount, requested)
	amount -= taken
	return taken

func deplete() -> void:
	if respawn_scene and respawn_time > 0.0:
		var position := global_position
		var parent_node := get_parent()
		get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
			var respawned := respawn_scene.instantiate()
			respawned.global_position = position
			parent_node.add_child(respawned)
		)
	queue_free()
