extends Node
class_name ResourceDefinition

## Defines resource types with properties like name, description, rarity, gather_time, and tools_needed

# Resource rarity enumeration
enum Rarity {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# Resource class
class ResourceDef:
	var name: String
	var description: String
	var rarity: int
	var gather_time: float
	var tools_needed: Array[String]
	
	func _init(p_name: String, p_description: String, p_rarity: int, p_gather_time: float, p_tools_needed: Array[String]) -> void:
		name = p_name
		description = p_description
		rarity = p_rarity
		gather_time = p_gather_time
		tools_needed = p_tools_needed
	
	func _to_string() -> String:
		var rarity_name = Rarity.keys()[rarity]
		return "Resource(%s, Rarity: %s, Gather Time: %.1fs, Tools: %s)" % [name, rarity_name, gather_time, ", ".join(tools_needed)]
	
	func get_info() -> Dictionary:
		return {
			"name": name,
			"description": description,
			"rarity": Rarity.keys()[rarity],
			"gather_time": gather_time,
			"tools_needed": tools_needed
		}

# Dictionary to store resource definitions
var resources: Dictionary = {}

func _ready() -> void:
	_initialize_resources()

## Initialize default resource definitions
func _initialize_resources() -> void:
	# Example resources - add more as needed
	add_resource("wood", ResourceDef.new(
		"Wood",
		"Common material harvested from trees",
		Rarity.COMMON,
		3.0,
		["Axe"]
	))
	
	add_resource("stone", ResourceDef.new(
		"Stone",
		"Basic building material found in rocks",
		Rarity.COMMON,
		4.0,
		["Pickaxe"]
	))
	
	add_resource("copper_ore", ResourceDef.new(
		"Copper Ore",
		"Valuable ore used for crafting",
		Rarity.UNCOMMON,
		5.5,
		["Pickaxe", "Mining_Helmet"]
	))
	
	add_resource("iron_ore", ResourceDef.new(
		"Iron Ore",
		"Strong ore used for advanced crafting",
		Rarity.RARE,
		7.0,
		["Steel_Pickaxe"]
	))
	
	add_resource("mithril", ResourceDef.new(
		"Mithril",
		"Legendary ore with magical properties",
		Rarity.LEGENDARY,
		15.0,
		["Enchanted_Pickaxe", "Magical_Gloves"]
	))

## Add or update a resource definition
func add_resource(resource_id: String, resource: ResourceDef) -> void:
	resources[resource_id] = resource
	print("Added resource: %s" % resource_id)

## Get a resource by ID
func get_resource(resource_id: String) -> ResourceDef:
	if resource_id in resources:
		return resources[resource_id]
	push_error("Resource not found: %s" % resource_id)
	return null

## Get all resources
func get_all_resources() -> Dictionary:
	return resources

## Get resources by rarity level
func get_resources_by_rarity(rarity: int) -> Array:
	var filtered_resources: Array = []
	for resource in resources.values():
		if resource.rarity == rarity:
			filtered_resources.append(resource)
	return filtered_resources

## Get resources that require a specific tool
func get_resources_by_tool(tool: String) -> Array:
	var filtered_resources: Array = []
	for resource in resources.values():
		if tool in resource.tools_needed:
			filtered_resources.append(resource)
	return filtered_resources

## Check if a player has the required tools to gather a resource
func can_gather_resource(resource_id: String, player_tools: Array[String]) -> bool:
	var resource = get_resource(resource_id)
	if resource == null:
		return false
	
	for tool_needed in resource.tools_needed:
		if tool_needed not in player_tools:
			return false
	
	return true

## Get resource gathering difficulty based on rarity and tools needed
func get_difficulty_rating(resource_id: String) -> float:
	var resource = get_resource(resource_id)
	if resource == null:
		return 0.0
	
	var base_difficulty = float(resource.rarity + 1) * 0.5
	var tools_multiplier = 1.0 + (resource.tools_needed.size() * 0.1)
	
	return base_difficulty * tools_multiplier
