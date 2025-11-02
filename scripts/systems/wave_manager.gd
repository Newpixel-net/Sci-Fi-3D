extends Node
## Wave Manager - Controls wave progression and difficulty
##
## Manages wave configuration, spawning timing, and difficulty scaling.

signal wave_prepare(wave_number: int)
signal wave_start(wave_number: int)
signal wave_complete(wave_number: int)

@export var enemy_spawner: Node3D
@export var prepare_time: float = 5.0

# Wave configuration
var current_wave: int = 0
var base_enemy_count: int = 5
var enemy_count_increase_per_wave: int = 3

# Enemy scenes (set these in scene or load them)
var enemy_scenes: Array[PackedScene] = []

var is_wave_active: bool = false

func _ready() -> void:
	# Connect to game manager
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.wave_completed.connect(_on_wave_completed)

	print("Wave Manager ready")

## Prepare for wave (countdown)
func prepare_wave(wave_number: int) -> void:
	current_wave = wave_number
	wave_prepare.emit(wave_number)

	print("Preparing for wave %d... (%d seconds)" % [wave_number, prepare_time])

	await get_tree().create_timer(prepare_time).timeout

	start_wave()

## Start spawning wave
func start_wave() -> void:
	if not enemy_spawner:
		print("Error: No enemy spawner set!")
		return

	is_wave_active = true
	wave_start.emit(current_wave)

	# Calculate enemy count for this wave
	var enemy_count = calculate_wave_enemy_count(current_wave)

	# Get enemy types for this wave
	var wave_enemies = get_wave_enemy_types(current_wave)

	# Calculate spawn delay
	var spawn_delay = calculate_spawn_delay(current_wave)

	print("Wave %d: Spawning %d enemies" % [current_wave, enemy_count])

	# Notify game manager
	GameManager.set_wave_enemies(enemy_count)

	# Start spawning
	enemy_spawner.spawn_wave(enemy_count, wave_enemies, spawn_delay)

## Calculate enemy count for wave
func calculate_wave_enemy_count(wave: int) -> int:
	var difficulty = GameManager.get_difficulty_multiplier()
	var base_count = base_enemy_count + (wave - 1) * enemy_count_increase_per_wave
	return int(base_count * difficulty)

## Get enemy types for wave
func get_wave_enemy_types(wave: int) -> Array[PackedScene]:
	# For now, return all available enemy types
	# Later, can configure which enemies appear in which waves
	return enemy_scenes

## Calculate spawn delay between enemies
func calculate_spawn_delay(wave: int) -> float:
	# Faster spawns in later waves
	var base_delay = 2.0
	var min_delay = 0.5
	return max(min_delay, base_delay - (wave * 0.1))

## Wave started (from GameManager)
func _on_wave_started(wave_number: int) -> void:
	prepare_wave(wave_number)

## Wave completed (from GameManager)
func _on_wave_completed(wave_number: int, credits_earned: int) -> void:
	is_wave_active = false
	wave_complete.emit(wave_number)
	print("Wave %d complete!" % wave_number)

## Set enemy scenes
func set_enemy_scenes(scenes: Array[PackedScene]) -> void:
	enemy_scenes = scenes
	print("Wave Manager: %d enemy types configured" % enemy_scenes.size())

## Add enemy scene
func add_enemy_scene(scene: PackedScene) -> void:
	enemy_scenes.append(scene)
