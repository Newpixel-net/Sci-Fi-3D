extends Node
## Game Manager - Central game state and progression controller
##
## Manages game states, wave progression, scoring, and currency.
## Acts as an event bus for game-wide communication.

# Game states
enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	WAVE_COMPLETE,
	UPGRADE_SHOP,
	GAME_OVER
}

# Signals for game events
signal state_changed(new_state: GameState)
signal wave_started(wave_number: int)
signal wave_completed(wave_number: int, credits_earned: int)
signal score_changed(new_score: int)
signal credits_changed(new_credits: int)
signal player_died()
signal enemy_killed(enemy_type: String, credits_earned: int)
signal game_over(final_score: int, final_wave: int)

# Game state variables
var current_state: GameState = GameState.MENU
var current_wave: int = 0
var score: int = 0
var credits: int = 0
var enemies_killed_total: int = 0
var enemies_remaining: int = 0
var high_score: int = 0

# Difficulty scaling
var difficulty_multiplier: float = 1.0
const DIFFICULTY_INCREASE_PER_WAVE: float = 0.15

func _ready() -> void:
	print("GameManager initialized")
	# Load high score from save
	high_score = SaveManager.load_high_score()

## Change game state with validation
func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return

	var old_state = current_state
	current_state = new_state

	print("Game state changed: %s -> %s" % [GameState.keys()[old_state], GameState.keys()[new_state]])

	# Handle state transitions
	match new_state:
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.MENU:
			get_tree().paused = false
			reset_game()
		GameState.GAME_OVER:
			get_tree().paused = true
			_handle_game_over()
		GameState.UPGRADE_SHOP:
			get_tree().paused = true

	state_changed.emit(new_state)

## Start a new game
func start_new_game() -> void:
	reset_game()
	change_state(GameState.PLAYING)
	start_wave(1)

## Reset all game variables
func reset_game() -> void:
	current_wave = 0
	score = 0
	credits = 100  # Starting credits
	enemies_killed_total = 0
	enemies_remaining = 0
	difficulty_multiplier = 1.0

	score_changed.emit(score)
	credits_changed.emit(credits)

## Start a new wave
func start_wave(wave_number: int) -> void:
	current_wave = wave_number
	difficulty_multiplier = 1.0 + (current_wave - 1) * DIFFICULTY_INCREASE_PER_WAVE

	print("Starting wave %d (difficulty: %.2f)" % [current_wave, difficulty_multiplier])
	wave_started.emit(current_wave)

## Wave completed
func complete_wave() -> void:
	var wave_bonus = current_wave * 100
	add_credits(wave_bonus)

	print("Wave %d completed! Bonus: %d credits" % [current_wave, wave_bonus])
	wave_completed.emit(current_wave, wave_bonus)
	change_state(GameState.WAVE_COMPLETE)

## Register enemy death
func register_enemy_killed(enemy_type: String, credit_value: int) -> void:
	enemies_killed_total += 1
	enemies_remaining -= 1

	add_score(credit_value)
	add_credits(credit_value)

	enemy_killed.emit(enemy_type, credit_value)

	# Check if wave is complete
	if enemies_remaining <= 0:
		complete_wave()

## Add score
func add_score(amount: int) -> void:
	score += amount
	score_changed.emit(score)

## Add credits (currency)
func add_credits(amount: int) -> void:
	credits += amount
	credits_changed.emit(credits)

## Spend credits
func spend_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		credits_changed.emit(credits)
		return true
	return false

## Set enemies for current wave
func set_wave_enemies(count: int) -> void:
	enemies_remaining = count
	print("Wave %d: %d enemies" % [current_wave, count])

## Player died
func handle_player_death() -> void:
	print("Player died!")
	player_died.emit()
	change_state(GameState.GAME_OVER)

## Handle game over
func _handle_game_over() -> void:
	# Update high score
	if score > high_score:
		high_score = score
		SaveManager.save_high_score(high_score)
		print("New high score: %d" % high_score)

	game_over.emit(score, current_wave)

## Get difficulty multiplier for current wave
func get_difficulty_multiplier() -> float:
	return difficulty_multiplier

## Continue to next wave
func continue_to_next_wave() -> void:
	change_state(GameState.PLAYING)
	start_wave(current_wave + 1)

## Open upgrade shop
func open_upgrade_shop() -> void:
	change_state(GameState.UPGRADE_SHOP)

## Close upgrade shop and continue
func close_upgrade_shop() -> void:
	continue_to_next_wave()

## Pause game
func pause_game() -> void:
	if current_state == GameState.PLAYING:
		change_state(GameState.PAUSED)

## Resume game
func resume_game() -> void:
	if current_state == GameState.PAUSED:
		change_state(GameState.PLAYING)

## Return to main menu
func return_to_menu() -> void:
	change_state(GameState.MENU)
