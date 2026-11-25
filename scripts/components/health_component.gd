extends Node
class_name HealthComponent

## Configuration
@export var max_health: int = 100
@export var regeneration_rate: float = 0.0  # Health per second
@export var regeneration_delay: float = 5.0  # Seconds after taking damage before regen starts

## Signals
signal health_changed(current: int, max: int)
signal damaged(amount: int, source: Node)
signal healed(amount: int)
signal died

## State
var current_health: int
var last_damage_time: float = -100.0
var is_regenerating: bool = false

func _ready() -> void:
	current_health = max_health

func _process(delta: float) -> void:
	if regeneration_rate > 0 and current_health < max_health:
		if Time.get_ticks_msec() / 1000.0 - last_damage_time >= regeneration_delay:
			regenerate(delta)

func take_damage(amount: int, source: Node = null) -> void:
	if current_health <= 0:
		return

	current_health = max(0, current_health - amount)
	last_damage_time = Time.get_ticks_msec() / 1000.0

	health_changed.emit(current_health, max_health)
	damaged.emit(amount, source)

	if current_health <= 0:
		died.emit()

func heal(amount: int) -> void:
	if current_health <= 0:
		return

	var old_health = current_health
	current_health = min(max_health, current_health + amount)
	var actual_heal = current_health - old_health

	if actual_heal > 0:
		health_changed.emit(current_health, max_health)
		healed.emit(actual_heal)

func regenerate(delta: float) -> void:
	var heal_amount = regeneration_rate * delta
	heal(int(heal_amount))

func set_max_health(new_max: int) -> void:
	var ratio = current_health / max_health if max_health > 0 else 1.0
	max_health = new_max
	current_health = int(max_health * ratio)
	health_changed.emit(current_health, max_health)

func get_health_percent() -> float:
	return current_health / max_health if max_health > 0 else 0.0

func is_at_max_health() -> bool:
	return current_health >= max_health

func is_dead() -> bool:
	return current_health <= 0