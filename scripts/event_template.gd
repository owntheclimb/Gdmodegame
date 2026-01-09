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
@export var reward_resource := ""
@export var reward_amount := 0.0
@export var reward_action := ""

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
		"scouted_area",
		"stone",
		8.0,
		"found_ruins"
	))
	templates.append(_make_template(
		"shattered_debris",
		"grassland",
		"Shattered Debris",
		"Fresh debris hints at a recent crash.",
		"debris",
		"Salvage Debris",
		1,
		"cleared_rubble",
		"wood",
		10.0,
		"salvaged_debris"
	))
	templates.append(_make_template(
		"odd_artifact",
		"grassland",
		"Odd Artifact",
		"A humming shard glows faintly in the soil.",
		"artifact",
		"Secure Artifact",
		3,
		"completed_task",
		"",
		0.0,
		"recovered_artifact"
	))
	templates.append(_make_template(
		"meadow_encampment",
		"grassland",
		"Nomad Encampment",
		"Smoke rises from a small camp on the plain.",
		"camp",
		"Parley with Nomads",
		2,
		"scouted_area",
		"food",
		12.0,
		"met_nomads"
	))
	templates.append(_make_template(
		"meadow_encampment",
		"grassland",
		"Nomad Encampment",
		"Smoke rises from a small camp on the plain.",
		"camp",
		"Parley with Nomads",
		2,
		"scouted_area"
	))
	templates.append(_make_template(
		"sea_ruins",
		"coastal",
		"Sea-Bleached Ruins",
		"Salt-worn ruins jut from the sand.",
		"ruins",
		"Survey Ruins",
		2,
		"scouted_area",
		"stone",
		6.0,
		"surveyed_ruins"
	))
	templates.append(_make_template(
		"drifted_artifact",
		"coastal",
		"Drifted Artifact",
		"A tide-polished relic rests among shells.",
		"artifact",
		"Recover Relic",
		3,
		"completed_task",
		"",
		0.0,
		"recovered_relic"
	))
	templates.append(_make_template(
		"tide_pool_grotto",
		"coastal",
		"Tide Pool Grotto",
		"Strange shells ring a shallow grotto.",
		"grotto",
		"Gather Rare Shells",
		2,
		"gathered_food",
		"food",
		15.0,
		"gathered_shells"
	))
	templates.append(_make_template(
		"forest_shrine",
		"forest",
		"Mossy Shrine",
		"A forgotten shrine hides beneath the canopy.",
		"shrine",
		"Cleanse Shrine",
		3,
		"scouted_area",
		"",
		0.0,
		"cleansed_shrine"
	))
	templates.append(_make_template(
		"lost_hunter",
		"forest",
		"Lost Hunter",
		"A lone hunter seeks the way back.",
		"camp",
		"Guide Hunter Home",
		2,
		"completed_task",
		"food",
		10.0,
		"aided_hunter"
	))
	templates.append(_make_template(
		"highland_outcrop",
		"highlands",
		"Windy Outcrop",
		"Stone spires overlook the valley.",
		"outcrop",
		"Survey Outcrop",
		2,
		"scouted_area",
		"stone",
		12.0,
		"surveyed_outcrop"
	))
	templates.append(_make_template(
		"mountain_cache",
		"highlands",
		"Mountain Cache",
		"A stash of tools lies wedged in the rocks.",
		"cache",
		"Recover Supplies",
		3,
		"gathered_stone",
		"wood",
		8.0,
		"recovered_cache"
	))
	templates.append(_make_template(
		"tide_pool_grotto",
		"coastal",
		"Tide Pool Grotto",
		"Strange shells ring a shallow grotto.",
		"grotto",
		"Gather Rare Shells",
		2,
		"gathered_food"
	))
	templates.append(_make_template(
		"forest_shrine",
		"forest",
		"Mossy Shrine",
		"A forgotten shrine hides beneath the canopy.",
		"shrine",
		"Cleanse Shrine",
		3,
		"scouted_area"
	))
	templates.append(_make_template(
		"lost_hunter",
		"forest",
		"Lost Hunter",
		"A lone hunter seeks the way back.",
		"camp",
		"Guide Hunter Home",
		2,
		"completed_task"
	))
	templates.append(_make_template(
		"highland_outcrop",
		"highlands",
		"Windy Outcrop",
		"Stone spires overlook the valley.",
		"outcrop",
		"Survey Outcrop",
		2,
		"scouted_area"
	))
	templates.append(_make_template(
		"mountain_cache",
		"highlands",
		"Mountain Cache",
		"A stash of tools lies wedged in the rocks.",
		"cache",
		"Recover Supplies",
		3,
		"gathered_stone"
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
		related_action: String,
		reward_resource: String = "",
		reward_amount: float = 0.0,
		reward_action: String = ""
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
	template.reward_resource = reward_resource
	template.reward_amount = reward_amount
	template.reward_action = reward_action
	return template
