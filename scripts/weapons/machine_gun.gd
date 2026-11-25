extends Weapon
class_name MachineGun

func _ready() -> void:
	super._ready()
	stats.damage = 6
	stats.fire_rate = 0.08
	stats.projectile_speed = 700
	stats.projectile_count = 1
	stats.spread = 0.15
	stats.piercing = 0
	stats.knockback = 80