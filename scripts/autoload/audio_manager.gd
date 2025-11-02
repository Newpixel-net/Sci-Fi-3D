extends Node
## Audio Manager - Centralized audio playback system
##
## Manages music layers, sound effects, and spatial audio.
## Handles volume control and audio ducking for dramatic moments.

# Audio bus names
const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"

# Audio player pools
var sfx_players: Array[AudioStreamPlayer] = []
var sfx_3d_players: Array[AudioStreamPlayer3D] = []
const MAX_SFX_PLAYERS = 20

# Music player
var music_player: AudioStreamPlayer

# Current music track
var current_music: AudioStream = null
var is_music_playing: bool = false

func _ready() -> void:
	# Create music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = MUSIC_BUS
	add_child(music_player)

	# Create SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player = AudioStreamPlayer.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_players.append(player)

	# Create 3D SFX player pool
	for i in MAX_SFX_PLAYERS:
		var player = AudioStreamPlayer3D.new()
		player.bus = SFX_BUS
		add_child(player)
		sfx_3d_players.append(player)

	print("AudioManager initialized with %d SFX players" % MAX_SFX_PLAYERS)

## Play a sound effect (2D)
func play_sfx(sound: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sound:
		return

	var player = _get_available_sfx_player()
	if player:
		player.stream = sound
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()

## Play a sound effect at a 3D position
func play_sfx_3d(sound: AudioStream, position: Vector3, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	if not sound:
		return

	var player = _get_available_sfx_3d_player()
	if player:
		player.stream = sound
		player.global_position = position
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.max_distance = 50.0
		player.play()

## Play music track
func play_music(music: AudioStream, fade_in_duration: float = 1.0) -> void:
	if not music:
		return

	if current_music == music and is_music_playing:
		return

	current_music = music
	music_player.stream = music

	if fade_in_duration > 0:
		music_player.volume_db = -80
		music_player.play()
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", 0.0, fade_in_duration)
	else:
		music_player.volume_db = 0.0
		music_player.play()

	is_music_playing = true

## Stop music
func stop_music(fade_out_duration: float = 1.0) -> void:
	if not is_music_playing:
		return

	if fade_out_duration > 0:
		var tween = create_tween()
		tween.tween_property(music_player, "volume_db", -80.0, fade_out_duration)
		tween.tween_callback(music_player.stop)
	else:
		music_player.stop()

	is_music_playing = false

## Set music volume
func set_music_volume(volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(MUSIC_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

## Set SFX volume
func set_sfx_volume(volume: float) -> void:
	var bus_index = AudioServer.get_bus_index(SFX_BUS)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume))

## Set master volume
func set_master_volume(volume: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume))

## Get an available SFX player
func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player

	# If all busy, return first one (will interrupt)
	return sfx_players[0]

## Get an available 3D SFX player
func _get_available_sfx_3d_player() -> AudioStreamPlayer3D:
	for player in sfx_3d_players:
		if not player.playing:
			return player

	# If all busy, return first one (will interrupt)
	return sfx_3d_players[0]

## Play random pitch variation
func play_sfx_random_pitch(sound: AudioStream, volume_db: float = 0.0, pitch_min: float = 0.9, pitch_max: float = 1.1) -> void:
	var pitch = randf_range(pitch_min, pitch_max)
	play_sfx(sound, volume_db, pitch)

## Play weapon shot sound
func play_weapon_shot(weapon_type: String, position: Vector3 = Vector3.ZERO) -> void:
	# Placeholder - will load actual sounds later
	# For now, just print
	print("Playing weapon sound: %s at %s" % [weapon_type, position])

## Play impact sound
func play_impact(position: Vector3) -> void:
	print("Playing impact sound at %s" % position)

## Play enemy death sound
func play_enemy_death(enemy_type: String, position: Vector3) -> void:
	print("Playing enemy death sound: %s at %s" % [enemy_type, position])

## UI sound effects
func play_ui_click() -> void:
	print("UI Click")

func play_ui_hover() -> void:
	print("UI Hover")

func play_ui_purchase() -> void:
	print("UI Purchase")

func play_ui_error() -> void:
	print("UI Error")
