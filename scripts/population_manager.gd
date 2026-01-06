extends Node
class_name PopulationManager

@export var villager_scene: PackedScene = preload("res://scenes/Villager.tscn")
@export var birth_cooldown := 20.0

var _last_birth_time := -100.0

func _ready() -> void:
	add_to_group("population_manager")

func queue_birth(position: Vector2) -> void:
	var now := Time.get_unix_time_from_system()
	if now - _last_birth_time < birth_cooldown:
		return
	_last_birth_time = now
	_spawn_villager(position)

func _spawn_villager(position: Vector2) -> void:
	var villager := villager_scene.instantiate()
	villager.global_position = position
	get_tree().get_root().add_child(villager)
