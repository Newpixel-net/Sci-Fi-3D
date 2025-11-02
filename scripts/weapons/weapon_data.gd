extends Resource
## Weapon Data Resource
##
## Data-driven weapon configuration. Create resources for each weapon type.

class_name WeaponData

@export var weapon_name: String = "Weapon"
@export var weapon_type: String = "rifle"

# Damage
@export var base_damage: float = 10.0
@export var headshot_multiplier: float = 2.0

# Fire rate
@export var fire_rate: float = 10.0  # Rounds per second
@export var auto_fire: bool = true

# Ammo
@export var magazine_size: int = 30
@export var max_ammo: int = 300
@export var unlimited_ammo: bool = false
@export var reload_time: float = 2.0

# Accuracy
@export var base_spread: float = 0.02  # Degrees
@export var max_spread: float = 0.1
@export var spread_increase_per_shot: float = 0.01
@export var spread_recovery_rate: float = 0.05

# Projectile
@export var projectile_speed: float = 100.0
@export var projectile_lifetime: float = 2.0
@export var is_hitscan: bool = false

# Recoil
@export var recoil_strength: float = 0.1

# Effects
@export var muzzle_flash_enabled: bool = true
@export var shell_ejection_enabled: bool = true

# Audio (will be AudioStream references later)
@export var shoot_sound: String = ""
@export var reload_sound: String = ""
@export var empty_sound: String = ""
