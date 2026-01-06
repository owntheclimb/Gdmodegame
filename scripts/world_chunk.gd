extends TileMap

const TILE_WATER := 0
const TILE_SAND := 1
const TILE_GRASS := 2

var chunk_coord: Vector2i
var chunk_size := 32
var noise: FastNoiseLite

func setup(coord: Vector2i, size: int, tileset: TileSet, noise_source: FastNoiseLite) -> void:
	chunk_coord = coord
	chunk_size = size
	noise = noise_source
	tile_set = tileset
	_generate()

func _generate() -> void:
	var start := chunk_coord * chunk_size
	for x in chunk_size:
		for y in chunk_size:
			var world_x := start.x + x
			var world_y := start.y + y
			var value := noise.get_noise_2d(world_x, world_y)
			var tile_id := _tile_from_noise(value)
			set_cell(0, Vector2i(x, y), 0, Vector2i(tile_id, 0))

func _tile_from_noise(value: float) -> int:
	if value < 0.2:
		return TILE_WATER
	if value < 0.4:
		return TILE_SAND
	return TILE_GRASS

func is_walkable(local_tile_coord: Vector2i) -> bool:
	var atlas_coords := get_cell_atlas_coords(0, local_tile_coord)
	return atlas_coords.x != TILE_WATER
