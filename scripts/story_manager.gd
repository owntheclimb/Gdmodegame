extends Node
class_name StoryManager

## 6-Chapter Island Mystery Storyline with Multiple Endings
## The Island Mystery: Why are you here? What happened to the previous civilization?

signal chapter_changed(chapter_index: int, chapter: Dictionary)
signal story_event(event_id: String, event_data: Dictionary)
signal ending_reached(ending_id: String)

# Story state
var current_chapter_index := 0
var discovered_lore: Array[String] = []
var story_choices: Dictionary = {}  # choice_id -> selected_option
var artifacts_found: int = 0
var secrets_discovered: int = 0

# Endings based on player choices
enum Ending { 
	ASCENSION,    # United the island, discovered the truth
	ESCAPE,       # Built ships and left the island
	DOMINION,     # Conquered all tribes, ruled by force
	HARMONY,      # Balanced with nature, became guardians
	DARKNESS      # Awakened the ancient evil, island destroyed
}

const STORY_CHAPTERS: Array[Dictionary] = [
	{
		"id": "chapter_1",
		"number": 1,
		"title": "Awakening",
		"description": "Survivors of a mysterious shipwreck wash ashore on an unknown island.",
		"intro_text": "You awaken on a strange beach, the wreckage of your ship scattered around you. Others have survived too. You must work together to survive... but something about this island feels wrong.",
		"objectives": [
			"Build your first shelter",
			"Gather food for survival",
			"Find the first ancient ruin"
		],
		"requirements": {
			"buildings_built": 1,
			"food_gathered": 30,
			"ruins_discovered": 1
		},
		"lore_unlocked": ["the_shipwreck", "strange_markings"]
	},
	{
		"id": "chapter_2", 
		"number": 2,
		"title": "The First Settlement",
		"description": "Establish your village and face the challenges of island life.",
		"intro_text": "Your small camp is growing into a real settlement. The strange ruins you found speak of an ancient civilization that once thrived here. But they are gone now... why?",
		"objectives": [
			"Reach population of 10",
			"Survive your first winter",
			"Research ancient technology"
		],
		"requirements": {
			"population": 10,
			"winters_survived": 1,
			"techs_researched": 1
		},
		"lore_unlocked": ["ancient_civilization", "the_warning"]
	},
	{
		"id": "chapter_3",
		"number": 3,
		"title": "Expanding Horizons",
		"description": "Explore the island and discover other survivors.",
		"intro_text": "You are not alone on this island. Scouts report other camps - some friendly, some wary. The ancient ruins grow more elaborate as you venture further inland. Something was protecting this place...",
		"objectives": [
			"Scout 50% of the island",
			"Contact other survivor groups",
			"Collect 3 ancient artifacts"
		],
		"requirements": {
			"map_explored": 50,
			"tribes_contacted": 2,
			"artifacts_found": 3
		},
		"lore_unlocked": ["the_guardians", "the_seal"],
		"story_choice": {
			"id": "tribe_relations",
			"prompt": "How do you approach the other tribes?",
			"options": ["diplomacy", "trade", "force"]
		}
	},
	{
		"id": "chapter_4",
		"number": 4,
		"title": "Ancient Secrets",
		"description": "The true nature of the island begins to reveal itself.",
		"intro_text": "The artifacts you've collected tell a terrifying story. The ancient civilization didn't just vanish - they sacrificed themselves to seal something beneath the island. And the seal is weakening...",
		"objectives": [
			"Discover the island's secret",
			"Research the ancient seal",
			"Prepare for the truth"
		],
		"requirements": {
			"secrets_discovered": 3,
			"seal_researched": 1,
			"advanced_techs": 3
		},
		"lore_unlocked": ["the_darkness", "the_sacrifice"],
		"story_choice": {
			"id": "the_seal",
			"prompt": "What do you do about the weakening seal?",
			"options": ["strengthen_it", "break_it", "study_it"]
		}
	},
	{
		"id": "chapter_5",
		"number": 5,
		"title": "The Awakening",
		"description": "A great threat emerges from beneath the island.",
		"intro_text": "It has awakened. The ancient darkness that the previous civilization died to contain now stirs beneath the earth. Your choices have led to this moment. Unite, flee, or fight - but you cannot ignore what comes.",
		"objectives": [
			"Unite all settlements",
			"Prepare defenses or escape",
			"Face the ancient threat"
		],
		"requirements": {
			"settlements_unified": 1,
			"final_preparation": 1,
			"threat_confronted": 1
		},
		"lore_unlocked": ["the_truth", "the_choice"],
		"story_choice": {
			"id": "final_choice",
			"prompt": "How do you face the awakened threat?",
			"options": ["fight", "contain", "flee", "embrace"]
		}
	},
	{
		"id": "chapter_6",
		"number": 6,
		"title": "Ascendance",
		"description": "The fate of the island is decided.",
		"intro_text": "This is the end of your journey... and the beginning of a new era. Your choices have shaped the destiny of everyone on this island. What legacy will you leave behind?",
		"objectives": [
			"Complete your chosen path",
			"Witness the island's fate"
		],
		"requirements": {
			"ending_achieved": 1
		},
		"lore_unlocked": ["epilogue"]
	}
]

# Lore entries for discovery
const LORE_ENTRIES: Dictionary = {
	"the_shipwreck": {
		"title": "The Shipwreck",
		"text": "Strange... none of us remember boarding the ship, or where we were going. The last thing anyone recalls is a blinding light, then waking on this beach."
	},
	"strange_markings": {
		"title": "Strange Markings",
		"text": "The ruins bear symbols unlike any known language. Yet somehow, they feel familiar, as if calling to something deep within us."
	},
	"ancient_civilization": {
		"title": "The Ancients",
		"text": "This island was once home to a thriving civilization. Their buildings show advanced knowledge... and great fear. Something drove them to desperate measures."
	},
	"the_warning": {
		"title": "The Warning",
		"text": "An inscription, translated at great effort: 'WE WHO CAME BEFORE FAILED. DO NOT BREAK THE SEAL. DO NOT AWAKEN WHAT SLEEPS. LEAVE THIS PLACE.'"
	},
	"the_guardians": {
		"title": "The Guardians",
		"text": "The other tribes speak of 'Guardians' - descendants of the ancients who stayed behind to maintain the seal. But we have seen no such people..."
	},
	"the_seal": {
		"title": "The Seal",
		"text": "At the island's center lies a massive stone circle, pulsing with faint energy. The ground around it is dead, as if life itself fears what lies beneath."
	},
	"the_darkness": {
		"title": "The Darkness Below",
		"text": "The artifacts speak of an entity - not quite alive, not quite dead. It came from beyond the stars, and the ancients could not destroy it. Only contain it."
	},
	"the_sacrifice": {
		"title": "The Sacrifice",
		"text": "The ancients gave their lives to power the seal. Every soul that dies on this island strengthens it. But we... we are not bound by their magic."
	},
	"the_truth": {
		"title": "The Truth",
		"text": "We were not shipwrecked by accident. We were CALLED here. The entity needed someone not bound by the seal to set it free. And we obliged."
	},
	"the_choice": {
		"title": "The Choice",
		"text": "The power to reseal the darkness lies within us. But it will cost everything. Are we willing to make the same sacrifice the ancients made?"
	},
	"epilogue": {
		"title": "Epilogue",
		"text": "And so the story of Isola continues, shaped by the choices of those who came to its shores..."
	}
}

func _ready() -> void:
	add_to_group("story_manager")
	var game_state := _get_game_state()
	if game_state:
		if game_state.has_signal("action_recorded"):
			game_state.action_recorded.connect(_on_action_recorded)
	
	# Show Chapter 1 intro on first load
	call_deferred("_show_chapter_intro", 0)

func _on_action_recorded(action: String) -> void:
	_check_chapter_progress()
	
	# Track specific story actions
	if action.begins_with("discovered_"):
		var lore_id := action.replace("discovered_", "")
		discover_lore(lore_id)
	elif action == "found_artifact":
		artifacts_found += 1
	elif action == "discovered_secret":
		secrets_discovered += 1

func _check_chapter_progress() -> void:
	var chapter := get_current_chapter()
	if chapter.is_empty():
		return
	
	if _requirements_met(chapter.get("requirements", {})):
		_advance_chapter()

func _requirements_met(requirements: Dictionary) -> bool:
	var game_state := _get_game_state()
	if not game_state:
		return false
	
	for key in requirements:
		var needed: int = requirements[key]
		var current := 0
		
		# Check different requirement sources
		match key:
			"population":
				current = get_tree().get_nodes_in_group("villager").size()
			"artifacts_found":
				current = artifacts_found
			"secrets_discovered":
				current = secrets_discovered
			"map_explored":
				var world := get_tree().get_first_node_in_group("world")
				if world and world.has_method("get_explored_percent"):
					current = int(world.get_explored_percent())
			_:
				current = game_state.get_action_count(key) if game_state.has_method("get_action_count") else 0
		
		if current < needed:
			return false
	
	return true

func _advance_chapter() -> void:
	if current_chapter_index >= STORY_CHAPTERS.size() - 1:
		_check_ending()
		return
	
	current_chapter_index += 1
	var chapter := get_current_chapter()
	
	# Unlock chapter lore
	var lore_unlocked: Array = chapter.get("lore_unlocked", [])
	for lore_id in lore_unlocked:
		discover_lore(lore_id)
	
	chapter_changed.emit(current_chapter_index, chapter)
	_show_chapter_intro(current_chapter_index)
	
	# Check for story choice
	if chapter.has("story_choice"):
		call_deferred("_present_story_choice", chapter.story_choice)

func _show_chapter_intro(chapter_index: int) -> void:
	if chapter_index < 0 or chapter_index >= STORY_CHAPTERS.size():
		return
	
	var chapter: Dictionary = STORY_CHAPTERS[chapter_index]
	var title: String = "Chapter %d: %s" % [chapter.number, chapter.title]
	var text: String = chapter.get("intro_text", "")
	
	story_event.emit("chapter_intro", {"chapter": chapter_index, "title": title, "text": text})
	
	# Show notification
	var action_menu := get_tree().get_first_node_in_group("action_menu")
	if action_menu and action_menu.has_method("_show_notification"):
		action_menu._show_notification(title)

func _present_story_choice(choice_data: Dictionary) -> void:
	story_event.emit("story_choice", choice_data)
	# The UI should handle presenting the choice and calling make_story_choice()

func make_story_choice(choice_id: String, selected_option: String) -> void:
	story_choices[choice_id] = selected_option
	story_event.emit("choice_made", {"choice_id": choice_id, "option": selected_option})

func _check_ending() -> void:
	var ending := _determine_ending()
	ending_reached.emit(ending)
	
	var game_state := _get_game_state()
	if game_state:
		game_state.record_action("ending_achieved")
		game_state.record_action("ending_" + ending)

func _determine_ending() -> String:
	# Determine ending based on story choices
	var final_choice: String = story_choices.get("final_choice", "fight")
	var seal_choice: String = story_choices.get("the_seal", "strengthen_it")
	var tribe_choice: String = story_choices.get("tribe_relations", "diplomacy")
	
	if final_choice == "embrace":
		return "DARKNESS"
	elif final_choice == "flee":
		return "ESCAPE"
	elif seal_choice == "break_it" and tribe_choice == "force":
		return "DOMINION"
	elif seal_choice == "strengthen_it" and tribe_choice == "diplomacy":
		return "HARMONY"
	else:
		return "ASCENSION"

func discover_lore(lore_id: String) -> void:
	if lore_id in discovered_lore:
		return
	
	discovered_lore.append(lore_id)
	
	if LORE_ENTRIES.has(lore_id):
		var entry: Dictionary = LORE_ENTRIES[lore_id]
		story_event.emit("lore_discovered", {"id": lore_id, "entry": entry})
		
		var action_menu := get_tree().get_first_node_in_group("action_menu")
		if action_menu and action_menu.has_method("_show_notification"):
			action_menu._show_notification("Lore Discovered: " + entry.get("title", "Unknown"))

# Public API
func get_current_chapter() -> Dictionary:
	if current_chapter_index < 0 or current_chapter_index >= STORY_CHAPTERS.size():
		return {}
	return STORY_CHAPTERS[current_chapter_index]

func get_current_chapter_id() -> String:
	var chapter := get_current_chapter()
	return str(chapter.get("id", ""))

func get_current_chapter_text() -> String:
	var chapter := get_current_chapter()
	if chapter.is_empty():
		return "Story: --"
	return "Chapter %d: %s" % [chapter.get("number", 0), chapter.get("title", "Unknown")]

func get_chapter_progress() -> float:
	return float(current_chapter_index) / float(STORY_CHAPTERS.size())

func get_discovered_lore() -> Array[String]:
	return discovered_lore

func get_lore_entry(lore_id: String) -> Dictionary:
	return LORE_ENTRIES.get(lore_id, {})

func _get_game_state() -> GameState:
	return get_tree().get_first_node_in_group("game_state") as GameState
