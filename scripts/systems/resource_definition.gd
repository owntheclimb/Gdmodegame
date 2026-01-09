extends Node
class_name ResourceDefinition

## Defines 15+ resource types with processing chains:
## Raw -> Processed -> Finished goods

# Resource categories
enum Category { RAW, PROCESSED, SPECIAL }

# Resource rarity enumeration
enum Rarity { COMMON, UNCOMMON, RARE, EPIC, LEGENDARY }

# Resource class
class ResourceDef:
	var id: String
	var name: String
	var description: String
	var category: int  # Category enum
	var rarity: int  # Rarity enum
	var gather_time: float
	var tools_needed: Array[String]
	var processing_chain: Dictionary  # {required_building: output_resource, ratio: float}
	var icon_path: String
	
	func _init(p_id: String, p_name: String, p_description: String, p_category: int, p_rarity: int, p_gather_time: float, p_tools: Array[String] = []) -> void:
		id = p_id
		name = p_name
		description = p_description
		category = p_category
		rarity = p_rarity
		gather_time = p_gather_time
		tools_needed = p_tools
		processing_chain = {}
		icon_path = ""
	
	func set_processing(building: String, output: String, ratio: float) -> ResourceDef:
		processing_chain = {"building": building, "output": output, "ratio": ratio}
		return self
	
	func _to_string() -> String:
		return "Resource(%s, %s)" % [name, Category.keys()[category]]
	
	func get_info() -> Dictionary:
		return {
			"id": id,
			"name": name,
			"description": description,
			"category": Category.keys()[category],
			"rarity": Rarity.keys()[rarity],
			"gather_time": gather_time,
			"tools_needed": tools_needed,
			"processing_chain": processing_chain
		}

# Dictionary to store resource definitions
var resources: Dictionary = {}

# Processing chain definitions
var processing_chains: Array[Dictionary] = []

func _ready() -> void:
	_initialize_resources()
	_initialize_processing_chains()

## Initialize all resource definitions (15+ resources)
func _initialize_resources() -> void:
	# ============== RAW RESOURCES (Gathered) ==============
	
	add_resource("wood", ResourceDef.new(
		"wood", "Wood", "Harvested from trees, essential for construction",
		Category.RAW, Rarity.COMMON, 3.0, ["Axe"]
	).set_processing("lumber_mill", "planks", 0.8))
	
	add_resource("stone", ResourceDef.new(
		"stone", "Stone", "Basic building material from rocks",
		Category.RAW, Rarity.COMMON, 4.0, ["Pickaxe"]
	).set_processing("quarry", "cut_stone", 0.9))
	
	add_resource("food", ResourceDef.new(
		"food", "Berries", "Gathered from bushes, provides basic nutrition",
		Category.RAW, Rarity.COMMON, 2.0, []
	).set_processing("kitchen", "meals", 2.0))
	
	add_resource("clay", ResourceDef.new(
		"clay", "Clay", "Found near riverbanks, used for pottery and bricks",
		Category.RAW, Rarity.COMMON, 3.5, []
	).set_processing("forge", "bricks", 0.7))
	
	add_resource("ore", ResourceDef.new(
		"ore", "Iron Ore", "Found in mountain deposits, refined into metal",
		Category.RAW, Rarity.UNCOMMON, 6.0, ["Pickaxe"]
	).set_processing("forge", "metal", 0.6))
	
	add_resource("herbs", ResourceDef.new(
		"herbs", "Herbs", "Found on forest floor, used for medicine",
		Category.RAW, Rarity.UNCOMMON, 4.0, []
	).set_processing("healers_hut", "medicine", 0.5))
	
	add_resource("fiber", ResourceDef.new(
		"fiber", "Fiber", "Gathered from tall grass, used for textiles",
		Category.RAW, Rarity.COMMON, 2.5, []
	).set_processing("tailor", "cloth", 0.8))
	
	add_resource("wheat", ResourceDef.new(
		"wheat", "Wheat", "Grown on farms, processed into flour",
		Category.RAW, Rarity.COMMON, 5.0, []
	).set_processing("mill", "flour", 0.85))
	
	# ============== PROCESSED RESOURCES (Crafted) ==============
	
	add_resource("planks", ResourceDef.new(
		"planks", "Planks", "Processed wood for advanced construction",
		Category.PROCESSED, Rarity.COMMON, 0.0, []
	).set_processing("workshop", "furniture", 0.5))
	
	add_resource("cut_stone", ResourceDef.new(
		"cut_stone", "Cut Stone", "Refined stone for quality buildings",
		Category.PROCESSED, Rarity.COMMON, 0.0, []
	))
	
	add_resource("bricks", ResourceDef.new(
		"bricks", "Bricks", "Fired clay for durable construction",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("metal", ResourceDef.new(
		"metal", "Metal", "Smelted ore for tools and weapons",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	).set_processing("blacksmith", "tools", 0.5))
	
	add_resource("cloth", ResourceDef.new(
		"cloth", "Cloth", "Woven fiber for clothing",
		Category.PROCESSED, Rarity.COMMON, 0.0, []
	).set_processing("tailor", "clothing", 0.7))
	
	add_resource("medicine", ResourceDef.new(
		"medicine", "Medicine", "Prepared herbs for healing",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("meals", ResourceDef.new(
		"meals", "Cooked Meals", "Prepared food with better nutrition",
		Category.PROCESSED, Rarity.COMMON, 0.0, []
	))
	
	add_resource("flour", ResourceDef.new(
		"flour", "Flour", "Ground wheat for baking",
		Category.PROCESSED, Rarity.COMMON, 0.0, []
	).set_processing("kitchen", "bread", 0.9))
	
	add_resource("bread", ResourceDef.new(
		"bread", "Bread", "Premium food with excellent nutrition",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("ale", ResourceDef.new(
		"ale", "Ale", "Fermented drink that boosts morale",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("tools", ResourceDef.new(
		"tools", "Tools", "Crafted metal tools for productivity",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("furniture", ResourceDef.new(
		"furniture", "Furniture", "Crafted wood items for comfort",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("clothing", ResourceDef.new(
		"clothing", "Clothing", "Tailored garments for comfort",
		Category.PROCESSED, Rarity.UNCOMMON, 0.0, []
	))
	
	# ============== SPECIAL RESOURCES ==============
	
	add_resource("research_points", ResourceDef.new(
		"research_points", "Research Points", "Generated by scholars for technology",
		Category.SPECIAL, Rarity.UNCOMMON, 0.0, []
	))
	
	add_resource("divine_favor", ResourceDef.new(
		"divine_favor", "Divine Favor", "Earned through shrine worship",
		Category.SPECIAL, Rarity.RARE, 0.0, []
	))
	
	add_resource("gold", ResourceDef.new(
		"gold", "Gold", "Valuable currency for trade",
		Category.SPECIAL, Rarity.RARE, 10.0, ["Pickaxe"]
	))
	
	add_resource("artifacts", ResourceDef.new(
		"artifacts", "Ancient Artifacts", "Found in ruins, unlock secrets",
		Category.SPECIAL, Rarity.EPIC, 0.0, []
	))
	
	add_resource("essence", ResourceDef.new(
		"essence", "Essence", "Extracted from legendary creatures",
		Category.SPECIAL, Rarity.LEGENDARY, 0.0, []
	))

## Initialize processing chain display info
func _initialize_processing_chains() -> void:
	processing_chains = [
		{"name": "Food Production", "steps": ["wheat", "flour", "bread"], "buildings": ["Farm", "Mill", "Kitchen"]},
		{"name": "Textile Production", "steps": ["fiber", "cloth", "clothing"], "buildings": ["Gather", "Tailor", "Tailor"]},
		{"name": "Metal Working", "steps": ["ore", "metal", "tools"], "buildings": ["Quarry", "Forge", "Blacksmith"]},
		{"name": "Wood Processing", "steps": ["wood", "planks", "furniture"], "buildings": ["Trees", "Lumber Mill", "Workshop"]},
		{"name": "Construction", "steps": ["clay", "bricks"], "buildings": ["Riverbank", "Forge"]},
		{"name": "Medicine", "steps": ["herbs", "medicine"], "buildings": ["Forest", "Healer's Hut"]},
	]

## Add or update a resource definition
func add_resource(resource_id: String, resource: ResourceDef) -> void:
	resources[resource_id] = resource

## Get a resource by ID
func get_resource(resource_id: String) -> ResourceDef:
	if resource_id in resources:
		return resources[resource_id]
	return null

## Get all resources
func get_all_resources() -> Dictionary:
	return resources

## Get resources by category
func get_resources_by_category(cat: int) -> Array:
	var filtered: Array = []
	for resource in resources.values():
		if resource.category == cat:
			filtered.append(resource)
	return filtered

## Get resources by rarity level
func get_resources_by_rarity(rarity: int) -> Array:
	var filtered: Array = []
	for resource in resources.values():
		if resource.rarity == rarity:
			filtered.append(resource)
	return filtered

## Get the output of processing a resource
func get_processing_output(resource_id: String) -> Dictionary:
	var resource = get_resource(resource_id)
	if resource == null:
		return {}
	return resource.processing_chain

## Get the full processing chain for a resource
func get_full_chain(resource_id: String) -> Array[String]:
	var chain: Array[String] = [resource_id]
	var current := resource_id
	
	for _i in range(5):  # Max 5 levels of processing
		var resource = get_resource(current)
		if resource == null or resource.processing_chain.is_empty():
			break
		var output: String = resource.processing_chain.get("output", "")
		if output.is_empty() or output in chain:
			break
		chain.append(output)
		current = output
	
	return chain

## Get all raw resources
func get_raw_resources() -> Array:
	return get_resources_by_category(Category.RAW)

## Get all processed resources
func get_processed_resources() -> Array:
	return get_resources_by_category(Category.PROCESSED)

## Get all special resources
func get_special_resources() -> Array:
	return get_resources_by_category(Category.SPECIAL)

## Get total resource count
func get_resource_count() -> int:
	return resources.size()

## Get processing chains for display
func get_processing_chains() -> Array[Dictionary]:
	return processing_chains
