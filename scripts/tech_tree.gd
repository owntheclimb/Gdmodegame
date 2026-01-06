extends Resource
class_name TechTree

@export var unlocked := []

func unlock(tech_name: String) -> void:
	if tech_name in unlocked:
		return
	unlocked.append(tech_name)
