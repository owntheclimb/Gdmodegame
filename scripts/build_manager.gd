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
	var blueprint := BuildingBlueprint.new()
	blueprint.building_name = "Hut"
	blueprint.required_resources = {"wood": 5.0, "stone": 2.0}
	blueprint.build_time = 8.0
	blueprint.building_scene = default_building_scene
	var tech_manager := get_tree().get_first_node_in_group("tech_manager")
	if tech_manager and "Stoneworking" in tech_manager.tech_tree.unlocked:
		blueprint.build_time = 6.0
	if tech_manager and "Farming" in tech_manager.tech_tree.unlocked:
		blueprint.required_resources["wood"] = 4.0
	if site.has_method("configure"):
		site.configure(blueprint)
	var world := get_tree().get_first_node_in_group("world")
	if world and not world.is_walkable_world(position):
		return
	site.global_position = position
	get_tree().get_root().add_child(site)
