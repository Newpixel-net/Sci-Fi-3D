extends Resource
## Enemy Data Resource
##
## Data-driven enemy configuration.

class_name EnemyData

@export var enemy_name: String = "Enemy"
@export var enemy_type: String = "scout"

# Stats
@export var max_health: float = 50.0
@export var move_speed: float = 4.0
@export var rotation_speed: float = 5.0

# Combat
@export var damage: float = 10.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 1.5
@export var detection_range: float = 30.0

# Rewards
@export var credit_value: int = 50

# AI behavior
@export var aggression: float = 1.0  # How quickly they chase
@export var retreat_health_threshold: float = 0.2  # Retreat when health below this
