extends Weapon
class_name BasicPistol

## Visual
@onready var muzzle_flash: GpuParticles2D = %MuzzleFlash

func _ready() -> void:
	super._ready()
	# Pistol specific stats
	stats.damage = 12
	stats.fire_rate = 0.25
	stats.projectile_speed = 700
	stats.projectile_count = 1
	stats.spread = 0.0
	stats.piercing = 0
	stats.knockback = 150

func shoot(player_pos: Vector2, target_pos: Vector2) -> void:
	super.shoot(player_pos, target_pos)

	# Muzzle flash effect
	if muzzle_flash:
		muzzle_flash.restart()
		muzzle_flash.rotation = aim_direction.angle()