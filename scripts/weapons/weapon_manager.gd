extends Node
## Weapon Manager - Handles weapon switching and management
##
## Manages multiple weapons, switching between them, and ammo management.

signal weapon_switched(weapon_index: int, weapon_name: String)
signal current_weapon_ammo_changed(current_ammo: int, reserve_ammo: int)

@export var weapons: Array[Node3D] = []
@export var starting_weapon_index: int = 0

var current_weapon_index: int = 0
var current_weapon: Node3D = null

func _ready() -> void:
	# Initialize weapons
	for i in range(weapons.size()):
		if weapons[i]:
			weapons[i].visible = (i == starting_weapon_index)

	# Set initial weapon
	if weapons.size() > starting_weapon_index:
		switch_weapon(starting_weapon_index)

## Switch to weapon by index
func switch_weapon(index: int) -> void:
	if index < 0 or index >= weapons.size():
		return

	if index == current_weapon_index and current_weapon:
		return

	# Hide current weapon
	if current_weapon:
		current_weapon.visible = false
		if current_weapon.has_signal("ammo_changed"):
			current_weapon.ammo_changed.disconnect(_on_weapon_ammo_changed)

	# Show new weapon
	current_weapon_index = index
	current_weapon = weapons[index]

	if current_weapon:
		current_weapon.visible = true

		# Connect signals
		if current_weapon.has_signal("ammo_changed"):
			current_weapon.ammo_changed.connect(_on_weapon_ammo_changed)

		var weapon_name = current_weapon.weapon_data.weapon_name if current_weapon.weapon_data else "Unknown"
		print("Switched to weapon: %s" % weapon_name)
		weapon_switched.emit(index, weapon_name)

		# Emit initial ammo
		if current_weapon.has_method("initialize_weapon"):
			_on_weapon_ammo_changed(current_weapon.current_ammo, current_weapon.reserve_ammo)

## Switch to next weapon
func next_weapon() -> void:
	var next_index = (current_weapon_index + 1) % weapons.size()
	switch_weapon(next_index)

## Switch to previous weapon
func previous_weapon() -> void:
	var prev_index = (current_weapon_index - 1 + weapons.size()) % weapons.size()
	switch_weapon(prev_index)

## Try to shoot current weapon
func try_shoot() -> bool:
	if current_weapon and current_weapon.has_method("try_shoot"):
		return current_weapon.try_shoot()
	return false

## Reload current weapon
func reload() -> void:
	if current_weapon and current_weapon.has_method("reload"):
		current_weapon.reload()

## Get current weapon
func get_current_weapon() -> Node3D:
	return current_weapon

## Handle ammo changed signal from weapon
func _on_weapon_ammo_changed(current_ammo: int, reserve_ammo: int) -> void:
	current_weapon_ammo_changed.emit(current_ammo, reserve_ammo)
