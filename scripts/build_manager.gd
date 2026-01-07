extends Node2D
class_name BuildManager

@onready var construction_site_scene: PackedScene = preload("res://scenes/ConstructionSite.tscn")
@onready var default_building_scene: PackedScene = preload("res://scenes/Building.tscn")

func _ready() -> void:
	add_to_group("build_manager")
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_building"):
		_place_construction_site(get_global_mouse_position())

func _place_construction_site(position: Vector2) -> void:
	var site := construction_site_scene.instantiate()
	var blueprint := Blueprint.new()
	blueprint.name = "Hut"
	blueprint.costs = {"wood": 5.0, "stone": 2.0}
	blueprint.build_time = 8.0
	blueprint.building_scene = default_building_scene
	if site.has_method("assign_blueprint"):
		site.assign_blueprint(blueprint)
	var world := get_tree().get_first_node_in_group("world")
	if world and not world.is_walkable_world(position):
		return
	site.global_position = position
	get_tree().get_root().add_child(site)
