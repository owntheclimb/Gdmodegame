extends Node2D

@export var tile_size := 16
@export var chunk_size := 32
@export var view_distance := 1

@onready var chunks_root: Node2D = $Chunks

const TILE_WATER := 0
const TILE_SAND := 1
const TILE_GRASS := 2

var noise := FastNoiseLite.new()
var biome_noise := FastNoiseLite.new()
var _seed := 0
var _chunks: Dictionary = {}
var _tileset: TileSet

func _ready() -> void:
	add_to_group("world")
	randomize()
	_setup_tileset()
	_seed = randi()
	noise.seed = _seed
	biome_noise.seed = _seed + 7
	noise.frequency = 0.04
	biome_noise.frequency = 0.02
	_update_chunks()

func _process(_delta: float) -> void:
	_update_chunks()

func _update_chunks() -> void:
	var center := _get_focus_chunk()
	for x in range(center.x - view_distance, center.x + view_distance + 1):
		for y in range(center.y - view_distance, center.y + view_distance + 1):
			var coord := Vector2i(x, y)
			if not _chunks.has(coord):
				_create_chunk(coord)
	_prune_chunks(center)

func is_walkable(tile_coord: Vector2i) -> bool:
	var chunk_coord := Vector2i(floori(tile_coord.x / chunk_size), floori(tile_coord.y / chunk_size))
	var chunk := _chunks.get(chunk_coord)
	if not chunk:
		return false
	return chunk.is_walkable_world(chunk.to_global(chunk.tile_map.map_to_local(tile_coord - chunk_coord * chunk_size)))

func is_walkable_world(world_position: Vector2) -> bool:
	var chunk_coord := _world_to_chunk(world_position)
	var chunk := _chunks.get(chunk_coord)
	if not chunk:
		return false
	return chunk.is_walkable_world(world_position)

func get_biome_at(world_position: Vector2) -> String:
	var value := biome_noise.get_noise_2d(world_position.x / tile_size, world_position.y / tile_size)
	if value < -0.2:
		return "beach"
	if value < 0.2:
		return "jungle"
	return "ruins"

func get_random_walkable_position() -> Vector2:
	var attempts := 20
	for _i in attempts:
		var chunk_coords := _chunks.keys()
		if chunk_coords.is_empty():
			break
		var chunk_coord: Vector2i = chunk_coords.pick_random()
		var chunk := _chunks[chunk_coord]
		var local := Vector2(randf_range(0, chunk_size * tile_size), randf_range(0, chunk_size * tile_size))
		var world_position := chunk.to_global(local)
		if chunk.is_walkable_world(world_position):
			return world_position
	return Vector2.ZERO

func _setup_tileset() -> void:
	var image := Image.create(tile_size * 3, tile_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color(0.1, 0.35, 0.8))
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color(0.85, 0.78, 0.5))
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color(0.2, 0.7, 0.3))

	var texture := ImageTexture.create_from_image(image)
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(tile_size, tile_size)

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(tile_size, tile_size)
	atlas_source.create_tile(Vector2i(0, 0))
	atlas_source.create_tile(Vector2i(1, 0))
	atlas_source.create_tile(Vector2i(2, 0))

	_tileset.add_source(atlas_source, 0)

func _create_chunk(coord: Vector2i) -> void:
	var chunk := WorldChunk.new()
	chunk.setup(coord, noise, _tileset, chunk_size, tile_size)
	chunk.position = Vector2(coord.x * chunk_size * tile_size, coord.y * chunk_size * tile_size)
	chunks_root.add_child(chunk)
	_chunks[coord] = chunk

func _world_to_chunk(world_position: Vector2) -> Vector2i:
	var chunk_world_size := chunk_size * tile_size
	return Vector2i(floori(world_position.x / chunk_world_size), floori(world_position.y / chunk_world_size))

func _get_focus_chunk() -> Vector2i:
	var focus := get_tree().get_first_node_in_group("villager")
	if focus:
		return _world_to_chunk(focus.global_position)
	return Vector2i.ZERO

func _prune_chunks(center: Vector2i) -> void:
	var keys := _chunks.keys()
	for coord in keys:
		if abs(coord.x - center.x) > view_distance + 1 or abs(coord.y - center.y) > view_distance + 1:
			var chunk := _chunks[coord]
			if chunk:
				chunk.queue_free()
			_chunks.erase(coord)

func get_seed() -> int:
	return _seed

func set_seed(seed_value: int) -> void:
	_seed = seed_value
	noise.seed = _seed
	biome_noise.seed = _seed + 7
	for coord in _chunks.keys():
		var chunk := _chunks[coord]
		if chunk:
			chunk.queue_free()
	_chunks.clear()
	_update_chunks()
