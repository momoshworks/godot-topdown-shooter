extends Enemy
class_name ChargerEnemy

func _ready() -> void:
	super._ready()
	behavior_type = "charger"
	base_health = 80
	base_damage = 20
	base_speed = 80.0
	xp_reward = 15
	detection_range = 500.0
	attack_range = 60.0
	attack_cooldown = 3.0
	knockback_resistance = 0.8

func _spawn_death_effects() -> void:
	# Spawn health and XP
	Pickup.spawn_health(global_position, 20, get_parent())
	Pickup.spawn_xp(global_position, xp_reward, get_parent())