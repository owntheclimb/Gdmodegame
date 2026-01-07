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

class Storage:
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

# Building Properties
var building_id: String = ""
var building_name: String = ""
var description: String = ""
var building_type: String = ""  # Residential, Production, Storage, Defense, Utility
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

# Building Type Specific Data
var residential_data: Residential = null
var production_data: Production = null
var storage_data: Storage = null
var defense_data: Defense = null
var utility_data: Utility = null

# Static building registry
static var _buildings_database: Dictionary = {}

func _init():
	super()
	_initialize_buildings_database()

# Initialize the buildings database with all available buildings
func _initialize_buildings_database() -> void:
	if _buildings_database.is_empty():
		# Residential Buildings
		var hut = _create_hut()
		var cottage = _create_cottage()
		
		# Production Buildings
		var farm = _create_farm()
		var mill = _create_mill()
		var blacksmith = _create_blacksmith()
		var stable = _create_stable()
		var workshop = _create_workshop()
		
		# Storage Buildings
		var granary = _create_granary()
		var warehouse = _create_warehouse()
		
		# Defense Buildings
		var watchtower = _create_watchtower()
		var barracks = _create_barracks()
		
		# Utility/Religious Buildings
		var temple = _create_temple()
		var shrine = _create_shrine()
		var well = _create_well()
		var library = _create_library()
		var bathhouse = _create_bathhouse()
		var marketplace = _create_marketplace()
		
		# Register all buildings
		for building in [hut, cottage, farm, mill, blacksmith, stable, workshop, 
						granary, warehouse, watchtower, barracks, temple, shrine, 
						well, library, bathhouse, marketplace]:
			_buildings_database[building.building_id] = building

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
	building.storage_data = Storage.new(500, "grain", 0.95)
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
	building.storage_data = Storage.new(1000, "general", 0.9)
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

# Get a specific building by ID
func get_building(building_id: String) -> BuildingDefinition:
	if building_id in _buildings_database:
		return _buildings_database[building_id]
	push_error("Building not found: " + building_id)
	return null

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
