# Top-Down Shooter RPG - Godot 4 Project

A feature-complete top-down shooter/RPG built with Godot 4 and GDScript. Includes wave-based gameplay, experience/leveling system, multiple weapon types, enemy varieties, and a full UI/HUD.

## Features

- **Player Movement**: 8-directional movement with dash ability (Shift/Ctrl)
- **Mouse Aiming**: Full 360° aiming with mouse
- **Weapon System**: Modular weapon system with 4 weapon types (Pistol, Shotgun, Rifle, Machine Gun)
- **Experience & Leveling**: Gain XP from kills, level up to choose upgrades
- **Wave System**: Progressive difficulty with 3 enemy types
- **Health System**: Damage, knockback, invincibility frames, regeneration
- **Pickups**: Health, XP, and stat boost pickups
- **Full UI/HUD**: Health bar, XP bar, score, wave counter, level-up choices
- **Pause Menu**: Resume, Restart, Quit
- **Game Over Screen**: Final score, high score tracking
- **Audio Manager**: Music/SFX with volume controls and pooling
- **Save System**: Persistent high score and settings

## Project Structure

```
godot_topdown_shooter/
├── project.godot              # Project configuration
├── icon.svg                   # Game icon
├── README.md                  # This file
├── scenes/
│   ├── main.tscn              # Main game scene
│   ├── player.tscn            # Player scene
│   ├── ui/
│   │   └── hud.tscn           # HUD and menus
│   └── enemies/
│       ├── basic_enemy.tscn   # Melee enemy
│       ├── ranged_enemy.tscn  # Ranged enemy
│       └── charger_enemy.tscn # Charging enemy
├── scripts/
│   ├── player/
│   │   └── player.gd          # Player controller
│   ├── enemies/
│   │   ├── enemy.gd           # Base enemy class
│   │   ├── ranged_enemy.gd    # Ranged enemy
│   │   └── charger_enemy.gd   # Charger enemy
│   ├── weapons/
│   │   ├── weapon.gd          # Base weapon class
│   │   ├── weapon_manager.gd  # Weapon switching/stats
│   │   ├── projectile.gd      # Player projectile
│   │   ├── enemy_projectile.gd# Enemy projectile
│   │   ├── basic_pistol.gd    # Starting weapon
│   │   ├── shotgun.gd         # Spread weapon
│   │   ├── rifle.gd           # High damage, piercing
│   │   └── machine_gun.gd     # Fast fire rate
│   ├── components/
│   │   ├── health_component.gd# Reusable health system
│   │   ├── experience_component.gd # XP/Leveling
│   │   └── pickup.gd          # Pickup system
│   ├── managers/
│   │   ├── game_manager.gd    # Game state, waves, spawning
│   │   ├── audio_manager.gd   # Audio system
│   │   └── save_manager.gd    # Save/load system
│   └── ui/
│       └── hud.gd             # HUD logic
└── assets/
    ├── sprites/               # Place sprites here
    └── audio/                 # Place audio files here
```

## Controls

| Action | Keys |
|--------|------|
| Move Up | W / ↑ |
| Move Down | S / ↓ |
| Move Left | A / ← |
| Move Right | D / → |
| Shoot | Space / Left Click |
| Dash | Shift / Ctrl |
| Interact | E / Enter |
| Pause | Esc / P |

## Getting Started

### Prerequisites
- Godot 4.2 or later

### Running the Game
1. Open Godot 4
2. Click "Import" and select `project.godot` in this folder
3. Press F5 (or click Play) to run

### Adding Assets
The game uses placeholder graphics. To add your own:

1. **Sprites**: Place PNG files in `assets/sprites/` and update the AnimatedSprite2D nodes in:
   - `scenes/player.tscn`
   - `scenes/enemies/basic_enemy.tscn`
   - `scenes/enemies/ranged_enemy.tscn`
   - `scenes/enemies/charger_enemy.tscn`

2. **Audio**: Place OGG/WAV files in `assets/audio/` and assign them in the AudioManager inspector

## Gameplay Mechanics

### Weapons
- **Pistol** (Starting): Balanced single shot
- **Shotgun**: 5-projectile spread, high knockback
- **Rifle**: High damage, piercing, fast projectile
- **Machine Gun**: Rapid fire, slight spread

### Enemy Types
- **Basic (Melee)**: Chases and attacks on contact
- **Ranged**: Keeps distance, shoots projectiles
- **Charger**: Slow but tanks hits, charges at high speed

### Level Upgrades
Each level grants a choice of 3 random upgrades:
- Damage +20%
- Fire Rate +15%
- Max Health +25
- Extra Projectile
- Move Speed +20%
- Piercing +1

### Wave System
- Wave 1: 5 enemies
- Each wave: 30% more enemies
- Enemy types unlock progressively
- 5 second cooldown between waves

## Extending the Game

### Adding New Weapons
1. Create new script extending `Weapon` in `scripts/weapons/`
2. Set stats in `_ready()`
3. Add to `WeaponManager` or create pickup to unlock

### Adding New Enemies
1. Create new script extending `Enemy` in `scripts/enemies/`
2. Set behavior_type and stats in `_ready()`
3. Create `.tscn` scene in `scenes/enemies/`
4. Add to `enemy_scenes` array in `GameManager`

### Adding New Upgrades
Edit `_apply_level_up_choice()` in `game_manager.gd` and `_populate_choices()` in `hud.gd`

## Architecture Notes

- **Component-based**: Health, Experience, WeaponManager are separate components
- **Signal-driven**: Loose coupling via Godot signals
- **Autoloads**: GameManager, AudioManager, SaveManager as singletons
- **Object pooling**: AudioManager reuses AudioStreamPlayers
- **Clean separation**: Gameplay logic in managers, presentation in scenes

## License

MIT License - Feel free to use for learning or commercial projects!