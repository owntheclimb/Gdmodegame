extends Node2D

@export var map_width := 100
@export var map_height := 100
@export var tile_size := 16

@onready var tile_map: TileMap = $TileMap

const TILE_WATER := 0
const TILE_SAND := 1
const TILE_GRASS := 2

var noise := FastNoiseLite.new()

func _ready() -> void:
	add_to_group("world")
	randomize()
	noise.seed = randi()
	noise.frequency = 0.04
	_generate_map()

func _generate_map() -> void:
	for x in map_width:
		for y in map_height:
			var value := noise.get_noise_2d(x, y)
			var tile_id := _tile_from_noise(value)
			tile_map.set_cell(0, Vector2i(x, y), tile_id, Vector2i.ZERO)

func _tile_from_noise(value: float) -> int:
	if value < 0.2:
		return TILE_WATER
	if value < 0.4:
		return TILE_SAND
	return TILE_GRASS

func is_walkable(tile_coord: Vector2i) -> bool:
	var tile_id := tile_map.get_cell_source_id(0, tile_coord)
	return tile_id != TILE_WATER

func is_walkable_world(world_position: Vector2) -> bool:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	return is_walkable(tile_coord)
