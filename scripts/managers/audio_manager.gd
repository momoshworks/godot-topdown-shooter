extends Node
class_name AudioManager

## Audio buses
const BUS_MASTER = "Master"
const BUS_MUSIC = "Music"
const BUS_SFX = "SFX"

## Sound effects (add your .ogg/.wav files to assets/audio/)
@export var sfx_shoot: AudioStream
@export var sfx_hit: AudioStream
@export var sfx_enemy_death: AudioStream
@export var sfx_player_hurt: AudioStream
@export var sfx_level_up: AudioStream
@export var sfx_dash: AudioStream
@export var sfx_pickup: AudioStream
@export var sfx_wave_start: AudioStream

## Music
@export var music_gameplay: AudioStream
@export var music_boss: AudioStream

## State
var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var current_music: AudioStream
var music_volume: float = 0.5
var sfx_volume: float = 0.8

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = BUS_MUSIC
	add_child(music_player)

	# Pre-create SFX players for pooling
	for i in range(10):
		var player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		sfx_players.append(player)

	# Load saved volumes
	music_volume = SaveManager.get_music_volume()
	sfx_volume = SaveManager.get_sfx_volume()
	_set_bus_volumes()

	# Start gameplay music
	play_music(music_gameplay)

func _set_bus_volumes() -> void:
	AudioServer.set_bus_volume_db(BUS_MUSIC, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(BUS_SFX, linear_to_db(sfx_volume))

func play_sfx(sound: AudioStream, pitch_variance: float = 0.1) -> void:
	if not sound:
		return

	# Find available player
	var player = null
	for p in sfx_players:
		if not p.playing:
			player = p
			break

	if not player:
		# All busy, create new one
		player = AudioStreamPlayer.new()
		player.bus = BUS_SFX
		add_child(player)
		sfx_players.append(player)

	player.stream = sound
	player.pitch_scale = 1.0 + randf_range(-pitch_variance, pitch_variance)
	player.play()

func play_music(music: AudioStream, fade_time: float = 1.0) -> void:
	if not music or music == current_music:
		return

	current_music = music

	if music_player.playing:
		# Crossfade
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_time)
		tween.tween_callback(_switch_music.bind(music))
		tween.tween_property(music_player, "volume_db", linear_to_db(music_volume), fade_time)
	else:
		_switch_music(music)

func _switch_music(music: AudioStream) -> void:
	music_player.stream = music
	music_player.play()
	music_player.volume_db = linear_to_db(music_volume)

func stop_music(fade_time: float = 1.0) -> void:
	if music_player.playing:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80, fade_time)
		tween.tween_callback(func(): music_player.stop())

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(BUS_MUSIC, linear_to_db(music_volume))
	SaveManager.set_music_volume(music_volume)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(BUS_SFX, linear_to_db(sfx_volume))
	SaveManager.set_sfx_volume(sfx_volume)

func get_music_volume() -> float:
	return music_volume

func get_sfx_volume() -> float:
	return sfx_volume

# Convenience methods for common sounds
func play_shoot() -> void:
	play_sfx(sfx_shoot, 0.15)

func play_hit() -> void:
	play_sfx(sfx_hit)

func play_enemy_death() -> void:
	play_sfx(sfx_enemy_death, 0.2)

func play_player_hurt() -> void:
	play_sfx(sfx_player_hurt)

func play_level_up() -> void:
	play_sfx(sfx_level_up)

func play_dash() -> void:
	play_sfx(sfx_dash)

func play_pickup() -> void:
	play_sfx(sfx_pickup)

func play_wave_start() -> void:
	play_sfx(sfx_wave_start)