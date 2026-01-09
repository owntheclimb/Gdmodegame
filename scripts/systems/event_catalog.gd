extends Node
class_name EventCatalog

## Expanded Event System with 50+ events across categories

# Event categories
enum Category { WEATHER, SOCIAL, DISASTER, OPPORTUNITY, MYSTERY, COMBAT }

const CATEGORY_NAMES: Dictionary = {
	Category.WEATHER: "Weather",
	Category.SOCIAL: "Social",
	Category.DISASTER: "Disaster",
	Category.OPPORTUNITY: "Opportunity",
	Category.MYSTERY: "Mystery",
	Category.COMBAT: "Combat",
}

# Event definition
class EventDef:
	var id: String
	var name: String
	var description: String
	var category: int
	var effects: Dictionary  # {effect_type: value}
	var duration: float  # In-game minutes
	var choices: Array[Dictionary]  # [{text, outcome}]
	var requirements: Dictionary  # Conditions to trigger
	var weight: float  # Spawn probability
	var chain_next: String  # Next event in chain
	var is_recurring: bool
	
	func _init(p_id: String, p_name: String, p_desc: String, p_cat: int) -> void:
		id = p_id
		name = p_name
		description = p_desc
		category = p_cat
		effects = {}
		duration = 0.0
		choices = []
		requirements = {}
		weight = 1.0
		chain_next = ""
		is_recurring = false

# All events
var _events: Dictionary = {}

func _ready() -> void:
	add_to_group("event_catalog")
	_initialize_events()

func _initialize_events() -> void:
	# ============== WEATHER EVENTS (8) ==============
	_add_event(_make_weather_event("storm", "Storm", "Heavy rain and wind damage buildings", {"damage": 10, "mood": -5}, 30.0))
	_add_event(_make_weather_event("drought", "Drought", "No rain reduces food production", {"food_production": 0.5}, 60.0))
	_add_event(_make_weather_event("perfect_weather", "Perfect Weather", "Ideal conditions boost production", {"production": 1.5, "mood": 10}, 45.0))
	_add_event(_make_weather_event("blizzard", "Blizzard", "Extreme cold, stay inside", {"health": -20, "energy": -30}, 20.0))
	_add_event(_make_weather_event("heat_wave", "Heat Wave", "Extreme heat drains energy", {"energy": -20}, 40.0))
	_add_event(_make_weather_event("fog", "Dense Fog", "Visibility reduced, exploration harder", {"exploration": 0.5}, 15.0))
	_add_event(_make_weather_event("rainbow", "Rainbow", "Beautiful sight boosts happiness", {"mood": 20}, 5.0))
	_add_event(_make_weather_event("eclipse", "Solar Eclipse", "Strange phenomena occur", {"mystery": 1}, 10.0))
	
	# ============== SOCIAL EVENTS (12) ==============
	_add_event(_make_social_event("festival", "Festival Celebration", "Villagers celebrate together!", {"mood": 30, "social": 20}))
	_add_event(_make_social_event("wedding", "Wedding Ceremony", "Two villagers get married", {"mood": 25}))
	_add_event(_make_social_event("birth", "New Birth", "A baby is born in the village!", {"population": 1, "mood": 15}))
	_add_event(_make_social_event("funeral", "Funeral", "The village mourns a loss", {"mood": -20}))
	_add_event(_make_social_event("conflict", "Villager Conflict", "Two villagers are fighting", {"mood": -10}))
	_add_event(_make_social_event("romance", "Romance Blooms", "Love is in the air", {"mood": 10}))
	_add_event(_make_social_event("rivalry", "Rivalry Starts", "Competition emerges", {"productivity": 1.1, "mood": -5}))
	_add_event(_make_social_event("friendship", "New Friendship", "Bonds are forming", {"social": 15}))
	_add_event(_make_social_event("elder_wisdom", "Elder's Wisdom", "An elder shares knowledge", {"research": 10}))
	_add_event(_make_social_event("coming_of_age", "Coming of Age", "A child becomes adult", {"mood": 10}))
	_add_event(_make_social_event("hero_return", "Hero Returns", "A villager returns with glory", {"mood": 25, "reputation": 10}))
	_add_event(_make_social_event("gossip", "Village Gossip", "Rumors spread", {"social": 5, "mood": -5}))
	
	# ============== DISASTER EVENTS (10) ==============
	_add_event(_make_disaster_event("fire", "Building Fire", "A building catches fire!", {"damage": 50}))
	_add_event(_make_disaster_event("plague", "Disease Outbreak", "Illness spreads", {"health": -30}, true))
	_add_event(_make_disaster_event("famine", "Food Shortage", "Not enough food to eat", {"hunger": -40}))
	_add_event(_make_disaster_event("earthquake", "Earthquake", "The ground shakes violently", {"damage": 30}))
	_add_event(_make_disaster_event("flood", "Flood", "Water damages low areas", {"damage": 25}))
	_add_event(_make_disaster_event("infestation", "Pest Infestation", "Pests destroy crops", {"food": -50}))
	_add_event(_make_disaster_event("cave_in", "Mine Collapse", "A mine has collapsed", {"damage": 40}))
	_add_event(_make_disaster_event("curse", "Mysterious Curse", "Strange affliction", {"mood": -25}))
	_add_event(_make_disaster_event("bandit_raid", "Bandit Attack", "Bandits raid the village", {"damage": 20, "gold": -30}))
	_add_event(_make_disaster_event("monster_attack", "Monster Sighting", "A dangerous creature appears", {"fear": 20}))
	
	# ============== OPPORTUNITY EVENTS (10) ==============
	_add_event(_make_opportunity_event("merchant_caravan", "Merchant Caravan", "Traders arrive with goods", {"trade_opportunity": 1}))
	_add_event(_make_opportunity_event("wandering_scholar", "Wandering Scholar", "A scholar offers knowledge", {"research": 25}))
	_add_event(_make_opportunity_event("lost_survivors", "Lost Survivors", "Survivors found!", {"population": 2}))
	_add_event(_make_opportunity_event("hidden_treasure", "Hidden Treasure", "Treasure discovered!", {"gold": 50}))
	_add_event(_make_opportunity_event("rare_creature", "Rare Creature", "A rare animal is spotted", {"hunt_opportunity": 1}))
	_add_event(_make_opportunity_event("artifact_discovery", "Ancient Artifact", "An artifact is found", {"artifact": 1, "lore": 1}))
	_add_event(_make_opportunity_event("trade_opportunity", "Trade Offer", "Favorable trade proposed", {"gold": 20}))
	_add_event(_make_opportunity_event("alliance_offer", "Alliance Offer", "A tribe offers alliance", {"diplomacy": 1}))
	_add_event(_make_opportunity_event("fertile_land", "Fertile Land", "New farmable land found", {"farm_slots": 2}))
	_add_event(_make_opportunity_event("ore_vein", "Rich Ore Vein", "Metal deposits discovered", {"ore": 100}))
	
	# ============== MYSTERY EVENTS (8) ==============
	_add_event(_make_mystery_event("strange_lights", "Strange Lights", "Mysterious lights in the sky"))
	_add_event(_make_mystery_event("mysterious_stranger", "Mysterious Stranger", "An unknown figure arrives"))
	_add_event(_make_mystery_event("prophetic_dream", "Prophetic Dream", "A villager has a vision"))
	_add_event(_make_mystery_event("ancient_awakening", "Ancient Awakening", "Something stirs beneath"))
	_add_event(_make_mystery_event("portal_opening", "Portal Opens", "A doorway appears"))
	_add_event(_make_mystery_event("time_anomaly", "Time Anomaly", "Time flows strangely"))
	_add_event(_make_mystery_event("ghostly_visitor", "Ghostly Visitor", "A spirit appears"))
	_add_event(_make_mystery_event("divine_sign", "Divine Sign", "A sign from above"))
	
	# ============== COMBAT EVENTS (6) ==============
	_add_event(_make_combat_event("wolf_attack", "Wolf Pack Attack", "Wolves attack at night", 3, 50))
	_add_event(_make_combat_event("bandit_raid_large", "Major Bandit Raid", "A large bandit force approaches", 8, 80))
	_add_event(_make_combat_event("goblin_invasion", "Goblin Invasion", "Goblins swarm the village", 10, 40))
	_add_event(_make_combat_event("siege", "Village Siege", "The village is under siege", 20, 80))
	_add_event(_make_combat_event("beast_attack", "Beast Attack", "A powerful beast attacks", 1, 150))
	_add_event(_make_combat_event("boss_encounter", "Legendary Beast", "A legendary creature appears", 1, 500))

func _make_weather_event(id: String, name_str: String, desc: String, effects: Dictionary, duration: float) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.WEATHER)
	e.effects = effects
	e.duration = duration
	e.is_recurring = true
	return e

func _make_social_event(id: String, name_str: String, desc: String, effects: Dictionary) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.SOCIAL)
	e.effects = effects
	e.is_recurring = true
	return e

func _make_disaster_event(id: String, name_str: String, desc: String, effects: Dictionary, is_chain: bool = false) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.DISASTER)
	e.effects = effects
	e.weight = 0.3  # Less common
	return e

func _make_opportunity_event(id: String, name_str: String, desc: String, effects: Dictionary) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.OPPORTUNITY)
	e.effects = effects
	e.weight = 0.5
	return e

func _make_mystery_event(id: String, name_str: String, desc: String) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.MYSTERY)
	e.effects = {"mystery": 1, "lore": 1}
	e.weight = 0.2
	return e

func _make_combat_event(id: String, name_str: String, desc: String, enemy_count: int, enemy_power: float) -> EventDef:
	var e := EventDef.new(id, name_str, desc, Category.COMBAT)
	e.effects = {"enemy_count": enemy_count, "enemy_power": enemy_power}
	e.weight = 0.25
	return e

func _add_event(event: EventDef) -> void:
	_events[event.id] = event

# Public API
func get_event(event_id: String) -> EventDef:
	return _events.get(event_id)

func get_all_events() -> Dictionary:
	return _events.duplicate()

func get_events_by_category(cat: int) -> Array:
	var result: Array = []
	for event in _events.values():
		if event.category == cat:
			result.append(event)
	return result

func get_random_event(allowed_categories: Array = []) -> EventDef:
	var candidates: Array = []
	var total_weight := 0.0
	
	for event in _events.values():
		if allowed_categories.is_empty() or event.category in allowed_categories:
			candidates.append(event)
			total_weight += event.weight
	
	if candidates.is_empty():
		return null
	
	var roll := randf() * total_weight
	var cumulative := 0.0
	
	for event in candidates:
		cumulative += event.weight
		if roll <= cumulative:
			return event
	
	return candidates.back()

func get_event_count() -> int:
	return _events.size()
