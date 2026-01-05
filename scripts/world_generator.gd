extends Node2D

@export var tile_size := 16
@export var chunk_size := 32
@export var render_distance := 2

const WorldChunk := preload("res://scripts/world_chunk.gd")

var noise := FastNoiseLite.new()
var tileset: TileSet
var loaded_chunks: Dictionary = {}

func _ready() -> void:
	add_to_group("world")
	randomize()
	tileset = _setup_tileset()
	noise.seed = randi()
	noise.frequency = 0.04
	_generate_map()
	_update_game_state_biome()

func _process(_delta: float) -> void:
	_update_loaded_chunks()

func _update_loaded_chunks() -> void:
	var focus_position := _get_focus_position()
	var center_chunk := _world_to_chunk(focus_position)
	var desired_chunks: Dictionary = {}

	for x in range(center_chunk.x - render_distance, center_chunk.x + render_distance + 1):
		for y in range(center_chunk.y - render_distance, center_chunk.y + render_distance + 1):
			var coord := Vector2i(x, y)
			desired_chunks[coord] = true
			if not loaded_chunks.has(coord):
				_load_chunk(coord)

	for coord in loaded_chunks.keys():
		if not desired_chunks.has(coord):
			_unload_chunk(coord)

func _load_chunk(chunk_coord: Vector2i) -> void:
	var chunk := WorldChunk.new()
	chunk.name = "Chunk_%s_%s" % [chunk_coord.x, chunk_coord.y]
	chunk.position = Vector2(chunk_coord.x * chunk_size * tile_size, chunk_coord.y * chunk_size * tile_size)
	add_child(chunk)
	chunk.setup(chunk_coord, chunk_size, tileset, noise)
	loaded_chunks[chunk_coord] = chunk

func _unload_chunk(chunk_coord: Vector2i) -> void:
	var chunk: TileMap = loaded_chunks.get(chunk_coord)
	if chunk:
		chunk.queue_free()
	loaded_chunks.erase(chunk_coord)

func _get_focus_position() -> Vector2:
	var camera := get_viewport().get_camera_2d()
	if camera:
		return camera.global_position
	var villager := get_tree().get_first_node_in_group("villager")
	if villager:
		return villager.global_position
	return global_position

func _world_to_chunk(world_position: Vector2) -> Vector2i:
	var tile_coord := Vector2i(
		floor(world_position.x / tile_size),
		floor(world_position.y / tile_size)
	)
	return _tile_to_chunk(tile_coord)

func _tile_to_chunk(tile_coord: Vector2i) -> Vector2i:
	return Vector2i(
		floor(float(tile_coord.x) / chunk_size),
		floor(float(tile_coord.y) / chunk_size)
	)

func _tile_to_local(tile_coord: Vector2i) -> Vector2i:
	return Vector2i(
		posmod(tile_coord.x, chunk_size),
		posmod(tile_coord.y, chunk_size)
	)

func is_walkable_world(world_position: Vector2) -> bool:
	var tile_coord := Vector2i(
		floor(world_position.x / tile_size),
		floor(world_position.y / tile_size)
	)
	var chunk_coord := _tile_to_chunk(tile_coord)
	var local_coord := _tile_to_local(tile_coord)
	var chunk := loaded_chunks.get(chunk_coord)
	if not chunk:
		_load_chunk(chunk_coord)
		chunk = loaded_chunks.get(chunk_coord)
	if not chunk:
		return false
	return chunk.is_walkable(local_coord)

func _setup_tileset() -> TileSet:
	var image := Image.create(tile_size * 3, tile_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color(0.1, 0.35, 0.8))
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color(0.85, 0.78, 0.5))
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color(0.2, 0.7, 0.3))

	var texture := ImageTexture.create_from_image(image)
	var new_tileset := TileSet.new()
	new_tileset.tile_size = Vector2i(tile_size, tile_size)

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(tile_size, tile_size)
	atlas_source.create_tile(Vector2i(0, 0))
	atlas_source.create_tile(Vector2i(1, 0))
	atlas_source.create_tile(Vector2i(2, 0))

	tileset.add_source(atlas_source, 0)
	tile_map.tile_set = tileset

func get_random_walkable_position(max_attempts := 60) -> Vector2:
	for _i in max_attempts:
		var coord := Vector2i(randi_range(0, map_width - 1), randi_range(0, map_height - 1))
		if is_walkable(coord):
			var local := tile_map.map_to_local(coord)
			local += Vector2(tile_size / 2.0, tile_size / 2.0)
			return tile_map.to_global(local)
	return Vector2.ZERO

func _update_game_state_biome() -> void:
	var center := Vector2i(map_width / 2, map_height / 2)
	var atlas_coords := tile_map.get_cell_atlas_coords(0, center)
	var biome := "grassland"
	if atlas_coords.x == TILE_WATER or atlas_coords.x == TILE_SAND:
		biome = "coastal"
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state:
		game_state.current_biome = biome
