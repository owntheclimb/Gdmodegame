extends Node2D
class_name FogOfWar

## Fog of War System
## - Unexplored areas are hidden
## - Explored but not visible areas are dimmed
## - Areas near villagers are fully visible

signal area_explored(world_pos: Vector2)
signal poi_discovered(poi_type: String, world_pos: Vector2)

const TILE_SIZE := 32
const VISION_RADIUS := 5  # Tiles around villagers that are visible
const EXPLORE_RADIUS := 8  # Tiles that get explored (remembered)

# Fog states
enum FogState { HIDDEN, EXPLORED, VISIBLE }

# POI Types for discovery
const POI_TYPES: Dictionary = {
	"ancient_ruins": {"name": "Ancient Ruins", "icon": "🏛️", "reward": "artifacts"},
	"sacred_grove": {"name": "Sacred Grove", "icon": "🌳", "reward": "divine_favor"},
	"fertile_valley": {"name": "Fertile Valley", "icon": "🌾", "reward": "farm_bonus"},
	"mountain_pass": {"name": "Mountain Pass", "icon": "⛰️", "reward": "trade_route"},
	"abandoned_village": {"name": "Abandoned Village", "icon": "🏚️", "reward": "resources"},
	"monster_lair": {"name": "Monster Lair", "icon": "🐉", "reward": "treasure"},
	"hot_springs": {"name": "Hot Springs", "icon": "♨️", "reward": "healing"},
	"crystal_cave": {"name": "Crystal Cave", "icon": "💎", "reward": "crystals"},
	"shipwreck": {"name": "Shipwreck", "icon": "🚢", "reward": "survivors"},
	"underground_tunnels": {"name": "Underground Tunnels", "icon": "🕳️", "reward": "exploration"},
	"magical_anomaly": {"name": "Magical Anomaly", "icon": "✨", "reward": "mystery"},
	"mysterious_monument": {"name": "Mysterious Monument", "icon": "🗿", "reward": "puzzle"},
	"hidden_oasis": {"name": "Hidden Oasis", "icon": "🏝️", "reward": "water"},
	"volcanic_vent": {"name": "Volcanic Vent", "icon": "🌋", "reward": "metals"},
	"ancient_library": {"name": "Ancient Library", "icon": "📚", "reward": "knowledge"},
}

# Map data
var _map_width: int = 200
var _map_height: int = 200
var _fog_data: Array = []  # 2D array of FogState
var _explored_percent: float = 0.0

# POIs on the map
var _discovered_pois: Array[Dictionary] = []
var _undiscovered_pois: Array[Dictionary] = []

# Visual representation
var _fog_texture: ImageTexture
var _fog_image: Image
var _fog_sprite: Sprite2D

func _ready() -> void:
	add_to_group("fog_of_war")
	_initialize_fog()
	_generate_pois()
	_create_fog_visual()

func _initialize_fog() -> void:
	_fog_data = []
	for _y in range(_map_height):
		var row: Array = []
		for _x in range(_map_width):
			row.append(FogState.HIDDEN)
		_fog_data.append(row)

func _generate_pois() -> void:
	# Generate random POIs across the map
	var poi_count := 15 + randi() % 10
	var poi_keys := POI_TYPES.keys()
	
	for _i in range(poi_count):
		var poi_type: String = poi_keys[randi() % poi_keys.size()]
		var x := randi() % _map_width
		var y := randi() % _map_height
		
		_undiscovered_pois.append({
			"type": poi_type,
			"tile_x": x,
			"tile_y": y,
			"world_pos": Vector2(x * TILE_SIZE, y * TILE_SIZE),
			"discovered": false,
		})

func _create_fog_visual() -> void:
	_fog_image = Image.create(_map_width, _map_height, false, Image.FORMAT_RGBA8)
	_fog_image.fill(Color(0, 0, 0, 0.8))  # Dark fog
	
	_fog_texture = ImageTexture.create_from_image(_fog_image)
	
	_fog_sprite = Sprite2D.new()
	_fog_sprite.texture = _fog_texture
	_fog_sprite.centered = false
	_fog_sprite.scale = Vector2(TILE_SIZE, TILE_SIZE)
	_fog_sprite.z_index = 100
	add_child(_fog_sprite)

func _process(_delta: float) -> void:
	_update_visibility()

func _update_visibility() -> void:
	# Reset all visible to explored
	for y in range(_map_height):
		for x in range(_map_width):
			if _fog_data[y][x] == FogState.VISIBLE:
				_fog_data[y][x] = FogState.EXPLORED
	
	# Get all villager positions
	var villagers := get_tree().get_nodes_in_group("villager")
	
	for villager in villagers:
		var tile_pos := _world_to_tile(villager.global_position)
		_reveal_around(tile_pos, VISION_RADIUS, FogState.VISIBLE)
		_reveal_around(tile_pos, EXPLORE_RADIUS, FogState.EXPLORED)
	
	_update_fog_texture()
	_check_poi_discoveries()
	_calculate_explored_percent()

func _reveal_around(center: Vector2i, radius: int, state: FogState) -> void:
	for dy in range(-radius, radius + 1):
		for dx in range(-radius, radius + 1):
			if dx * dx + dy * dy <= radius * radius:
				var x := center.x + dx
				var y := center.y + dy
				if _is_valid_tile(x, y):
					if state == FogState.VISIBLE or _fog_data[y][x] == FogState.HIDDEN:
						_fog_data[y][x] = state

func _update_fog_texture() -> void:
	for y in range(_map_height):
		for x in range(_map_width):
			var color: Color
			match _fog_data[y][x]:
				FogState.HIDDEN:
					color = Color(0, 0, 0, 0.9)
				FogState.EXPLORED:
					color = Color(0, 0, 0, 0.4)
				FogState.VISIBLE:
					color = Color(0, 0, 0, 0.0)
			_fog_image.set_pixel(x, y, color)
	
	_fog_texture.update(_fog_image)

func _check_poi_discoveries() -> void:
	for poi in _undiscovered_pois.duplicate():
		if _fog_data[poi.tile_y][poi.tile_x] >= FogState.EXPLORED:
			poi.discovered = true
			_discovered_pois.append(poi)
			_undiscovered_pois.erase(poi)
			
			var poi_info: Dictionary = POI_TYPES[poi.type]
			poi_discovered.emit(poi.type, poi.world_pos)
			_show_notification("Discovered: %s %s!" % [poi_info.icon, poi_info.name])

func _calculate_explored_percent() -> void:
	var explored := 0
	var total := _map_width * _map_height
	
	for y in range(_map_height):
		for x in range(_map_width):
			if _fog_data[y][x] != FogState.HIDDEN:
				explored += 1
	
	_explored_percent = float(explored) / float(total) * 100.0

func _world_to_tile(world_pos: Vector2) -> Vector2i:
	return Vector2i(int(world_pos.x / TILE_SIZE), int(world_pos.y / TILE_SIZE))

func _tile_to_world(tile_pos: Vector2i) -> Vector2:
	return Vector2(tile_pos.x * TILE_SIZE, tile_pos.y * TILE_SIZE)

func _is_valid_tile(x: int, y: int) -> bool:
	return x >= 0 and x < _map_width and y >= 0 and y < _map_height

func _show_notification(text: String) -> void:
	var action_menu := get_tree().get_first_node_in_group("action_menu")
	if action_menu and action_menu.has_method("_show_notification"):
		action_menu._show_notification(text)

# Public API
func get_explored_percent() -> float:
	return _explored_percent

func is_tile_visible(tile_x: int, tile_y: int) -> bool:
	if not _is_valid_tile(tile_x, tile_y):
		return false
	return _fog_data[tile_y][tile_x] == FogState.VISIBLE

func is_tile_explored(tile_x: int, tile_y: int) -> bool:
	if not _is_valid_tile(tile_x, tile_y):
		return false
	return _fog_data[tile_y][tile_x] >= FogState.EXPLORED

func is_position_visible(world_pos: Vector2) -> bool:
	var tile := _world_to_tile(world_pos)
	return is_tile_visible(tile.x, tile.y)

func is_position_explored(world_pos: Vector2) -> bool:
	var tile := _world_to_tile(world_pos)
	return is_tile_explored(tile.x, tile.y)

func get_discovered_pois() -> Array[Dictionary]:
	return _discovered_pois

func get_undiscovered_poi_count() -> int:
	return _undiscovered_pois.size()

func reveal_area(world_pos: Vector2, radius: int) -> void:
	var tile := _world_to_tile(world_pos)
	_reveal_around(tile, radius, FogState.EXPLORED)

func set_map_size(width: int, height: int) -> void:
	_map_width = width
	_map_height = height
	_initialize_fog()
	_create_fog_visual()
