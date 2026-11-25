extends Area2D
class_name EnemyProjectile

## Configuration
@export var lifetime: float = 5.0
@export var speed: float = 400.0
@export var damage: int = 15

## State
var direction: Vector2 = Vector2.RIGHT
var lifetime_timer: float

func _ready() -> void:
	lifetime_timer = lifetime
	collision_layer = 16  # EnemyProjectile layer
	collision_mask = 2  # Player layer
	rotation = direction.angle()

	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	lifetime_timer -= delta

	if lifetime_timer <= 0:
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		if area.has_method("take_damage"):
			area.take_damage(damage, direction * 100)
		queue_free()
	elif area.is_in_group("walls"):
		queue_free()