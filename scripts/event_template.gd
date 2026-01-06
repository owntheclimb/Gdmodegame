extends Resource
class_name EventTemplate

@export var template_id := ""
@export var biome := ""
@export var title := ""
@export var description := ""
@export var location_type := ""
@export var task_type := ""
@export var priority := 0
@export var related_action := ""

static func default_templates() -> Array[EventTemplate]:
	var templates: Array[EventTemplate] = []
	templates.append(_make_template(
		"ruins_overgrown",
		"grassland",
		"Overgrown Ruins",
		"Vines cover a collapsed stone hall.",
		"ruins",
		"Investigate Ruins",
		2,
		"scouted_area"
	))
	templates.append(_make_template(
		"shattered_debris",
		"grassland",
		"Shattered Debris",
		"Fresh debris hints at a recent crash.",
		"debris",
		"Salvage Debris",
		1,
		"cleared_rubble"
	))
	templates.append(_make_template(
		"odd_artifact",
		"grassland",
		"Odd Artifact",
		"A humming shard glows faintly in the soil.",
		"artifact",
		"Secure Artifact",
		3,
		"completed_task"
	))
	templates.append(_make_template(
		"sea_ruins",
		"coastal",
		"Sea-Bleached Ruins",
		"Salt-worn ruins jut from the sand.",
		"ruins",
		"Survey Ruins",
		2,
		"scouted_area"
	))
	templates.append(_make_template(
		"drifted_artifact",
		"coastal",
		"Drifted Artifact",
		"A tide-polished relic rests among shells.",
		"artifact",
		"Recover Relic",
		3,
		"completed_task"
	))
	return templates

static func _make_template(
		template_id: String,
		biome: String,
		title: String,
		description: String,
		location_type: String,
		task_type: String,
		priority: int,
		related_action: String
	) -> EventTemplate:
	var template := EventTemplate.new()
	template.template_id = template_id
	template.biome = biome
	template.title = title
	template.description = description
	template.location_type = location_type
	template.task_type = task_type
	template.priority = priority
	template.related_action = related_action
	return template
