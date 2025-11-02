extends Control
## Wave Complete Screen
##
## Shows wave completion stats and option to continue or upgrade.

@export var title_label: Label
@export var wave_label: Label
@export var credits_earned_label: Label
@export var continue_button: Button
@export var upgrade_button: Button

func _ready() -> void:
	# Create basic UI if not set
	if not title_label:
		create_basic_ui()

	# Connect buttons
	if continue_button:
		continue_button.pressed.connect(_on_continue_pressed)
	if upgrade_button:
		upgrade_button.pressed.connect(_on_upgrade_pressed)

	# Connect to game manager
	GameManager.wave_completed.connect(_on_wave_completed)

	# Initially hidden
	visible = false

## Create basic UI
func create_basic_ui() -> void:
	# Semi-transparent background
	var background = ColorRect.new()
	background.color = Color(0, 0.2, 0, 0.7)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)

	# Center container
	var center_container = VBoxContainer.new()
	center_container.position = get_viewport_rect().size / 2 - Vector2(200, 150)
	center_container.custom_minimum_size = Vector2(400, 300)
	add_child(center_container)

	# Title
	title_label = Label.new()
	title_label.text = "WAVE COMPLETE!"
	title_label.add_theme_font_size_override("font_size", 48)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.modulate = Color(0.5, 1, 0.5)
	center_container.add_child(title_label)

	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 30)
	center_container.add_child(spacer1)

	# Wave number
	wave_label = Label.new()
	wave_label.text = "Wave 1 Complete"
	wave_label.add_theme_font_size_override("font_size", 24)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(wave_label)

	# Credits earned
	credits_earned_label = Label.new()
	credits_earned_label.text = "Credits Earned: +100"
	credits_earned_label.add_theme_font_size_override("font_size", 20)
	credits_earned_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	center_container.add_child(credits_earned_label)

	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 30)
	center_container.add_child(spacer2)

	# Continue Button
	continue_button = Button.new()
	continue_button.text = "CONTINUE TO NEXT WAVE"
	continue_button.custom_minimum_size = Vector2(300, 60)
	center_container.add_child(continue_button)

	# Upgrade Button
	upgrade_button = Button.new()
	upgrade_button.text = "UPGRADE SHOP"
	upgrade_button.custom_minimum_size = Vector2(300, 60)
	center_container.add_child(upgrade_button)

## Handle wave completed
func _on_wave_completed(wave_number: int, credits_earned: int) -> void:
	# Update labels
	if wave_label:
		wave_label.text = "Wave %d Complete" % wave_number

	if credits_earned_label:
		credits_earned_label.text = "Credits Earned: +%d" % credits_earned

	# Show screen
	visible = true

	# Show mouse
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

## Continue to next wave
func _on_continue_pressed() -> void:
	AudioManager.play_ui_click()
	visible = false
	GameManager.continue_to_next_wave()

	# Capture mouse again
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

## Open upgrade shop
func _on_upgrade_pressed() -> void:
	AudioManager.play_ui_click()
	visible = false
	GameManager.open_upgrade_shop()
	# TODO: Show upgrade shop UI
