extends Node
## Player Health - Manages player health and damage
##
## Tracks health, applies damage, handles death, and emits health change signals.

signal health_changed(current_health: float, max_health: float)
signal damage_taken(amount: float, current_health: float)
signal health_critical(current_health: float)
signal player_died()

@export var max_health: float = 100.0
@export var critical_health_threshold: float = 25.0

var current_health: float = 100.0
var is_alive: bool = true
var invulnerable: bool = false

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)

## Take damage
func take_damage(amount: float) -> void:
	if not is_alive or invulnerable or amount <= 0:
		return

	current_health -= amount
	current_health = max(0, current_health)

	print("Player took %d damage. Health: %d/%d" % [amount, current_health, max_health])

	# Emit signals
	damage_taken.emit(amount, current_health)
	health_changed.emit(current_health, max_health)

	# Check critical health
	if current_health <= critical_health_threshold and current_health > 0:
		health_critical.emit(current_health)

	# Check death
	if current_health <= 0 and is_alive:
		die()

## Heal
func heal(amount: float) -> void:
	if not is_alive or amount <= 0:
		return

	current_health += amount
	current_health = min(current_health, max_health)

	health_changed.emit(current_health, max_health)

## Set max health
func set_max_health(new_max: float) -> void:
	max_health = new_max
	current_health = min(current_health, max_health)
	health_changed.emit(current_health, max_health)

## Get health percentage
func get_health_percentage() -> float:
	return current_health / max_health if max_health > 0 else 0.0

## Is health critical
func is_health_critical() -> bool:
	return current_health <= critical_health_threshold

## Die
func die() -> void:
	if not is_alive:
		return

	is_alive = false
	print("Player died!")

	player_died.emit()
	GameManager.handle_player_death()

## Respawn
func respawn() -> void:
	current_health = max_health
	is_alive = true
	health_changed.emit(current_health, max_health)

## Set invulnerability (for testing or power-ups)
func set_invulnerable(value: bool) -> void:
	invulnerable = value
