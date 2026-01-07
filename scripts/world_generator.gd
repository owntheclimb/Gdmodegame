extends Node2D

@export var tile_size := 16
@export var chunk_size := 32
@export var render_distance := 2
@export var map_width := 128
@export var map_height := 128
@export var initial_trees := 45
@export var initial_rocks := 28
@export var initial_berry_bushes := 22

const WorldChunk := preload("res://scripts/world_chunk.gd")
const TILE_WATER := 0
const TILE_SAND := 1
const TILE_GRASS := 2
const TILE_FOREST := 3
const TILE_MOUNTAIN := 4

var noise := FastNoiseLite.new()
var moisture_noise := FastNoiseLite.new()
var tileset: TileSet
var loaded_chunks: Dictionary = {}
@onready var tile_map: TileMap = $TileMap
@onready var tree_scene: PackedScene = preload("res://scenes/Tree.tscn")
@onready var rock_scene: PackedScene = preload("res://scenes/Rock.tscn")
@onready var berry_scene: PackedScene = preload("res://scenes/BerryBush.tscn")
var _world_seed := 0

func _ready() -> void:
	add_to_group("world")
	tileset = _setup_tileset()
	tile_map.tile_set = tileset
	_world_seed = randi()
	_apply_seed(_world_seed)
	_generate_map()
	_spawn_resources()
	_update_game_state_biome()

func _process(_delta: float) -> void:
	_update_loaded_chunks()

func _update_loaded_chunks() -> void:
	var focus_position: Vector2 = _get_focus_position()
	_update_game_state_biome_at_position(focus_position)

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
	if tile_type == TILE_MOUNTAIN:
		return false
	return true

func is_walkable_world(world_position: Vector2, allow_water := true) -> bool:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	return is_walkable(tile_coord, allow_water)

func _setup_tileset() -> TileSet:
	var image := Image.create(tile_size * 5, tile_size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	image.fill_rect(Rect2i(0, 0, tile_size, tile_size), Color(0.1, 0.35, 0.8))
	image.fill_rect(Rect2i(tile_size, 0, tile_size, tile_size), Color(0.85, 0.78, 0.5))
	image.fill_rect(Rect2i(tile_size * 2, 0, tile_size, tile_size), Color(0.2, 0.7, 0.3))
	image.fill_rect(Rect2i(tile_size * 3, 0, tile_size, tile_size), Color(0.12, 0.45, 0.2))
	image.fill_rect(Rect2i(tile_size * 4, 0, tile_size, tile_size), Color(0.5, 0.5, 0.55))

	var texture := ImageTexture.create_from_image(image)
	var new_tileset := TileSet.new()
	new_tileset.tile_size = Vector2i(tile_size, tile_size)

	var atlas_source := TileSetAtlasSource.new()
	atlas_source.texture = texture
	atlas_source.texture_region_size = Vector2i(tile_size, tile_size)
	atlas_source.create_tile(Vector2i(0, 0))
	atlas_source.create_tile(Vector2i(1, 0))
	atlas_source.create_tile(Vector2i(2, 0))
	atlas_source.create_tile(Vector2i(3, 0))
	atlas_source.create_tile(Vector2i(4, 0))

	new_tileset.add_source(atlas_source, 0)
	return new_tileset

func _generate_map() -> void:
	tile_map.clear()
	for x in range(map_width):
		for y in range(map_height):
			var height := noise.get_noise_2d(x, y)
			var moisture := moisture_noise.get_noise_2d(x + 1000, y + 1000)
			var tile_id := _tile_from_noise(height, moisture)
			tile_map.set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _tile_from_noise(height: float, moisture: float) -> int:
	if height < -0.25:
		return TILE_WATER
	if height < -0.05:
		return TILE_SAND
	if height < 0.25:
		if moisture > 0.2:
			return TILE_FOREST
		return TILE_GRASS
	if height < 0.45:
		if moisture > 0.35:
			return TILE_FOREST
		return TILE_GRASS
	return TILE_MOUNTAIN

func get_random_walkable_position(max_attempts := 60) -> Vector2:
	for _i in range(max_attempts):
		var coord := Vector2i(randi_range(0, map_width - 1), randi_range(0, map_height - 1))
		if is_walkable(coord):
			var local := tile_map.map_to_local(coord)
			local += Vector2(tile_size / 2.0, tile_size / 2.0)
			return tile_map.to_global(local)
	return Vector2.ZERO

func _spawn_resources() -> void:
	for node in get_tree().get_nodes_in_group("resource"):
		if node is Node:
			node.queue_free()
	_spawn_resource_set(tree_scene, initial_trees, [TILE_FOREST, TILE_GRASS])
	_spawn_resource_set(rock_scene, initial_rocks, [TILE_MOUNTAIN, TILE_GRASS])
	_spawn_resource_set(berry_scene, initial_berry_bushes, [TILE_GRASS, TILE_FOREST])

func _spawn_resource_set(scene: PackedScene, count: int, preferred_tiles: Array[int]) -> void:
	if not scene or count <= 0:
		return
	for _i in range(count):
		var position := _get_random_walkable_position_for_tiles(preferred_tiles, 80)
		if position == Vector2.ZERO:
			continue
		var instance := scene.instantiate()
		if instance is Node2D:
			instance.global_position = position
		get_tree().current_scene.add_child(instance)

func _get_random_walkable_position_for_tiles(preferred_tiles: Array[int], max_attempts := 80) -> Vector2:
	for _i in range(max_attempts):
		var coord := Vector2i(randi_range(0, map_width - 1), randi_range(0, map_height - 1))
		if not is_walkable(coord):
			continue
		var tile_type := get_tile_type(coord)
		if not preferred_tiles.is_empty() and not preferred_tiles.has(tile_type):
			continue
		var local := tile_map.map_to_local(coord)
		local += Vector2(tile_size / 2.0, tile_size / 2.0)
		return tile_map.to_global(local)
	return Vector2.ZERO

func _update_game_state_biome() -> void:
	var center := Vector2i(map_width / 2, map_height / 2)
	_update_game_state_biome_at_tile(center)

func _update_game_state_biome_at_position(world_position: Vector2) -> void:
	var tile_coord := tile_map.local_to_map(tile_map.to_local(world_position))
	_update_game_state_biome_at_tile(tile_coord)

func _update_game_state_biome_at_tile(tile_coord: Vector2i) -> void:
	var atlas_coords := tile_map.get_cell_atlas_coords(0, tile_coord)
	if atlas_coords == Vector2i(-1, -1):
		return
	var biome := _biome_from_tile(atlas_coords.x)
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state and game_state.current_biome != biome:
		game_state.current_biome = biome

func _biome_from_tile(tile_type: int) -> String:
	match tile_type:
		TILE_WATER, TILE_SAND:
			return "coastal"
		TILE_FOREST:
			return "forest"
		TILE_MOUNTAIN:
			return "highlands"
		_:
			return "grassland"

func _get_focus_position() -> Vector2:
	var villager := get_tree().get_first_node_in_group("villager")
	if villager and villager is Node2D:
		return villager.global_position
	var center := Vector2(map_width * tile_size / 2.0, map_height * tile_size / 2.0)
	return center

func _apply_seed(seed: int) -> void:
	_world_seed = seed
	noise.seed = seed
	noise.frequency = 0.04
	moisture_noise.seed = seed + 1337
	moisture_noise.frequency = 0.06

func get_seed() -> int:
	return _world_seed

func set_seed(seed: int) -> void:
	_apply_seed(seed)
	if tile_map:
		_generate_map()
		_spawn_resources()
		_update_game_state_biome()
