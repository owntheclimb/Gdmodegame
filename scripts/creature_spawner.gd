extends Node
class_name CreatureSpawner

@export var max_creatures := 18
@export var spawn_interval := 6.0

@onready var creature_scene: PackedScene = preload("res://scenes/Creature.tscn")
@onready var _timer := Timer.new()

func _ready() -> void:
	add_to_group("creature_spawner")
	randomize()
	_timer.wait_time = spawn_interval
	_timer.autostart = true
	_timer.one_shot = false
	_timer.timeout.connect(_on_spawn_timer)
	add_child(_timer)
	_spawn_initial()

func _spawn_initial() -> void:
	for _i in range(6):
		_spawn_creature()

func _on_spawn_timer() -> void:
	_spawn_creature()

func _spawn_creature() -> void:
	if not creature_scene:
		return
	var existing := get_tree().get_nodes_in_group("creature").size()
	if existing >= max_creatures:
		return
	var world := _get_world()
	if not world:
		return
	var position := world.get_random_walkable_position()
	if position == Vector2.ZERO:
		return
	var creature := creature_scene.instantiate()
	_configure_creature(creature, world.get_biome_at_position(position))
	if creature is Node2D:
		creature.global_position = position
	get_tree().current_scene.add_child(creature)

func _configure_creature(creature: Node, biome: String) -> void:
	if not (creature is Creature):
		return
	var catalog := _get_catalog_for_biome(biome)
	var selection := catalog[randi() % catalog.size()]
	creature.species = selection["species"]
	creature.temperament = selection["temperament"]
	creature.max_speed = selection["speed"]
	creature.health = selection["health"]
	creature.attack_power = selection["attack"]
	creature.resource_drop = selection["resource"]
	creature.resource_amount = selection["amount"]

func _get_catalog_for_biome(biome: String) -> Array:
	match biome:
		"forest":
			return [
				{"species": "Deer", "temperament": Creature.Temperament.TIMID, "speed": 55.0, "health": 24.0, "attack": 4.0, "resource": "food", "amount": 9.0},
				{"species": "Boar", "temperament": Creature.Temperament.AGGRESSIVE, "speed": 40.0, "health": 32.0, "attack": 7.0, "resource": "food", "amount": 12.0},
				{"species": "Wolf", "temperament": Creature.Temperament.AGGRESSIVE, "speed": 60.0, "health": 28.0, "attack": 8.0, "resource": "food", "amount": 10.0}
			]
		"highlands":
			return [
				{"species": "Goat", "temperament": Creature.Temperament.TIMID, "speed": 50.0, "health": 22.0, "attack": 4.0, "resource": "food", "amount": 8.0},
				{"species": "Bear", "temperament": Creature.Temperament.AGGRESSIVE, "speed": 35.0, "health": 45.0, "attack": 10.0, "resource": "food", "amount": 16.0}
			]
		"coastal":
			return [
				{"species": "Seabird", "temperament": Creature.Temperament.TIMID, "speed": 65.0, "health": 18.0, "attack": 3.0, "resource": "food", "amount": 6.0},
				{"species": "Crab", "temperament": Creature.Temperament.NEUTRAL, "speed": 30.0, "health": 20.0, "attack": 4.0, "resource": "food", "amount": 7.0}
			]
		_:
			return [
				{"species": "Deer", "temperament": Creature.Temperament.TIMID, "speed": 55.0, "health": 24.0, "attack": 4.0, "resource": "food", "amount": 9.0},
				{"species": "Boar", "temperament": Creature.Temperament.AGGRESSIVE, "speed": 40.0, "health": 32.0, "attack": 7.0, "resource": "food", "amount": 12.0}
			]

func _get_world() -> Node:
	return get_tree().get_first_node_in_group("world")
