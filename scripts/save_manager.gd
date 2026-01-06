extends Node
class_name SaveManager

const SAVE_PATH := "user://savegame.json"
@onready var villager_scene: PackedScene = preload("res://scenes/Villager.tscn")

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
		"storage": {},
		"day": 0,
		"world_seed": 0,
		"resources": [],
		"rocks": [],
		"buildings": [],
		"construction_sites": [],
		"events": [],
		"tasks": []
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
			"energy": villager.energy,
			"age": villager.age,
			"gender": villager.gender
		})

	for node in get_tree().get_nodes_in_group("resource_node"):
		data["resources"].append({
			"scene": node.scene_file_path,
			"position": [node.global_position.x, node.global_position.y],
			"amount": node.amount
		})

	for rock in get_tree().get_nodes_in_group("rock"):
		data["rocks"].append({
			"scene": rock.scene_file_path,
			"position": [rock.global_position.x, rock.global_position.y]
		})

	for building in get_tree().get_nodes_in_group("building"):
		data["buildings"].append({
			"scene": building.scene_file_path,
			"position": [building.global_position.x, building.global_position.y]
		})

	for site in get_tree().get_nodes_in_group("construction_site"):
		data["construction_sites"].append({
			"scene": site.scene_file_path,
			"position": [site.global_position.x, site.global_position.y],
			"progress": site.progress,
			"remaining_resources": site.remaining_resources,
			"build_time": site.build_time,
			"building_scene": site.building_scene.resource_path if site.building_scene else ""
		})

	for marker in get_tree().get_nodes_in_group("event_marker"):
		data["events"].append({
			"scene": marker.scene_file_path,
			"position": [marker.global_position.x, marker.global_position.y]
		})

	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if task_board:
		for task in task_board.get_all_tasks():
			data["tasks"].append({
				"task_id": task.task_id,
				"task_type": task.task_type,
				"priority": task.priority,
				"status": task.status,
				"target_world_position": [task.target_world_position.x, task.target_world_position.y],
				"target_node_path": str(task.target_node_path),
				"metadata": task.metadata,
				"created_at": task.created_at,
				"ttl_seconds": task.ttl_seconds,
				"assigned_villager_id": task.assigned_villager_id
			})

	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
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
		storage.resources = data.get("storage", {})

	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if task_board:
		task_board.clear_tasks()

	_clear_world_objects()
	_restore_objects(data)
	_restore_tasks(data)

	var villagers := get_tree().get_nodes_in_group("villager")
	var saved_villagers: Array = data.get("villagers", [])
	_sync_villagers(villagers, saved_villagers.size())
	villagers = get_tree().get_nodes_in_group("villager")
	var count := min(villagers.size(), saved_villagers.size())
	for i in count:
		var info: Dictionary = saved_villagers[i]
		villagers[i].global_position = Vector2(info["position"][0], info["position"][1])
		villagers[i].health = info["health"]
		villagers[i].hunger = info["hunger"]
		villagers[i].energy = info.get("energy", 100.0)
		villagers[i].age = info["age"]
		villagers[i].gender = info["gender"]

func _sync_villagers(existing: Array, target_count: int) -> void:
	if existing.size() < target_count:
		for _i in range(target_count - existing.size()):
			var villager := villager_scene.instantiate()
			get_tree().get_root().add_child(villager)
	elif existing.size() > target_count:
		for i in range(existing.size() - target_count):
			existing[i].queue_free()

func _clear_world_objects() -> void:
	for group_name in ["resource_node", "rock", "building", "construction_site", "event_marker"]:
		for node in get_tree().get_nodes_in_group(group_name):
			node.queue_free()

func _restore_objects(data: Dictionary) -> void:
	for entry in data.get("resources", []):
		_spawn_scene(entry["scene"], entry["position"], func(node: Node) -> void:
			if node is ResourceNode:
				node.amount = entry["amount"]
		)

	for entry in data.get("rocks", []):
		_spawn_scene(entry["scene"], entry["position"])

	for entry in data.get("buildings", []):
		_spawn_scene(entry["scene"], entry["position"])

	for entry in data.get("construction_sites", []):
		_spawn_scene(entry["scene"], entry["position"], func(node: Node) -> void:
			if node is ConstructionSite:
				node.progress = entry["progress"]
				node.remaining_resources = entry["remaining_resources"]
				node.build_time = entry["build_time"]
				if entry["building_scene"] != "":
					node.building_scene = load(entry["building_scene"])
		)

	for entry in data.get("events", []):
		_spawn_scene(entry["scene"], entry["position"])

func _restore_tasks(data: Dictionary) -> void:
	var task_board: TaskBoard = get_tree().get_first_node_in_group("task_board")
	if not task_board:
		return
	for entry in data.get("tasks", []):
		var task := Task.new()
		task.task_id = entry["task_id"]
		task.task_type = entry["task_type"]
		task.priority = entry["priority"]
		task.status = entry["status"]
		task.target_world_position = Vector2(entry["target_world_position"][0], entry["target_world_position"][1])
		task.target_node_path = NodePath(entry["target_node_path"])
		task.metadata = entry.get("metadata", {})
		task.created_at = entry.get("created_at", Time.get_unix_time_from_system())
		task.ttl_seconds = entry.get("ttl_seconds", task.ttl_seconds)
		task.assigned_villager_id = entry.get("assigned_villager_id", 0)
		task_board.add_task(task)
	_cleanup_orphaned_tasks(task_board)

	for task in task_board.get_all_tasks():
		if task.assigned_villager_id == 0:
			continue
		for villager in get_tree().get_nodes_in_group("villager"):
			if villager.get_instance_id() == task.assigned_villager_id:
				task.assign_to(villager)
				break

func _cleanup_orphaned_tasks(task_board: TaskBoard) -> void:
	for task in task_board.get_all_tasks():
		if task.target_node_path != NodePath():
			var node := get_tree().get_root().get_node_or_null(task.target_node_path)
			if not node:
				task.mark_expired()

func _spawn_scene(scene_path: String, position: Array, configure: Callable = Callable()) -> void:
	if scene_path == "":
		return
	var scene := load(scene_path)
	if not scene:
		return
	var node := scene.instantiate()
	node.global_position = Vector2(position[0], position[1])
	get_tree().get_root().add_child(node)
	if configure.is_valid():
		configure.call(node)
