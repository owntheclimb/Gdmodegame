extends Node2D

@export var ring_color := Color(1.0, 0.9, 0.3, 0.8)
@export var ring_radius := 14.0
@export var ring_width := 2.0
@export var pulse_speed := 3.0

var _pulse_time := 0.0

func _process(delta: float) -> void:
	if visible:
		_pulse_time += delta * pulse_speed
		queue_redraw()

func _draw() -> void:
	if not visible:
		return
	
	# Pulsing effect
	var pulse := 1.0 + sin(_pulse_time) * 0.1
	var current_radius := ring_radius * pulse
	
	# Draw outer glow
	var glow_color := Color(ring_color.r, ring_color.g, ring_color.b, 0.3)
	draw_arc(Vector2.ZERO, current_radius + 2, 0, TAU, 32, glow_color, ring_width + 2)
	
	# Draw main ring
	draw_arc(Vector2.ZERO, current_radius, 0, TAU, 32, ring_color, ring_width)
	
	# Draw selection arrow above
	var arrow_y := -current_radius - 8
	var arrow_bob := sin(_pulse_time * 2) * 2
	var arrow_points: PackedVector2Array = [
		Vector2(0, arrow_y + arrow_bob),
		Vector2(-4, arrow_y - 6 + arrow_bob),
		Vector2(4, arrow_y - 6 + arrow_bob)
	]
	draw_colored_polygon(arrow_points, ring_color)
