extends Node
class_name VisualEffects

## Visual Effects System
## Particles, animations, screen effects, and feedback juice

signal effect_spawned(effect_type: String, position: Vector2)

# Effect presets
const PARTICLE_PRESETS: Dictionary = {
	"wood_chips": {
		"amount": 8,
		"lifetime": 0.5,
		"color": Color(0.6, 0.4, 0.2),
		"gravity": Vector2(0, 100),
		"spread": 45.0,
	},
	"stone_dust": {
		"amount": 12,
		"lifetime": 0.4,
		"color": Color(0.6, 0.6, 0.65),
		"gravity": Vector2(0, 80),
		"spread": 60.0,
	},
	"harvest_sparkle": {
		"amount": 5,
		"lifetime": 0.8,
		"color": Color(0.9, 0.9, 0.3),
		"gravity": Vector2(0, -30),
		"spread": 90.0,
	},
	"build_complete": {
		"amount": 20,
		"lifetime": 1.0,
		"color": Color(0.8, 0.6, 0.2),
		"gravity": Vector2(0, 50),
		"spread": 180.0,
	},
	"level_up": {
		"amount": 15,
		"lifetime": 1.2,
		"color": Color(1.0, 0.9, 0.4),
		"gravity": Vector2(0, -50),
		"spread": 360.0,
	},
	"hearts": {
		"amount": 5,
		"lifetime": 1.5,
		"color": Color(1.0, 0.4, 0.5),
		"gravity": Vector2(0, -20),
		"spread": 45.0,
	},
	"damage": {
		"amount": 6,
		"lifetime": 0.3,
		"color": Color(1.0, 0.2, 0.2),
		"gravity": Vector2(0, 100),
		"spread": 120.0,
	},
	"heal": {
		"amount": 8,
		"lifetime": 0.8,
		"color": Color(0.3, 1.0, 0.5),
		"gravity": Vector2(0, -40),
		"spread": 90.0,
	},
}

# Screen shake parameters
var _shake_intensity := 0.0
var _shake_duration := 0.0
var _original_camera_offset := Vector2.ZERO

# Flash overlay
var _flash_overlay: ColorRect

func _ready() -> void:
	add_to_group("visual_effects")
	_setup_flash_overlay()

func _setup_flash_overlay() -> void:
	_flash_overlay = ColorRect.new()
	_flash_overlay.color = Color.WHITE
	_flash_overlay.modulate.a = 0.0
	_flash_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_flash_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_flash_overlay.z_index = 1000
	
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	canvas.add_child(_flash_overlay)
	add_child(canvas)

func _process(delta: float) -> void:
	_update_screen_shake(delta)

# Spawn particle effect at position
func spawn_particles(effect_type: String, world_pos: Vector2) -> void:
	var preset: Dictionary = PARTICLE_PRESETS.get(effect_type, {})
	if preset.is_empty():
		return
	
	var particles := CPUParticles2D.new()
	particles.emitting = true
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.amount = preset.get("amount", 10)
	particles.lifetime = preset.get("lifetime", 0.5)
	particles.gravity = preset.get("gravity", Vector2(0, 100))
	particles.spread = preset.get("spread", 45.0)
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 100.0
	particles.color = preset.get("color", Color.WHITE)
	particles.global_position = world_pos
	
	# Auto-remove after lifetime
	get_tree().root.add_child(particles)
	get_tree().create_timer(particles.lifetime + 0.5).timeout.connect(particles.queue_free)
	
	effect_spawned.emit(effect_type, world_pos)

# Spawn floating text (damage numbers, XP, etc)
func spawn_floating_text(text: String, world_pos: Vector2, color: Color = Color.WHITE, duration: float = 1.0) -> void:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 14)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.global_position = world_pos - Vector2(30, 0)
	label.z_index = 500
	
	get_tree().root.add_child(label)
	
	# Animate up and fade
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "global_position:y", world_pos.y - 40, duration)
	tween.tween_property(label, "modulate:a", 0.0, duration).set_delay(duration * 0.5)
	tween.chain().tween_callback(label.queue_free)

# Screen shake
func shake_screen(intensity: float, duration: float) -> void:
	_shake_intensity = intensity
	_shake_duration = duration
	
	var camera := get_viewport().get_camera_2d()
	if camera:
		_original_camera_offset = camera.offset

func _update_screen_shake(delta: float) -> void:
	if _shake_duration <= 0:
		return
	
	_shake_duration -= delta
	
	var camera := get_viewport().get_camera_2d()
	if camera:
		if _shake_duration > 0:
			camera.offset = _original_camera_offset + Vector2(
				randf_range(-_shake_intensity, _shake_intensity),
				randf_range(-_shake_intensity, _shake_intensity)
			)
		else:
			camera.offset = _original_camera_offset

# Screen flash
func flash_screen(color: Color = Color.WHITE, duration: float = 0.2) -> void:
	_flash_overlay.color = color
	_flash_overlay.modulate.a = 0.5
	
	var tween := create_tween()
	tween.tween_property(_flash_overlay, "modulate:a", 0.0, duration)

# Achievement popup
func show_achievement(title: String, description: String) -> void:
	var popup := PanelContainer.new()
	popup.set_anchors_preset(Control.PRESET_CENTER_TOP)
	popup.offset_top = -100
	popup.offset_bottom = -60
	popup.offset_left = -150
	popup.offset_right = 150
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.15, 0.15, 0.2, 0.95)
	style.border_color = Color(1, 0.8, 0.2)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	popup.add_theme_stylebox_override("panel", style)
	
	var vbox := VBoxContainer.new()
	popup.add_child(vbox)
	
	var title_label := Label.new()
	title_label.text = "🏆 " + title
	title_label.add_theme_color_override("font_color", Color(1, 0.9, 0.4))
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title_label)
	
	var desc_label := Label.new()
	desc_label.text = description
	desc_label.add_theme_font_size_override("font_size", 12)
	desc_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(desc_label)
	
	var canvas := CanvasLayer.new()
	canvas.layer = 50
	canvas.add_child(popup)
	add_child(canvas)
	
	# Animate in and out
	popup.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(popup, "modulate:a", 1.0, 0.3)
	tween.tween_property(popup, "offset_top", 20, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(3.0)
	tween.tween_property(popup, "modulate:a", 0.0, 0.5)
	tween.tween_callback(canvas.queue_free)

# Convenience methods
func wood_chips(pos: Vector2) -> void:
	spawn_particles("wood_chips", pos)

func stone_dust(pos: Vector2) -> void:
	spawn_particles("stone_dust", pos)

func harvest_sparkle(pos: Vector2) -> void:
	spawn_particles("harvest_sparkle", pos)

func build_complete(pos: Vector2) -> void:
	spawn_particles("build_complete", pos)
	shake_screen(3.0, 0.2)

func level_up(pos: Vector2) -> void:
	spawn_particles("level_up", pos)
	flash_screen(Color(1, 0.9, 0.4), 0.15)

func show_damage(pos: Vector2, amount: int) -> void:
	spawn_particles("damage", pos)
	spawn_floating_text("-%d" % amount, pos, Color(1, 0.3, 0.3))

func show_heal(pos: Vector2, amount: int) -> void:
	spawn_particles("heal", pos)
	spawn_floating_text("+%d" % amount, pos, Color(0.3, 1, 0.5))

func show_xp(pos: Vector2, amount: int) -> void:
	spawn_floating_text("+%d XP" % amount, pos, Color(0.8, 0.6, 1))

func show_resource(pos: Vector2, resource: String, amount: int) -> void:
	spawn_floating_text("+%d %s" % [amount, resource.capitalize()], pos, Color(0.9, 0.8, 0.4))
