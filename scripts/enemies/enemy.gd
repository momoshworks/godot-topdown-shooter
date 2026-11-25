extends CharacterBody2D
class_name Enemy

## Configuration
@export var base_health: int = 50
@export var base_damage: int = 10
@export var base_speed: float = 150.0
@export var xp_reward: int = 10
@export var detection_range: float = 400.0
@export var attack_range: float = 50.0
@export var attack_cooldown: float = 1.5
@export var knockback_resistance: float = 0.5

## Behavior
@export var behavior_type: String = "melee"  # melee, ranged, charger
@export var projectile_scene: PackedScene

## Components
@onready var health: HealthComponent = %HealthComponent
@onready var animated_sprite: AnimatedSprite2D = %Sprite
@onready var detection_area: Area2D = %DetectionArea
@onready var attack_area: Area2D = %AttackArea

## State
var target: Node = null
var current_speed: float
var attack_timer: float = 0.0
var is_attacking: bool = false
var last_damage_time: float = 0.0
var hit_flash_timer: float = 0.0

## Signals
signal died(enemy: Enemy, xp_reward: int)
signal damaged(amount: int)

func _ready() -> void:
	current_speed = base_speed
	health.max_health = base_health
	health.current_health = base_health
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	health.damaged.connect(_on_damaged)

	detection_area.monitoring = true
	detection_area.monitorable = true
	detection_area.area_entered.connect(_on_player_detected)
	detection_area.area_exited.connect(_on_player_lost)

	attack_area.monitoring = true
	attack_area.monitorable = true
	attack_area.area_entered.connect(_on_attack_area_entered)

	collision_layer = 8  # Enemy layer
	collision_mask = 2 | 16  # Player + Wall layers

	# Randomize initial attack timer
	attack_timer = randf() * attack_cooldown

func _physics_process(delta: float) -> void:
	if not target or health.is_dead():
		velocity = Vector2.ZERO
		_set_animation("idle")
		move_and_slide()
		return

	attack_timer -= delta
	hit_flash_timer = max(0, hit_flash_timer - delta)

	if hit_flash_timer <= 0:
		animated_sprite.modulate = Color.WHITE

	var direction_to_target = (target.global_position - global_position).normalized()
	var distance_to_target = global_position.distance_to(target.global_position)

	# Behavior based on type
	match behavior_type:
		"melee":
			_handle_melee_behavior(direction_to_target, distance_to_target, delta)
		"ranged":
			_handle_ranged_behavior(direction_to_target, distance_to_target, delta)
		"charger":
			_handle_charger_behavior(direction_to_target, distance_to_target, delta)

	move_and_slide()
	_update_animation(direction_to_target)

func _handle_melee_behavior(direction: Vector2, distance: float, delta: float) -> void:
	if distance <= attack_range and attack_timer <= 0:
		_attack()
	else:
		velocity = direction * current_speed

func _handle_ranged_behavior(direction: Vector2, distance: float, delta: float) -> void:
	var optimal_range = attack_range * 1.5

	if distance > optimal_range:
		# Move closer
		velocity = direction * current_speed
	elif distance < attack_range * 0.5:
		# Move away
		velocity = -direction * current_speed
	else:
		# Stay and shoot
		velocity = Vector2.ZERO
		if attack_timer <= 0:
			_attack()

func _handle_charger_behavior(direction: Vector2, distance: float, delta: float) -> void:
	if distance <= attack_range * 2 and attack_timer <= 0:
		# Charge attack
		is_attacking = true
		velocity = direction * current_speed * 3
		attack_timer = attack_cooldown * 2
	else:
		is_attacking = false
		velocity = direction * current_speed

func _attack() -> void:
	attack_timer = attack_cooldown

	match behavior_type:
		"melee":
			# Damage is handled by attack_area
			_set_animation("attack")
		"ranged":
			_shoot_projectile()
			_set_animation("attack")
		"charger":
			# Damage on collision during charge
			_set_animation("charge")

func _shoot_projectile() -> void:
	if projectile_scene:
		var projectile = projectile_scene.instantiate()
		var direction = (target.global_position - global_position).normalized()
		projectile.global_position = global_position
		projectile.direction = direction
		projectile.damage = base_damage
		projectile.owner_id = get_instance_id()
		get_parent().add_child(projectile)

func _on_attack_area_entered(area: Area2D) -> void:
	if area.is_in_group("player") and (behavior_type == "melee" or is_attacking):
		if area.has_method("take_damage"):
			area.take_damage(base_damage, (area.global_position - global_position).normalized() * 200)

func _on_player_detected(area: Area2D) -> void:
	if area.is_in_group("player") and not target:
		target = area

func _on_player_lost(area: Area2D) -> void:
	if area == target:
		target = null

func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	health.take_damage(amount)

	if knockback.length() > 0:
		velocity = knockback * knockback_resistance

	hit_flash_timer = 0.1
	animated_sprite.modulate = Color(1, 0.3, 0.3)
	last_damage_time = Time.get_ticks_msec() / 1000.0

func _on_health_changed(current: int, max: int) -> void:
	damaged.emit(max - current)

func _on_damaged(amount: int, source: Node) -> void:
	# Could add aggro logic here
	pass

func _on_died() -> void:
	died.emit(self, xp_reward)
	_spawn_death_effects()
	queue_free()

func _spawn_death_effects() -> void:
	# Override in subclasses
	pass

func _update_animation(direction: Vector2) -> void:
	if velocity.length() > 10:
		_set_animation("walk")
	elif not is_attacking:
		_set_animation("idle")

func _set_animation(base: String) -> void:
	var anim_dir = _get_animation_direction(velocity)
	var new_anim = "%s_%s" % [base, anim_dir]
	if animated_sprite.sprite_frames.has_animation(new_anim):
		animated_sprite.animation = new_anim
	elif animated_sprite.sprite_frames.has_animation(base):
		animated_sprite.animation = base

func _get_animation_direction(vel: Vector2) -> String:
	if abs(vel.x) > abs(vel.y):
		return "right" if vel.x > 0 else "left"
	else:
		return "down" if vel.y > 0 else "up"