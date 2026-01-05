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
	_setup_tileset()
	noise.seed = randi()
	noise.frequency = 0.04
	_generate_map()
	_update_game_state_biome()

func _generate_map() -> void:
	for x in map_width:
		for y in map_height:
			var value := noise.get_noise_2d(x, y)
			var tile_id := _tile_from_noise(value)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _tile_from_noise(value: float) -> int:
	if value < 0.2:
		return TILE_WATER
	if value < 0.4:
		return TILE_SAND
	return TILE_GRASS

func is_walkable(tile_coord: Vector2i) -> bool:
	var atlas_coords := tile_map.get_cell_atlas_coords(0, tile_coord)
	return atlas_coords.x != TILE_WATER

func is_walkable_world(world_position: Vector2) -> bool:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	return is_walkable(tile_coord)

func _setup_tileset() -> void:
	var image := Image.create(tile_size * 3, tile_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color(0.1, 0.35, 0.8))
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color(0.85, 0.78, 0.5))
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color(0.2, 0.7, 0.3))

	var texture := ImageTexture.create_from_image(image)
	var tileset := TileSet.new()
	tileset.tile_size = Vector2i(tile_size, tile_size)

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
