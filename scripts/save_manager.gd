extends Node
class_name SaveManager

const SAVE_PATH := "user://savegame.json"
const VILLAGER_SCENE: PackedScene = preload("res://scenes/Villager.tscn")
const CONSTRUCTION_SITE_SCENE: PackedScene = preload("res://scenes/ConstructionSite.tscn")
const DEFAULT_BUILDING_SCENE: PackedScene = preload("res://scenes/Building.tscn")
const RESOURCE_SCENES := {
	"wood": preload("res://scenes/Tree.tscn"),
	"stone": preload("res://scenes/Stone.tscn"),
	"food": preload("res://scenes/BerryBush.tscn")
}

func _ready() -> void:
	add_to_group("save_manager")
	set_process_input(true)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("save_game"):
		save_game()
	if event.is_action_pressed("load_game"):
		load_game()

func save_game() -> void:
	var data := {
		"villagers": [],
		"construction_sites": [],
		"buildings": [],
		"resources": [],
		"storage": {},
		"day": 0,
		"world_seed": 0
	}

	var game_state: GameState = get_tree().get_first_node_in_group("game_state")
	if game_state:
		data["day"] = game_state.days_survived

	var world := get_tree().get_first_node_in_group("world")
	if world:
		data["world_seed"] = world.get_seed()

	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if storage:
		data["storage"] = storage.resources

	for villager in get_tree().get_nodes_in_group("villager"):
		data["villagers"].append({
			"position": [villager.global_position.x, villager.global_position.y],
			"health": villager.health,
			"hunger": villager.hunger,
			"age": villager.age,
			"gender": villager.gender
		})

	for site in get_tree().get_nodes_in_group("construction_site"):
		var blueprint_path := ""
		var blueprint_data := {}
		if site is ConstructionSite:
			var site_blueprint := site.blueprint
			if site_blueprint:
				if site_blueprint.resource_path != "":
					blueprint_path = site_blueprint.resource_path
				else:
					blueprint_data = {
						"name": site_blueprint.name,
						"build_time": site_blueprint.build_time,
						"costs": site_blueprint.costs,
						"building_scene_path": site_blueprint.building_scene.resource_path if site_blueprint.building_scene else ""
					}
			var build_task_created := site.is_build_task_created() if site.has_method("is_build_task_created") else false
			data["construction_sites"].append({
				"position": [site.global_position.x, site.global_position.y],
				"blueprint_path": blueprint_path,
				"blueprint_data": blueprint_data,
				"remaining_costs": site.remaining_costs,
				"remaining_build_time": site.remaining_build_time,
				"build_task_created": build_task_created
			})

	for building in get_tree().get_nodes_in_group("building"):
		if building is Building:
			var building_blueprint_path := ""
			var building_blueprint_data := {}
			if building.blueprint:
				if building.blueprint.resource_path != "":
					building_blueprint_path = building.blueprint.resource_path
				else:
					building_blueprint_data = {
						"name": building.blueprint.name,
						"build_time": building.blueprint.build_time,
						"costs": building.blueprint.costs,
						"building_scene_path": building.blueprint.building_scene.resource_path if building.blueprint.building_scene else ""
					}
			data["buildings"].append({
				"position": [building.global_position.x, building.global_position.y],
				"scene_path": building.scene_file_path,
				"blueprint_path": building_blueprint_path,
				"blueprint_data": building_blueprint_data
			})

	for node in get_tree().get_nodes_in_group("resource"):
		if node is ResourceNode:
			data["resources"].append({
				"type": node.resource_type,
				"position": [node.global_position.x, node.global_position.y],
				"remaining_amount": node.resource_amount,
				"scene_path": node.scene_file_path
			})

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % SAVE_PATH)
		return
	file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: %s" % SAVE_PATH)
		return
	var content := file.get_as_text()
	var parsed := JSON.parse_string(content)
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	var data: Dictionary = parsed
	var game_state: GameState = get_tree().get_first_node_in_group("game_state")
	if game_state:
		game_state.days_survived = data.get("day", 0)

	var world := get_tree().get_first_node_in_group("world")
	if world:
		world.set_seed(data.get("world_seed", 0))

	var storage: Storage = get_tree().get_first_node_in_group("storage")
	if storage:
		var storage_data := data.get("storage", {})
		if typeof(storage_data) == TYPE_DICTIONARY:
			storage.resources = storage_data

	var villagers := get_tree().get_nodes_in_group("villager")
	var saved_villagers: Array = _as_array(data.get("villagers", []))
	_reconcile_villager_count(villagers, saved_villagers.size())
	villagers = get_tree().get_nodes_in_group("villager")
	var count := mini(villagers.size(), saved_villagers.size())
	for i in range(count):
		var info := saved_villagers[i]
		if typeof(info) != TYPE_DICTIONARY:
			continue
		var position := _as_vector2(info.get("position", null), villagers[i].global_position)
		villagers[i].global_position = position
		if _is_number(info.get("health", null)):
			villagers[i].health = float(info.get("health"))
		if _is_number(info.get("hunger", null)):
			villagers[i].hunger = float(info.get("hunger"))
		if _is_number(info.get("age", null)):
			villagers[i].age = int(info.get("age"))
		if typeof(info.get("gender", null)) == TYPE_STRING:
			villagers[i].gender = info.get("gender")

	_restore_construction_sites(_as_array(data.get("construction_sites", [])))
	_restore_buildings(_as_array(data.get("buildings", [])))
	_restore_resources(_as_array(data.get("resources", [])))

func _reconcile_villager_count(villagers: Array, target_count: int) -> void:
	if target_count < 0:
		target_count = 0
	for i in range(villagers.size() - 1, target_count - 1, -1):
		var villager := villagers[i]
		if villager and villager is Node:
			villager.queue_free()
	if villagers.size() >= target_count:
		return
	var to_spawn := target_count - villagers.size()
	for _i in range(to_spawn):
		var instance := VILLAGER_SCENE.instantiate()
		if instance is Node2D:
			instance.global_position = Vector2.ZERO
		var parent := get_tree().current_scene if get_tree().current_scene else get_tree().root
		parent.add_child(instance)

func _restore_construction_sites(saved_sites: Array) -> void:
	for site in get_tree().get_nodes_in_group("construction_site"):
		if site and site is Node:
			site.queue_free()
	for site_data in saved_sites:
		if typeof(site_data) != TYPE_DICTIONARY:
			continue
		var blueprint_path := _as_string(site_data.get("blueprint_path", ""))
		var blueprint_data := _as_dictionary(site_data.get("blueprint_data", {}))
		var blueprint := _load_blueprint(blueprint_path, blueprint_data)
		var remaining_costs := _as_dictionary(site_data.get("remaining_costs", {}))
		var remaining_time := _as_float(site_data.get("remaining_build_time", 0.0))
		var build_task_created := bool(site_data.get("build_task_created", false))
		var site := CONSTRUCTION_SITE_SCENE.instantiate()
		if site is ConstructionSite:
			site.apply_loaded_state(blueprint, remaining_costs, remaining_time, build_task_created)
		if site is Node2D:
			site.global_position = _as_vector2(site_data.get("position", null), Vector2.ZERO)
		var parent := get_tree().current_scene if get_tree().current_scene else get_tree().root
		parent.add_child(site)

func _restore_buildings(saved_buildings: Array) -> void:
	for building in get_tree().get_nodes_in_group("building"):
		if building and building is Node:
			building.queue_free()
	for building_data in saved_buildings:
		if typeof(building_data) != TYPE_DICTIONARY:
			continue
		var scene_path := _as_string(building_data.get("scene_path", ""))
		var scene := load(scene_path) if scene_path != "" else DEFAULT_BUILDING_SCENE
		if not (scene is PackedScene):
			scene = DEFAULT_BUILDING_SCENE
		var instance := scene.instantiate()
		if instance is Node2D:
			instance.global_position = _as_vector2(building_data.get("position", null), Vector2.ZERO)
		var blueprint_path := _as_string(building_data.get("blueprint_path", ""))
		var blueprint_data := _as_dictionary(building_data.get("blueprint_data", {}))
		var blueprint := _load_blueprint(blueprint_path, blueprint_data)
		if blueprint and instance.has_method("set_blueprint"):
			instance.set_blueprint(blueprint)
		var parent := get_tree().current_scene if get_tree().current_scene else get_tree().root
		parent.add_child(instance)

func _restore_resources(saved_resources: Array) -> void:
	for resource_node in get_tree().get_nodes_in_group("resource"):
		if resource_node and resource_node is Node:
			resource_node.queue_free()
	for resource_data in saved_resources:
		if typeof(resource_data) != TYPE_DICTIONARY:
			continue
		var resource_type := _as_string(resource_data.get("type", ""))
		var scene_path := _as_string(resource_data.get("scene_path", ""))
		var scene := load(scene_path) if scene_path != "" else RESOURCE_SCENES.get(resource_type, null)
		if not (scene is PackedScene):
			continue
		var instance := scene.instantiate()
		if instance is Node2D:
			instance.global_position = _as_vector2(resource_data.get("position", null), Vector2.ZERO)
		var parent := get_tree().current_scene if get_tree().current_scene else get_tree().root
		parent.add_child(instance)
		if instance is ResourceNode:
			if resource_type != "":
				instance.resource_type = resource_type
			var remaining_amount := _as_float(resource_data.get("remaining_amount", instance.resource_amount))
			instance.resource_amount = remaining_amount

func _as_array(value) -> Array:
	if typeof(value) == TYPE_ARRAY:
		return value
	return []

func _as_dictionary(value) -> Dictionary:
	if typeof(value) == TYPE_DICTIONARY:
		return value
	return {}

func _as_string(value) -> String:
	if typeof(value) == TYPE_STRING:
		return value
	return ""

func _as_float(value, default := 0.0) -> float:
	if _is_number(value):
		return float(value)
	return default

func _is_number(value) -> bool:
	return typeof(value) == TYPE_INT or typeof(value) == TYPE_FLOAT

func _as_vector2(value, fallback: Vector2) -> Vector2:
	if typeof(value) != TYPE_ARRAY:
		return fallback
	if value.size() < 2:
		return fallback
	if not _is_number(value[0]) or not _is_number(value[1]):
		return fallback
	return Vector2(float(value[0]), float(value[1]))

func _load_blueprint(blueprint_path: String, blueprint_data: Dictionary) -> Blueprint:
	if blueprint_path != "":
		var loaded := load(blueprint_path)
		if loaded is Blueprint:
			return loaded
	var name_value := blueprint_data.get("name", "")
	var build_time := blueprint_data.get("build_time", null)
	var costs := blueprint_data.get("costs", null)
	var building_scene_path := _as_string(blueprint_data.get("building_scene_path", ""))
	if typeof(name_value) != TYPE_STRING and not _is_number(build_time) and typeof(costs) != TYPE_DICTIONARY:
		return null
	var blueprint := Blueprint.new()
	if typeof(name_value) == TYPE_STRING:
		blueprint.name = name_value
	if _is_number(build_time):
		blueprint.build_time = float(build_time)
	if typeof(costs) == TYPE_DICTIONARY:
		blueprint.costs = costs
	if building_scene_path != "":
		var scene := load(building_scene_path)
		if scene is PackedScene:
			blueprint.building_scene = scene
	return blueprint
