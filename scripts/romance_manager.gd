extends Node
class_name RomanceManager

signal child_born(parent_a: Villager, parent_b: Villager, child: Villager)
signal villager_aged(villager: Villager, new_age: int)

var pending_pairs: Array = []
var families: Array[Dictionary] = []  # Tracks family relationships
var pregnancies: Array[Dictionary] = []  # {mother, father, time_remaining}

const PREGNANCY_DURATION := 30.0  # Game seconds
const CHILD_GROWTH_RATE := 1.0  # Age increase per game day
const MIN_ROMANCE_AGE := 18

@onready var _age_timer := Timer.new()

func _ready() -> void:
	add_to_group("romance_manager")
	
	# Setup age timer (ticks every game day)
	_age_timer.wait_time = 60.0  # 1 game day
	_age_timer.autostart = true
	_age_timer.timeout.connect(_on_day_passed)
	add_child(_age_timer)

func _process(delta: float) -> void:
	_update_pregnancies(delta)

func register_pair(a: Villager, b: Villager) -> void:
	if not a or not b:
		return
	if a == b:
		return
	if a.age < MIN_ROMANCE_AGE or b.age < MIN_ROMANCE_AGE:
		return
	pending_pairs.append({"a": a, "b": b})

func claim_partner(villager: Villager) -> Villager:
	for pair in pending_pairs:
		if pair["a"] == villager:
			return pair["b"]
		if pair["b"] == villager:
			return pair["a"]
	return null

func clear_pair(villager: Villager) -> void:
	pending_pairs = pending_pairs.filter(func(pair: Dictionary) -> bool:
		return pair["a"] != villager and pair["b"] != villager
	)

func start_pregnancy(mother: Villager, father: Villager) -> void:
	if not mother or not father:
		return
	# Check if mother is already pregnant
	for p in pregnancies:
		if p["mother"] == mother:
			return
	
	pregnancies.append({
		"mother": mother,
		"father": father,
		"time_remaining": PREGNANCY_DURATION
	})
	
	# Visual indicator - mother walks slower
	if mother.has_method("set_pregnant"):
		mother.set_pregnant(true)

func _update_pregnancies(delta: float) -> void:
	var completed: Array[int] = []
	
	for i in range(pregnancies.size()):
		var p := pregnancies[i]
		p["time_remaining"] -= delta
		
		if p["time_remaining"] <= 0:
			completed.append(i)
			_deliver_baby(p["mother"], p["father"])
	
	# Remove completed pregnancies (reverse order)
	for i in range(completed.size() - 1, -1, -1):
		pregnancies.remove_at(completed[i])

func _deliver_baby(mother: Villager, father: Villager) -> void:
	if not is_instance_valid(mother):
		return
	
	var child := _create_child(mother, father)
	if child:
		# Add to scene
		var parent_node := mother.get_parent()
		if parent_node:
			parent_node.add_child(child)
		
		# Track family
		_register_family(mother, father, child)
		
		# Emit signal
		child_born.emit(mother, father, child)
		
		# Clear pregnancy visual
		if mother.has_method("set_pregnant"):
			mother.set_pregnant(false)

func _create_child(mother: Villager, father: Villager) -> Villager:
	var child_scene := preload("res://scenes/Villager.tscn")
	var child: Villager = child_scene.instantiate()
	
	# Position near mother
	child.global_position = mother.global_position + Vector2(randf_range(-10, 10), randf_range(-10, 10))
	
	# Set child properties
	child.age = 0
	child.gender = "Male" if randf() < 0.5 else "Female"
	child.health = 100.0
	child.hunger = 100.0
	
	# Inherit traits from parents
	if mother.has_method("_merge_traits"):
		child.traits = mother._merge_traits(mother.traits, father.traits if is_instance_valid(father) else [])
	
	return child

func _register_family(parent_a: Villager, parent_b: Villager, child: Villager) -> void:
	families.append({
		"parent_a": parent_a,
		"parent_b": parent_b,
		"child": child,
		"birth_day": _get_current_day()
	})

func _get_current_day() -> int:
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state:
		return game_state.days_survived
	return 0

func _on_day_passed() -> void:
	# Age all villagers
	var villagers := get_tree().get_nodes_in_group("villager")
	for v in villagers:
		if v is Villager:
			v.age += 1
			villager_aged.emit(v, v.age)
			
			# Check for death from old age
			if v.age >= 80 and randf() < 0.1:  # 10% chance per day after 80
				_villager_dies_of_age(v)

func _villager_dies_of_age(villager: Villager) -> void:
	# Notify systems
	var game_state := get_tree().get_first_node_in_group("game_state")
	if game_state and game_state.has_method("record_action"):
		game_state.record_action("villager_died")
	
	# Remove villager
	villager.queue_free()

func get_children_of(villager: Villager) -> Array[Villager]:
	var children: Array[Villager] = []
	for f in families:
		if f["parent_a"] == villager or f["parent_b"] == villager:
			if is_instance_valid(f["child"]):
				children.append(f["child"])
	return children

func get_parents_of(villager: Villager) -> Array[Villager]:
	var parents: Array[Villager] = []
	for f in families:
		if f["child"] == villager:
			if is_instance_valid(f["parent_a"]):
				parents.append(f["parent_a"])
			if is_instance_valid(f["parent_b"]):
				parents.append(f["parent_b"])
	return parents

func is_pregnant(villager: Villager) -> bool:
	for p in pregnancies:
		if p["mother"] == villager:
			return true
	return false

func get_pregnancy_progress(villager: Villager) -> float:
	for p in pregnancies:
		if p["mother"] == villager:
			return 1.0 - (p["time_remaining"] / PREGNANCY_DURATION)
	return 0.0
