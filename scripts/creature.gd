extends CharacterBody2D
class_name Creature

enum Temperament { TIMID, NEUTRAL, AGGRESSIVE }

@export var species := "Deer"
@export var temperament := Temperament.NEUTRAL
@export var max_speed := 45.0
@export var health := 30.0
@export var attack_power := 6.0
@export var resource_drop := "food"
@export var resource_amount := 8.0

var _wander_target := Vector2.ZERO
var _wander_timer := 0.0
var _attack_cooldown := 0.0

@onready var sprite: Sprite2D = $Sprite

func _ready() -> void:
	add_to_group("creature")
	_setup_placeholder_sprite()
	_pick_new_wander_target()

func _physics_process(delta: float) -> void:
	_wander_timer += delta
	_attack_cooldown = maxf(_attack_cooldown - delta, 0.0)
	var villager := _get_nearest_villager()
	if villager and _is_threatened_by(villager):
		_handle_threat(delta, villager)
		return
	_handle_wander(delta)

func _handle_wander(_delta: float) -> void:
	if _wander_timer >= 2.5 or global_position.distance_to(_wander_target) < 6.0:
		_pick_new_wander_target()
		_wander_timer = 0.0
	velocity = ( _wander_target - global_position ).normalized() * max_speed
	move_and_slide()

func _handle_threat(_delta: float, villager: Node2D) -> void:
	match temperament:
		Temperament.TIMID:
			var flee_dir := (global_position - villager.global_position).normalized()
			velocity = flee_dir * max_speed * 1.2
		Temperament.AGGRESSIVE:
			var attack_dir := (villager.global_position - global_position).normalized()
			velocity = attack_dir * max_speed * 1.1
			if global_position.distance_to(villager.global_position) < 18.0:
				_attack_villager(villager)
		_:
			velocity = Vector2.ZERO
	move_and_slide()

func _attack_villager(villager: Node2D) -> void:
	if _attack_cooldown > 0.0:
		return
	_attack_cooldown = 1.2
	if "health" in villager:
		villager.health = maxf(villager.health - attack_power, 0.0)

func take_damage(amount: float) -> bool:
	health = maxf(health - amount, 0.0)
	if health <= 0.0:
		queue_free()
		return true
	return false

func _is_threatened_by(villager: Node2D) -> bool:
	if not villager:
		return false
	return global_position.distance_to(villager.global_position) < 90.0

func _get_nearest_villager() -> Node2D:
	var villagers := get_tree().get_nodes_in_group("villager")
	var nearest: Node2D = null
	var nearest_distance := INF
	for villager in villagers:
		if not (villager is Node2D):
			continue
		var dist := global_position.distance_to(villager.global_position)
		if dist < nearest_distance:
			nearest_distance = dist
			nearest = villager
	return nearest

func _pick_new_wander_target() -> void:
	var offset := Vector2(randf_range(-120.0, 120.0), randf_range(-120.0, 120.0))
	_wander_target = global_position + offset

func _setup_placeholder_sprite() -> void:
	if sprite.texture:
		return
	var image := Image.create(14, 14, false, Image.FORMAT_RGBA8)
	image.fill(_species_color())
	var texture := ImageTexture.create_from_image(image)
	sprite.texture = texture

func _species_color() -> Color:
	match species:
		"Deer":
			return Color(0.65, 0.5, 0.35)
		"Boar":
			return Color(0.35, 0.25, 0.2)
		"Wolf":
			return Color(0.4, 0.4, 0.45)
		"Bear":
			return Color(0.25, 0.2, 0.15)
		_:
			return Color(0.6, 0.6, 0.6)
