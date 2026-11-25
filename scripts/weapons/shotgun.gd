extends Weapon
class_name Shotgun

func _ready() -> void:
	super._ready()
	stats.damage = 8
	stats.fire_rate = 0.8
	stats.projectile_speed = 600
	stats.projectile_count = 5
	stats.spread = 0.5  # radians (~30 degrees)
	stats.piercing = 0
	stats.knockback = 300

func shoot(player_pos: Vector2, target_pos: Vector2) -> void:
	super.shoot(player_pos, target_pos)
	# Shotgun has fixed spread pattern
	# The base class handles the spread via stats.spread