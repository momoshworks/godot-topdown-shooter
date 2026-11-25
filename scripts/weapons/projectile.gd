extends Area2D
class_name Projectile

## Configuration
@export var lifetime: float = 3.0
@export var hit_particles: PackedScene

## Properties (set by weapon)
var direction: Vector2 = Vector2.RIGHT
var speed: float = 600.0
var damage: int = 10
var piercing: int = 0
var knockback: float = 100.0
var owner_id: int = 0

## State
var lifetime_timer: float = 0.0
var hit_entities: Array[int] = []

## Signals
signal hit_target(target: Node, damage: int)

func _ready() -> void:
	lifetime_timer = lifetime
	collision_layer = 4  # PlayerProjectile layer
	collision_mask = 8 | 16  # Enemy + Wall layers

	# Set up collision
	area_entered.connect(_on_area_entered)

	# Rotate to face direction
	rotation = direction.angle()

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime_timer -= delta

	if lifetime_timer <= 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Don't hit owner
	if area.get_instance_id() == owner_id:
		return

	# Don't hit same entity twice (for piercing)
	if area.get_instance_id() in hit_entities:
		return

	# Check if it's an enemy or damageable
	if area.has_method("take_damage"):
		area.take_damage(damage, direction * knockback)
		hit_entities.append(area.get_instance_id())
		hit_target.emit(area, damage)

		# Spawn hit particles
		if hit_particles:
			var particles = hit_particles.instantiate()
			get_parent().add_child(particles)
			particles.global_position = global_position

		# Handle piercing
		piercing -= 1
		if piercing < 0:
			queue_free()
	elif area.is_in_group("walls"):
		# Hit wall
		queue_free()

func _draw() -> void:
	# Simple debug draw
	draw_circle(Vector2.ZERO, 4, Color.RED)