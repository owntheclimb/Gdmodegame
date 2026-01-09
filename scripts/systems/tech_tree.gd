extends Node
class_name TechTree

## Technology Tree System with 25+ techs across 5 eras
## Each tech unlocks buildings, abilities, or bonuses

signal tech_researched(tech_id: String)
signal era_advanced(new_era: int)
signal research_progress(tech_id: String, progress: float)

# Technology Eras
enum Era { SURVIVAL, SETTLEMENT, DEVELOPMENT, ADVANCEMENT, CIVILIZATION }

const ERA_NAMES: Dictionary = {
	Era.SURVIVAL: "Survival",
	Era.SETTLEMENT: "Settlement",
	Era.DEVELOPMENT: "Development",
	Era.ADVANCEMENT: "Advancement",
	Era.CIVILIZATION: "Civilization",
}

const ERA_COLORS: Dictionary = {
	Era.SURVIVAL: Color(0.6, 0.4, 0.2),      # Brown
	Era.SETTLEMENT: Color(0.4, 0.6, 0.3),    # Green
	Era.DEVELOPMENT: Color(0.3, 0.5, 0.7),   # Blue
	Era.ADVANCEMENT: Color(0.6, 0.4, 0.7),   # Purple
	Era.CIVILIZATION: Color(0.8, 0.7, 0.3),  # Gold
}

# Technology definition
class Tech:
	var id: String
	var name: String
	var description: String
	var era: int  # Era enum
	var research_cost: int  # Research points needed
	var prerequisites: Array[String]  # Tech IDs required first
	var unlocks_buildings: Array[String]
	var unlocks_abilities: Array[String]
	var bonuses: Dictionary  # {bonus_type: value}
	var icon_path: String
	var researched: bool
	var research_progress: float
	
	func _init(p_id: String, p_name: String, p_desc: String, p_era: int, p_cost: int) -> void:
		id = p_id
		name = p_name
		description = p_desc
		era = p_era
		research_cost = p_cost
		prerequisites = []
		unlocks_buildings = []
		unlocks_abilities = []
		bonuses = {}
		icon_path = ""
		researched = false
		research_progress = 0.0
	
	func requires(tech_ids: Array[String]) -> Tech:
		prerequisites = tech_ids
		return self
	
	func unlocks(buildings: Array[String]) -> Tech:
		unlocks_buildings = buildings
		return self
	
	func grants_ability(abilities: Array[String]) -> Tech:
		unlocks_abilities = abilities
		return self
	
	func grants_bonus(bonus_type: String, value: float) -> Tech:
		bonuses[bonus_type] = value
		return self

# All technologies
var _techs: Dictionary = {}  # tech_id -> Tech

# Current era
var current_era: Era = Era.SURVIVAL

# Currently researching
var _current_research: String = ""
var _research_points_stored: float = 0.0

func _ready() -> void:
	add_to_group("tech_tree")
	_initialize_techs()

func _initialize_techs() -> void:
	# ============== ERA 1: SURVIVAL ==============
	
	_add_tech(Tech.new(
		"basic_tools", "Basic Tools", "Craft simple stone tools for gathering",
		Era.SURVIVAL, 10
	).unlocks(["storage_pit"]).grants_bonus("gather_speed", 1.2))
	
	_add_tech(Tech.new(
		"fire", "Fire", "Harness fire for cooking and warmth",
		Era.SURVIVAL, 15
	).requires(["basic_tools"]).unlocks(["campfire"]).grants_ability(["cook_food"]))
	
	_add_tech(Tech.new(
		"shelter", "Shelter", "Build basic protection from the elements",
		Era.SURVIVAL, 20
	).requires(["basic_tools"]).unlocks(["lean_to", "hut"]))
	
	_add_tech(Tech.new(
		"foraging", "Foraging", "Efficient gathering of wild food",
		Era.SURVIVAL, 15
	).grants_bonus("food_gather", 1.3))
	
	# ============== ERA 2: SETTLEMENT ==============
	
	_add_tech(Tech.new(
		"woodworking", "Woodworking", "Process wood into useful materials",
		Era.SETTLEMENT, 30
	).requires(["basic_tools"]).unlocks(["lumber_mill"]).grants_bonus("wood_production", 1.25))
	
	_add_tech(Tech.new(
		"stoneworking", "Stoneworking", "Quarry and shape stone efficiently",
		Era.SETTLEMENT, 30
	).requires(["basic_tools"]).unlocks(["quarry"]).grants_bonus("stone_production", 1.25))
	
	_add_tech(Tech.new(
		"cooking", "Cooking", "Prepare better meals for nutrition",
		Era.SETTLEMENT, 25
	).requires(["fire"]).unlocks(["kitchen"]).grants_bonus("food_quality", 1.5))
	
	_add_tech(Tech.new(
		"construction", "Construction", "Build more advanced structures",
		Era.SETTLEMENT, 35
	).requires(["shelter", "woodworking"]).unlocks(["cottage", "granary"]))
	
	_add_tech(Tech.new(
		"agriculture", "Agriculture", "Grow crops for reliable food",
		Era.SETTLEMENT, 40
	).requires(["foraging"]).unlocks(["farm"]).grants_ability(["plant_crops"]))
	
	# ============== ERA 3: DEVELOPMENT ==============
	
	_add_tech(Tech.new(
		"milling", "Milling", "Process grain into flour",
		Era.DEVELOPMENT, 50
	).requires(["agriculture", "construction"]).unlocks(["mill"]))
	
	_add_tech(Tech.new(
		"masonry", "Masonry", "Build with stone for durability",
		Era.DEVELOPMENT, 55
	).requires(["stoneworking", "construction"]).unlocks(["house", "walls"]))
	
	_add_tech(Tech.new(
		"food_preservation", "Food Preservation", "Keep food from spoiling",
		Era.DEVELOPMENT, 45
	).requires(["cooking"]).unlocks(["granary"]).grants_bonus("food_decay", 0.5))
	
	_add_tech(Tech.new(
		"architecture", "Architecture", "Design impressive buildings",
		Era.DEVELOPMENT, 60
	).requires(["masonry"]).unlocks(["meeting_hall", "school"]))
	
	_add_tech(Tech.new(
		"animal_husbandry", "Animal Husbandry", "Raise animals for resources",
		Era.DEVELOPMENT, 55
	).requires(["agriculture"]).unlocks(["stable"]).grants_ability(["tame_animals"]))
	
	_add_tech(Tech.new(
		"textiles", "Textiles", "Produce cloth and clothing",
		Era.DEVELOPMENT, 50
	).requires(["agriculture"]).unlocks(["tailor"]))
	
	# ============== ERA 4: ADVANCEMENT ==============
	
	_add_tech(Tech.new(
		"metallurgy", "Metallurgy", "Smelt ore into metal",
		Era.ADVANCEMENT, 80
	).requires(["stoneworking"]).unlocks(["forge", "blacksmith"]).grants_ability(["craft_metal"]))
	
	_add_tech(Tech.new(
		"fortification", "Fortification", "Build defensive structures",
		Era.ADVANCEMENT, 70
	).requires(["masonry"]).unlocks(["watchtower", "barracks"]).grants_bonus("defense", 1.5))
	
	_add_tech(Tech.new(
		"medicine", "Medicine", "Heal injuries and cure disease",
		Era.ADVANCEMENT, 75
	).requires(["foraging"]).unlocks(["healers_hut"]).grants_ability(["heal_villagers"]))
	
	_add_tech(Tech.new(
		"fermentation", "Fermentation", "Produce ale for morale",
		Era.ADVANCEMENT, 60
	).requires(["agriculture", "cooking"]).unlocks(["brewery"]))
	
	_add_tech(Tech.new(
		"education", "Education", "Teach skills to children",
		Era.ADVANCEMENT, 70
	).requires(["architecture"]).unlocks(["library"]).grants_bonus("skill_gain", 1.3))
	
	# ============== ERA 5: CIVILIZATION ==============
	
	_add_tech(Tech.new(
		"trade", "Trade", "Exchange goods with others",
		Era.CIVILIZATION, 100
	).requires(["metallurgy"]).unlocks(["marketplace", "treasury"]).grants_ability(["establish_trade"]))
	
	_add_tech(Tech.new(
		"military", "Military", "Train soldiers for defense",
		Era.CIVILIZATION, 100
	).requires(["fortification", "metallurgy"]).grants_bonus("combat", 1.5).grants_ability(["train_soldiers"]))
	
	_add_tech(Tech.new(
		"hospital", "Hospital", "Advanced medical care",
		Era.CIVILIZATION, 120
	).requires(["medicine", "architecture"]).grants_bonus("health", 1.5).grants_bonus("lifespan", 1.2))
	
	_add_tech(Tech.new(
		"luxury_goods", "Luxury Goods", "Produce goods for comfort and trade",
		Era.CIVILIZATION, 90
	).requires(["textiles", "trade"]).grants_bonus("happiness", 1.3))
	
	_add_tech(Tech.new(
		"advanced_architecture", "Advanced Architecture", "Build grand structures",
		Era.CIVILIZATION, 150
	).requires(["architecture", "masonry"]).unlocks(["manor", "temple"]))
	
	_add_tech(Tech.new(
		"leadership", "Leadership", "Organize the village efficiently",
		Era.CIVILIZATION, 100
	).requires(["education"]).unlocks(["meeting_hall"]).grants_ability(["declare_festival", "set_priorities"]))
	
	_add_tech(Tech.new(
		"spirituality", "Spirituality", "Connect with the divine",
		Era.CIVILIZATION, 80
	).requires(["architecture"]).unlocks(["shrine", "temple"]).grants_ability(["earn_favor"]))

func _add_tech(tech: Tech) -> void:
	_techs[tech.id] = tech

# Public API
func get_tech(tech_id: String) -> Tech:
	return _techs.get(tech_id)

func get_all_techs() -> Dictionary:
	return _techs.duplicate()

func get_techs_by_era(era: Era) -> Array:
	var result: Array = []
	for tech in _techs.values():
		if tech.era == era:
			result.append(tech)
	return result

func is_tech_available(tech_id: String) -> bool:
	var tech := get_tech(tech_id)
	if not tech:
		return false
	if tech.researched:
		return false
	
	# Check prerequisites
	for prereq in tech.prerequisites:
		var prereq_tech := get_tech(prereq)
		if not prereq_tech or not prereq_tech.researched:
			return false
	
	return true

func is_tech_researched(tech_id: String) -> bool:
	var tech := get_tech(tech_id)
	return tech.researched if tech else false

func start_research(tech_id: String) -> bool:
	if not is_tech_available(tech_id):
		return false
	_current_research = tech_id
	return true

func add_research_points(points: float) -> void:
	if _current_research.is_empty():
		_research_points_stored += points
		return
	
	var tech := get_tech(_current_research)
	if not tech:
		return
	
	tech.research_progress += points
	research_progress.emit(_current_research, tech.research_progress / tech.research_cost)
	
	if tech.research_progress >= tech.research_cost:
		complete_research(_current_research)

func complete_research(tech_id: String) -> void:
	var tech := get_tech(tech_id)
	if not tech:
		return
	
	tech.researched = true
	tech.research_progress = tech.research_cost
	_current_research = ""
	
	tech_researched.emit(tech_id)
	
	# Check for era advancement
	_check_era_advancement()

func _check_era_advancement() -> void:
	var era_techs := get_techs_by_era(current_era)
	var all_researched := true
	
	for tech in era_techs:
		if not tech.researched:
			all_researched = false
			break
	
	if all_researched and current_era < Era.CIVILIZATION:
		current_era = (current_era + 1) as Era
		era_advanced.emit(current_era)

func get_current_research() -> String:
	return _current_research

func get_research_progress() -> float:
	if _current_research.is_empty():
		return 0.0
	var tech := get_tech(_current_research)
	if not tech:
		return 0.0
	return tech.research_progress / tech.research_cost

func get_available_techs() -> Array:
	var result: Array = []
	for tech in _techs.values():
		if is_tech_available(tech.id):
			result.append(tech)
	return result

func get_researched_count() -> int:
	var count := 0
	for tech in _techs.values():
		if tech.researched:
			count += 1
	return count

func get_total_tech_count() -> int:
	return _techs.size()

func get_era_progress() -> float:
	var era_techs := get_techs_by_era(current_era)
	if era_techs.is_empty():
		return 1.0
	
	var researched := 0
	for tech in era_techs:
		if tech.researched:
			researched += 1
	
	return float(researched) / float(era_techs.size())

# Get all unlocked buildings
func get_unlocked_buildings() -> Array[String]:
	var buildings: Array[String] = []
	for tech in _techs.values():
		if tech.researched:
			for building in tech.unlocks_buildings:
				if building not in buildings:
					buildings.append(building)
	return buildings

# Get all unlocked abilities
func get_unlocked_abilities() -> Array[String]:
	var abilities: Array[String] = []
	for tech in _techs.values():
		if tech.researched:
			for ability in tech.unlocks_abilities:
				if ability not in abilities:
					abilities.append(ability)
	return abilities

# Get total bonus for a type
func get_bonus(bonus_type: String) -> float:
	var total := 1.0
	for tech in _techs.values():
		if tech.researched and tech.bonuses.has(bonus_type):
			total *= tech.bonuses[bonus_type]
	return total

# Check if an ability is unlocked
func has_ability(ability: String) -> bool:
	return ability in get_unlocked_abilities()

# Check if a building is unlocked
func is_building_unlocked(building_id: String) -> bool:
	return building_id in get_unlocked_buildings()
