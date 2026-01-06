extends Node
class_name PopulationManager

@export var villager_scene: PackedScene = preload("res://scenes/Villager.tscn")
@export var birth_cooldown := 20.0

var _last_birth_time := -100.0

func _ready() -> void:
	add_to_group("population_manager")

func queue_birth(position: Vector2, parent_a: Villager = null, parent_b: Villager = null) -> void:
	var now := Time.get_unix_time_from_system()
	if now - _last_birth_time < birth_cooldown:
		return
	_last_birth_time = now
	_spawn_villager(position, parent_a, parent_b)

func _spawn_villager(position: Vector2, parent_a: Villager, parent_b: Villager) -> void:
	var villager := villager_scene.instantiate()
	villager.global_position = position
	if parent_a and parent_b:
		var inherited := []
		if parent_a.traits.size() > 0:
			inherited.append(parent_a.traits.pick_random())
		if parent_b.traits.size() > 0:
			inherited.append(parent_b.traits.pick_random())
		if randf() < 0.2:
			var traits_db := get_tree().get_first_node_in_group("traits_db")
			if traits_db:
				inherited.append(traits_db.traits.pick_random())
		villager.traits = inherited
	get_tree().get_root().add_child(villager)
