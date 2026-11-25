extends Node
class_name GameManager

## Game state
enum GameState { PLAYING, PAUSED, GAME_OVER, LEVEL_UP }
var current_state: GameState = GameState.PLAYING

## References
@onready var player: Player = %Player
@onready var enemies_node: Node2D = %Enemies
@onready var projectiles_node: Node2D = %Projectiles
@onready var pickups_node: Node2D = %Pickups
@onready var particles_node: Node2D = %Particles
@onready var hud: HUD = %HUD
@onready var pause_menu: CanvasLayer = %PauseMenu
@onready var game_over_screen: CanvasLayer = %GameOverScreen
@onready var level_up_screen: CanvasLayer = %LevelUpScreen
@onready var background: ColorRect = %Background
@onready var audio_manager: AudioManager = %AudioManager

## Wave system
var current_wave: int = 1
var enemies_in_wave: int = 0
var enemies_killed: int = 0
var wave_spawn_timer: float = 0.0
var wave_cooldown: float = 5.0
var enemies_per_wave_base: int = 5
var enemies_per_wave_growth: float = 1.3

## Spawn settings
var spawn_radius_min: float = 400.0
var spawn_radius_max: float = 600.0
var enemy_scenes: Array[PackedScene] = []

## Score
var score: int = 0
var high_score: int = 0

## Signals
signal game_started
signal wave_started(wave: int)
signal wave_completed(wave: int)
signal game_over(final_score: int)
signal score_changed(new_score: int)

func _ready() -> void:
	# Load enemy scenes
	enemy_scenes.append(preload("res://scenes/enemies/basic_enemy.tscn"))
	# Add more enemy types here as needed

	# Connect signals
	player.died.connect(_on_player_died)
	player.health_changed.connect(_on_player_health_changed)
	player.experience_gained.connect(_on_experience_gained)
	player.level_up.connect(_on_player_level_up)

	# Start first wave
	start_new_wave()

	# Hide menus
	pause_menu.visible = false
	game_over_screen.visible = false
	level_up_screen.visible = false

	game_started.emit()

func _process(delta: float) -> void:
	if current_state != GameState.PLAYING:
		return

	_handle_wave_spawning(delta)
	_handle_input()

func _handle_input() -> void:
	if Input.is_action_just_pressed("pause"):
		toggle_pause()

func _handle_wave_spawning(delta: float) -> void:
	if enemies_in_wave <= 0 and enemies_killed >= get_enemies_for_wave(current_wave):
		# Wave complete
		wave_spawn_timer -= delta
		if wave_spawn_timer <= 0:
			current_wave += 1
			start_new_wave()
	else:
		# Spawn enemies gradually
		wave_spawn_timer -= delta
		if wave_spawn_timer <= 0 and enemies_in_wave < get_enemies_for_wave(current_wave):
			spawn_enemy()
			wave_spawn_timer = 0.5  # Spawn interval

func start_new_wave() -> void:
	enemies_in_wave = 0
	enemies_killed = 0
	wave_spawn_timer = 1.0
	wave_started.emit(current_wave)

func get_enemies_for_wave(wave: int) -> int:
	return int(enemies_per_wave_base * pow(enemies_per_wave_growth, wave - 1))

func spawn_enemy() -> void:
	if enemy_scenes.is_empty():
		return

	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()

	# Spawn in a circle around player
	var angle = randf() * TAU
	var radius = randf_range(spawn_radius_min, spawn_radius_max)
	var spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * radius

	# Clamp to screen bounds (with margin)
	var viewport = get_viewport_rect()
	spawn_pos.x = clamp(spawn_pos.x, 100, viewport.size.x - 100)
	spawn_pos.y = clamp(spawn_pos.y, 100, viewport.size.y - 100)

	enemy.global_position = spawn_pos
	enemies_node.add_child(enemy)
	enemies_in_wave += 1

	# Connect enemy death
	enemy.died.connect(_on_enemy_died.bind(enemy))

func _on_enemy_died(enemy: Enemy, xp_reward: int) -> void:
	enemies_in_wave -= 1
	enemies_killed += 1
	player.add_experience(xp_reward)
	add_score(10 * current_wave)

func _on_player_died() -> void:
	current_state = GameState.GAME_OVER
	game_over_screen.visible = true
	get_tree().paused = true
	game_over.emit(score)

	if score > high_score:
		high_score = score
		# Save high score
		SaveManager.save_high_score(high_score)

func _on_player_health_changed(current: int, max: int) -> void:
	hud.update_health(current, max)

func _on_experience_gained(amount: int) -> void:
	hud.show_xp_gain(amount)

func _on_player_level_up(new_level: int) -> void:
	current_state = GameState.LEVEL_UP
	level_up_screen.visible = true
	get_tree().paused = true
	hud.show_level_up(new_level)

func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)
	hud.update_score(score)

func toggle_pause() -> void:
	if current_state == GameState.PLAYING:
		current_state = GameState.PAUSED
		pause_menu.visible = true
		get_tree().paused = true
	elif current_state == GameState.PAUSED:
		resume_game()

func resume_game() -> void:
	current_state = GameState.PLAYING
	pause_menu.visible = false
	game_over_screen.visible = false
	level_up_screen.visible = false
	get_tree().paused = false

func restart_game() -> void:
	get_tree().reload_current_scene()

func return_to_menu() -> void:
	# Could load a main menu scene
	get_tree().reload_current_scene()

func on_level_up_choice_selected(choice_index: int) -> void:
	# Handle level up upgrade selection
	current_state = GameState.PLAYING
	level_up_screen.visible = false
	get_tree().paused = false
	# Apply upgrade based on choice_index
	_apply_level_up_choice(choice_index)

func _apply_level_up_choice(choice_index: int) -> void:
	# This would be expanded with actual upgrade options
	var upgrades = [
		{"name": "Damage +20%", "func": func(): player.weapon_manager.add_damage(player.weapon_manager.get_stat("damage") * 0.2)},
		{"name": "Fire Rate +15%", "func": func(): player.weapon_manager.add_fire_rate(0.85)},
		{"name": "Max Health +25", "func": func(): player.health.set_max_health(player.health.max_health + 25)},
		{"name": "Projectile +1", "func": func(): player.weapon_manager.add_projectile_count(1)},
		{"name": "Speed +20%", "func": func(): player.current_speed *= 1.2},
	]

	if choice_index < upgrades.size():
		upgrades[choice_index].func.call()