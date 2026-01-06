extends Node2D
class_name WorldChunk

var chunk_coord := Vector2i.ZERO
var chunk_size := 32
var tile_size := 16
var noise: FastNoiseLite
var tile_set: TileSet

@onready var tile_map: TileMap = TileMap.new()

func _ready() -> void:
	add_child(tile_map)
	_generate_tiles()

func setup(coord: Vector2i, noise_source: FastNoiseLite, tileset: TileSet, size: int, tile_px: int) -> void:
	chunk_coord = coord
	noise = noise_source
	tile_set = tileset
	chunk_size = size
	tile_size = tile_px

func _generate_tiles() -> void:
	if not noise or not tile_set:
		return
	tile_map.tile_set = tile_set
	for x in chunk_size:
		for y in chunk_size:
			var world_x := chunk_coord.x * chunk_size + x
			var world_y := chunk_coord.y * chunk_size + y
			var value := noise.get_noise_2d(world_x, world_y)
			var tile_id := _tile_from_noise(value)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _tile_from_noise(value: float) -> int:
	if value < 0.2:
		return 0
	if value < 0.4:
		return 1
	return 2

func is_walkable_world(world_position: Vector2) -> bool:
	var local_pos := to_local(world_position)
	var tile_coord := tile_map.local_to_map(local_pos)
	var atlas_coords := tile_map.get_cell_atlas_coords(0, tile_coord)
	return atlas_coords.x != 0
