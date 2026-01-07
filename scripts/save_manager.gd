extends Node
class_name SaveManager

const SAVE_PATH := "user://savegame.json"

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

	var villagers := get_tree().get_nodes_in_group("villager")
	var saved_villagers: Array = data.get("villagers", [])
	var count := mini(villagers.size(), saved_villagers.size())
	for i in range(count):
		var info: Dictionary = saved_villagers[i]
		villagers[i].global_position = Vector2(info["position"][0], info["position"][1])
		villagers[i].health = info["health"]
		villagers[i].hunger = info["hunger"]
		villagers[i].age = info["age"]
		villagers[i].gender = info["gender"]
