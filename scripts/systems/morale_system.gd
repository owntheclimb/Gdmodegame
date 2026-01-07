extends Node
class_name MoraleSystem

# Morale level enum
enum MoraleLevel {
	TERRIBLE,
	POOR,
	NEUTRAL,
	GOOD,
	EXCELLENT
}

# Inner class for morale modifiers
class MoraleModifier:
	var source: String
	var value: float
	var duration: float
	var decay_rate: float
	var applied_time: float
	
	func _init(p_source: String, p_value: float, p_duration: float = -1.0, p_decay_rate: float = 0.0) -> void:
		source = p_source
		value = p_value
		duration = p_duration
		decay_rate = p_decay_rate
		applied_time = 0.0
	
	func is_expired() -> bool:
		if duration < 0:
			return false
		return applied_time >= duration
	
	func apply_decay(delta: float) -> void:
		if decay_rate > 0 and duration > 0:
			value = max(0, value - (decay_rate * delta))
			applied_time += delta

# Morale state variables
var current_morale: float = 50.0
var morale_modifiers: Array = []
var morale_history: Array = []
var relationships: Dictionary = {}

# Configuration
var max_history_entries: int = 100
var morale_update_interval: float = 0.1
var time_since_update: float = 0.0

func _ready() -> void:
	add_to_group("systems")
	initialize_morale_state()

func _process(delta: float) -> void:
	time_since_update += delta
	if time_since_update >= morale_update_interval:
		update(delta)
		time_since_update = 0.0

func initialize_morale_state() -> void:
	current_morale = 50.0
	morale_modifiers.clear()
	morale_history.clear()
	relationships.clear()
	record_morale_history()

# ============================================================================
# Morale Modifier Management
# ============================================================================

func add_morale_modifier(source: String, value: float, duration: float = -1.0, decay_rate: float = 0.0) -> MoraleModifier:
	var modifier = MoraleModifier.new(source, value, duration, decay_rate)
	morale_modifiers.append(modifier)
	
	if duration < 0:
		print_debug("Added permanent morale modifier from '%s' with value %.2f" % [source, value])
	else:
		print_debug("Added temporary morale modifier from '%s' with value %.2f (duration: %.2f)" % [source, value, duration])
	
	return modifier

func remove_morale_modifier(modifier: MoraleModifier) -> void:
	if morale_modifiers.has(modifier):
		morale_modifiers.erase(modifier)
		print_debug("Removed morale modifier from '%s'" % modifier.source)

func remove_modifier_by_source(source: String) -> void:
	var to_remove = []
	for modifier in morale_modifiers:
		if modifier.source == source:
			to_remove.append(modifier)
	
	for modifier in to_remove:
		remove_morale_modifier(modifier)

# ============================================================================
# Morale Calculation
# ============================================================================

func calculate_current_morale() -> float:
	var base_morale: float = 50.0
	var modifier_sum: float = 0.0
	
	for modifier in morale_modifiers:
		modifier_sum += modifier.value
	
	var calculated_morale = base_morale + modifier_sum
	current_morale = clamp(calculated_morale, 0.0, 100.0)
	
	return current_morale

func get_morale_level() -> int:
	if current_morale >= 90:
		return MoraleLevel.EXCELLENT
	elif current_morale >= 70:
		return MoraleLevel.GOOD
	elif current_morale >= 40:
		return MoraleLevel.NEUTRAL
	elif current_morale >= 20:
		return MoraleLevel.POOR
	else:
		return MoraleLevel.TERRIBLE

func get_morale_level_name() -> String:
	match get_morale_level():
		MoraleLevel.EXCELLENT:
			return "EXCELLENT"
		MoraleLevel.GOOD:
			return "GOOD"
		MoraleLevel.NEUTRAL:
			return "NEUTRAL"
		MoraleLevel.POOR:
			return "POOR"
		MoraleLevel.TERRIBLE:
			return "TERRIBLE"
		_:
			return "UNKNOWN"

# ============================================================================
# Morale Effects
# ============================================================================

func get_efficiency_multiplier() -> float:
	var morale_level = get_morale_level()
	
	match morale_level:
		MoraleLevel.EXCELLENT:
			return 1.5
		MoraleLevel.GOOD:
			return 1.25
		MoraleLevel.NEUTRAL:
			return 1.0
		MoraleLevel.POOR:
			return 0.75
		MoraleLevel.TERRIBLE:
			return 0.5
		_:
			return 1.0

func get_morale_status() -> Dictionary:
	return {
		"current_morale": current_morale,
		"morale_level": get_morale_level_name(),
		"efficiency_multiplier": get_efficiency_multiplier(),
		"active_modifiers_count": morale_modifiers.size(),
		"relationships_count": relationships.size()
	}

# ============================================================================
# Relationship Management
# ============================================================================

func add_relationship(entity_id: String, initial_points: float = 0.0) -> void:
	if not relationships.has(entity_id):
		relationships[entity_id] = {
			"points": initial_points,
			"history": []
		}
		print_debug("Added relationship with '%s'" % entity_id)

func get_relationship(entity_id: String) -> float:
	if relationships.has(entity_id):
		return relationships[entity_id]["points"]
	return 0.0

func increase_relationship_points(entity_id: String, amount: float) -> void:
	if not relationships.has(entity_id):
		add_relationship(entity_id, 0.0)
	
	var old_points = relationships[entity_id]["points"]
	relationships[entity_id]["points"] += amount
	relationships[entity_id]["history"].append({
		"timestamp": Time.get_ticks_msec(),
		"change": amount,
		"previous": old_points,
		"new": relationships[entity_id]["points"]
	})
	
	print_debug("Relationship with '%s' changed by %.2f (now: %.2f)" % [entity_id, amount, relationships[entity_id]["points"]])

func decrease_relationship_points(entity_id: String, amount: float) -> void:
	increase_relationship_points(entity_id, -amount)

# ============================================================================
# Update and Decay
# ============================================================================

func update(delta: float) -> void:
	# Apply decay to temporary modifiers
	for modifier in morale_modifiers:
		modifier.apply_decay(delta)
	
	# Remove expired modifiers
	var expired_modifiers = []
	for modifier in morale_modifiers:
		if modifier.is_expired():
			expired_modifiers.append(modifier)
	
	for modifier in expired_modifiers:
		remove_morale_modifier(modifier)
	
	# Recalculate morale
	calculate_current_morale()
	
	# Record history periodically
	record_morale_history()

func record_morale_history() -> void:
	var history_entry = {
		"timestamp": Time.get_ticks_msec(),
		"morale": current_morale,
		"level": get_morale_level_name(),
		"modifier_count": morale_modifiers.size()
	}
	
	morale_history.append(history_entry)
	
	# Trim history if it exceeds max entries
	if morale_history.size() > max_history_entries:
		morale_history.pop_front()

# ============================================================================
# Debug and Diagnostics
# ============================================================================

func print_morale_state() -> void:
	print("\n" + "=".repeat(60))
	print("MORALE SYSTEM STATE - %s" % Time.get_datetime_string_from_system())
	print("=".repeat(60))
	
	print("\n[CURRENT STATUS]")
	print("Current Morale: %.2f / 100.0" % current_morale)
	print("Morale Level: %s" % get_morale_level_name())
	print("Efficiency Multiplier: %.2f" % get_efficiency_multiplier())
	
	print("\n[ACTIVE MODIFIERS] (%d)" % morale_modifiers.size())
	if morale_modifiers.size() > 0:
		for modifier in morale_modifiers:
			if modifier.duration < 0:
				print("  - %s: %.2f (PERMANENT)" % [modifier.source, modifier.value])
			else:
				var remaining = modifier.duration - modifier.applied_time
				print("  - %s: %.2f (Expires in: %.2fs)" % [modifier.source, modifier.value, remaining])
	else:
		print("  No active modifiers")
	
	print("\n[RELATIONSHIPS] (%d)" % relationships.size())
	if relationships.size() > 0:
		for entity_id in relationships.keys():
			var points = relationships[entity_id]["points"]
			print("  - %s: %.2f points" % [entity_id, points])
	else:
		print("  No relationships tracked")
	
	print("\n[MORALE HISTORY] (Last 5 entries)")
	var start_idx = max(0, morale_history.size() - 5)
	for i in range(start_idx, morale_history.size()):
		var entry = morale_history[i]
		print("  [%d] Morale: %.2f (%s) - Modifiers: %d" % [i, entry["morale"], entry["level"], entry["modifier_count"]])
	
	print("=".repeat(60) + "\n")

func get_debug_info() -> Dictionary:
	return {
		"current_morale": current_morale,
		"morale_level": get_morale_level_name(),
		"efficiency_multiplier": get_efficiency_multiplier(),
		"active_modifiers": morale_modifiers.size(),
		"relationships": relationships.size(),
		"history_entries": morale_history.size(),
		"modifiers_detail": _get_modifiers_detail(),
		"relationships_detail": _get_relationships_detail()
	}

func _get_modifiers_detail() -> Array:
	var details = []
	for modifier in morale_modifiers:
		details.append({
			"source": modifier.source,
			"value": modifier.value,
			"duration": modifier.duration,
			"decay_rate": modifier.decay_rate,
			"applied_time": modifier.applied_time
		})
	return details

func _get_relationships_detail() -> Dictionary:
	var details = {}
	for entity_id in relationships.keys():
		details[entity_id] = {
			"points": relationships[entity_id]["points"],
			"history_count": relationships[entity_id]["history"].size()
		}
	return details
