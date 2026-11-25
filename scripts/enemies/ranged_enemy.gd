extends Enemy
class_name RangedEnemy

func _ready() -> void:
	super._ready()
	behavior_type = "ranged"
	base_health = 40
	base_damage = 12
	base_speed = 100.0
	xp_reward = 8
	detection_range = 600.0
	attack_range = 300.0
	attack_cooldown = 2.0

	# Load projectile scene
	projectile_scene = preload("res://scripts/weapons/enemy_projectile.gd")

func _spawn_death_effects() -> void:
	# Spawn XP pickup
	Pickup.spawn_xp(global_position, xp_reward, get_parent())