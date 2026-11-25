extends Node
class_name WeaponManager

## Configuration
@export var starting_weapon: PackedScene = preload("res://scripts/weapons/basic_pistol.gd")

## State
var current_weapon: Weapon
var weapon_stats: Dictionary = {
	"damage": 10,
	"fire_rate": 0.3,
	"projectile_speed": 600,
	"projectile_count": 1,
	"spread": 0.0,
	"piercing": 0,
	"knockback": 100
}

## References
@onready var projectile_container = get_tree().root.get_node("Main/Projectiles")

func _ready() -> void:
	equip_weapon(starting_weapon)

func _process(delta: float) -> void:
	if current_weapon:
		current_weapon.update(delta)

func equip_weapon(weapon_scene: PackedScene) -> void:
	if current_weapon:
		current_weapon.queue_free()

	current_weapon = weapon_scene.instantiate()
	current_weapon.stats = weapon_stats.duplicate()
	add_child(current_weapon)
	current_weapon.owner = self

func update_aim(player_pos: Vector2, target_pos: Vector2) -> void:
	if current_weapon:
		current_weapon.update_aim(player_pos, target_pos)

func try_shoot(player_pos: Vector2, target_pos: Vector2) -> void:
	if current_weapon:
		current_weapon.try_shoot(player_pos, target_pos)

func modify_stat(stat_name: StringName, value: Variant) -> void:
	if weapon_stats.has(stat_name):
		weapon_stats[stat_name] = value
		if current_weapon:
			current_weapon.stats[stat_name] = value

func get_stat(stat_name: StringName) -> Variant:
	return weapon_stats.get(stat_name, null)

func add_projectile_count(amount: int) -> void:
	modify_stat("projectile_count", weapon_stats.projectile_count + amount)

func add_damage(amount: float) -> void:
	modify_stat("damage", weapon_stats.damage + amount)

func add_fire_rate(multiplier: float) -> void:
	modify_stat("fire_rate", weapon_stats.fire_rate * multiplier)

func add_spread(amount: float) -> void:
	modify_stat("spread", weapon_stats.spread + amount)

func add_piercing(amount: int) -> void:
	modify_stat("piercing", weapon_stats.piercing + amount)