extends Control
## Game Over Screen
##
## Displays final score and options to retry or return to menu.

@export var title_label: Label
@export var score_label: Label
@export var wave_label: Label
@export var high_score_label: Label
@export var retry_button: Button
@export var main_menu_button: Button

var final_score: int = 0
var final_wave: int = 0

func _ready() -> void:
	# Create basic menu if not set
	if not title_label:
		create_basic_menu()

	# Connect buttons
	if retry_button:
		retry_button.pressed.connect(_on_retry_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Connect to game manager
	GameManager.game_over.connect(_on_game_over)

	# Initially hidden
	visible = false

## Create basic game over UI
func create_basic_menu() -> void:
	# Semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0.1, 0, 0, 0.8)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Center container
	var center_container = VBoxContainer.new()
	center_container.position = get_viewport_rect().size / 2 - Vector2(200, 200)
	center_container.custom_minimum_size = Vector2(400, 400)
	add_child(center_container)

	# Title
	title_label = Label.new()
	title_label.text = "GAME OVER"
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color(1, 0.2, 0.2)
	center_container.add_child(title_label)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 40)
	center_container.add_child(spacer1)

	# Score
	score_label = Label.new()
	score_label.text = "FINAL SCORE: 0"
	score_label.add_theme_font_size_override("font_size", 28)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(score_label)

	# Wave
	wave_label = Label.new()
	wave_label.text = "REACHED WAVE: 1"
	wave_label.add_theme_font_size_override("font_size", 24)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(wave_label)

	# High Score
	high_score_label = Label.new()
	high_score_label.text = "HIGH SCORE: 0"
	high_score_label.add_theme_font_size_override("font_size", 20)
	high_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(high_score_label)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	center_container.add_child(spacer2)

	# Retry Button
	retry_button = Button.new()
	retry_button.text = "RETRY"
	retry_button.custom_minimum_size = Vector2(250, 60)
	center_container.add_child(retry_button)

	# Main Menu Button
	main_menu_button = Button.new()
	main_menu_button.text = "MAIN MENU"
	main_menu_button.custom_minimum_size = Vector2(250, 60)
	center_container.add_child(main_menu_button)

## Handle game over
func _on_game_over(score: int, wave: int) -> void:
	final_score = score
	final_wave = wave

	# Update labels
	if score_label:
		score_label.text = "FINAL SCORE: %d" % score

	if wave_label:
		wave_label.text = "REACHED WAVE: %d" % wave

	if high_score_label:
		high_score_label.text = "HIGH SCORE: %d" % GameManager.high_score

		# Check if new high score
		if score >= GameManager.high_score:
			high_score_label.text = "NEW HIGH SCORE: %d!" % score
			high_score_label.modulate = Color(1, 1, 0)

	# Show screen
	visible = true

	# Show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Retry button pressed
func _on_retry_pressed() -> void:
	AudioManager.play_ui_click()
	GameManager.start_new_game()
	visible = false
	get_tree().reload_current_scene()

## Main menu button pressed
func _on_main_menu_pressed() -> void:
	AudioManager.play_ui_click()
	GameManager.return_to_menu()
	get_tree().change_scene_to_file("res://scenes/main.tscn")
