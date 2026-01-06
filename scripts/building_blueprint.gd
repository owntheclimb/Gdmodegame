extends Resource
class_name BuildingBlueprint

@export var building_name := ""
@export var required_resources := {"wood": 5.0, "stone": 2.0}
@export var build_time := 8.0
@export var building_scene: PackedScene
