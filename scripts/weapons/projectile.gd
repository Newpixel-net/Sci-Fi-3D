extends Area3D
## Projectile - Moving bullet/projectile
##
## Handles ballistic projectiles with collision detection and damage.

var velocity: Vector3 = Vector3.ZERO
var damage: float = 10.0
var lifetime: float = 5.0
var source: Node3D = null  # Who shot this

var time_alive: float = 0.0

func _ready() -> void:
	# Set collision layers
	collision_layer = 8  # Projectile layer
	collision_mask = 1 | 4  # Collide with Environment and Enemies

	# Connect collision
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	# Move projectile
	global_position += velocity * delta

	# Track lifetime
	time_alive += delta
	if time_alive >= lifetime:
		queue_free()

## Initialize projectile
func initialize(start_position: Vector3, direction: Vector3, speed: float, projectile_damage: float, projectile_lifetime: float) -> void:
	global_position = start_position
	velocity = direction.normalized() * speed
	damage = projectile_damage
	lifetime = projectile_lifetime

	# Rotate to face direction
	look_at(global_position + direction, Vector3.UP)

## Handle collision with body
func _on_body_entered(body: Node3D) -> void:
	# Don't hit source
	if body == source:
		return

	# Apply damage if possible
	if body.has_method("take_damage"):
		body.take_damage(damage)

	# Spawn impact effect
	spawn_impact_effect(global_position)

	# Destroy projectile
	queue_free()

## Handle collision with area
func _on_area_entered(area: Area3D) -> void:
	# Similar to body collision
	if area == source or area.get_parent() == source:
		return

	var parent = area.get_parent()
	if parent and parent.has_method("take_damage"):
		parent.take_damage(damage)

	spawn_impact_effect(global_position)
	queue_free()

## Spawn impact effect
func spawn_impact_effect(position: Vector3) -> void:
	AudioManager.play_impact(position)
	# Will add visual effect later
