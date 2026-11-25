extends Node
class_name ExperienceComponent

## Configuration
@export var base_xp_required: int = 100
@export var xp_growth_factor: float = 1.5
@export var max_level: int = 50

## Signals
signal experience_gained(amount: int, total: int)
signal level_up(new_level: int, skill_points: int)

## State
var current_level: int = 1
var current_xp: int = 0
var xp_to_next_level: int
var unspent_skill_points: int = 0

func _ready() -> void:
	xp_to_next_level = base_xp_required

func add_experience(amount: int) -> void:
	if current_level >= max_level:
		return

	current_xp += amount
	experience_gained.emit(amount, current_xp)

	while current_xp >= xp_to_next_level and current_level < max_level:
		current_xp -= xp_to_next_level
		current_level += 1
		unspent_skill_points += 1
		xp_to_next_level = int(base_xp_required * pow(xp_growth_factor, current_level - 1))
		level_up.emit(current_level, unspent_skill_points)

func spend_skill_point() -> bool:
	if unspent_skill_points > 0:
		unspent_skill_points -= 1
		return true
	return false

func get_xp_percent() -> float:
	return current_xp / xp_to_next_level if xp_to_next_level > 0 else 1.0

func get_level_progress() -> Dictionary:
	return {
		"level": current_level,
		"current_xp": current_xp,
		"xp_to_next": xp_to_next_level,
		"percent": get_xp_percent(),
		"skill_points": unspent_skill_points
	}