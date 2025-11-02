extends Node3D
## Enemy Spawner - Spawns enemies at designated spawn points
##
## Manages enemy spawning with configurable spawn rates and enemy types.

signal enemy_spawned(enemy: Node3D)
signal all_enemies_spawned()

@export var spawn_points: Array[Marker3D] = []
@export var enemy_scenes: Array[PackedScene] = []

var enemies_to_spawn: int = 0
var enemies_spawned: int = 0
var spawn_delay: float = 1.0
var is_spawning: bool = false

func _ready() -> void:
	# Find all spawn points if not set
	if spawn_points.is_empty():
		for child in get_children():
			if child is Marker3D:
				spawn_points.append(child)

	print("Enemy Spawner ready with %d spawn points" % spawn_points.size())

## Start spawning wave
func spawn_wave(enemy_count: int, enemy_types: Array[PackedScene], delay_between_spawns: float = 1.0) -> void:
	if is_spawning:
		return

	enemies_to_spawn = enemy_count
	enemies_spawned = 0
	spawn_delay = delay_between_spawns
	enemy_scenes = enemy_types
	is_spawning = true

	print("Starting spawn wave: %d enemies" % enemy_count)

	_spawn_next_enemy()

## Spawn next enemy
func _spawn_next_enemy() -> void:
	if enemies_spawned >= enemies_to_spawn:
		is_spawning = false
		all_enemies_spawned.emit()
		print("All enemies spawned!")
		return

	# Pick random enemy type
	if enemy_scenes.is_empty():
		print("Error: No enemy scenes configured!")
		return

	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]

	# Pick random spawn point
	if spawn_points.is_empty():
		print("Error: No spawn points!")
		return

	var spawn_point = spawn_points[randi() % spawn_points.size()]

	# Spawn enemy
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_point.global_position

	enemies_spawned += 1
	enemy_spawned.emit(enemy)

	print("Spawned enemy %d/%d at %s" % [enemies_spawned, enemies_to_spawn, spawn_point.name])

	# Schedule next spawn
	if enemies_spawned < enemies_to_spawn:
		await get_tree().create_timer(spawn_delay).timeout
		_spawn_next_enemy()

## Spawn single enemy
func spawn_enemy(enemy_scene: PackedScene, spawn_point_index: int = -1) -> Node3D:
	if spawn_points.is_empty():
		print("Error: No spawn points!")
		return null

	# Pick spawn point
	var spawn_point: Marker3D
	if spawn_point_index >= 0 and spawn_point_index < spawn_points.size():
		spawn_point = spawn_points[spawn_point_index]
	else:
		spawn_point = spawn_points[randi() % spawn_points.size()]

	# Spawn enemy
	var enemy = enemy_scene.instantiate()
	get_parent().add_child(enemy)
	enemy.global_position = spawn_point.global_position

	enemy_spawned.emit(enemy)
	return enemy

## Clear all enemies
func clear_all_enemies() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		enemy.queue_free()

	print("Cleared all enemies")

## Stop spawning
func stop_spawning() -> void:
	is_spawning = false
