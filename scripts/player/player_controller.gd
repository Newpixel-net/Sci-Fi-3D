extends CharacterBody3D
## Player Controller - Main player movement and input handling
##
## Handles WASD movement, mouse look, camera control, and physics.
## Integrates with InputManager for multi-platform support.

# Movement parameters
@export var move_speed: float = 7.0
@export var sprint_speed: float = 10.0
@export var acceleration: float = 20.0
@export var deceleration: float = 25.0
@export var air_acceleration: float = 5.0
@export var jump_velocity: float = 6.0

# Rotation parameters
@export var rotation_speed: float = 10.0

# Camera parameters
@export var camera_distance: float = 5.0
@export var camera_height: float = 2.0
@export var camera_sensitivity: float = 0.003

# Weapon attachment point
@export var weapon_attachment: Node3D

# Components
var camera_pivot: Node3D
var camera: Camera3D
var spring_arm: SpringArm3D

# State
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var is_alive: bool = true
var current_weapon = null

# Camera rotation
var camera_rotation_x: float = 0.0
var camera_rotation_y: float = 0.0

# Damage feedback
var damage_shake_amount: float = 0.0

func _ready() -> void:
	setup_camera()
	setup_weapon_attachment()

	# Connect to game manager
	GameManager.player_died.connect(_on_player_died)

	# Capture mouse for desktop
	if not InputManager.is_touch_mode():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	# Set collision layer (layer 2 = Player)
	collision_layer = 2
	collision_mask = 1 | 4  # Collide with Environment (1) and Projectiles (4)

	print("Player controller ready")

func _input(event: InputEvent) -> void:
	# Mouse look (desktop only)
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_camera_mouse(event.relative)

	# Release mouse with ESC (for testing)
	if event.is_action_pressed("ui_cancel") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Handle camera rotation (gamepad/touch)
	if InputManager.current_input_mode != InputManager.InputMode.KEYBOARD_MOUSE:
		var look_input = InputManager.get_look_input(delta)
		rotate_camera_input(look_input)

	# Get movement input
	var input_dir = InputManager.get_movement_input()

	# Calculate movement direction relative to camera
	var move_dir = calculate_move_direction(input_dir)

	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle jumping (disabled for now - not in design)
	# if is_on_floor() and Input.is_action_just_pressed("jump"):
	#     velocity.y = jump_velocity

	# Calculate target velocity
	var target_velocity = move_dir * move_speed

	# Accelerate/decelerate
	var accel = acceleration if is_on_floor() else air_acceleration
	if move_dir.length() > 0:
		velocity.x = move_toward(velocity.x, target_velocity.x, accel * delta)
		velocity.z = move_toward(velocity.z, target_velocity.z, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		velocity.z = move_toward(velocity.z, 0, deceleration * delta)

	# Rotate player to face movement direction
	if move_dir.length() > 0.1:
		var target_rotation = atan2(move_dir.x, move_dir.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, rotation_speed * delta)

	# Move
	move_and_slide()

	# Update camera
	update_camera(delta)

	# Handle weapon input
	handle_weapon_input()

## Setup camera system
func setup_camera() -> void:
	# Create camera pivot (follows player at offset)
	camera_pivot = Node3D.new()
	camera_pivot.name = "CameraPivot"
	add_child(camera_pivot)
	camera_pivot.position = Vector3(0, camera_height, 0)

	# Create spring arm for collision detection
	spring_arm = SpringArm3D.new()
	spring_arm.name = "SpringArm"
	spring_arm.spring_length = camera_distance
	spring_arm.collision_mask = 1  # Only collide with environment
	camera_pivot.add_child(spring_arm)

	# Create camera
	camera = Camera3D.new()
	camera.name = "Camera"
	camera.current = true
	spring_arm.add_child(camera)

	# Initial camera angle
	camera_rotation_x = -20.0  # Look down slightly
	camera_pivot.rotation_degrees.x = camera_rotation_x

## Setup weapon attachment point
func setup_weapon_attachment() -> void:
	if not weapon_attachment:
		weapon_attachment = Node3D.new()
		weapon_attachment.name = "WeaponAttachment"
		add_child(weapon_attachment)
		weapon_attachment.position = Vector3(0.3, 1.5, 0.5)  # Right hand position

## Calculate movement direction relative to camera
func calculate_move_direction(input_dir: Vector2) -> Vector3:
	if input_dir.length() < 0.01:
		return Vector3.ZERO

	# Get camera forward direction (flattened to XZ plane)
	var camera_forward = -camera_pivot.global_transform.basis.z
	camera_forward.y = 0
	camera_forward = camera_forward.normalized()

	var camera_right = camera_pivot.global_transform.basis.x
	camera_right.y = 0
	camera_right = camera_right.normalized()

	# Calculate movement direction
	var move_dir = (camera_right * input_dir.x + camera_forward * -input_dir.y).normalized()
	return move_dir

## Rotate camera with mouse
func rotate_camera_mouse(relative: Vector2) -> void:
	var sensitivity = InputManager.get_mouse_sensitivity() * camera_sensitivity

	camera_rotation_y -= relative.x * sensitivity
	camera_rotation_x -= relative.y * sensitivity

	# Clamp vertical rotation
	camera_rotation_x = clamp(camera_rotation_x, -80.0, 20.0)

	# Apply rotation
	camera_pivot.rotation.x = deg_to_rad(camera_rotation_x)
	camera_pivot.rotation.y = deg_to_rad(camera_rotation_y)

## Rotate camera with input (gamepad/touch)
func rotate_camera_input(look_input: Vector2) -> void:
	camera_rotation_y -= look_input.x * 50.0
	camera_rotation_x -= look_input.y * 50.0

	# Clamp vertical rotation
	camera_rotation_x = clamp(camera_rotation_x, -80.0, 20.0)

	# Apply rotation
	camera_pivot.rotation.x = deg_to_rad(camera_rotation_x)
	camera_pivot.rotation.y = deg_to_rad(camera_rotation_y)

## Update camera (smoothing, shake, etc.)
func update_camera(delta: float) -> void:
	# Apply damage shake
	if damage_shake_amount > 0:
		camera.position = Vector3(
			randf_range(-damage_shake_amount, damage_shake_amount),
			randf_range(-damage_shake_amount, damage_shake_amount),
			0
		)
		damage_shake_amount = lerp(damage_shake_amount, 0.0, 5.0 * delta)
	else:
		camera.position = Vector3.ZERO

## Handle weapon input
func handle_weapon_input() -> void:
	# Weapon switching
	var weapon_switch = InputManager.get_weapon_switch_input()
	if weapon_switch > 0 and current_weapon:
		current_weapon.switch_weapon(weapon_switch - 1)

	# Shooting
	if InputManager.is_shoot_pressed() and current_weapon:
		current_weapon.try_shoot()

	# Reloading
	if InputManager.is_reload_pressed() and current_weapon:
		current_weapon.reload()

## Take damage
func take_damage(amount: float, from_position: Vector3 = Vector3.ZERO) -> void:
	if not is_alive:
		return

	# Apply damage shake
	damage_shake_amount = 0.1

	# Delegate to health component
	var health_component = get_node_or_null("PlayerHealth")
	if health_component and health_component.has_method("take_damage"):
		health_component.take_damage(amount)

## Get camera for aiming
func get_camera() -> Camera3D:
	return camera

## Get aim direction
func get_aim_direction() -> Vector3:
	if camera:
		return -camera.global_transform.basis.z
	return global_transform.basis.z

## Get aim position (raycast from camera)
func get_aim_position() -> Vector3:
	if not camera:
		return global_position + global_transform.basis.z * 100

	var space_state = get_world_3d().direct_space_state
	var screen_center = get_viewport().get_visible_rect().size / 2
	var from = camera.project_ray_origin(screen_center)
	var to = from + camera.project_ray_normal(screen_center) * 1000

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 | 4  # Environment and enemies
	var result = space_state.intersect_ray(query)

	if result:
		return result.position
	return to

## Set weapon
func set_weapon(weapon: Node) -> void:
	current_weapon = weapon

## Player died
func _on_player_died() -> void:
	is_alive = false
	# Could add death animation here
	print("Player died!")

## Respawn player
func respawn(spawn_position: Vector3) -> void:
	global_position = spawn_position
	velocity = Vector3.ZERO
	is_alive = true
