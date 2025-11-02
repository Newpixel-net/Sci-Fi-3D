extends Control
## HUD - Heads-Up Display
##
## Displays player health, ammo, wave info, score, and crosshair.

# UI Elements (set in scene)
@export var health_bar: ProgressBar
@export var health_label: Label
@export var ammo_label: Label
@export var wave_label: Label
@export var score_label: Label
@export var credits_label: Label
@export var weapon_name_label: Label
@export var crosshair: Control

# References
var player: Node3D
var player_health: Node

func _ready() -> void:
	# Create basic UI if nodes not set
	if not health_bar:
		create_basic_hud()

	# Connect to game manager signals
	GameManager.wave_started.connect(_on_wave_started)
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.credits_changed.connect(_on_credits_changed)

	# Find player
	call_deferred("find_player")

	# Hide crosshair initially
	if crosshair:
		crosshair.visible = false

## Create basic HUD elements
func create_basic_hud() -> void:
	# Health Bar
	var health_container = VBoxContainer.new()
	health_container.position = Vector2(20, 20)
	add_child(health_container)

	var health_title = Label.new()
	health_title.text = "HEALTH"
	health_title.add_theme_font_size_override("font_size", 14)
	health_container.add_child(health_title)

	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(200, 20)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	health_container.add_child(health_bar)

	health_label = Label.new()
	health_label.text = "100 / 100"
	health_label.add_theme_font_size_override("font_size", 16)
	health_container.add_child(health_label)

	# Ammo Display
	var ammo_container = VBoxContainer.new()
	ammo_container.position = Vector2(20, 120)
	add_child(ammo_container)

	var ammo_title = Label.new()
	ammo_title.text = "AMMO"
	ammo_title.add_theme_font_size_override("font_size", 14)
	ammo_container.add_child(ammo_title)

	ammo_label = Label.new()
	ammo_label.text = "30 / 300"
	ammo_label.add_theme_font_size_override("font_size", 24)
	ammo_container.add_child(ammo_label)

	weapon_name_label = Label.new()
	weapon_name_label.text = "ASSAULT RIFLE"
	weapon_name_label.add_theme_font_size_override("font_size", 14)
	ammo_container.add_child(weapon_name_label)

	# Wave/Score Display (top center)
	var top_center = VBoxContainer.new()
	top_center.position = Vector2(get_viewport_rect().size.x / 2 - 100, 20)
	top_center.custom_minimum_size = Vector2(200, 0)
	add_child(top_center)

	wave_label = Label.new()
	wave_label.text = "WAVE 1"
	wave_label.add_theme_font_size_override("font_size", 24)
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_center.add_child(wave_label)

	score_label = Label.new()
	score_label.text = "SCORE: 0"
	score_label.add_theme_font_size_override("font_size", 18)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_center.add_child(score_label)

	credits_label = Label.new()
	credits_label.text = "CREDITS: 0"
	credits_label.add_theme_font_size_override("font_size", 18)
	credits_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	top_center.add_child(credits_label)

	# Crosshair (center)
	crosshair = Control.new()
	crosshair.position = get_viewport_rect().size / 2
	add_child(crosshair)

	var crosshair_h = ColorRect.new()
	crosshair_h.color = Color(1, 1, 1, 0.8)
	crosshair_h.size = Vector2(20, 2)
	crosshair_h.position = Vector2(-10, -1)
	crosshair.add_child(crosshair_h)

	var crosshair_v = ColorRect.new()
	crosshair_v.color = Color(1, 1, 1, 0.8)
	crosshair_v.size = Vector2(2, 20)
	crosshair_v.position = Vector2(-1, -10)
	crosshair.add_child(crosshair_v)

## Find player and connect signals
func find_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

		# Find player health component
		player_health = player.get_node_or_null("PlayerHealth")
		if player_health:
			player_health.health_changed.connect(_on_player_health_changed)
			_on_player_health_changed(player_health.current_health, player_health.max_health)

		# Find weapon manager
		var weapon_manager = player.get_node_or_null("WeaponManager")
		if weapon_manager:
			weapon_manager.weapon_switched.connect(_on_weapon_switched)
			weapon_manager.current_weapon_ammo_changed.connect(_on_ammo_changed)

## Update health display
func _on_player_health_changed(current_health: float, max_health: float) -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health

	if health_label:
		health_label.text = "%d / %d" % [current_health, max_health]

	# Color health bar
	if health_bar:
		var health_percent = current_health / max_health
		if health_percent > 0.5:
			health_bar.modulate = Color(0, 1, 0)  # Green
		elif health_percent > 0.25:
			health_bar.modulate = Color(1, 1, 0)  # Yellow
		else:
			health_bar.modulate = Color(1, 0, 0)  # Red

## Update ammo display
func _on_ammo_changed(current_ammo: int, reserve_ammo: int) -> void:
	if ammo_label:
		ammo_label.text = "%d / %d" % [current_ammo, reserve_ammo]

## Update weapon name
func _on_weapon_switched(weapon_index: int, weapon_name: String) -> void:
	if weapon_name_label:
		weapon_name_label.text = weapon_name.to_upper()

## Update wave display
func _on_wave_started(wave_number: int) -> void:
	if wave_label:
		wave_label.text = "WAVE %d" % wave_number

## Update score display
func _on_score_changed(new_score: int) -> void:
	if score_label:
		score_label.text = "SCORE: %d" % new_score

## Update credits display
func _on_credits_changed(new_credits: int) -> void:
	if credits_label:
		credits_label.text = "CREDITS: %d" % new_credits

## Show/hide HUD
func set_visible_hud(value: bool) -> void:
	visible = value

## Show crosshair
func show_crosshair(value: bool) -> void:
	if crosshair:
		crosshair.visible = value
