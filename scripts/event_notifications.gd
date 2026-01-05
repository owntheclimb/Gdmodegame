extends CanvasLayer
class_name EventNotifications

@export var max_messages := 4

@onready var list_container: VBoxContainer = $Panel/MarginContainer/MessageList

var _messages: Array[String] = []

func _ready() -> void:
	var event_manager := _get_event_manager()
	if event_manager:
		event_manager.event_created.connect(_on_event_created)

func _on_event_created(event_info: Dictionary) -> void:
	if not event_info.has("template"):
		return
	var template: EventTemplate = event_info["template"]
	var message := "%s - %s" % [template.title, template.description]
	_messages.append(message)
	if _messages.size() > max_messages:
		_messages.remove_at(0)
	_refresh_messages()

func _refresh_messages() -> void:
	for child in list_container.get_children():
		child.queue_free()
	for message in _messages:
		var label := Label.new()
		label.text = message
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		list_container.add_child(label)

func _get_event_manager() -> EventManager:
	return get_tree().get_first_node_in_group("event_manager")
