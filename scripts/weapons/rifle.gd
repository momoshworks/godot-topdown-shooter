extends Weapon
class_name Rifle

func _ready() -> void:
	super._ready()
	stats.damage = 18
	stats.fire_rate = 0.15
	stats.projectile_speed = 900
	stats.projectile_count = 1
	stats.spread = 0.05  # Small spread for accuracy
	stats.piercing = 1
	stats.knockback = 200