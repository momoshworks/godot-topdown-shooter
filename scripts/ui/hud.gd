extends CanvasLayer
class_name HUD

## UI References
@onready var health_bar: ProgressBar = %HealthBar
@onready var health_text: Label = %HealthText
@onready var xp_bar: ProgressBar = %XPBar
@onready var xp_text: Label = %XPText
@onready var level_label: Label = %LevelLabel
@onready var score_label: Label = %ScoreLabel
@onready var wave_label: Label = %WaveLabel
@onready var xp_popup_container: CanvasLayer = %XPPopupContainer
@onready var level_up_popup: Panel = %LevelUpPopup

## State
var xp_popup_timer: float = 0.0

func _ready() -> void:
	# Set up progress bars
	health_bar.min_value = 0
	xp_bar.min_value = 0

	level_up_popup.visible = false

func update_health(current: int, max: int) -> void:
	health_bar.max_value = max
	health_bar.value = current
	health_text.text = "%d / %d" % [current, max]

	# Color coding
	if current / max <= 0.25:
		health_bar.modulate = Color.RED
	elif current / max <= 0.5:
		health_bar.modulate = Color.YELLOW
	else:
		health_bar.modulate = Color.GREEN

func show_xp_gain(amount: int) -> void:
	# Create floating XP text
	var label = Label.new()
	label.text = "+%d XP" % amount
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.position = Vector2(randf_range(-50, 50), -30)

	xp_popup_container.add_child(label)

	# Animate
	var tween = create_tween()
	tween.tween_property(label, "position:y", -80, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(func(): label.queue_free())

func update_xp(current: int, max: int, level: int) -> void:
	xp_bar.max_value = max
	xp_bar.value = current
	xp_text.text = "%d / %d" % [current, max]
	level_label.text = "Level %d" % level

func update_score(score: int) -> void:
	score_label.text = "Score: %d" % score

func update_wave(wave: int) -> void:
	wave_label.text = "Wave: %d" % wave

func show_level_up(new_level: int) -> void:
	level_up_popup.visible = true
	var level_text = level_up_popup.get_node("LevelText")
	if level_text:
		level_text.text = "Level %d Reached!" % new_level

	# Populate upgrade choices
	var choices_container = level_up_popup.get_node("ChoicesContainer")
	if choices_container:
		_populate_choices(choices_container)

func _populate_choices(container: Container) -> void:
	# Clear existing
	for child in container.get_children():
		child.queue_free()

	var upgrades = [
		{"name": "Damage +20%", "description": "Increase weapon damage", "icon": "🗡️"},
		{"name": "Fire Rate +15%", "description": "Shoot faster", "icon": "⚡"},
		{"name": "Max Health +25", "description": "More survivability", "icon": "❤️"},
		{"name": "Projectile +1", "description": "Shoot an extra projectile", "icon": "💫"},
		{"name": "Move Speed +20%", "description": "Move faster", "icon": "👟"},
		{"name": "Piercing +1", "description": "Projectiles pierce enemies", "icon": "🎯"},
	]

	# Pick 3 random upgrades
	var selected = upgrades.duplicate()
	selected.shuffle()
	selected = selected.slice(0, 3)

	for i, upgrade in enumerate(selected):
		var button = Button.new()
		button.text = "%s %s\n%s" % [upgrade.icon, upgrade.name, upgrade.description]
		button.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		button.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		button.custom_minimum_size = Vector2(200, 80)
		button.pressed.connect(_on_choice_selected.bind(i))
		container.add_child(button)

func _on_choice_selected(index: int) -> void:
	level_up_popup.visible = false
	var game_manager = get_tree().root.get_node("Main")
	if game_manager and game_manager.has_method("on_level_up_choice_selected"):
		game_manager.on_level_up_choice_selected(index)