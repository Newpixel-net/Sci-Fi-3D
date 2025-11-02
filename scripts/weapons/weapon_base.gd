extends Node3D
## Base Weapon Class
##
## Handles shooting, reloading, ammo management, and visual effects.
## Uses WeaponData resource for configuration.

signal ammo_changed(current_ammo: int, reserve_ammo: int)
signal weapon_fired()
signal reload_started()
signal reload_completed()

@export var weapon_data: WeaponData

# Ammo state
var current_ammo: int = 0
var reserve_ammo: int = 0
var is_reloading: bool = false

# Fire rate control
var time_since_last_shot: float = 0.0
var can_shoot: bool = true

# Spread/accuracy
var current_spread: float = 0.0

# Components (to be set in scene)
@export var muzzle_point: Marker3D
@export var muzzle_flash: GPUParticles3D

# Projectile scene
var projectile_scene: PackedScene

func _ready() -> void:
	if weapon_data:
		initialize_weapon()

func _process(delta: float) -> void:
	# Recover from fire rate cooldown
	if time_since_last_shot > 0:
		time_since_last_shot -= delta
		if time_since_last_shot <= 0:
			can_shoot = true

	# Recover accuracy
	if current_spread > weapon_data.base_spread:
		current_spread = max(weapon_data.base_spread, current_spread - weapon_data.spread_recovery_rate * delta)

## Initialize weapon with data
func initialize_weapon() -> void:
	current_ammo = weapon_data.magazine_size
	reserve_ammo = weapon_data.max_ammo

	# Setup muzzle point if not set
	if not muzzle_point:
		muzzle_point = Marker3D.new()
		muzzle_point.name = "MuzzlePoint"
		add_child(muzzle_point)
		muzzle_point.position = Vector3(0, 0, -0.5)  # Forward

	ammo_changed.emit(current_ammo, reserve_ammo)
	print("Weapon initialized: %s (%d/%d)" % [weapon_data.weapon_name, current_ammo, reserve_ammo])

## Try to shoot (called from player input)
func try_shoot() -> bool:
	if not can_shoot or is_reloading:
		return false

	# Check if auto fire
	if not weapon_data.auto_fire:
		# For semi-auto, handled by input_just_pressed
		pass

	# Check ammo
	if current_ammo <= 0:
		# Play empty sound
		AudioManager.play_ui_click()  # Placeholder
		return false

	# Shoot
	shoot()
	return true

## Shoot weapon
func shoot() -> void:
	if not weapon_data:
		return

	# Consume ammo
	if not weapon_data.unlimited_ammo:
		current_ammo -= 1
		ammo_changed.emit(current_ammo, reserve_ammo)

	# Fire rate cooldown
	can_shoot = false
	time_since_last_shot = 1.0 / weapon_data.fire_rate

	# Increase spread
	current_spread = min(weapon_data.max_spread, current_spread + weapon_data.spread_increase_per_shot)

	# Calculate shot direction with spread
	var shoot_direction = calculate_shoot_direction()

	# Spawn projectile or raycast
	if weapon_data.is_hitscan:
		perform_hitscan(shoot_direction)
	else:
		spawn_projectile(shoot_direction)

	# Visual effects
	play_muzzle_flash()

	# Audio
	play_shoot_sound()

	# Emit signal
	weapon_fired.emit()

	print("Shot fired! Ammo: %d/%d" % [current_ammo, reserve_ammo])

## Calculate shoot direction with spread
func calculate_shoot_direction() -> Vector3:
	# Get base direction from player camera
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("get_aim_direction"):
		var base_direction = player.get_aim_direction()

		# Apply spread
		var spread_x = randf_range(-current_spread, current_spread)
		var spread_y = randf_range(-current_spread, current_spread)

		# Create rotation for spread
		var spread_rotation = Basis()
		spread_rotation = spread_rotation.rotated(Vector3.RIGHT, spread_y)
		spread_rotation = spread_rotation.rotated(Vector3.UP, spread_x)

		return spread_rotation * base_direction
	else:
		# Fallback
		return -global_transform.basis.z

## Perform hitscan (instant hit)
func perform_hitscan(direction: Vector3) -> void:
	var from = muzzle_point.global_position if muzzle_point else global_position
	var to = from + direction * 1000.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1 | 4  # Environment and Enemies

	var result = space_state.intersect_ray(query)

	if result:
		var hit_position = result.position
		var hit_normal = result.normal
		var collider = result.collider

		# Apply damage
		apply_hit_damage(collider, hit_position)

		# Spawn impact effect
		spawn_impact_effect(hit_position, hit_normal)

## Spawn projectile (ballistic)
func spawn_projectile(direction: Vector3) -> void:
	# Will implement with object pooling later
	print("Spawning projectile in direction: %s" % direction)

	# For now, perform a delayed hitscan to simulate projectile travel
	perform_hitscan(direction)

## Apply damage to hit object
func apply_hit_damage(collider: Object, hit_position: Vector3) -> void:
	if collider.has_method("take_damage"):
		var damage = weapon_data.base_damage
		# Could check for headshot here
		collider.take_damage(damage)
		print("Hit %s for %d damage" % [collider.name, damage])

## Spawn impact effect
func spawn_impact_effect(position: Vector3, normal: Vector3) -> void:
	# Play impact sound
	AudioManager.play_impact(position)
	# Spawn visual effect (will implement later)

## Play muzzle flash
func play_muzzle_flash() -> void:
	if muzzle_flash and weapon_data.muzzle_flash_enabled:
		muzzle_flash.restart()

## Play shoot sound
func play_shoot_sound() -> void:
	AudioManager.play_weapon_shot(weapon_data.weapon_type, global_position)

## Reload weapon
func reload() -> void:
	if is_reloading:
		return

	# Check if already full
	if current_ammo >= weapon_data.magazine_size:
		return

	# Check if have reserve ammo
	if reserve_ammo <= 0 and not weapon_data.unlimited_ammo:
		return

	is_reloading = true
	reload_started.emit()

	print("Reloading %s..." % weapon_data.weapon_name)

	# Wait for reload time
	await get_tree().create_timer(weapon_data.reload_time).timeout

	# Perform reload
	if weapon_data.unlimited_ammo:
		current_ammo = weapon_data.magazine_size
	else:
		var ammo_needed = weapon_data.magazine_size - current_ammo
		var ammo_to_reload = min(ammo_needed, reserve_ammo)

		current_ammo += ammo_to_reload
		reserve_ammo -= ammo_to_reload

	is_reloading = false
	ammo_changed.emit(current_ammo, reserve_ammo)
	reload_completed.emit()

	print("Reload complete! Ammo: %d/%d" % [current_ammo, reserve_ammo])

## Add ammo to reserve
func add_ammo(amount: int) -> void:
	reserve_ammo = min(reserve_ammo + amount, weapon_data.max_ammo)
	ammo_changed.emit(current_ammo, reserve_ammo)

## Get ammo percentage
func get_ammo_percentage() -> float:
	return float(current_ammo) / float(weapon_data.magazine_size) if weapon_data.magazine_size > 0 else 0.0
