extends Node2D

@onready var storage: Storage = $Storage
@onready var food_label: Label = $UI/StoragePanel/FoodLabel
@onready var wood_label: Label = $UI/StoragePanel/WoodLabel
@onready var stone_label: Label = $UI/StoragePanel/StoneLabel

func _ready() -> void:
	_update_storage_labels()
	storage.storage_changed.connect(_update_storage_labels)

func _update_storage_labels() -> void:
	food_label.text = "Food: %d" % int(storage.get_amount("food"))
	wood_label.text = "Wood: %d" % int(storage.get_amount("wood"))
	stone_label.text = "Stone: %d" % int(storage.get_amount("stone"))
