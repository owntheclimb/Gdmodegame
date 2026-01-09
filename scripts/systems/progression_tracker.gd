extends Node
class_name ProgressionTracker

## Multiple Progression Tracks:
## - Village Level (Camp → Metropolis)
## - Technology Era (Stone Age → Enlightenment)
## - Reputation (Unknown → Mythical)
## - Dynasty (Generations and legacies)

signal village_level_up(new_level: int, new_name: String)
signal era_changed(new_era: int, new_name: String)
signal reputation_changed(new_tier: int, new_name: String)
signal generation_changed(new_generation: int)

# Village Levels
enum VillageLevel { CAMP, SETTLEMENT, VILLAGE, TOWN, CITY, CAPITAL, METROPOLIS }

const VILLAGE_LEVEL_NAMES: Dictionary = {
	VillageLevel.CAMP: "Camp",
	VillageLevel.SETTLEMENT: "Settlement",
	VillageLevel.VILLAGE: "Village",
	VillageLevel.TOWN: "Town",
	VillageLevel.CITY: "City",
	VillageLevel.CAPITAL: "Capital",
	VillageLevel.METROPOLIS: "Metropolis",
}

const VILLAGE_LEVEL_REQUIREMENTS: Dictionary = {
	VillageLevel.CAMP: {"population": 0, "buildings": 0},
	VillageLevel.SETTLEMENT: {"population": 5, "buildings": 3},
	VillageLevel.VILLAGE: {"population": 15, "buildings": 8},
	VillageLevel.TOWN: {"population": 30, "buildings": 15},
	VillageLevel.CITY: {"population": 60, "buildings": 25},
	VillageLevel.CAPITAL: {"population": 100, "buildings": 40},
	VillageLevel.METROPOLIS: {"population": 200, "buildings": 60},
}

# Technology Eras
enum TechEra { STONE_AGE, BRONZE_AGE, IRON_AGE, MEDIEVAL, RENAISSANCE, ENLIGHTENMENT }

const TECH_ERA_NAMES: Dictionary = {
	TechEra.STONE_AGE: "Stone Age",
	TechEra.BRONZE_AGE: "Bronze Age",
	TechEra.IRON_AGE: "Iron Age",
	TechEra.MEDIEVAL: "Medieval",
	TechEra.RENAISSANCE: "Renaissance",
	TechEra.ENLIGHTENMENT: "Enlightenment",
}

# Reputation tiers
enum Reputation { UNKNOWN, NOTICED, RESPECTED, FAMOUS, LEGENDARY, MYTHICAL }

const REPUTATION_NAMES: Dictionary = {
	Reputation.UNKNOWN: "Unknown",
	Reputation.NOTICED: "Noticed",
	Reputation.RESPECTED: "Respected",
	Reputation.FAMOUS: "Famous",
	Reputation.LEGENDARY: "Legendary",
	Reputation.MYTHICAL: "Mythical",
}

const REPUTATION_THRESHOLDS: Dictionary = {
	Reputation.UNKNOWN: 0,
	Reputation.NOTICED: 50,
	Reputation.RESPECTED: 150,
	Reputation.FAMOUS: 350,
	Reputation.LEGENDARY: 700,
	Reputation.MYTHICAL: 1500,
}

# Current state
var village_level: VillageLevel = VillageLevel.CAMP
var tech_era: TechEra = TechEra.STONE_AGE
var reputation_tier: Reputation = Reputation.UNKNOWN
var reputation_points: int = 0
var current_generation: int = 1
var dynasty_bonuses: Dictionary = {}

# Dynasty tracking
var founder_name: String = ""
var generations_history: Array[Dictionary] = []

func _ready() -> void:
	add_to_group("progression_tracker")

func _process(_delta: float) -> void:
	_check_village_level()
	_check_reputation()

func _check_village_level() -> void:
	var population := get_tree().get_nodes_in_group("villager").size()
	var buildings := get_tree().get_nodes_in_group("building").size()
	
	for level in range(VillageLevel.METROPOLIS, -1, -1):
		var reqs: Dictionary = VILLAGE_LEVEL_REQUIREMENTS[level]
		if population >= reqs.population and buildings >= reqs.buildings:
			if level != village_level:
				var old_level := village_level
				village_level = level as VillageLevel
				if level > old_level:
					village_level_up.emit(level, VILLAGE_LEVEL_NAMES[level])
					_show_notification("Village upgraded to %s!" % VILLAGE_LEVEL_NAMES[level])
			break

func _check_reputation() -> void:
	for tier in range(Reputation.MYTHICAL, -1, -1):
		if reputation_points >= REPUTATION_THRESHOLDS[tier]:
			if tier != reputation_tier:
				reputation_tier = tier as Reputation
				reputation_changed.emit(tier, REPUTATION_NAMES[tier])
				_show_notification("Reputation increased: %s!" % REPUTATION_NAMES[tier])
			break

func add_reputation(amount: int) -> void:
	reputation_points += amount
	_check_reputation()

func set_tech_era(era: TechEra) -> void:
	if era != tech_era:
		tech_era = era
		era_changed.emit(era, TECH_ERA_NAMES[era])
		_show_notification("New Era: %s!" % TECH_ERA_NAMES[era])

func advance_generation(leader_name: String) -> void:
	# Record current generation
	generations_history.append({
		"generation": current_generation,
		"leader": leader_name,
		"village_level": village_level,
		"population": get_tree().get_nodes_in_group("villager").size(),
		"tech_era": tech_era,
	})
	
	current_generation += 1
	
	# Dynasty bonuses accumulate
	dynasty_bonuses["legacy_bonus"] = current_generation * 0.02  # 2% per generation
	
	generation_changed.emit(current_generation)
	_show_notification("Generation %d begins!" % current_generation)

func set_founder(villager_name: String) -> void:
	if founder_name.is_empty():
		founder_name = villager_name

func _show_notification(text: String) -> void:
	var action_menu := get_tree().get_first_node_in_group("action_menu")
	if action_menu and action_menu.has_method("_show_notification"):
		action_menu._show_notification(text)

# Public API
func get_village_level_name() -> String:
	return VILLAGE_LEVEL_NAMES[village_level]

func get_tech_era_name() -> String:
	return TECH_ERA_NAMES[tech_era]

func get_reputation_name() -> String:
	return REPUTATION_NAMES[reputation_tier]

func get_village_progress() -> float:
	if village_level >= VillageLevel.METROPOLIS:
		return 1.0
	
	var current_reqs: Dictionary = VILLAGE_LEVEL_REQUIREMENTS[village_level]
	var next_reqs: Dictionary = VILLAGE_LEVEL_REQUIREMENTS[village_level + 1]
	
	var population := get_tree().get_nodes_in_group("villager").size()
	var buildings := get_tree().get_nodes_in_group("building").size()
	
	var pop_progress := float(population - current_reqs.population) / float(next_reqs.population - current_reqs.population)
	var build_progress := float(buildings - current_reqs.buildings) / float(next_reqs.buildings - current_reqs.buildings)
	
	return clampf((pop_progress + build_progress) / 2.0, 0.0, 1.0)

func get_reputation_progress() -> float:
	if reputation_tier >= Reputation.MYTHICAL:
		return 1.0
	
	var current_threshold: int = REPUTATION_THRESHOLDS[reputation_tier]
	var next_threshold: int = REPUTATION_THRESHOLDS[reputation_tier + 1]
	
	return clampf(float(reputation_points - current_threshold) / float(next_threshold - current_threshold), 0.0, 1.0)

func get_dynasty_bonus(bonus_type: String) -> float:
	return dynasty_bonuses.get(bonus_type, 0.0)

func get_progress_summary() -> Dictionary:
	return {
		"village_level": VILLAGE_LEVEL_NAMES[village_level],
		"village_progress": get_village_progress(),
		"tech_era": TECH_ERA_NAMES[tech_era],
		"reputation": REPUTATION_NAMES[reputation_tier],
		"reputation_points": reputation_points,
		"reputation_progress": get_reputation_progress(),
		"generation": current_generation,
		"founder": founder_name,
	}

# Reputation actions
func complete_quest() -> void:
	add_reputation(10)

func defeat_enemy() -> void:
	add_reputation(5)

func help_tribe() -> void:
	add_reputation(20)

func build_wonder() -> void:
	add_reputation(100)

func complete_trade() -> void:
	add_reputation(3)
