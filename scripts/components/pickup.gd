extends Area2D
class_name Pickup

enum PickupType { HEALTH, XP, SPEED, DAMAGE, FIRE_RATE, MAX_HEALTH }

@export var pickup_type: int = PickupType.HEALTH
@export var amount: int = 25
@export var duration: float = 10.0  # For timed buffs
@export var attraction_range: float = 100.0
@export var attraction_speed: float = 300.0
@export var bob_speed: float = 2.0
@export var bob_height: float = 5.0
@export var pickup_sound: AudioStream
@export var pickup_particles: PackedScene

var base_y: float = 0.0
var bob_timer: float = 0.0

func _ready() -> void:
	base_y = position.y
	collision_layer = 0
	collision_mask = 2  # Player layer

	# Attraction area
	var attract_area = Area2D.new()
	var attract_shape = CircleShape2D.new()
	attract_shape.radius = attraction_range
	var attract_col = CollisionShape2D.new()
	attract_col.shape = attract_shape
	attract_area.add_child(attract_col)
	attract_area.collision_layer = 0
	attract_area.collision_mask = 2
	add_child(attract_area)
	attract_area.area_entered.connect(_on_player_in_range)

	# Pickup area
	area_entered.connect(_on_pickup)

	# Animation
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(self, "position:y", base_y - bob_height, 1.0)
	tween.tween_property(self, "position:y", base_y + bob_height, 1.0)

func _process(delta: float) -> void:
	# Rotation animation
	rotation += delta * 2

func _on_player_in_range(area: Area2D) -> void:
	if area.is_in_group("player"):
		var direction = (area.global_position - global_position).normalized()
		position += direction * attraction_speed * get_physics_process_delta_time()

func _on_pickup(area: Area2D) -> void:
	if not area.is_in_group("player"):
		return

	var player = area
	var applied = false

	match pickup_type:
		PickupType.HEALTH:
			if player.has_method("heal") and not player.health.is_at_max_health():
				player.heal(amount)
				applied = true

		PickupType.XP:
			if player.has_method("add_experience"):
				player.add_experience(amount)
				applied = true

		PickupType.SPEED:
			if player.has_method("current_speed"):
				player.current_speed *= 1.3
				# TODO: Add timer to revert
				applied = true

		PickupType.DAMAGE:
			if player.has_method("get_stat"):
				player.weapon_manager.add_damage(amount)
				applied = true

		PickupType.FIRE_RATE:
			if player.has_method("get_stat"):
				player.weapon_manager.add_fire_rate(0.8)
				applied = true

		PickupType.MAX_HEALTH:
			if player.has_method("get_stat"):
				player.health.set_max_health(player.health.max_health + amount)
				player.heal(amount)
				applied = true

	if applied:
		# Play sound
		if pickup_sound:
			AudioServer.play(pickup_sound, 0, 1.0)

		# Spawn particles
		if pickup_particles:
			var particles = pickup_particles.instantiate()
			get_parent().add_child(particles)
			particles.global_position = global_position

		queue_free()


# Convenience static methods for spawning
static func spawn_health(position: Vector2, amount: int = 25, parent: Node = null) -> Pickup:
	return _spawn(PickupType.HEALTH, amount, position, parent)

static func spawn_xp(position: Vector2, amount: int = 10, parent: Node = null) -> Pickup:
	return _spawn(PickupType.XP, amount, position, parent)

static func _spawn(type: int, amount: int, position: Vector2, parent: Node) -> Pickup:
	var pickup = Pickup.new()
	pickup.pickup_type = type
	pickup.amount = amount
	pickup.global_position = position
	if parent:
		parent.add_child(pickup)
	else:
		get_tree().root.get_node("Main/Pickups").add_child(pickup)
	return pickup