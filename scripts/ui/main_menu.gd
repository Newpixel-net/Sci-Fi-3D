extends Control
## Main Menu
##
## Game's main menu with start game, settings, and quit options.

@export var start_button: Button
@export var settings_button: Button
@export var quit_button: Button
@export var title_label: Label
@export var high_score_label: Label

func _ready() -> void:
	# Create basic menu if buttons not set
	if not start_button:
		create_basic_menu()

	# Connect buttons
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

	# Update high score
	if high_score_label:
		high_score_label.text = "HIGH SCORE: %d" % GameManager.high_score

	# Show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Create basic menu UI
func create_basic_menu() -> void:
	# Center container
	var center_container = VBoxContainer.new()
	center_container.position = get_viewport_rect().size / 2 - Vector2(150, 200)
	center_container.custom_minimum_size = Vector2(300, 400)
	add_child(center_container)

	# Title
	title_label = Label.new()
	title_label.text = "SECTOR DEFENSE"
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(title_label)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 50)
	center_container.add_child(spacer1)

	# High Score
	high_score_label = Label.new()
	high_score_label.text = "HIGH SCORE: 0"
	high_score_label.add_theme_font_size_override("font_size", 20)
	high_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(high_score_label)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	center_container.add_child(spacer2)

	# Start Button
	start_button = Button.new()
	start_button.text = "START GAME"
	start_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(start_button)

	# Settings Button
	settings_button = Button.new()
	settings_button.text = "SETTINGS"
	settings_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(settings_button)

	# Quit Button
	quit_button = Button.new()
	quit_button.text = "QUIT"
	quit_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(quit_button)

	# Instructions
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 30)
	center_container.add_child(spacer3)

	var instructions = Label.new()
	instructions.text = "Controls:\nWASD - Move\nMouse - Aim\nLeft Click - Shoot\nR - Reload\n1-3 - Switch Weapons"
	instructions.add_theme_font_size_override("font_size", 14)
	instructions.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(instructions)

## Start game
func _on_start_pressed() -> void:
	AudioManager.play_ui_click()
	print("Starting game...")

	# Load game scene
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")

## Open settings
func _on_settings_pressed() -> void:
	AudioManager.play_ui_click()
	print("Settings not implemented yet")
	# TODO: Open settings menu

## Quit game
func _on_quit_pressed() -> void:
	AudioManager.play_ui_click()
	print("Quitting game...")
	get_tree().quit()
