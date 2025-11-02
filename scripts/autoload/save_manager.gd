extends Node
## Save Manager - Handles game data persistence
##
## Manages saving and loading of player progression, settings, and statistics.
## Uses JSON format and stores in user:// directory.

const SAVE_FILE_PATH = "user://save_game.json"
const SETTINGS_FILE_PATH = "user://settings.json"

# Default save data structure
var default_save_data = {
	"high_score": 0,
	"total_enemies_killed": 0,
	"total_games_played": 0,
	"highest_wave_reached": 0,
	"total_credits_earned": 0,
	"upgrades": {},
	"unlocked_weapons": ["pistol"],
	"statistics": {
		"total_playtime": 0.0,
		"shots_fired": 0,
		"shots_hit": 0,
		"headshots": 0
	}
}

# Default settings
var default_settings = {
	"audio": {
		"master_volume": 1.0,
		"music_volume": 0.7,
		"sfx_volume": 0.8
	},
	"graphics": {
		"fullscreen": false,
		"vsync": true,
		"msaa": 2
	},
	"controls": {
		"mouse_sensitivity": 1.0,
		"invert_y": false
	}
}

var save_data: Dictionary = {}
var settings: Dictionary = {}

func _ready() -> void:
	load_save_data()
	load_settings()
	print("SaveManager initialized")

## Load save data from file
func load_save_data() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				save_data = json.get_data()
				print("Save data loaded successfully")
			else:
				print("Error parsing save file: ", json.get_error_message())
				save_data = default_save_data.duplicate(true)
	else:
		print("No save file found, using defaults")
		save_data = default_save_data.duplicate(true)

## Save game data to file
func save_game_data() -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(save_data, "\t")
		file.store_string(json_string)
		file.close()
		print("Game data saved successfully")
	else:
		print("Error: Could not open save file for writing")

## Load settings from file
func load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE_PATH):
		var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()

			var json = JSON.new()
			var parse_result = json.parse(json_string)

			if parse_result == OK:
				settings = json.get_data()
				apply_settings()
				print("Settings loaded successfully")
			else:
				print("Error parsing settings file")
				settings = default_settings.duplicate(true)
	else:
		print("No settings file found, using defaults")
		settings = default_settings.duplicate(true)

## Save settings to file
func save_settings() -> void:
	var file = FileAccess.open(SETTINGS_FILE_PATH, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(settings, "\t")
		file.store_string(json_string)
		file.close()
		apply_settings()
		print("Settings saved successfully")
	else:
		print("Error: Could not open settings file for writing")

## Apply current settings to engine
func apply_settings() -> void:
	# Audio
	AudioServer.set_bus_volume_db(0, linear_to_db(settings.audio.master_volume))

	# Graphics
	if settings.graphics.fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if settings.graphics.vsync else DisplayServer.VSYNC_DISABLED
	)

## Get high score
func load_high_score() -> int:
	return save_data.get("high_score", 0)

## Save high score
func save_high_score(score: int) -> void:
	save_data["high_score"] = score
	save_game_data()

## Save game statistics
func save_game_stats(wave: int, score: int, enemies_killed: int) -> void:
	save_data["total_games_played"] += 1
	save_data["total_enemies_killed"] += enemies_killed
	save_data["total_credits_earned"] += score

	if wave > save_data.get("highest_wave_reached", 0):
		save_data["highest_wave_reached"] = wave

	save_game_data()

## Get upgrade level
func get_upgrade_level(upgrade_name: String) -> int:
	return save_data.upgrades.get(upgrade_name, 0)

## Set upgrade level
func set_upgrade_level(upgrade_name: String, level: int) -> void:
	save_data.upgrades[upgrade_name] = level
	save_game_data()

## Check if weapon is unlocked
func is_weapon_unlocked(weapon_name: String) -> bool:
	return weapon_name in save_data.unlocked_weapons

## Unlock weapon
func unlock_weapon(weapon_name: String) -> void:
	if not is_weapon_unlocked(weapon_name):
		save_data.unlocked_weapons.append(weapon_name)
		save_game_data()

## Update statistics
func update_stat(stat_name: String, value: int) -> void:
	if stat_name in save_data.statistics:
		save_data.statistics[stat_name] += value
	else:
		save_data.statistics[stat_name] = value

## Get statistic
func get_stat(stat_name: String) -> int:
	return save_data.statistics.get(stat_name, 0)

## Reset all save data (for debugging)
func reset_save_data() -> void:
	save_data = default_save_data.duplicate(true)
	save_game_data()
	print("Save data reset to defaults")
