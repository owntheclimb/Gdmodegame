extends Node
class_name WeatherSystem

## Seasons and Weather System
## 4 seasons, dynamic weather affecting gameplay

signal season_changed(new_season: int)
signal weather_changed(new_weather: int)

# Seasons
enum Season { SPRING, SUMMER, AUTUMN, WINTER }

const SEASON_NAMES: Dictionary = {
	Season.SPRING: "Spring",
	Season.SUMMER: "Summer",
	Season.AUTUMN: "Autumn",
	Season.WINTER: "Winter",
}

const SEASON_COLORS: Dictionary = {
	Season.SPRING: Color(0.5, 0.8, 0.5),   # Green
	Season.SUMMER: Color(0.9, 0.8, 0.3),   # Yellow
	Season.AUTUMN: Color(0.9, 0.5, 0.2),   # Orange
	Season.WINTER: Color(0.7, 0.8, 0.9),   # Light blue
}

# Weather types
enum Weather { CLEAR, CLOUDY, RAIN, STORM, SNOW, FOG, HEATWAVE }

const WEATHER_NAMES: Dictionary = {
	Weather.CLEAR: "Clear",
	Weather.CLOUDY: "Cloudy",
	Weather.RAIN: "Rain",
	Weather.STORM: "Storm",
	Weather.SNOW: "Snow",
	Weather.FOG: "Fog",
	Weather.HEATWAVE: "Heat Wave",
}

# Season effects on gameplay
const SEASON_EFFECTS: Dictionary = {
	Season.SPRING: {
		"crop_growth": 1.2,
		"energy_drain": 1.0,
		"mood": 1.1,
		"description": "New growth, perfect for planting"
	},
	Season.SUMMER: {
		"crop_growth": 1.0,
		"energy_drain": 1.2,
		"mood": 1.0,
		"description": "Hot days, harvest time"
	},
	Season.AUTUMN: {
		"crop_growth": 0.8,
		"energy_drain": 1.0,
		"mood": 0.95,
		"description": "Time to prepare for winter"
	},
	Season.WINTER: {
		"crop_growth": 0.0,
		"energy_drain": 1.3,
		"mood": 0.8,
		"description": "Cold and harsh, survival is key"
	},
}

# Weather effects
const WEATHER_EFFECTS: Dictionary = {
	Weather.CLEAR: {
		"visibility": 1.0,
		"outdoor_work": 1.0,
		"mood": 1.05,
	},
	Weather.CLOUDY: {
		"visibility": 0.9,
		"outdoor_work": 0.95,
		"mood": 1.0,
	},
	Weather.RAIN: {
		"visibility": 0.7,
		"outdoor_work": 0.7,
		"mood": 0.9,
		"crop_bonus": 1.1,
	},
	Weather.STORM: {
		"visibility": 0.4,
		"outdoor_work": 0.3,
		"mood": 0.7,
		"damage_chance": 0.1,
	},
	Weather.SNOW: {
		"visibility": 0.6,
		"outdoor_work": 0.5,
		"mood": 0.85,
		"movement_speed": 0.7,
	},
	Weather.FOG: {
		"visibility": 0.3,
		"outdoor_work": 0.8,
		"mood": 0.95,
	},
	Weather.HEATWAVE: {
		"visibility": 1.0,
		"outdoor_work": 0.6,
		"mood": 0.8,
		"energy_drain": 1.5,
	},
}

# Weather probability by season
const WEATHER_PROBABILITIES: Dictionary = {
	Season.SPRING: {
		Weather.CLEAR: 0.3,
		Weather.CLOUDY: 0.3,
		Weather.RAIN: 0.35,
		Weather.FOG: 0.05,
	},
	Season.SUMMER: {
		Weather.CLEAR: 0.5,
		Weather.CLOUDY: 0.2,
		Weather.RAIN: 0.15,
		Weather.STORM: 0.1,
		Weather.HEATWAVE: 0.05,
	},
	Season.AUTUMN: {
		Weather.CLEAR: 0.25,
		Weather.CLOUDY: 0.35,
		Weather.RAIN: 0.3,
		Weather.FOG: 0.1,
	},
	Season.WINTER: {
		Weather.CLEAR: 0.2,
		Weather.CLOUDY: 0.3,
		Weather.SNOW: 0.4,
		Weather.STORM: 0.1,
	},
}

# Current state
var current_season: Season = Season.SPRING
var current_weather: Weather = Weather.CLEAR
var day_in_season: int = 0
var year: int = 1

# Timing
const DAYS_PER_SEASON := 30
var _weather_timer := 0.0
const WEATHER_CHECK_INTERVAL := 60.0  # Real seconds between weather checks

func _ready() -> void:
	add_to_group("weather_system")
	_randomize_weather()

func _process(delta: float) -> void:
	_weather_timer += delta
	if _weather_timer >= WEATHER_CHECK_INTERVAL:
		_weather_timer = 0.0
		_check_weather_change()

func advance_day() -> void:
	day_in_season += 1
	
	if day_in_season >= DAYS_PER_SEASON:
		day_in_season = 0
		_advance_season()
	
	# Weather changes daily
	_randomize_weather()

func _advance_season() -> void:
	var old_season := current_season
	current_season = ((current_season + 1) % 4) as Season
	
	if current_season == Season.SPRING:
		year += 1
	
	season_changed.emit(current_season)
	_show_notification("Season changed to %s!" % SEASON_NAMES[current_season])

func _check_weather_change() -> void:
	# 20% chance to change weather each check
	if randf() < 0.2:
		_randomize_weather()

func _randomize_weather() -> void:
	var probs: Dictionary = WEATHER_PROBABILITIES.get(current_season, {})
	var roll := randf()
	var cumulative := 0.0
	
	for weather_type in probs:
		cumulative += probs[weather_type]
		if roll <= cumulative:
			if weather_type != current_weather:
				current_weather = weather_type
				weather_changed.emit(current_weather)
			return
	
	# Default to clear if nothing matched
	if current_weather != Weather.CLEAR:
		current_weather = Weather.CLEAR
		weather_changed.emit(current_weather)

func _show_notification(text: String) -> void:
	var action_menu := get_tree().get_first_node_in_group("action_menu")
	if action_menu and action_menu.has_method("_show_notification"):
		action_menu._show_notification(text)

# Public API
func get_season_name() -> String:
	return SEASON_NAMES[current_season]

func get_weather_name() -> String:
	return WEATHER_NAMES[current_weather]

func get_season_effect(effect: String) -> float:
	var effects: Dictionary = SEASON_EFFECTS.get(current_season, {})
	return effects.get(effect, 1.0)

func get_weather_effect(effect: String) -> float:
	var effects: Dictionary = WEATHER_EFFECTS.get(current_weather, {})
	return effects.get(effect, 1.0)

func get_combined_effect(effect: String) -> float:
	return get_season_effect(effect) * get_weather_effect(effect)

func can_grow_crops() -> bool:
	return get_season_effect("crop_growth") > 0

func get_date_string() -> String:
	return "Year %d, %s Day %d" % [year, SEASON_NAMES[current_season], day_in_season + 1]

func get_weather_icon() -> String:
	match current_weather:
		Weather.CLEAR: return "☀️"
		Weather.CLOUDY: return "☁️"
		Weather.RAIN: return "🌧️"
		Weather.STORM: return "⛈️"
		Weather.SNOW: return "❄️"
		Weather.FOG: return "🌫️"
		Weather.HEATWAVE: return "🔥"
		_: return "❓"

func get_season_icon() -> String:
	match current_season:
		Season.SPRING: return "🌸"
		Season.SUMMER: return "☀️"
		Season.AUTUMN: return "🍂"
		Season.WINTER: return "❄️"
		_: return "❓"

func is_winter() -> bool:
	return current_season == Season.WINTER

func is_stormy() -> bool:
	return current_weather == Weather.STORM

func winters_survived() -> int:
	return year - 1 + (1 if current_season > Season.WINTER else 0)
