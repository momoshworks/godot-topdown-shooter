extends Node
class_name Weapon

## Stats (set by WeaponManager)
var stats: Dictionary = {}

## State
var fire_timer: float = 0.0
var aim_direction: Vector2 = Vector2.RIGHT
var projectile_container: Node

func _ready() -> void:
	# Find projectile container
	var main = get_tree().root.get_node("Main")
	if main:
		projectile_container = main.get_node("Projectiles")

func _process(delta: float) -> void:
	if fire_timer > 0:
		fire_timer -= delta

func update(delta: float) -> void:
	# Override in subclasses for special behavior
	pass

func update_aim(player_pos: Vector2, target_pos: Vector2) -> void:
	aim_direction = (target_pos - player_pos).normalized()

func try_shoot(player_pos: Vector2, target_pos: Vector2) -> void:
	if fire_timer <= 0:
		shoot(player_pos, target_pos)
		fire_timer = stats.get("fire_rate", 0.3)

func shoot(player_pos: Vector2, target_pos: Vector2) -> void:
	update_aim(player_pos, target_pos)

	var count = stats.get("projectile_count", 1)
	var spread = stats.get("spread", 0.0)
	var base_angle = aim_direction.angle()

	for i in range(count):
		var angle = base_angle
		if count > 1:
			angle += (i - (count - 1) / 2.0) * spread

		var direction = Vector2(cos(angle), sin(angle))
		spawn_projectile(player_pos, direction)

func spawn_projectile(position: Vector2, direction: Vector2) -> void:
	var projectile = Projectile.new()
	projectile.position = position
	projectile.direction = direction
	projectile.speed = stats.get("projectile_speed", 600)
	projectile.damage = stats.get("damage", 10)
	projectile.piercing = stats.get("piercing", 0)
	projectile.knockback = stats.get("knockback", 100)
	projectile.owner_id = get_parent().get_instance_id()  # Player ID

	if projectile_container:
		projectile_container.add_child(projectile)
	else:
		get_parent().add_child(projectile)

func get_stats() -> Dictionary:
	return stats.duplicate()