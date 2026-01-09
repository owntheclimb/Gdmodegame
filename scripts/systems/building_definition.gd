extends Blueprint
class_name BuildingDefinition

# Building Definition System
# Manages all building types, properties, and requirements for the settlement system

# Inner Classes for Different Building Types
class Residential:
	var housing_capacity: int = 0
	var happiness_modifier: float = 0.0
	var health_bonus: float = 0.0
	
	func _init(capacity: int, happiness: float, health: float = 0.0):
		housing_capacity = capacity
		happiness_modifier = happiness
		health_bonus = health

class Production:
	var input_resource: String = ""
	var output_resource: String = ""
	var production_rate: float = 0.0
	var conversion_ratio: float = 1.0
	
	func _init(input: String, output: String, rate: float, ratio: float = 1.0):
		input_resource = input
		output_resource = output
		production_rate = rate
		conversion_ratio = ratio

class StorageData:
	var capacity: int = 0
	var stored_resource: String = ""
	var efficiency: float = 1.0
	
	func _init(cap: int, resource: String, eff: float = 1.0):
		capacity = cap
		stored_resource = resource
		efficiency = eff

class Defense:
	var garrison_capacity: int = 0
	var defense_bonus: float = 0.0
	var range: float = 0.0
	var attack_power: float = 0.0
	
	func _init(capacity: int, defense: float, atk_range: float, atk_power: float):
		garrison_capacity = capacity
		defense_bonus = defense
		range = atk_range
		attack_power = atk_power

class Utility:
	var utility_type: String = ""
	var effect_radius: float = 0.0
	var efficiency: float = 1.0
	var affected_population: int = 0
	
	func _init(type: String, radius: float, eff: float = 1.0):
		utility_type = type
		effect_radius = radius
		efficiency = eff

# Building Categories
enum Category { HOUSING, PRODUCTION, COMMUNITY, STORAGE, DEFENSE }

# Building Eras
enum Era { SURVIVAL, SETTLEMENT, DEVELOPMENT, ADVANCEMENT, CIVILIZATION }

# Building Properties
var building_id: String = ""
var building_name: String = ""
var description: String = ""
var building_type: String = ""  # Residential, Production, Storage, Defense, Utility
var category: Category = Category.PRODUCTION
var era: Era = Era.SURVIVAL
var max_workers: int = 0
var production_rate: float = 0.0
var production_output: String = ""
var maintenance_cost: Dictionary = {}  # {resource_type: amount}
var tech_requirement: String = ""
var build_requirements: Dictionary = {
	"ground_type": [],  # e.g., ["grass", "plains"]
	"area_needed": 0,
	"resources": {}
}
var capabilities: Array[String] = []
var construction_time: int = 0  # in game days
var upgrade_from: String = ""  # Building this upgrades from
var upgrade_to: String = ""  # Building this upgrades to

# Building Type Specific Data
var residential_data: Residential = null
var production_data: Production = null
var storage_data: StorageData = null
var defense_data: Defense = null
var utility_data: Utility = null

# Static building registry
static var _buildings_database: Dictionary = {}
static var _initialized: bool = false

func _init():
	pass

# Initialize the buildings database with all available buildings (call lazily)
static func _ensure_initialized() -> void:
	if _initialized:
		return
	_initialized = true
	# Buildings will be registered on first access via get_building()
	# To avoid infinite recursion, we don't pre-create all buildings here

# ============== Building Creation Methods ==============

func _create_hut() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "hut"
	building.building_name = "Hut"
	building.description = "Simple dwelling for settlers"
	building.building_type = "Residential"
	building.max_workers = 0
	building.residential_data = Residential.new(4, 0.5, 0.1)
	building.maintenance_cost = {"food": 0.5}
	building.tech_requirement = ""
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 4,
		"resources": {"wood": 10, "stone": 5}
	}
	building.capabilities = ["housing"]
	building.construction_time = 5
	return building

func _create_cottage() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "cottage"
	building.building_name = "Cottage"
	building.description = "Improved dwelling with better comfort"
	building.building_type = "Residential"
	building.max_workers = 0
	building.residential_data = Residential.new(6, 1.0, 0.2)
	building.maintenance_cost = {"food": 1.0, "wood": 0.2}
	building.tech_requirement = "construction_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 6,
		"resources": {"wood": 20, "stone": 15}
	}
	building.capabilities = ["housing", "storage"]
	building.construction_time = 10
	return building

func _create_farm() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "farm"
	building.building_name = "Farm"
	building.description = "Produces food from agricultural land"
	building.building_type = "Production"
	building.max_workers = 5
	building.production_rate = 2.0
	building.production_output = "food"
	building.production_data = Production.new("", "food", 2.0, 1.0)
	building.maintenance_cost = {"wood": 0.1}
	building.tech_requirement = ""
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 12,
		"resources": {"wood": 15, "stone": 5}
	}
	building.capabilities = ["production", "food_production"]
	building.construction_time = 8
	return building

func _create_mill() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "mill"
	building.building_name = "Mill"
	building.description = "Converts grain into flour for bread production"
	building.building_type = "Production"
	building.max_workers = 3
	building.production_rate = 1.5
	building.production_output = "flour"
	building.production_data = Production.new("grain", "flour", 1.5, 0.8)
	building.maintenance_cost = {"wood": 0.3}
	building.tech_requirement = "milling_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 8,
		"resources": {"wood": 30, "stone": 20}
	}
	building.capabilities = ["production", "grain_processing"]
	building.construction_time = 12
	return building

func _create_blacksmith() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "blacksmith"
	building.building_name = "Blacksmith"
	building.description = "Forges metal tools and weapons"
	building.building_type = "Production"
	building.max_workers = 4
	building.production_rate = 0.8
	building.production_output = "metal_tools"
	building.production_data = Production.new("iron", "metal_tools", 0.8, 1.2)
	building.maintenance_cost = {"food": 0.3, "wood": 0.2}
	building.tech_requirement = "metallurgy_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 6,
		"resources": {"wood": 25, "stone": 30, "iron": 10}
	}
	building.capabilities = ["production", "crafting", "tool_production"]
	building.construction_time = 15
	return building

func _create_stable() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "stable"
	building.building_name = "Stable"
	building.description = "Raises and trains horses"
	building.building_type = "Production"
	building.max_workers = 3
	building.production_rate = 0.5
	building.production_output = "horse"
	building.production_data = Production.new("food", "horse", 0.5, 2.0)
	building.maintenance_cost = {"food": 1.5, "wood": 0.2}
	building.tech_requirement = "animal_husbandry"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 10,
		"resources": {"wood": 20, "stone": 10}
	}
	building.capabilities = ["production", "animal_husbandry", "mount_production"]
	building.construction_time = 10
	return building

func _create_workshop() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "workshop"
	building.building_name = "Workshop"
	building.description = "Crafts various goods and tools"
	building.building_type = "Production"
	building.max_workers = 6
	building.production_rate = 1.2
	building.production_output = "crafted_goods"
	building.production_data = Production.new("", "crafted_goods", 1.2, 1.0)
	building.maintenance_cost = {"wood": 0.4}
	building.tech_requirement = "crafting_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 8,
		"resources": {"wood": 35, "stone": 25}
	}
	building.capabilities = ["production", "crafting", "general_crafting"]
	building.construction_time = 14
	return building

func _create_granary() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "granary"
	building.building_name = "Granary"
	building.description = "Stores grain and prevents spoilage"
	building.building_type = "Storage"
	building.max_workers = 2
	building.storage_data = StorageData.new(500, "grain", 0.95)
	building.maintenance_cost = {"wood": 0.1}
	building.tech_requirement = ""
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 6,
		"resources": {"wood": 20, "stone": 15}
	}
	building.capabilities = ["storage", "grain_storage"]
	building.construction_time = 8
	return building

func _create_warehouse() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "warehouse"
	building.building_name = "Warehouse"
	building.description = "General storage for various goods"
	building.building_type = "Storage"
	building.max_workers = 3
	building.storage_data = StorageData.new(1000, "general", 0.9)
	building.maintenance_cost = {"wood": 0.2}
	building.tech_requirement = "storage_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 12,
		"resources": {"wood": 40, "stone": 30}
	}
	building.capabilities = ["storage", "general_storage"]
	building.construction_time = 12
	return building

func _create_watchtower() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "watchtower"
	building.building_name = "Watchtower"
	building.description = "Provides defense and surveillance"
	building.building_type = "Defense"
	building.max_workers = 2
	building.defense_data = Defense.new(5, 1.5, 15.0, 3.0)
	building.maintenance_cost = {"wood": 0.1, "food": 0.2}
	building.tech_requirement = "defense_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 4,
		"resources": {"wood": 15, "stone": 40}
	}
	building.capabilities = ["defense", "surveillance", "archer_tower"]
	building.construction_time = 10
	return building

func _create_barracks() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "barracks"
	building.building_name = "Barracks"
	building.description = "Trains and houses soldiers"
	building.building_type = "Defense"
	building.max_workers = 4
	building.defense_data = Defense.new(10, 2.0, 10.0, 5.0)
	building.maintenance_cost = {"food": 0.5, "wood": 0.2}
	building.tech_requirement = "military_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 8,
		"resources": {"wood": 30, "stone": 30}
	}
	building.capabilities = ["defense", "military_training", "garrison"]
	building.construction_time = 14
	return building

func _create_temple() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "temple"
	building.building_name = "Temple"
	building.description = "Religious center that increases happiness"
	building.building_type = "Utility"
	building.max_workers = 2
	building.utility_data = Utility.new("religious", 12.0, 1.0)
	building.maintenance_cost = {"food": 0.3}
	building.tech_requirement = "religion_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 6,
		"resources": {"wood": 25, "stone": 35}
	}
	building.capabilities = ["utility", "religious", "happiness_boost"]
	building.construction_time = 16
	return building

func _create_shrine() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "shrine"
	building.building_name = "Shrine"
	building.description = "Small religious site for spiritual comfort"
	building.building_type = "Utility"
	building.max_workers = 1
	building.utility_data = Utility.new("religious", 8.0, 0.8)
	building.maintenance_cost = {"food": 0.1}
	building.tech_requirement = ""
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 3,
		"resources": {"wood": 10, "stone": 15}
	}
	building.capabilities = ["utility", "religious", "spiritual"]
	building.construction_time = 7
	return building

func _create_well() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "well"
	building.building_name = "Well"
	building.description = "Provides fresh water to nearby inhabitants"
	building.building_type = "Utility"
	building.max_workers = 1
	building.utility_data = Utility.new("water", 10.0, 1.0)
	building.maintenance_cost = {"wood": 0.05}
	building.tech_requirement = ""
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 2,
		"resources": {"wood": 5, "stone": 10}
	}
	building.capabilities = ["utility", "water_supply", "health_bonus"]
	building.construction_time = 5
	return building

func _create_library() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "library"
	building.building_name = "Library"
	building.description = "Advances learning and technological progress"
	building.building_type = "Utility"
	building.max_workers = 3
	building.utility_data = Utility.new("education", 8.0, 1.2)
	building.maintenance_cost = {"food": 0.2, "wood": 0.3}
	building.tech_requirement = "education_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 6,
		"resources": {"wood": 30, "stone": 25}
	}
	building.capabilities = ["utility", "education", "research_boost", "tech_advancement"]
	building.construction_time = 18
	return building

func _create_bathhouse() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "bathhouse"
	building.building_name = "Bathhouse"
	building.description = "Improves health and sanitation"
	building.building_type = "Utility"
	building.max_workers = 2
	building.utility_data = Utility.new("health", 10.0, 0.9)
	building.maintenance_cost = {"water": 0.5, "wood": 0.1}
	building.tech_requirement = "sanitation_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 5,
		"resources": {"wood": 20, "stone": 20}
	}
	building.capabilities = ["utility", "health", "sanitation", "disease_prevention"]
	building.construction_time = 12
	return building

func _create_marketplace() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "marketplace"
	building.building_name = "Marketplace"
	building.description = "Facilitates trade and commerce"
	building.building_type = "Utility"
	building.max_workers = 4
	building.utility_data = Utility.new("commerce", 12.0, 1.1)
	building.maintenance_cost = {"food": 0.2, "wood": 0.1}
	building.tech_requirement = "trade_01"
	building.build_requirements = {
		"ground_type": ["grass", "plains"],
		"area_needed": 8,
		"resources": {"wood": 25, "stone": 20}
	}
	building.capabilities = ["utility", "trade", "commerce", "goods_exchange"]
	building.construction_time = 11
	return building

# ============== Public Methods ==============

# Get a specific building by ID (creates on-demand to avoid infinite recursion)
func get_building(building_id: String) -> BuildingDefinition:
	if building_id in _buildings_database:
		return _buildings_database[building_id]
	# Lazy create the building if not in database
	var building: BuildingDefinition = _create_building_by_id(building_id)
	if building:
		_buildings_database[building_id] = building
		return building
	push_error("Building not found: " + building_id)
	return null

func _create_building_by_id(building_id: String) -> BuildingDefinition:
	match building_id:
		# HOUSING
		"lean_to": return _create_lean_to()
		"hut": return _create_hut()
		"cottage": return _create_cottage()
		"house": return _create_house()
		"manor": return _create_manor()
		# PRODUCTION
		"campfire": return _create_campfire()
		"farm": return _create_farm()
		"farm_plot": return _create_farm()
		"lumber_mill": return _create_lumber_mill()
		"quarry": return _create_quarry()
		"mill": return _create_mill()
		"blacksmith": return _create_blacksmith()
		"forge": return _create_blacksmith()
		"stable": return _create_stable()
		"workshop": return _create_workshop()
		"kitchen": return _create_kitchen()
		"brewery": return _create_brewery()
		"tailor": return _create_tailor()
		# COMMUNITY
		"shrine": return _create_shrine()
		"temple": return _create_temple()
		"meeting_hall": return _create_meeting_hall()
		"healers_hut": return _create_healers_hut()
		"school": return _create_school()
		"library": return _create_library()
		"bathhouse": return _create_bathhouse()
		"marketplace": return _create_marketplace()
		# STORAGE
		"storage_pit": return _create_storage_pit()
		"granary": return _create_granary()
		"warehouse": return _create_warehouse()
		"treasury": return _create_treasury()
		# DEFENSE
		"watchtower": return _create_watchtower()
		"walls": return _create_walls()
		"barracks": return _create_barracks()
		"well": return _create_well()
		_: return null

# ============== Additional Building Creation Methods ==============

func _create_lean_to() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "lean_to"
	building.building_name = "Lean-To"
	building.description = "Temporary shelter for one person"
	building.building_type = "Residential"
	building.category = Category.HOUSING
	building.era = Era.SURVIVAL
	building.residential_data = Residential.new(1, 0.1, 0.0)
	building.tech_requirement = ""
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 2, "resources": {"wood": 5}}
	building.upgrade_to = "hut"
	building.construction_time = 2
	return building

func _create_house() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "house"
	building.building_name = "House"
	building.description = "Comfortable dwelling for a family"
	building.building_type = "Residential"
	building.category = Category.HOUSING
	building.era = Era.DEVELOPMENT
	building.residential_data = Residential.new(6, 1.5, 0.3)
	building.tech_requirement = "masonry"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 8, "resources": {"wood": 50, "stone": 40, "clay": 10}}
	building.upgrade_from = "cottage"
	building.upgrade_to = "manor"
	building.construction_time = 15
	return building

func _create_manor() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "manor"
	building.building_name = "Manor"
	building.description = "Luxurious estate for distinguished families"
	building.building_type = "Residential"
	building.category = Category.HOUSING
	building.era = Era.CIVILIZATION
	building.residential_data = Residential.new(10, 2.5, 0.5)
	building.tech_requirement = "advanced_architecture"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 16, "resources": {"wood": 100, "stone": 80, "clay": 30}}
	building.upgrade_from = "house"
	building.construction_time = 25
	return building

func _create_campfire() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "campfire"
	building.building_name = "Campfire"
	building.description = "Cook food and provide warmth"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.SURVIVAL
	building.production_data = Production.new("food", "cooked_food", 1.0, 1.5)
	building.tech_requirement = ""
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 1, "resources": {"wood": 3, "stone": 2}}
	building.construction_time = 1
	return building

func _create_lumber_mill() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "lumber_mill"
	building.building_name = "Lumber Mill"
	building.description = "Process logs into planks faster"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.SETTLEMENT
	building.production_data = Production.new("wood", "planks", 2.0, 0.8)
	building.tech_requirement = "woodworking"
	building.build_requirements = {"ground_type": ["grass", "forest"], "area_needed": 10, "resources": {"wood": 40, "stone": 20}}
	building.construction_time = 12
	return building

func _create_quarry() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "quarry"
	building.building_name = "Quarry"
	building.description = "Mine stone more efficiently"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.SETTLEMENT
	building.production_data = Production.new("", "stone", 2.5, 1.0)
	building.tech_requirement = "stoneworking"
	building.build_requirements = {"ground_type": ["mountain", "hills"], "area_needed": 12, "resources": {"wood": 30, "stone": 10}}
	building.construction_time = 14
	return building

func _create_kitchen() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "kitchen"
	building.building_name = "Kitchen"
	building.description = "Cook advanced meals for better nutrition"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.DEVELOPMENT
	building.production_data = Production.new("food", "meals", 1.5, 2.0)
	building.tech_requirement = "cooking"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 6, "resources": {"wood": 25, "stone": 20}}
	building.construction_time = 10
	return building

func _create_brewery() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "brewery"
	building.building_name = "Brewery"
	building.description = "Make ale for morale boost"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.DEVELOPMENT
	building.production_data = Production.new("food", "ale", 0.8, 1.0)
	building.tech_requirement = "fermentation"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 8, "resources": {"wood": 35, "stone": 25}}
	building.construction_time = 12
	return building

func _create_tailor() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "tailor"
	building.building_name = "Tailor"
	building.description = "Make clothes for comfort"
	building.building_type = "Production"
	building.category = Category.PRODUCTION
	building.era = Era.DEVELOPMENT
	building.production_data = Production.new("fiber", "cloth", 1.0, 1.0)
	building.tech_requirement = "textiles"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 6, "resources": {"wood": 20, "stone": 15}}
	building.construction_time = 10
	return building

func _create_meeting_hall() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "meeting_hall"
	building.building_name = "Meeting Hall"
	building.description = "Boosts morale and enables festivals"
	building.building_type = "Utility"
	building.category = Category.COMMUNITY
	building.era = Era.DEVELOPMENT
	building.utility_data = Utility.new("social", 15.0, 1.2)
	building.tech_requirement = "leadership"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 12, "resources": {"wood": 50, "stone": 30}}
	building.construction_time = 18
	return building

func _create_healers_hut() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "healers_hut"
	building.building_name = "Healer's Hut"
	building.description = "Cure disease and heal injuries"
	building.building_type = "Utility"
	building.category = Category.COMMUNITY
	building.era = Era.SETTLEMENT
	building.utility_data = Utility.new("health", 10.0, 1.0)
	building.tech_requirement = "medicine"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 4, "resources": {"wood": 15, "stone": 10}}
	building.construction_time = 8
	return building

func _create_school() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "school"
	building.building_name = "School"
	building.description = "Children learn faster"
	building.building_type = "Utility"
	building.category = Category.COMMUNITY
	building.era = Era.DEVELOPMENT
	building.utility_data = Utility.new("education", 12.0, 1.0)
	building.tech_requirement = "education"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 8, "resources": {"wood": 30, "stone": 25}}
	building.construction_time = 14
	return building

func _create_storage_pit() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "storage_pit"
	building.building_name = "Storage Pit"
	building.description = "Basic storage for 50 resources"
	building.building_type = "Storage"
	building.category = Category.STORAGE
	building.era = Era.SURVIVAL
	building.storage_data = StorageData.new(50, "general", 0.8)
	building.tech_requirement = ""
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 4, "resources": {"wood": 5, "stone": 5}}
	building.upgrade_to = "granary"
	building.construction_time = 3
	return building

func _create_treasury() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "treasury"
	building.building_name = "Treasury"
	building.description = "Store gold and valuables"
	building.building_type = "Storage"
	building.category = Category.STORAGE
	building.era = Era.CIVILIZATION
	building.storage_data = StorageData.new(500, "gold", 1.0)
	building.tech_requirement = "trade"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 6, "resources": {"stone": 50, "metal": 20}}
	building.construction_time = 20
	return building

func _create_walls() -> BuildingDefinition:
	var building = BuildingDefinition.new()
	building.building_id = "walls"
	building.building_name = "Walls"
	building.description = "Block predators and enemies"
	building.building_type = "Defense"
	building.category = Category.DEFENSE
	building.era = Era.SETTLEMENT
	building.defense_data = Defense.new(0, 3.0, 0.0, 0.0)
	building.tech_requirement = "fortification"
	building.build_requirements = {"ground_type": ["grass", "plains"], "area_needed": 2, "resources": {"stone": 20, "wood": 5}}
	building.construction_time = 6
	return building

# Get all buildings
func get_all_buildings() -> Dictionary:
	return _buildings_database.duplicate()

# Add a new building to the registry
func add_building(building: BuildingDefinition) -> bool:
	if building.building_id in _buildings_database:
		push_warning("Building already exists: " + building.building_id)
		return false
	_buildings_database[building.building_id] = building
	return true

# Get buildings by type
func get_buildings_by_type(building_type: String) -> Array[BuildingDefinition]:
	var result: Array[BuildingDefinition] = []
	for building in _buildings_database.values():
		if building.building_type == building_type:
			result.append(building)
	return result

# Check if build requirements are met
func check_build_requirements(building_id: String, available_resources: Dictionary, 
							  available_ground: Array[String]) -> Dictionary:
	var building = get_building(building_id)
	if building == null:
		return {"valid": false, "reason": "Building not found"}
	
	var requirements = building.build_requirements
	
	# Check ground type
	var ground_ok = false
	for ground in available_ground:
		if ground in requirements["ground_type"]:
			ground_ok = true
			break
	
	if not ground_ok:
		return {"valid": false, "reason": "Unsuitable ground type"}
	
	# Check resources
	for resource in requirements["resources"]:
		if not resource in available_resources:
			return {"valid": false, "reason": "Missing resource: " + resource}
		if available_resources[resource] < requirements["resources"][resource]:
			return {"valid": false, "reason": "Insufficient " + resource}
	
	return {"valid": true, "reason": "Requirements met"}

# Get production information
func get_production_info(building_id: String) -> Dictionary:
	var building = get_building(building_id)
	if building == null:
		return {}
	
	return {
		"building_id": building.building_id,
		"building_name": building.building_name,
		"production_rate": building.production_rate,
		"production_output": building.production_output,
		"max_workers": building.max_workers,
		"production_data": building.production_data
	}

# Get maintenance information
func get_maintenance_info(building_id: String) -> Dictionary:
	var building = get_building(building_id)
	if building == null:
		return {}
	
	return {
		"building_id": building.building_id,
		"building_name": building.building_name,
		"maintenance_cost": building.maintenance_cost,
		"description": building.description
	}

# Get all available building IDs
func get_all_building_ids() -> Array[String]:
	return [
		# Housing (5)
		"lean_to", "hut", "cottage", "house", "manor",
		# Production (12)
		"campfire", "farm", "lumber_mill", "quarry", "mill",
		"blacksmith", "stable", "workshop", "kitchen", "brewery", "tailor",
		# Community (8)
		"shrine", "temple", "meeting_hall", "healers_hut", "school",
		"library", "bathhouse", "marketplace",
		# Storage (4)
		"storage_pit", "granary", "warehouse", "treasury",
		# Defense (3)
		"watchtower", "walls", "barracks", "well"
	]

# Get buildings by era
func get_buildings_by_era(target_era: Era) -> Array[BuildingDefinition]:
	var result: Array[BuildingDefinition] = []
	for id in get_all_building_ids():
		var building = get_building(id)
		if building and building.era == target_era:
			result.append(building)
	return result

# Get buildings by category
func get_buildings_by_category(target_category: Category) -> Array[BuildingDefinition]:
	var result: Array[BuildingDefinition] = []
	for id in get_all_building_ids():
		var building = get_building(id)
		if building and building.category == target_category:
			result.append(building)
	return result

# Get total building count
func get_building_count() -> int:
	return get_all_building_ids().size()
