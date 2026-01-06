extends Node
class_name RomanceManager

var pending_pairs: Array = []

func _ready() -> void:
	add_to_group("romance_manager")

func register_pair(a: Villager, b: Villager) -> void:
	if not a or not b:
		return
	if a == b:
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
