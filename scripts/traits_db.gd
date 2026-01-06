extends Node
class_name TraitsDB

var traits: Array[Trait] = []

func _ready() -> void:
	add_to_group("traits_db")
	_seed_traits()

func get_random_traits(count: int) -> Array[Trait]:
	var picked: Array[Trait] = []
	if traits.is_empty():
		return picked
	for _i in count:
		picked.append(traits.pick_random())
	return picked

func _seed_traits() -> void:
	traits.clear()

	var night_owl := Trait.new()
	night_owl.name = "Night Owl"
	night_owl.description = "Works better at night."
	night_owl.hunger_multiplier = 0.9
	traits.append(night_owl)

	var sprinter := Trait.new()
	sprinter.name = "Sprinter"
	sprinter.description = "Moves faster than average."
	sprinter.speed_multiplier = 1.2
	traits.append(sprinter)

	var hearty := Trait.new()
	hearty.name = "Hearty"
	hearty.description = "Gets hungry more slowly."
	hearty.hunger_multiplier = 0.8
	traits.append(hearty)
