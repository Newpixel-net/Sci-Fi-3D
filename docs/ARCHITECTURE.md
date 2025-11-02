# Architecture Documentation

## Overview

Sector Defense follows a modular, signal-based architecture with clear separation of concerns.

## Core Principles

1. **Signal-Based Communication**: Loose coupling between systems using Godot signals
2. **Resource-Driven Design**: Game data (enemies, weapons, waves) stored as resources
3. **Singleton Pattern**: Global managers (GameManager, AudioManager, etc.) as autoloads
4. **Object Pooling**: Reusable objects for performance (projectiles, VFX)
5. **Component-Based**: Small, focused scripts that compose complex behaviors

## System Architecture

### Autoload Singletons

**GameManager** (`scripts/autoload/game_manager.gd`)
- Central game state machine
- Wave progression
- Score/credits management
- Event bus for game-wide communication

**AudioManager** (`scripts/autoload/audio_manager.gd`)
- Centralized audio playback
- SFX and music management
- Object pooling for audio players
- Spatial 3D audio support

**SaveManager** (`scripts/autoload/save_manager.gd`)
- Persistent data storage
- Settings management
- JSON-based save system
- Statistics tracking

**InputManager** (`scripts/autoload/input_manager.gd`)
- Multi-platform input abstraction
- Auto-detection of input mode (KB/M, Gamepad, Touch)
- Virtual joystick support for mobile
- Unified input API

### Player System

**PlayerController** (`scripts/player/player_controller.gd`)
- CharacterBody3D-based movement
- 3rd person camera with collision detection
- Input handling via InputManager
- Weapon integration

**PlayerHealth** (`scripts/player/player_health.gd`)
- Health management
- Damage/healing
- Death handling
- Signal-based health updates

### Weapon System

**WeaponData** (`scripts/weapons/weapon_data.gd`)
- Resource defining weapon properties
- Damage, fire rate, ammo, accuracy
- Projectile configuration
- Recoil and effects

**WeaponBase** (`scripts/weapons/weapon_base.gd`)
- Base weapon functionality
- Shooting mechanics (hitscan/projectile)
- Ammo management
- Reload system
- Spread/accuracy simulation

**WeaponManager** (`scripts/weapons/weapon_manager.gd`)
- Weapon switching
- Multiple weapon inventory
- Ammo tracking across weapons

**Projectile** (`scripts/weapons/projectile.gd`)
- Ballistic projectiles
- Collision detection
- Damage application

### Enemy System

**EnemyData** (`scripts/enemies/enemy_data.gd`)
- Resource defining enemy properties
- Health, speed, damage
- AI behavior parameters
- Credit rewards

**EnemyBase** (`scripts/enemies/enemy_base.gd`)
- CharacterBody3D-based enemy
- AI state machine (IDLE, CHASE, ATTACK, RETREAT, DEAD)
- NavigationAgent3D pathfinding
- Combat system
- Health management

**EnemySpawner** (`scripts/enemies/enemy_spawner.gd`)
- Spawns enemies at designated points
- Wave spawning with delays
- Random spawn point selection
- Enemy type variation

### Wave System

**WaveManager** (`scripts/systems/wave_manager.gd`)
- Wave progression
- Enemy count scaling
- Difficulty calculation
- Spawn timing control
- Wave preparation countdown

### Utility Systems

**ObjectPool** (`scripts/utils/object_pool.gd`)
- Generic object pooling
- Reusable objects for performance
- Pool for projectiles, VFX, audio

### UI System

All UI scripts follow a consistent pattern:
- Self-contained Control nodes
- Signal-based updates from managers
- Automatic creation of basic UI if nodes not set
- Clean separation from game logic

**HUD** - Real-time game info (health, ammo, wave, score)
**MainMenu** - Entry point, start game
**PauseMenu** - In-game pause functionality
**GameOver** - End game stats and retry
**WaveComplete** - Wave completion celebration

## Data Flow

### Game Start
```
MainMenu → Start Button
  ↓
GameManager.start_new_game()
  ↓
Load Game Scene
  ↓
WaveManager.start_wave(1)
  ↓
EnemySpawner.spawn_wave()
```

### Combat Loop
```
Player shoots → WeaponBase.shoot()
  ↓
Hitscan/Projectile
  ↓
Enemy.take_damage()
  ↓
Enemy dies → EnemyBase.die()
  ↓
GameManager.register_enemy_killed()
  ↓
Update Score/Credits
  ↓
Check wave complete
```

### Wave Completion
```
All enemies dead → GameManager.complete_wave()
  ↓
WaveComplete UI shown
  ↓
Player choice: Continue or Upgrade
  ↓
GameManager.continue_to_next_wave()
  ↓
WaveManager.start_wave(wave + 1)
```

## Performance Considerations

1. **Object Pooling**: All projectiles and frequent VFX use pools
2. **Navigation**: NavigationAgent3D for efficient pathfinding
3. **LOD**: Will be implemented for models (Phase 7)
4. **Culling**: Frustum culling for off-screen objects
5. **Signal Optimization**: Disconnect signals when not needed

## Extensibility

### Adding New Weapon
1. Create WeaponData resource
2. Instantiate weapon scene with WeaponBase script
3. Add to player's WeaponManager
4. Configure projectile/hitscan

### Adding New Enemy
1. Create EnemyData resource
2. Create enemy scene with EnemyBase script
3. Add to WaveManager's enemy pool
4. Configure AI parameters

### Adding New Wave Configuration
1. Create wave config resource (future)
2. Specify enemy counts and types
3. Set difficulty modifiers
4. Assign to WaveManager

## File Organization

```
scripts/
├── autoload/        # Singleton managers
├── player/          # Player-specific logic
├── enemies/         # Enemy AI and data
├── weapons/         # Weapon system
├── systems/         # Game systems (waves, etc.)
├── ui/              # UI controllers
└── utils/           # Utility classes
```

## Signal Conventions

- Past tense for completed actions: `died`, `spawned`
- Present tense for state changes: `health_changed`
- Descriptive names: `wave_completed` not `wave_done`
- Include relevant data in signal parameters

## Code Style

- Type hints on all functions and variables
- Doc comments (##) on all classes and public methods
- Clear, descriptive names
- One class per file
- Constants in UPPER_CASE
- Private methods prefixed with `_`

## Testing Strategy

1. Test each system independently
2. Use placeholder assets initially
3. Profile regularly (especially on mobile)
4. Test edge cases (0 ammo, 0 health, etc.)
5. Verify signal connections
