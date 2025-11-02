extends Node
## Input Manager - Multi-platform input abstraction
##
## Handles input from keyboard/mouse, gamepad, and touch screens.
## Provides unified input API for all platforms.

signal input_mode_changed(mode: InputMode)

enum InputMode {
	KEYBOARD_MOUSE,
	GAMEPAD,
	TOUCH
}

var current_input_mode: InputMode = InputMode.KEYBOARD_MOUSE
var mouse_sensitivity: float = 1.0
var gamepad_sensitivity: float = 2.0
var touch_sensitivity: float = 1.5

# Touch input tracking
var touch_positions: Dictionary = {}
var virtual_joystick_active: bool = false
var virtual_joystick_center: Vector2 = Vector2.ZERO
var virtual_joystick_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Detect initial input mode
	if DisplayServer.get_name() == "Android" or DisplayServer.get_name() == "iOS":
		set_input_mode(InputMode.TOUCH)
	else:
		set_input_mode(InputMode.KEYBOARD_MOUSE)

	print("InputManager initialized - Mode: %s" % InputMode.keys()[current_input_mode])

func _input(event: InputEvent) -> void:
	# Auto-detect input mode changes
	if event is InputEventKey or event is InputEventMouse:
		if current_input_mode != InputMode.KEYBOARD_MOUSE:
			set_input_mode(InputMode.KEYBOARD_MOUSE)
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		if current_input_mode != InputMode.GAMEPAD:
			set_input_mode(InputMode.GAMEPAD)
	elif event is InputEventScreenTouch or event is InputEventScreenDrag:
		if current_input_mode != InputMode.TOUCH:
			set_input_mode(InputMode.TOUCH)

## Set input mode
func set_input_mode(mode: InputMode) -> void:
	if current_input_mode != mode:
		current_input_mode = mode
		input_mode_changed.emit(mode)
		print("Input mode changed to: %s" % InputMode.keys()[mode])

## Get movement input (normalized 2D vector)
func get_movement_input() -> Vector2:
	match current_input_mode:
		InputMode.KEYBOARD_MOUSE:
			return _get_keyboard_movement()
		InputMode.GAMEPAD:
			return _get_gamepad_movement()
		InputMode.TOUCH:
			return _get_touch_movement()
	return Vector2.ZERO

## Get look input (delta for camera rotation)
func get_look_input(delta: float) -> Vector2:
	match current_input_mode:
		InputMode.KEYBOARD_MOUSE:
			return Vector2.ZERO  # Mouse motion handled separately
		InputMode.GAMEPAD:
			return _get_gamepad_look() * delta * gamepad_sensitivity
		InputMode.TOUCH:
			return _get_touch_look() * delta * touch_sensitivity
	return Vector2.ZERO

## Check if shoot button is pressed
func is_shoot_pressed() -> bool:
	match current_input_mode:
		InputMode.KEYBOARD_MOUSE, InputMode.GAMEPAD:
			return Input.is_action_pressed("shoot")
		InputMode.TOUCH:
			return _is_touch_shoot_pressed()
	return false

## Check if shoot button was just pressed
func is_shoot_just_pressed() -> bool:
	match current_input_mode:
		InputMode.KEYBOARD_MOUSE, InputMode.GAMEPAD:
			return Input.is_action_just_pressed("shoot")
		InputMode.TOUCH:
			return _is_touch_shoot_just_pressed()
	return false

## Check if reload button was pressed
func is_reload_pressed() -> bool:
	return Input.is_action_just_pressed("reload")

## Check if pause button was pressed
func is_pause_pressed() -> bool:
	return Input.is_action_just_pressed("pause")

## Get weapon switch input (1-3 or 0 if none)
func get_weapon_switch_input() -> int:
	if Input.is_action_just_pressed("weapon_1"):
		return 1
	elif Input.is_action_just_pressed("weapon_2"):
		return 2
	elif Input.is_action_just_pressed("weapon_3"):
		return 3
	return 0

## Keyboard movement
func _get_keyboard_movement() -> Vector2:
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_axis("move_left", "move_right")
	input_dir.y = Input.get_axis("move_forward", "move_backward")
	return input_dir.normalized() if input_dir.length() > 0.1 else Vector2.ZERO

## Gamepad movement
func _get_gamepad_movement() -> Vector2:
	var input_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
		Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
	)
	# Apply deadzone
	if input_dir.length() < 0.2:
		return Vector2.ZERO
	return input_dir.normalized()

## Gamepad look
func _get_gamepad_look() -> Vector2:
	var look_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)
	# Apply deadzone
	if look_dir.length() < 0.2:
		return Vector2.ZERO
	return look_dir

## Touch movement (from virtual joystick)
func _get_touch_movement() -> Vector2:
	if virtual_joystick_active:
		return virtual_joystick_direction
	return Vector2.ZERO

## Touch look (from touch drag)
func _get_touch_look() -> Vector2:
	# This would be set by the touch handler in the UI
	return Vector2.ZERO

## Touch shoot check
func _is_touch_shoot_pressed() -> bool:
	# This would be set by the shoot button in the UI
	return false

func _is_touch_shoot_just_pressed() -> bool:
	return false

## Set mouse sensitivity
func set_mouse_sensitivity(sensitivity: float) -> void:
	mouse_sensitivity = clamp(sensitivity, 0.1, 3.0)

## Set gamepad sensitivity
func set_gamepad_sensitivity(sensitivity: float) -> void:
	gamepad_sensitivity = clamp(sensitivity, 0.5, 5.0)

## Set touch sensitivity
func set_touch_sensitivity(sensitivity: float) -> void:
	touch_sensitivity = clamp(sensitivity, 0.5, 5.0)

## Virtual joystick control (called from UI)
func set_virtual_joystick(active: bool, direction: Vector2 = Vector2.ZERO) -> void:
	virtual_joystick_active = active
	virtual_joystick_direction = direction.normalized() if direction.length() > 0.1 else Vector2.ZERO

## Get mouse sensitivity
func get_mouse_sensitivity() -> float:
	return mouse_sensitivity

## Check if using touch input
func is_touch_mode() -> bool:
	return current_input_mode == InputMode.TOUCH
