extends Node2D

@export var tile_size := 16
@export var chunk_size := 32
@export var render_distance := 2

const WorldChunk := preload("res://scripts/world_chunk.gd")

var noise := FastNoiseLite.new()
var tileset: TileSet
var loaded_chunks: Dictionary = {}
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	add_to_group("world")
	randomize()
	tileset = _setup_tileset()
	tile_map.tile_set = tileset
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

func get_tile_type(tile_coord: Vector2i) -> int:
	var atlas_coords := tile_map.get_cell_atlas_coords(0, tile_coord)
	return atlas_coords.x

func get_tile_type_world(world_position: Vector2) -> int:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	return get_tile_type(tile_coord)

func is_water_world(world_position: Vector2) -> bool:
	return get_tile_type_world(world_position) == TILE_WATER

func is_walkable(tile_coord: Vector2i, allow_water := true) -> bool:
	var tile_type := get_tile_type(tile_coord)
	if tile_type == -1:
		return false
	if tile_type == TILE_WATER and not allow_water:
		return false
	return true

func is_walkable_world(world_position: Vector2, allow_water := true) -> bool:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	return is_walkable(tile_coord, allow_water)

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

	new_tileset.add_source(atlas_source, 0)
	return new_tileset

func get_random_walkable_position(max_attempts := 60) -> Vector2:
	for _i in range(max_attempts):
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
