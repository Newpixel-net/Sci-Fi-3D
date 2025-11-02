extends Control
## Pause Menu
##
## In-game pause menu with resume, restart, and quit options.

@export var resume_button: Button
@export var restart_button: Button
@export var main_menu_button: Button
@export var title_label: Label

func _ready() -> void:
	# Create basic menu if buttons not set
	if not resume_button:
		create_basic_menu()

	# Connect buttons
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Connect to game manager
	GameManager.state_changed.connect(_on_game_state_changed)

	# Initially hidden
	visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

## Create basic pause menu UI
func create_basic_menu() -> void:
	# Semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0, 0, 0.7)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Center container
	var center_container = VBoxContainer.new()
	center_container.position = get_viewport_rect().size / 2 - Vector2(150, 150)
	center_container.custom_minimum_size = Vector2(300, 300)
	add_child(center_container)

	# Title
	title_label = Label.new()
	title_label.text = "PAUSED"
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(title_label)

	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 50)
	center_container.add_child(spacer)

	# Resume Button
	resume_button = Button.new()
	resume_button.text = "RESUME"
	resume_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(resume_button)

	# Restart Button
	restart_button = Button.new()
	restart_button.text = "RESTART"
	restart_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(restart_button)

	# Main Menu Button
	main_menu_button = Button.new()
	main_menu_button.text = "MAIN MENU"
	main_menu_button.custom_minimum_size = Vector2(200, 50)
	center_container.add_child(main_menu_button)

## Toggle pause
func toggle_pause() -> void:
	if GameManager.current_state == GameManager.GameState.PLAYING:
		pause_game()
	elif GameManager.current_state == GameManager.GameState.PAUSED:
		resume_game()

## Pause game
func pause_game() -> void:
	GameManager.pause_game()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Resume game
func resume_game() -> void:
	GameManager.resume_game()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Resume button pressed
func _on_resume_pressed() -> void:
	AudioManager.play_ui_click()
	resume_game()

## Restart button pressed
func _on_restart_pressed() -> void:
	AudioManager.play_ui_click()
	GameManager.start_new_game()
	get_tree().reload_current_scene()

## Main menu button pressed
func _on_main_menu_pressed() -> void:
	AudioManager.play_ui_click()
	GameManager.return_to_menu()
	get_tree().change_scene_to_file("res://scenes/main.tscn")

## Handle game state changes
func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.PAUSED:
		visible = true
	else:
		visible = false
