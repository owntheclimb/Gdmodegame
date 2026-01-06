extends Node
class_name DayNightCycle

signal day_started
signal night_started

@export var day_length_seconds := 120.0

var time_of_day := 0.0
var is_night := false

func _ready() -> void:
	add_to_group("day_night")

func _process(delta: float) -> void:
	time_of_day = fmod(time_of_day + delta, day_length_seconds)
	var now_night := time_of_day >= day_length_seconds * 0.5
	if now_night != is_night:
		is_night = now_night
		if is_night:
			night_started.emit()
		else:
			day_started.emit()

func get_time_ratio() -> float:
	return time_of_day / day_length_seconds
