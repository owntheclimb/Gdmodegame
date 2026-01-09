extends Node
class_name SkillSystem

## Skill System with 6 skills, levels 1-100, perks, and synergies

signal skill_leveled(villager: Villager, skill_id: String, new_level: int)
signal perk_unlocked(villager: Villager, skill_id: String, perk: Dictionary)

# Skill categories
enum Skill { FARMING, BUILDING, RESEARCH, COMBAT, SOCIAL, SURVIVAL }

const SKILL_NAMES: Dictionary = {
	Skill.FARMING: "Farming",
	Skill.BUILDING: "Building",
	Skill.RESEARCH: "Research",
	Skill.COMBAT: "Combat",
	Skill.SOCIAL: "Social",
	Skill.SURVIVAL: "Survival",
}

const SKILL_COLORS: Dictionary = {
	Skill.FARMING: Color(0.4, 0.7, 0.3),
	Skill.BUILDING: Color(0.7, 0.5, 0.3),
	Skill.RESEARCH: Color(0.3, 0.5, 0.8),
	Skill.COMBAT: Color(0.8, 0.3, 0.3),
	Skill.SOCIAL: Color(0.8, 0.5, 0.7),
	Skill.SURVIVAL: Color(0.5, 0.6, 0.4),
}

# XP required per level (increases exponentially)
const BASE_XP := 100
const XP_MULTIPLIER := 1.15

# Rank thresholds
const RANKS: Dictionary = {
	1: "Novice",
	11: "Apprentice",
	26: "Journeyman",
	51: "Expert",
	76: "Master",
	100: "Legendary"
}

# Perk definitions for each skill
const PERKS: Dictionary = {
	Skill.FARMING: {
		10: {"id": "green_thumb", "name": "Green Thumb", "desc": "+20% crop yield", "bonus": {"crop_yield": 1.2}},
		20: {"id": "quick_harvest", "name": "Quick Harvest", "desc": "+15% harvest speed", "bonus": {"harvest_speed": 1.15}},
		30: {"id": "crop_rotation", "name": "Crop Rotation", "desc": "+10% all farm production", "bonus": {"farm_production": 1.1}},
		40: {"id": "animal_friend", "name": "Animal Friend", "desc": "Can tame animals faster", "bonus": {"tame_speed": 1.5}},
		50: {"id": "master_farmer", "name": "Master Farmer", "desc": "Crops never fail", "bonus": {"crop_fail_chance": 0.0}},
		60: {"id": "abundant", "name": "Abundant Harvest", "desc": "+30% food production", "bonus": {"food_production": 1.3}},
		70: {"id": "teach_farming", "name": "Teacher", "desc": "Can teach farming to others", "bonus": {"can_teach": true}},
		80: {"id": "weather_sense", "name": "Weather Sense", "desc": "Predict weather changes", "bonus": {"weather_prediction": true}},
		90: {"id": "legendary_farmer", "name": "Legendary Farmer", "desc": "Double harvest chance", "bonus": {"double_harvest": 0.25}},
		100: {"id": "nature_master", "name": "Nature Master", "desc": "All nature bonuses doubled", "bonus": {"nature_bonus": 2.0}},
	},
	Skill.BUILDING: {
		10: {"id": "sturdy_build", "name": "Sturdy Build", "desc": "+10% building durability", "bonus": {"durability": 1.1}},
		20: {"id": "quick_hands", "name": "Quick Hands", "desc": "+15% build speed", "bonus": {"build_speed": 1.15}},
		30: {"id": "resource_saver", "name": "Resource Saver", "desc": "-10% material cost", "bonus": {"material_cost": 0.9}},
		40: {"id": "architect", "name": "Architect", "desc": "Unlock advanced blueprints", "bonus": {"advanced_blueprints": true}},
		50: {"id": "master_builder", "name": "Master Builder", "desc": "+25% all construction", "bonus": {"construction": 1.25}},
		60: {"id": "repair_expert", "name": "Repair Expert", "desc": "Repairs cost 50% less", "bonus": {"repair_cost": 0.5}},
		70: {"id": "teach_building", "name": "Teacher", "desc": "Can teach building to others", "bonus": {"can_teach": true}},
		80: {"id": "fortify", "name": "Fortify", "desc": "+20% defensive structures", "bonus": {"defense_bonus": 1.2}},
		90: {"id": "legendary_builder", "name": "Legendary Builder", "desc": "Buildings never decay", "bonus": {"no_decay": true}},
		100: {"id": "wonder_builder", "name": "Wonder Builder", "desc": "Can build wonders", "bonus": {"can_build_wonders": true}},
	},
	Skill.RESEARCH: {
		10: {"id": "quick_learner", "name": "Quick Learner", "desc": "+10% research speed", "bonus": {"research_speed": 1.1}},
		20: {"id": "curious", "name": "Curious", "desc": "+15% discovery chance", "bonus": {"discovery": 1.15}},
		30: {"id": "scholar", "name": "Scholar", "desc": "Generate research points", "bonus": {"research_gen": 1.0}},
		40: {"id": "inventor", "name": "Inventor", "desc": "Unlock inventions", "bonus": {"inventions": true}},
		50: {"id": "master_scholar", "name": "Master Scholar", "desc": "+25% all learning", "bonus": {"learning": 1.25}},
		60: {"id": "ancient_knowledge", "name": "Ancient Knowledge", "desc": "Understand artifacts", "bonus": {"artifact_bonus": 1.5}},
		70: {"id": "teach_research", "name": "Teacher", "desc": "Can teach research to others", "bonus": {"can_teach": true}},
		80: {"id": "genius", "name": "Genius", "desc": "Double research output", "bonus": {"research_output": 2.0}},
		90: {"id": "legendary_scholar", "name": "Legendary Scholar", "desc": "All research costs -30%", "bonus": {"research_cost": 0.7}},
		100: {"id": "enlightened", "name": "Enlightened", "desc": "Unlock hidden knowledge", "bonus": {"hidden_knowledge": true}},
	},
	Skill.COMBAT: {
		10: {"id": "tough", "name": "Tough", "desc": "+10% health", "bonus": {"health": 1.1}},
		20: {"id": "quick_reflexes", "name": "Quick Reflexes", "desc": "+15% dodge chance", "bonus": {"dodge": 0.15}},
		30: {"id": "weapon_training", "name": "Weapon Training", "desc": "+20% weapon damage", "bonus": {"damage": 1.2}},
		40: {"id": "defender", "name": "Defender", "desc": "+25% defense", "bonus": {"defense": 1.25}},
		50: {"id": "warrior", "name": "Warrior", "desc": "+30% combat effectiveness", "bonus": {"combat": 1.3}},
		60: {"id": "battle_hardened", "name": "Battle Hardened", "desc": "Resist fear effects", "bonus": {"fear_resist": true}},
		70: {"id": "teach_combat", "name": "Teacher", "desc": "Can teach combat to others", "bonus": {"can_teach": true}},
		80: {"id": "champion", "name": "Champion", "desc": "Inspire nearby allies", "bonus": {"inspire_radius": 10.0}},
		90: {"id": "legendary_warrior", "name": "Legendary Warrior", "desc": "Critical hit chance +25%", "bonus": {"crit_chance": 0.25}},
		100: {"id": "invincible", "name": "Invincible", "desc": "Cannot be killed in combat", "bonus": {"immortal_combat": true}},
	},
	Skill.SOCIAL: {
		10: {"id": "friendly", "name": "Friendly", "desc": "+10% relationship gain", "bonus": {"relationship": 1.1}},
		20: {"id": "charming", "name": "Charming", "desc": "+15% persuasion", "bonus": {"persuasion": 1.15}},
		30: {"id": "leader", "name": "Leader", "desc": "Boost nearby morale", "bonus": {"morale_aura": 1.1}},
		40: {"id": "matchmaker", "name": "Matchmaker", "desc": "Improve romance chances", "bonus": {"romance": 1.3}},
		50: {"id": "diplomat", "name": "Diplomat", "desc": "+25% trade deals", "bonus": {"trade": 1.25}},
		60: {"id": "orator", "name": "Orator", "desc": "Inspire during events", "bonus": {"event_bonus": 1.2}},
		70: {"id": "teach_social", "name": "Teacher", "desc": "Can teach social to others", "bonus": {"can_teach": true}},
		80: {"id": "mediator", "name": "Mediator", "desc": "Resolve conflicts", "bonus": {"conflict_resolve": true}},
		90: {"id": "legendary_leader", "name": "Legendary Leader", "desc": "Village-wide morale boost", "bonus": {"village_morale": 1.3}},
		100: {"id": "beloved", "name": "Beloved", "desc": "Everyone loves this villager", "bonus": {"universal_friend": true}},
	},
	Skill.SURVIVAL: {
		10: {"id": "hardy", "name": "Hardy", "desc": "+10% stamina", "bonus": {"stamina": 1.1}},
		20: {"id": "forager", "name": "Forager", "desc": "+15% gather speed", "bonus": {"gather": 1.15}},
		30: {"id": "tracker", "name": "Tracker", "desc": "Find animals easier", "bonus": {"tracking": 1.3}},
		40: {"id": "explorer", "name": "Explorer", "desc": "Reveal map faster", "bonus": {"exploration": 1.5}},
		50: {"id": "survivor", "name": "Survivor", "desc": "+25% all survival", "bonus": {"survival": 1.25}},
		60: {"id": "weathered", "name": "Weathered", "desc": "Resist weather effects", "bonus": {"weather_resist": 0.5}},
		70: {"id": "teach_survival", "name": "Teacher", "desc": "Can teach survival to others", "bonus": {"can_teach": true}},
		80: {"id": "pathfinder", "name": "Pathfinder", "desc": "+30% movement speed", "bonus": {"speed": 1.3}},
		90: {"id": "legendary_survivor", "name": "Legendary Survivor", "desc": "Never starve", "bonus": {"no_starve": true}},
		100: {"id": "one_with_nature", "name": "One with Nature", "desc": "Commune with wildlife", "bonus": {"wildlife_friend": true}},
	},
}

# Synergy definitions
const SYNERGIES: Dictionary = {
	"farming_survival": {"skills": [Skill.FARMING, Skill.SURVIVAL], "min_level": 30, "bonus": {"food_efficiency": 1.2}},
	"building_research": {"skills": [Skill.BUILDING, Skill.RESEARCH], "min_level": 40, "bonus": {"blueprint_cost": 0.8}},
	"combat_survival": {"skills": [Skill.COMBAT, Skill.SURVIVAL], "min_level": 35, "bonus": {"hunting_damage": 1.3}},
	"social_research": {"skills": [Skill.SOCIAL, Skill.RESEARCH], "min_level": 50, "bonus": {"teaching_speed": 1.5}},
	"farming_building": {"skills": [Skill.FARMING, Skill.BUILDING], "min_level": 40, "bonus": {"farm_building_speed": 1.25}},
}

func _ready() -> void:
	add_to_group("skill_system")

# Get XP required for a level
func get_xp_for_level(level: int) -> int:
	return int(BASE_XP * pow(XP_MULTIPLIER, level - 1))

# Get total XP required to reach a level from 1
func get_total_xp_for_level(level: int) -> int:
	var total := 0
	for i in range(1, level):
		total += get_xp_for_level(i)
	return total

# Get rank name for a level
func get_rank(level: int) -> String:
	var rank := "Novice"
	for threshold in RANKS:
		if level >= threshold:
			rank = RANKS[threshold]
	return rank

# Get all perks unlocked at or below a level
func get_unlocked_perks(skill: Skill, level: int) -> Array[Dictionary]:
	var perks: Array[Dictionary] = []
	var skill_perks: Dictionary = PERKS.get(skill, {})
	for threshold in skill_perks:
		if level >= threshold:
			perks.append(skill_perks[threshold])
	return perks

# Get the next perk for a skill
func get_next_perk(skill: Skill, level: int) -> Dictionary:
	var skill_perks: Dictionary = PERKS.get(skill, {})
	for threshold in skill_perks:
		if level < threshold:
			return {"level": threshold, "perk": skill_perks[threshold]}
	return {}

# Check if synergy is active
func check_synergy(villager_skills: Dictionary, synergy_id: String) -> bool:
	var synergy: Dictionary = SYNERGIES.get(synergy_id, {})
	if synergy.is_empty():
		return false
	
	var required_skills: Array = synergy.get("skills", [])
	var min_level: int = synergy.get("min_level", 0)
	
	for skill in required_skills:
		var skill_level: int = villager_skills.get(skill, 0)
		if skill_level < min_level:
			return false
	
	return true

# Get all active synergies for a villager
func get_active_synergies(villager_skills: Dictionary) -> Array[String]:
	var active: Array[String] = []
	for synergy_id in SYNERGIES:
		if check_synergy(villager_skills, synergy_id):
			active.append(synergy_id)
	return active

# Calculate total bonus from perks and synergies
func get_total_bonus(villager_skills: Dictionary, bonus_type: String) -> float:
	var total := 1.0
	
	# Add perk bonuses
	for skill in villager_skills:
		var level: int = villager_skills[skill]
		var perks := get_unlocked_perks(skill, level)
		for perk in perks:
			var bonuses: Dictionary = perk.get("bonus", {})
			if bonuses.has(bonus_type):
				var bonus = bonuses[bonus_type]
				if bonus is float:
					total *= bonus
	
	# Add synergy bonuses
	for synergy_id in get_active_synergies(villager_skills):
		var synergy: Dictionary = SYNERGIES[synergy_id]
		var bonuses: Dictionary = synergy.get("bonus", {})
		if bonuses.has(bonus_type):
			var bonus = bonuses[bonus_type]
			if bonus is float:
				total *= bonus
	
	return total

# Add XP to a skill
func add_skill_xp(villager: Villager, skill: Skill, xp: float) -> void:
	if not villager:
		return
	
	# Ensure villager has skills dictionary
	if not villager.has_method("get_skills"):
		return
	
	var skills: Dictionary = villager.get_skills()
	var skill_data: Dictionary = skills.get(skill, {"level": 1, "xp": 0.0})
	
	skill_data.xp += xp
	
	# Check for level up
	while skill_data.xp >= get_xp_for_level(skill_data.level) and skill_data.level < 100:
		skill_data.xp -= get_xp_for_level(skill_data.level)
		skill_data.level += 1
		skill_leveled.emit(villager, SKILL_NAMES[skill], skill_data.level)
		
		# Check for perk unlock
		if skill_data.level % 10 == 0:
			var skill_perks: Dictionary = PERKS.get(skill, {})
			if skill_perks.has(skill_data.level):
				perk_unlocked.emit(villager, SKILL_NAMES[skill], skill_perks[skill_data.level])
	
	skills[skill] = skill_data

# Get skill info for UI
func get_skill_info(skill: Skill, level: int) -> Dictionary:
	return {
		"name": SKILL_NAMES[skill],
		"color": SKILL_COLORS[skill],
		"level": level,
		"rank": get_rank(level),
		"xp_to_next": get_xp_for_level(level),
		"perks_unlocked": get_unlocked_perks(skill, level).size(),
		"next_perk": get_next_perk(skill, level),
	}
