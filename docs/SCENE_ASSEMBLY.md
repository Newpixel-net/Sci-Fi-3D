# Scene Assembly Guide

This guide explains how to assemble all the game scenes in Godot 4.5.

## Main Scene (scenes/main.tscn)

The entry point of the game - the main menu.

**Structure:**
```
Control (Main Menu)
├── Script: res://scripts/ui/main_menu.gd
└── Children will be created by script
```

**Setup:**
1. Create new Scene → 2D Scene (Control node)
2. Name it "MainMenu"
3. Attach script: `res://scripts/ui/main_menu.gd`
4. Save as `res://scenes/main.tscn`

## Game Scene (scenes/game/game.tscn)

The main gameplay scene containing all game elements.

**Structure:**
```
Node3D (Game)
├── WorldEnvironment
│   └── Environment (with Sky, Ambient Light)
├── DirectionalLight3D
├── NavigationRegion3D
│   └── Arena (CSGBox3D for now)
├── Player (CharacterBody3D)
│   ├── CollisionShape3D
│   ├── MeshInstance3D (placeholder capsule)
│   ├── CameraPivot (Node3D)
│   │   ├── SpringArm3D
│   │   │   └── Camera3D
│   ├── WeaponAttachment (Node3D)
│   │   └── WeaponManager
│   │       ├── Weapon1 (placeholder)
│   │       ├── Weapon2 (placeholder)
│   │       └── Weapon3 (placeholder)
│   ├── Script: player_controller.gd
│   └── PlayerHealth (Node)
│       └── Script: player_health.gd
├── EnemySpawner (Node3D)
│   ├── SpawnPoint1 (Marker3D)
│   ├── SpawnPoint2 (Marker3D)
│   ├── SpawnPoint3 (Marker3D)
│   ├── SpawnPoint4 (Marker3D)
│   └── Script: enemy_spawner.gd
├── WaveManager (Node)
│   └── Script: wave_manager.gd
├── UI (CanvasLayer)
│   ├── HUD (Control)
│   │   └── Script: hud.gd
│   ├── PauseMenu (Control)
│   │   └── Script: pause_menu.gd
│   ├── WaveComplete (Control)
│   │   └── Script: wave_complete.gd
│   └── GameOver (Control)
│       └── Script: game_over.gd
```

## Player Setup

1. Create CharacterBody3D node named "Player"
2. Add to group "player"
3. Add CollisionShape3D with CapsuleShape3D (height: 2, radius: 0.5)
4. Add MeshInstance3D with CapsuleMesh for placeholder
5. Attach `player_controller.gd` script
6. Add child Node named "PlayerHealth" with `player_health.gd` script
7. Create camera hierarchy as shown above
8. Create WeaponAttachment node at position (0.3, 1.5, 0.5)

## Enemy Setup (scenes/game/enemies/scout_robot.tscn)

1. Create CharacterBody3D node
2. Add CollisionShape3D with CapsuleShape3D
3. Add MeshInstance3D with CylinderMesh (placeholder)
4. Attach `enemy_base.gd` script
5. Create EnemyData resource in resources/enemy_data/
6. Assign resource to enemy_data export variable

## Weapon Setup (scenes/game/weapons/pistol.tscn)

1. Create Node3D
2. Add MeshInstance3D with BoxMesh (placeholder)
3. Add Marker3D named "MuzzlePoint" at front
4. Attach `weapon_base.gd` script
5. Create WeaponData resource in resources/weapon_data/
6. Assign resource to weapon_data export variable

## Arena Setup

1. Create Node3D for arena container
2. Add NavigationRegion3D
3. Add CSGBox3D for floor (30x30)
4. Set NavigationRegion3D to bake the navigation mesh
5. Add spawn points around perimeter (Marker3D nodes)

## Tips

- Use groups: "player", "enemies", "projectiles"
- Set proper collision layers (see project.godot)
- Configure export variables in Inspector
- Test each scene independently before integrating
