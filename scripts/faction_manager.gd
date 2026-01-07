extends Node
class_name FactionManager

signal reputation_changed(faction_id: String, value: int)

const DEFAULT_FACTIONS := [
	{
		"id": "nomads",
		"name": "Golden Nomads",
		"description": "Traveling traders who respect resourcefulness.",
		"reputation": 0
	},
	{
		"id": "highlanders",
		"name": "Stonecliff Clans",
		"description": "Mountain folk who prize strength and metalwork.",
		"reputation": 0
	},
	{
		"id": "coastal",
		"name": "Tideborn Guild",
		"description": "Sailors and salvagers guarding the shores.",
		"reputation": 0
	},
	{
		"id": "forest",
		"name": "Verdant Circle",
		"description": "Guardians of the deep woods and hidden shrines.",
		"reputation": 0
	}
]

var factions: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("faction_manager")
	factions = DEFAULT_FACTIONS.duplicate(true)
	var game_state := _get_game_state()
	if game_state:
		game_state.action_recorded.connect(_on_action_recorded)

func _on_action_recorded(action: String) -> void:
	match action:
		"met_nomads":
			_adjust_reputation("nomads", 5)
		"aided_hunter":
			_adjust_reputation("forest", 4)
		"recovered_relic":
			_adjust_reputation("coastal", 3)
		"recovered_cache":
			_adjust_reputation("highlanders", 3)
		"maintained_building":
			_adjust_reputation("highlanders", 1)
		"delivered_resource":
			_adjust_reputation("nomads", 1)
		"delivery_failed":
			_adjust_reputation("nomads", -1)
		"cleansed_shrine":
			_adjust_reputation("forest", 2)
		_:
			pass

func _adjust_reputation(faction_id: String, amount: int) -> void:
	for faction in factions:
		if faction.get("id") == faction_id:
			faction["reputation"] = int(faction.get("reputation", 0)) + amount
			reputation_changed.emit(faction_id, faction["reputation"])
			return

func get_reputation(faction_id: String) -> int:
	for faction in factions:
		if faction.get("id") == faction_id:
			return int(faction.get("reputation", 0))
	return 0

func get_summary_text() -> String:
	var lines := ["Factions:"]
	for faction in factions:
		lines.append("%s: %d" % [faction.get("name", "Unknown"), int(faction.get("reputation", 0))])
	return "\n".join(lines)

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state") as GameState
