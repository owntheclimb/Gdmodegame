extends Node
class_name GameState

signal game_over(reason: String)

@export var win_day_target := 10

var days_survived := 0
var is_game_over := false
var _check_timer := 0.0

func _ready() -> void:
	add_to_group("game_state")
	var day_night := get_tree().get_first_node_in_group("day_night")
	if day_night:
		day_night.day_started.connect(_on_day_started)
	
func _process(delta: float) -> void:
	if is_game_over:
		return
	_check_timer += delta
	if _check_timer >= 2.0:
		_check_timer = 0.0
		check_population()

func _on_day_started() -> void:
	if is_game_over:
		return
	days_survived += 1
	if days_survived >= win_day_target:
		game_over.emit("Victory: Survived %d days." % days_survived)
		is_game_over = true

func check_population() -> void:
	if is_game_over:
		return
	var villagers := get_tree().get_nodes_in_group("villager")
	if villagers.is_empty():
		game_over.emit("All villagers lost.")
		is_game_over = true
