extends Node3D
## Game Initialization Script
##
## Initializes the game scene, loads enemy prefabs, and starts the first wave.

@onready var wave_manager = $WaveManager
@onready var player = $Player
@onready var weapon_manager = $Player/WeaponAttachment/WeaponManager
@onready var enemy_spawner = $EnemySpawner

# Enemy scene paths
var enemy_scenes: Array[PackedScene] = []

func _ready() -> void:
	print("Game scene initializing...")

	# Load enemy scenes
	load_enemy_scenes()

	# Configure wave manager
	if wave_manager:
		# Manually set the enemy spawner reference
		if enemy_spawner:
			wave_manager.enemy_spawner = enemy_spawner
			print("Enemy spawner connected to wave manager")
		wave_manager.set_enemy_scenes(enemy_scenes)
		print("Wave manager configured with %d enemy types" % enemy_scenes.size())

	# Setup weapon manager
	if weapon_manager:
		# Properly type the weapons array as Array[Node3D]
		var weapon_nodes: Array[Node3D] = []
		for child in weapon_manager.get_children():
			if child is Node3D:
				weapon_nodes.append(child)
		weapon_manager.weapons = weapon_nodes
		weapon_manager.switch_weapon(0)
		print("Weapon manager initialized with %d weapons" % weapon_manager.weapons.size())

	# Connect player to weapon manager
	if player and weapon_manager:
		player.set_weapon(weapon_manager)
		print("Player connected to weapon manager")

	# Wait a frame then start the game
	await get_tree().process_frame
	start_game()

## Load enemy scene prefabs
func load_enemy_scenes() -> void:
	var scout = load("res://scenes/game/enemies/scout_robot.tscn")
	var soldier = load("res://scenes/game/enemies/soldier_robot.tscn")
	var heavy = load("res://scenes/game/enemies/heavy_robot.tscn")

	if scout:
		enemy_scenes.append(scout)
		print("Loaded Scout enemy")
	if soldier:
		enemy_scenes.append(soldier)
		print("Loaded Soldier enemy")
	if heavy:
		enemy_scenes.append(heavy)
		print("Loaded Heavy enemy")

## Start the game
func start_game() -> void:
	print("Starting game...")
	GameManager.start_new_game()
