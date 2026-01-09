extends Node
class_name CreatureCatalog

## Creature Catalog with 15+ creature types, behaviors, and genetics

signal creature_tamed(creature_type: String)
signal creature_bred(creature_type: String, offspring: Dictionary)

# Creature categories
enum Category { PASSIVE, HOSTILE, MYTHICAL }

# Creature behaviors
enum Behavior { DOCILE, SKITTISH, TERRITORIAL, PACK_HUNTER, SOLITARY, MAGICAL }

# Creature definition
class CreatureDef:
	var id: String
	var name: String
	var description: String
	var category: int  # Category enum
	var behavior: int  # Behavior enum
	var biomes: Array[String]  # Where creature spawns
	var health: float
	var damage: float
	var speed: float
	var tameable: bool
	var tame_difficulty: float  # 0-1
	var tame_food: String  # Food type to tame
	var products: Dictionary  # {product: amount_per_day}
	var drop_on_kill: Dictionary  # {resource: amount}
	var spawn_weight: float  # Relative spawn chance
	var genetics: Dictionary  # Genetic traits
	var icon_path: String
	
	func _init(p_id: String, p_name: String, p_desc: String, p_cat: int, p_behavior: int) -> void:
		id = p_id
		name = p_name
		description = p_desc
		category = p_cat
		behavior = p_behavior
		biomes = []
		health = 50.0
		damage = 5.0
		speed = 40.0
		tameable = false
		tame_difficulty = 0.5
		tame_food = "food"
		products = {}
		drop_on_kill = {}
		spawn_weight = 1.0
		genetics = {}
		icon_path = ""
	
	func found_in(p_biomes: Array[String]) -> CreatureDef:
		biomes = p_biomes
		return self
	
	func set_stats(p_health: float, p_damage: float, p_speed: float) -> CreatureDef:
		health = p_health
		damage = p_damage
		speed = p_speed
		return self
	
	func can_tame(difficulty: float, food: String) -> CreatureDef:
		tameable = true
		tame_difficulty = difficulty
		tame_food = food
		return self
	
	func produces(p_products: Dictionary) -> CreatureDef:
		products = p_products
		return self
	
	func drops(p_drops: Dictionary) -> CreatureDef:
		drop_on_kill = p_drops
		return self
	
	func weight(p_weight: float) -> CreatureDef:
		spawn_weight = p_weight
		return self

# All creatures
var _creatures: Dictionary = {}  # creature_id -> CreatureDef

func _ready() -> void:
	add_to_group("creature_catalog")
	_initialize_creatures()

func _initialize_creatures() -> void:
	# ============== PASSIVE CREATURES ==============
	
	_add_creature(CreatureDef.new(
		"rabbit", "Rabbit", "Small and quick, provides meat and fur",
		Category.PASSIVE, Behavior.SKITTISH
	).found_in(["grassland", "forest"]).set_stats(15, 0, 80).can_tame(0.3, "food").produces({"fur": 0.2}).drops({"meat": 2, "fur": 1}).weight(3.0))
	
	_add_creature(CreatureDef.new(
		"deer", "Deer", "Graceful forest dweller, good meat and leather",
		Category.PASSIVE, Behavior.SKITTISH
	).found_in(["forest", "grassland"]).set_stats(40, 5, 70).drops({"meat": 8, "leather": 3}).weight(2.0))
	
	_add_creature(CreatureDef.new(
		"sheep", "Sheep", "Domesticated for wool and meat",
		Category.PASSIVE, Behavior.DOCILE
	).found_in(["grassland"]).set_stats(30, 0, 30).can_tame(0.2, "food").produces({"wool": 1.0, "milk": 0.5}).drops({"meat": 6, "wool": 2}).weight(1.5))
	
	_add_creature(CreatureDef.new(
		"cow", "Cow", "Valuable for milk, meat, and leather",
		Category.PASSIVE, Behavior.DOCILE
	).found_in(["grassland"]).set_stats(60, 5, 25).can_tame(0.3, "food").produces({"milk": 2.0, "leather": 0.1}).drops({"meat": 15, "leather": 5}).weight(1.0))
	
	_add_creature(CreatureDef.new(
		"chicken", "Chicken", "Provides eggs and meat",
		Category.PASSIVE, Behavior.DOCILE
	).found_in(["grassland", "forest"]).set_stats(10, 0, 40).can_tame(0.1, "food").produces({"eggs": 1.0, "feathers": 0.2}).drops({"meat": 1, "feathers": 2}).weight(2.5))
	
	_add_creature(CreatureDef.new(
		"horse", "Horse", "Fast mount for transportation",
		Category.PASSIVE, Behavior.SKITTISH
	).found_in(["plains", "grassland"]).set_stats(80, 10, 100).can_tame(0.6, "food").drops({"meat": 12, "leather": 6}).weight(0.5))
	
	_add_creature(CreatureDef.new(
		"pig", "Pig", "Easy to raise, good meat",
		Category.PASSIVE, Behavior.DOCILE
	).found_in(["forest", "grassland"]).set_stats(40, 2, 35).can_tame(0.2, "food").drops({"meat": 10}).weight(1.5))
	
	# ============== HOSTILE CREATURES ==============
	
	_add_creature(CreatureDef.new(
		"wolf", "Wolf", "Dangerous pack hunter, hunts at night",
		Category.HOSTILE, Behavior.PACK_HUNTER
	).found_in(["forest", "tundra"]).set_stats(50, 15, 65).can_tame(0.7, "meat").drops({"meat": 5, "fur": 3}).weight(1.5))
	
	_add_creature(CreatureDef.new(
		"bear", "Bear", "Territorial and powerful predator",
		Category.HOSTILE, Behavior.TERRITORIAL
	).found_in(["forest", "mountain"]).set_stats(150, 30, 45).drops({"meat": 20, "fur": 8}).weight(0.5))
	
	_add_creature(CreatureDef.new(
		"boar", "Boar", "Aggressive when provoked",
		Category.HOSTILE, Behavior.TERRITORIAL
	).found_in(["forest"]).set_stats(60, 20, 50).drops({"meat": 12, "leather": 3}).weight(1.0))
	
	_add_creature(CreatureDef.new(
		"snake", "Snake", "Venomous and hidden in swamps",
		Category.HOSTILE, Behavior.SOLITARY
	).found_in(["swamp", "desert"]).set_stats(20, 25, 40).drops({"venom": 2, "scales": 1}).weight(1.5))
	
	_add_creature(CreatureDef.new(
		"bandit", "Bandit", "Human enemy that steals resources",
		Category.HOSTILE, Behavior.PACK_HUNTER
	).found_in(["grassland", "forest", "mountain"]).set_stats(80, 20, 45).drops({"gold": 5, "metal": 2}).weight(0.3))
	
	_add_creature(CreatureDef.new(
		"goblin", "Goblin", "Raids villages in groups",
		Category.HOSTILE, Behavior.PACK_HUNTER
	).found_in(["forest", "swamp", "mountain"]).set_stats(40, 12, 50).drops({"gold": 3, "metal": 1}).weight(0.4))
	
	# ============== MYTHICAL CREATURES ==============
	
	_add_creature(CreatureDef.new(
		"phoenix", "Phoenix", "Legendary fire bird that drops ember essence",
		Category.MYTHICAL, Behavior.SOLITARY
	).found_in(["volcano", "desert"]).set_stats(200, 50, 90).drops({"essence": 5, "ember": 10, "gold": 20}).weight(0.05))
	
	_add_creature(CreatureDef.new(
		"unicorn", "Unicorn", "Sacred creature that heals nearby entities",
		Category.MYTHICAL, Behavior.MAGICAL
	).found_in(["sacred_grove", "forest"]).set_stats(120, 10, 80).can_tame(0.9, "herbs").produces({"healing_aura": 1.0}).drops({"essence": 3, "horn": 1}).weight(0.08))
	
	_add_creature(CreatureDef.new(
		"dragon", "Dragon", "Ultimate threat and ultimate reward",
		Category.MYTHICAL, Behavior.TERRITORIAL
	).found_in(["mountain"]).set_stats(500, 100, 60).drops({"essence": 20, "scales": 30, "gold": 100, "artifact": 1}).weight(0.02))
	
	_add_creature(CreatureDef.new(
		"griffin", "Griffin", "Majestic flying predator",
		Category.MYTHICAL, Behavior.TERRITORIAL
	).found_in(["mountain", "plains"]).set_stats(180, 40, 100).can_tame(0.95, "meat").drops({"essence": 5, "feathers": 15}).weight(0.04))
	
	_add_creature(CreatureDef.new(
		"giant", "Giant", "Massive territorial guardian of ruins",
		Category.MYTHICAL, Behavior.TERRITORIAL
	).found_in(["mountain", "ruins"]).set_stats(400, 80, 30).drops({"stone": 50, "gold": 30, "artifact": 1}).weight(0.03))

func _add_creature(creature: CreatureDef) -> void:
	_creatures[creature.id] = creature

# Public API
func get_creature(creature_id: String) -> CreatureDef:
	return _creatures.get(creature_id)

func get_all_creatures() -> Dictionary:
	return _creatures.duplicate()

func get_creatures_by_category(cat: int) -> Array:
	var result: Array = []
	for creature in _creatures.values():
		if creature.category == cat:
			result.append(creature)
	return result

func get_creatures_for_biome(biome: String) -> Array:
	var result: Array = []
	for creature in _creatures.values():
		if biome in creature.biomes:
			result.append(creature)
	return result

func get_tameable_creatures() -> Array:
	var result: Array = []
	for creature in _creatures.values():
		if creature.tameable:
			result.append(creature)
	return result

func get_passive_creatures() -> Array:
	return get_creatures_by_category(Category.PASSIVE)

func get_hostile_creatures() -> Array:
	return get_creatures_by_category(Category.HOSTILE)

func get_mythical_creatures() -> Array:
	return get_creatures_by_category(Category.MYTHICAL)

# Calculate tame chance based on villager skill
func calculate_tame_chance(creature_id: String, villager_skill: int) -> float:
	var creature := get_creature(creature_id)
	if not creature or not creature.tameable:
		return 0.0
	
	var base_chance := 1.0 - creature.tame_difficulty
	var skill_bonus := villager_skill * 0.005  # 0.5% per skill level
	return clampf(base_chance + skill_bonus, 0.05, 0.95)

# Get spawn weights for a biome
func get_spawn_weights_for_biome(biome: String) -> Dictionary:
	var weights: Dictionary = {}
	for creature in _creatures.values():
		if biome in creature.biomes:
			weights[creature.id] = creature.spawn_weight
	return weights

# Generate offspring with genetics
func breed_creatures(parent_a_id: String, parent_b_id: String) -> Dictionary:
	if parent_a_id != parent_b_id:
		return {}  # Can only breed same species
	
	var creature := get_creature(parent_a_id)
	if not creature:
		return {}
	
	# Generate offspring with variation
	var offspring := {
		"type": creature.id,
		"health_mod": randf_range(0.9, 1.1),
		"speed_mod": randf_range(0.9, 1.1),
		"product_mod": randf_range(0.95, 1.2),
		"traits": []
	}
	
	# Random trait chance
	if randf() < 0.1:
		var traits := ["large", "small", "fast", "hardy", "productive"]
		offspring.traits.append(traits.pick_random())
	
	creature_bred.emit(parent_a_id, offspring)
	return offspring

func get_creature_count() -> int:
	return _creatures.size()
