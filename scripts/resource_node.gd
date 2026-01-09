extends Area2D
class_name ResourceNode

signal harvested(resource_type: String, amount: float)
signal depleted

@export var resource_type := ""
@export var resource_amount := 10.0
@export var max_resource_amount := 10.0
@export var respawn_time := 60.0  # Seconds to respawn
@export var harvest_amount := 5.0  # Amount harvested per action

var _is_depleted := false
var _respawn_timer := 0.0
var _shake_time := 0.0
var _shake_intensity := 0.0
var _original_position := Vector2.ZERO
var _harvest_particles: Array[Dictionary] = []

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("resource")
	if resource_type != "":
		add_to_group("resource_%s" % resource_type)
	_original_position = position
	max_resource_amount = resource_amount

func _process(delta: float) -> void:
	_update_shake(delta)
	_update_respawn(delta)
	_update_particles(delta)
	_update_visual_state()
	queue_redraw()

func harvest() -> float:
	if resource_amount <= 0.0 or _is_depleted:
		return 0.0
	
	var amount := minf(harvest_amount, resource_amount)
	resource_amount -= amount
	
	# Trigger shake animation
	_start_shake(3.0, 0.3)
	
	# Spawn harvest particles
	_spawn_harvest_particles(int(amount))
	
	harvested.emit(resource_type, amount)
	
	if resource_amount <= 0.0:
		_on_depleted()
	
	return amount

func _start_shake(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_time = duration

func _update_shake(delta: float) -> void:
	if _shake_time > 0:
		_shake_time -= delta
		var offset := Vector2(
			randf_range(-_shake_intensity, _shake_intensity),
			randf_range(-_shake_intensity, _shake_intensity)
		)
		position = _original_position + offset
		
		if _shake_time <= 0:
			position = _original_position

func _spawn_harvest_particles(count: int) -> void:
	var color := _get_resource_color()
	for i in range(count):
		_harvest_particles.append({
			"pos": Vector2(randf_range(-8, 8), randf_range(-8, 8)),
			"vel": Vector2(randf_range(-30, 30), randf_range(-60, -20)),
			"life": 1.0,
			"color": color
		})

func _update_particles(delta: float) -> void:
	var to_remove: Array[int] = []
	for i in range(_harvest_particles.size()):
		var p := _harvest_particles[i]
		p["vel"] = p["vel"] + Vector2(0, 100) * delta  # Gravity
		p["pos"] = p["pos"] + p["vel"] * delta
		p["life"] = p["life"] - delta
		if p["life"] <= 0:
			to_remove.append(i)
	
	# Remove dead particles (reverse order)
	for i in range(to_remove.size() - 1, -1, -1):
		_harvest_particles.remove_at(to_remove[i])

func _on_depleted() -> void:
	_is_depleted = true
	_respawn_timer = respawn_time
	depleted.emit()

func _update_respawn(delta: float) -> void:
	if not _is_depleted:
		return
	
	_respawn_timer -= delta
	if _respawn_timer <= 0:
		_respawn()

func _respawn() -> void:
	_is_depleted = false
	resource_amount = max_resource_amount
	_start_shake(2.0, 0.2)

func _update_visual_state() -> void:
	if not sprite:
		return
	
	# Fade when depleted
	if _is_depleted:
		var respawn_progress := 1.0 - (_respawn_timer / respawn_time)
		sprite.modulate.a = 0.3 + respawn_progress * 0.7
		sprite.scale = Vector2(0.7, 0.7) + Vector2(0.3, 0.3) * respawn_progress
	else:
		# Scale based on remaining resources
		var resource_ratio := resource_amount / max_resource_amount
		sprite.scale = Vector2(0.8, 0.8) + Vector2(0.2, 0.2) * resource_ratio
		sprite.modulate.a = 0.5 + resource_ratio * 0.5

func _get_resource_color() -> Color:
	match resource_type:
		"wood": return Color(0.5, 0.35, 0.2)
		"stone": return Color(0.5, 0.5, 0.55)
		"food": return Color(0.8, 0.3, 0.4)
		_: return Color.WHITE

func _draw() -> void:
	# Draw harvest particles
	for p in _harvest_particles:
		var alpha: float = float(p["life"])
		var color: Color = p["color"]
		color.a = alpha
		draw_circle(p["pos"], 2, color)
	
	# Draw resource amount indicator (small dots)
	if not _is_depleted and resource_amount < max_resource_amount:
		var ratio := resource_amount / max_resource_amount
		var indicator_y := -20.0
		draw_rect(Rect2(-8, indicator_y, 16, 3), Color(0.2, 0.2, 0.2, 0.6))
		draw_rect(Rect2(-8, indicator_y, 16 * ratio, 3), _get_resource_color())

func is_available() -> bool:
	return not _is_depleted and resource_amount > 0
