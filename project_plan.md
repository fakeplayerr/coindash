# CoinDash Project Restructuring Plan

## New Project Structure

The project has been reorganized into a more modular and maintainable structure following Godot best practices:

```
coindash/
├── assets/                      # Game assets (textures, sounds, etc.)
├── src/                         # Main source code folder
│   ├── autoload/                # Autoloaded singleton scripts
│   │   ├── save_manager.gd      # Save game manager
│   │   ├── game_assets.gd       # Centralized asset management
│   │   └── transition.gd        # Scene transition manager
│   ├── core/                    # Core game systems
│   │   ├── timer_manager.gd     # Timer and time management
│   │   └── screen_shake.gd      # Screen shake effect
│   ├── ui/                      # User interface components
│   │   ├── screens/             # Major UI screens
│   │   │   ├── start_screen.tscn/.gd           # Title/main menu screen
│   │   │   ├── game_over.tscn/.gd              # Game over screen
│   │   │   ├── upgrades_screen.tscn/.gd        # Upgrades menu
│   │   │   └── car_select_screen.tscn/.gd      # Vehicle selection screen
│   │   ├── components/          # Reusable UI components
│   │   │   ├── ui_animations.tscn/.gd          # UI animation system
│   │   │   └── upgrade_effect.tscn/.gd         # Visual effects for upgrades
│   ├── characters/              # Character-related components
│   │   ├── player/              # Player-related files
│   │   │   ├── player.tscn/.gd                 # Player character
│   │   │   └── player_trail.tscn/.gd           # Visual trail effect for player
│   │   └── npcs/                # Non-player characters
│   │       ├── human.tscn/.gd                  # Human NPC
│   │       └── human_npc.tscn/.gd              # Alternative human NPC
│   ├── projectiles/             # Projectile systems
│   │   └── coin_projectile.tscn/.gd            # Coin projectiles
│   ├── powerups/                # Power-up system
│   │   ├── power_up.tscn/.gd                   # Power-up base class
│   │   ├── power_up_manager.gd                 # Power-up management
│   │   └── power_up_spawner.gd                 # Power-up spawning system
│   ├── environment/             # Level and environment components
│   │   ├── road/                # Road-related components
│   │   │   ├── road_segment.tscn/.gd           # Road segment
│   │   │   ├── road_tile.tscn/.gd              # Individual road tile
│   │   │   ├── road_generator.gd               # Road generation logic
│   │   │   └── road_spawner.gd                 # Dynamic road spawning
│   │   └── obstacles/           # Obstacles and hazards
│   ├── gameplay/                # Game mechanics and managers
│   │   ├── main_game.tscn/.gd                  # Main game scene and controller
│   │   └── load_selected_car.gd                # Car selection persistence
```

## Required Path Updates

After restructuring, all script and scene paths need to be updated to reflect the new organization. Here are the main changes needed:

### 1. Update Script Class Names and Paths

All scripts that use `class_name` should be updated to match the new file location. For example:

```gdscript
# src/autoload/game_assets.gd
class_name GameAssets
```

### 2. Update Scene References in Scripts

All preloaded resources and scene references need to be updated with new paths:

```gdscript
# Old
@onready var coin_scene = preload("res://scenes/coin_projectile.tscn")

# New
@onready var coin_scene = preload("res://src/projectiles/coin_projectile.tscn")
```

### 3. Update Node Paths and References

All hard-coded node paths in scripts need to be checked and updated as needed:

```gdscript
# Old
var save_manager = get_node_or_null("/root/SaveManager")

# New (assuming it's an autoload)
var save_manager = get_node_or_null("/root/SaveManager")
# Or if referencing a scene instance:
var save_manager = get_node_or_null("path/to/SaveManager")
```

### 4. Update Project Settings Autoloads

The autoload paths need to be updated in the project settings:

1. Open Project → Project Settings
2. Go to Autoload tab
3. Update the paths for:
   - SaveManager: `res://src/autoload/save_manager.tscn`
   - GameAssets: `res://src/autoload/game_assets.gd`
   - Transition: `res://src/autoload/transition.tscn`

### 5. Update Main Scene

Update the main scene path in project settings:

1. Open Project → Project Settings
2. Go to Application → Run tab
3. Update Main Scene to `res://src/ui/screens/start_screen.tscn`

## Implementation Process

1. Create the new directory structure ✅
2. Copy all files to their new locations ✅
3. Update all script and scene references
4. Update autoload paths and project settings
5. Test the game thoroughly to ensure everything works correctly

## Benefits of New Structure

1. **Better Organization**: Files are grouped by function and responsibility.
2. **Improved Scalability**: Easier to add new features without cluttering folders.
3. **Better Maintainability**: Logical separation makes it easier to find and fix issues.
4. **Clearer Dependencies**: The project structure makes dependencies between components clearer.
5. **Easier Collaboration**: Team members can work on different parts of the code without conflicts.

## Next Steps

After successfully restructuring the project, these improvements could be considered:

1. **Resource System**: Create a more robust resource management system.
2. **Better Modularity**: Further decompose complex scripts into smaller, more focused components.
3. **Configuration Files**: Move hardcoded values to configuration files.
4. **Documentation**: Add more in-code documentation and create external documentation.
5. **Unit Tests**: Add unit tests for critical game systems. 