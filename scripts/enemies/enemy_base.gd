extends CharacterBody3D
## Enemy Base Class
##
## Base enemy with AI, health, combat, and pathfinding using NavigationAgent3D.

signal died(enemy_type: String, credit_value: int)
signal health_changed(current_health: float, max_health: float)

enum State {
	IDLE,
	CHASE,
	ATTACK,
	RETREAT,
	DEAD
}

@export var enemy_data: EnemyData

# Components
var nav_agent: NavigationAgent3D
var attack_timer: Timer

# State
var current_state: State = State.IDLE
var current_health: float = 100.0
var target: Node3D = null
var can_attack: bool = true

# Physics
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready() -> void:
	if enemy_data:
		initialize_enemy()

	setup_navigation()
	setup_timers()

	# Set collision layers (layer 3 = Enemies)
	collision_layer = 4
	collision_mask = 1 | 2  # Collide with Environment and Player

	# Find player
	call_deferred("find_player")

	# Add to enemy group
	add_to_group("enemies")

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Update AI
	update_ai(delta)

	# Move
	move_and_slide()

## Initialize enemy with data
func initialize_enemy() -> void:
	current_health = enemy_data.max_health
	health_changed.emit(current_health, enemy_data.max_health)

	print("Enemy initialized: %s (Health: %d)" % [enemy_data.enemy_name, current_health])

## Setup navigation
func setup_navigation() -> void:
	nav_agent = NavigationAgent3D.new()
	add_child(nav_agent)

	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = 0.5
	nav_agent.radius = 0.5
	nav_agent.height = 2.0
	nav_agent.max_speed = enemy_data.move_speed if enemy_data else 4.0

	# Wait for navigation to be ready
	await get_tree().physics_frame
	await get_tree().physics_frame

## Setup timers
func setup_timers() -> void:
	attack_timer = Timer.new()
	attack_timer.name = "AttackTimer"
	attack_timer.one_shot = false
	attack_timer.wait_time = enemy_data.attack_cooldown if enemy_data else 1.5
	add_child(attack_timer)
	attack_timer.timeout.connect(_on_attack_cooldown_finished)
	attack_timer.start()

## Find player target
func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]
		change_state(State.CHASE)

## Update AI logic
func update_ai(delta: float) -> void:
	if current_state == State.DEAD:
		return

	if not target:
		return

	var distance_to_target = global_position.distance_to(target.global_position)

	# State machine
	match current_state:
		State.IDLE:
			if distance_to_target <= enemy_data.detection_range:
				change_state(State.CHASE)

		State.CHASE:
			# Check if in attack range
			if distance_to_target <= enemy_data.attack_range:
				change_state(State.ATTACK)
			# Check if should retreat
			elif should_retreat():
				change_state(State.RETREAT)
			else:
				chase_target(delta)

		State.ATTACK:
			# Check if target moved out of range
			if distance_to_target > enemy_data.attack_range:
				change_state(State.CHASE)
			else:
				attack_target(delta)

		State.RETREAT:
			if not should_retreat():
				change_state(State.CHASE)
			else:
				retreat_from_target(delta)

## Change state
func change_state(new_state: State) -> void:
	if current_state == new_state:
		return

	print("%s: %s -> %s" % [enemy_data.enemy_name, State.keys()[current_state], State.keys()[new_state]])
	current_state = new_state

## Chase target using navigation
func chase_target(delta: float) -> void:
	if not nav_agent or not target:
		return

	# Update target position
	nav_agent.target_position = target.global_position

	# Get next position from navigation
	if nav_agent.is_navigation_finished():
		return

	var next_position = nav_agent.get_next_path_position()
	var direction = (next_position - global_position).normalized()

	# Move
	velocity.x = direction.x * enemy_data.move_speed
	velocity.z = direction.z * enemy_data.move_speed

	# Rotate to face direction
	if direction.length() > 0.1:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, enemy_data.rotation_speed * delta)

## Attack target
func attack_target(delta: float) -> void:
	# Stop moving
	velocity.x = 0
	velocity.z = 0

	# Face target
	var direction_to_target = (target.global_position - global_position).normalized()
	var target_rotation = atan2(direction_to_target.x, direction_to_target.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, enemy_data.rotation_speed * delta)

	# Attack if can
	if can_attack:
		perform_attack()

## Perform attack
func perform_attack() -> void:
	if not target or not can_attack:
		return

	can_attack = false

	# Apply damage to player
	if target.has_method("take_damage"):
		target.take_damage(enemy_data.damage)
		print("%s attacked player for %d damage" % [enemy_data.enemy_name, enemy_data.damage])

	# Play attack animation/sound
	AudioManager.play_impact(global_position)

## Retreat from target
func retreat_from_target(delta: float) -> void:
	if not target:
		return

	# Move away from target
	var direction_from_target = (global_position - target.global_position).normalized()
	velocity.x = direction_from_target.x * enemy_data.move_speed * 0.7
	velocity.z = direction_from_target.z * enemy_data.move_speed * 0.7

	# Still face target
	var direction_to_target = (target.global_position - global_position).normalized()
	var target_rotation = atan2(direction_to_target.x, direction_to_target.z)
	rotation.y = lerp_angle(rotation.y, target_rotation, enemy_data.rotation_speed * delta)

## Check if should retreat
func should_retreat() -> bool:
	if not enemy_data:
		return false
	return (current_health / enemy_data.max_health) < enemy_data.retreat_health_threshold

## Take damage
func take_damage(amount: float) -> void:
	if current_state == State.DEAD:
		return

	current_health -= amount
	current_health = max(0, current_health)

	print("%s took %d damage. Health: %d/%d" % [enemy_data.enemy_name, amount, current_health, enemy_data.max_health])

	health_changed.emit(current_health, enemy_data.max_health)

	# Check death
	if current_health <= 0:
		die()

## Die
func die() -> void:
	if current_state == State.DEAD:
		return

	change_state(State.DEAD)

	print("%s died!" % enemy_data.enemy_name)

	# Notify game manager
	GameManager.register_enemy_killed(enemy_data.enemy_type, enemy_data.credit_value)

	# Emit signal
	died.emit(enemy_data.enemy_type, enemy_data.credit_value)

	# Play death sound
	AudioManager.play_enemy_death(enemy_data.enemy_type, global_position)

	# Remove from scene
	queue_free()

## Attack cooldown finished
func _on_attack_cooldown_finished() -> void:
	can_attack = true
