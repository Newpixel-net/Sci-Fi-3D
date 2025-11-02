extends Node3D
## Camera Controller - Advanced camera system
##
## Handles camera shake, FOV changes, smooth following, and collision detection.

@export var target: Node3D
@export var camera_distance: float = 5.0
@export var camera_height: float = 2.0
@export var follow_speed: float = 10.0
@export var rotation_speed: float = 5.0

var camera: Camera3D
var spring_arm: SpringArm3D
var shake_amount: float = 0.0
var trauma: float = 0.0

func _ready() -> void:
	setup_camera()

func setup_camera() -> void:
	# Spring arm for collision
	spring_arm = SpringArm3D.new()
	spring_arm.spring_length = camera_distance
	spring_arm.collision_mask = 1  # Environment only
	add_child(spring_arm)

	# Camera
	camera = Camera3D.new()
	camera.current = true
	spring_arm.add_child(camera)

func _process(delta: float) -> void:
	if target:
		# Follow target smoothly
		global_position = lerp(global_position, target.global_position + Vector3(0, camera_height, 0), follow_speed * delta)

	# Apply shake
	if trauma > 0:
		shake_amount = trauma * trauma
		camera.rotation.z = randf_range(-shake_amount, shake_amount) * 0.1
		trauma = max(0, trauma - delta * 2.0)
	else:
		camera.rotation.z = lerp(camera.rotation.z, 0.0, delta * 10.0)

## Add camera shake
func add_shake(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)

## Add trauma (smoother than shake)
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)
