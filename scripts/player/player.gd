extends CharacterBody2D
class_name Player

## Movement settings
@export var base_speed: float = 300.0
@export var dash_speed: float = 800.0
@export var dash_cooldown: float = 1.0
@export var dash_duration: float = 0.2

## Animation names
const ANIM_IDLE = "idle"
const ANIM_WALK = "walk"
const ANIM_DASH = "dash"
const DIRECTIONS = ["down", "up", "left", "right"]

## Signals
signal health_changed(current: int, max: int)
signal experience_gained(amount: int)
signal level_up(new_level: int)
signal died

## Components
@onready var health: HealthComponent = %HealthComponent
@onready var experience: ExperienceComponent = %ExperienceComponent
@onready var weapon_manager: WeaponManager = %WeaponManager
@onready var animated_sprite: AnimatedSprite2D = %Sprite
@onready var dash_timer: Timer = %DashTimer
@onready var invincibility_timer: Timer = %InvincibilityTimer

## State
var current_speed: float
var is_dashing: bool = false
var dash_direction: Vector2 = Vector2.ZERO
var last_move_direction: Vector2 = Vector2.DOWN
var mouse_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_speed = base_speed
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	experience.level_up.connect(_on_level_up)
	dash_timer.timeout.connect(_on_dash_finished)
	invincibility_timer.timeout.connect(_on_invincibility_ended)

	# Set up collision layers
	collision_layer = 2  # Player layer
	collision_mask = 4 | 8  # Enemy + EnemyProjectile layers

	# Start with idle animation
	_set_animation("idle_down")

func _physics_process(delta: float) -> void:
	if is_dashing:
		_handle_dash(delta)
	else:
		_handle_movement(delta)

	_handle_rotation()
	move_and_slide()

func _process(delta: float) -> void:
	# Update mouse position for aiming
	mouse_position = get_global_mouse_position()
	weapon_manager.update_aim(global_position, mouse_position)

	# Handle shooting
	if Input.is_action_pressed("shoot"):
		weapon_manager.try_shoot(global_position, mouse_position)

func _handle_movement(delta: float) -> void:
	var input_dir = Vector2.ZERO

	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_up", "move_down")

	if input_dir.length() > 0:
		input_dir = input_dir.normalized()
		last_move_direction = input_dir
		velocity = input_dir * current_speed
		_set_animation("walk")
	else:
		velocity = Vector2.ZERO
		_set_animation("idle")

	# Handle dash input
	if Input.is_action_just_pressed("dash") and not dash_timer.is_stopped() == false:
		_start_dash(input_dir)

func _handle_dash(delta: float) -> void:
	velocity = dash_direction * dash_speed
	# Dash ignores collisions temporarily
	collision_layer = 0
	collision_mask = 0

func _handle_rotation() -> void:
	# Face mouse direction for aiming
	var direction = (mouse_position - global_position).normalized()
	var angle = direction.angle()

	# Update sprite based on movement direction for 4-directional sprites
	if not is_dashing:
		var anim_dir = _get_animation_direction(last_move_direction)
		animated_sprite.animation = "%s_%s" % [_get_current_anim_base(), anim_dir]

func _start_dash(direction: Vector2) -> void:
	if direction.length() == 0:
		direction = last_move_direction

	is_dashing = true
	dash_direction = direction.normalized()
	dash_timer.start(dash_duration)

	# Visual feedback
	_set_animation("dash")
	animated_sprite.modulate = Color(1, 1, 1, 0.5)

	# Invincibility during dash
	invincibility_timer.start(dash_duration)

func _on_dash_finished() -> void:
	is_dashing = false
	dash_timer.start(dash_cooldown)
	collision_layer = 2
	collision_mask = 4 | 8
	animated_sprite.modulate = Color(1, 1, 1, 1)

func _on_invincibility_ended() -> void:
	# Re-enable collision after invincibility
	collision_layer = 2
	collision_mask = 4 | 8

func _get_animation_direction(direction: Vector2) -> String:
	if abs(direction.x) > abs(direction.y):
		return "right" if direction.x > 0 else "left"
	else:
		return "down" if direction.y > 0 else "up"

func _get_current_anim_base() -> String:
	var anim = animated_sprite.animation
	if anim.begins_with("walk"):
		return "walk"
	elif anim.begins_with("idle"):
		return "idle"
	elif anim.begins_with("dash"):
		return "dash"
	return "idle"

func _set_animation(base: String) -> void:
	var dir = _get_animation_direction(last_move_direction)
	var new_anim = "%s_%s" % [base, dir]
	if animated_sprite.animation != new_anim and animated_sprite.sprite_frames.has_animation(new_anim):
		animated_sprite.animation = new_anim

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if invincibility_timer.time_left > 0:
		return

	health.take_damage(amount)

	if knockback.length() > 0:
		velocity = knockback
		invincibility_timer.start(0.5)
		animated_sprite.modulate = Color(1, 0.5, 0.5, 1)

func heal(amount: int) -> void:
	health.heal(amount)

func add_experience(amount: int) -> void:
	experience.add_experience(amount)

func get_stat(stat_name: StringName) -> Variant:
	return weapon_manager.get_stat(stat_name)

func _on_health_changed(current: int, max: int) -> void:
	health_changed.emit(current, max)

func _on_died() -> void:
	died.emit()
	queue_free()

func _on_level_up(new_level: int) -> void:
	level_up.emit(new_level)
	# Could show level up UI here