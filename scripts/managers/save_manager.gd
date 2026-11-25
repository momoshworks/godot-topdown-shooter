extends Node
class_name SaveManager

const SAVE_PATH = "user://save_game.json"
const SETTINGS_PATH = "user://settings.json"

## Default settings
static var default_settings = {
	"music_volume": 0.5,
	"sfx_volume": 0.8,
	"show_fps": false,
	"screen_shake": true,
	"auto_pause": true
}

static var current_settings: Dictionary = {}

static func _ready() -> void:
	load_settings()

static func save_high_score(score: int) -> void:
	var data = load_save_data()
	data.high_score = max(data.get("high_score", 0), score)
	save_save_data(data)

static func get_high_score() -> int:
	var data = load_save_data()
	return data.get("high_score", 0)

static func save_save_data(data: Dictionary) -> void:
	var json_string = JSON.stringify(data, "\t")
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

static func load_save_data() -> Dictionary:
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var result = JSON.parse_string(json_string)
		if result.error == OK:
			return result.value
	return {}

static func save_settings() -> void:
	var json_string = JSON.stringify(current_settings, "\t")
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file:
		file.store_string(json_string)
		file.close()

static func load_settings() -> void:
	var file = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var result = JSON.parse_string(json_string)
		if result.error == OK:
			current_settings = result.value
		else:
			current_settings = default_settings.duplicate()
	else:
		current_settings = default_settings.duplicate()

	# Ensure all default keys exist
	for key in default_settings:
		if not current_settings.has(key):
			current_settings[key] = default_settings[key]

	save_settings()

static func get_setting(key: String) -> Variant:
	if not current_settings:
		load_settings()
	return current_settings.get(key, default_settings.get(key))

static func set_setting(key: String, value: Variant) -> void:
	if not current_settings:
		load_settings()
	current_settings[key] = value
	save_settings()

static func get_music_volume() -> float:
	return get_setting("music_volume")

static func set_music_volume(volume: float) -> void:
	set_setting("music_volume", volume)

static func get_sfx_volume() -> float:
	return get_setting("sfx_volume")

static func set_sfx_volume(volume: float) -> void:
	set_setting("sfx_volume", volume)

static func reset_settings() -> void:
	current_settings = default_settings.duplicate()
	save_settings()

static func reset_save_data() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string("{}")
		file.close()