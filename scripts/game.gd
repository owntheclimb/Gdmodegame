extends Node2D

@onready var storage: Storage = $Storage
@onready var food_label: Label = $UI/StoragePanel/FoodLabel
@onready var wood_label: Label = $UI/StoragePanel/WoodLabel
@onready var stone_label: Label = $UI/StoragePanel/StoneLabel

func _ready() -> void:
	_ensure_manager("story_manager", "res://scripts/story_manager.gd")
	_ensure_manager("quest_manager", "res://scripts/quest_manager.gd")
	_ensure_manager("faction_manager", "res://scripts/faction_manager.gd")
	_ensure_manager("creature_spawner", "res://scripts/creature_spawner.gd")
	_update_storage_labels()
	storage.storage_changed.connect(_update_storage_labels)

func _update_storage_labels() -> void:
	food_label.text = "Food: %d" % int(storage.get_amount("food"))
	wood_label.text = "Wood: %d" % int(storage.get_amount("wood"))
	stone_label.text = "Stone: %d" % int(storage.get_amount("stone"))

func _ensure_manager(group_name: String, script_path: String) -> void:
	if get_tree().get_first_node_in_group(group_name):
		return
	var node := Node.new()
	node.name = group_name.to_pascal_case()
	node.set_script(load(script_path))
	add_child(node)
