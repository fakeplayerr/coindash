# CoinDash Project Migration Guide

This document provides step-by-step instructions for migrating the CoinDash project from its original flat structure to the new modular organization.

## Migration Steps

### 1. Create the New Directory Structure

```
# Create the main source directory
mkdir src

# Create the category directories
mkdir src\autoload
mkdir src\core
mkdir src\ui
mkdir src\ui\screens
mkdir src\ui\components
mkdir src\characters
mkdir src\characters\player
mkdir src\characters\npcs
mkdir src\projectiles
mkdir src\powerups
mkdir src\environment
mkdir src\environment\road
mkdir src\environment\obstacles
mkdir src\gameplay
```

### 2. Copy Files to the New Structure

```
# Player characters
copy scenes\player.gd src\characters\player\player.gd
copy scenes\player.tscn src\characters\player\player.tscn

# NPC characters
copy scenes\human.gd src\characters\npcs\human.gd
copy scenes\human.tscn src\characters\npcs\human.tscn
copy scenes\human_npc.gd src\characters\npcs\human_npc.gd
copy scenes\human_npc.tscn src\characters\npcs\human_npc.tscn

# Projectiles
copy scenes\coin_projectile.gd src\projectiles\coin_projectile.gd
copy scenes\coin_projectile.tscn src\projectiles\coin_projectile.tscn

# Power-ups
copy scenes\power_up.gd src\powerups\power_up.gd
copy scenes\power_up.tscn src\powerups\power_up.tscn

# Environment - Road
copy scenes\road_generator.gd src\environment\road\road_generator.gd
copy scenes\road_segment.gd src\environment\road\road_segment.gd
copy scenes\road_segment.tscn src\environment\road\road_segment.tscn
copy scenes\road_tile.tscn src\environment\road\road_tile.tscn
copy scenes\road_spawner.gd src\environment\road\road_spawner.gd

# Gameplay
copy scenes\main_game.gd src\gameplay\main_game.gd
copy scenes\main_game.tscn src\gameplay\main_game.tscn
copy scenes\load_selected_car.gd src\gameplay\load_selected_car.gd

# UI Screens
copy scenes\start_screen.gd src\ui\screens\start_screen.gd
copy scenes\start_screen.tscn src\ui\screens\start_screen.tscn
copy scenes\game_over.gd src\ui\screens\game_over.gd
copy scenes\game_over.tscn src\ui\screens\game_over.tscn
copy scenes\car_select_screen.gd src\ui\screens\car_select_screen.gd
copy scenes\car_select_screen.tscn src\ui\screens\car_select_screen.tscn
copy scenes\upgrades_screen.gd src\ui\screens\upgrades_screen.gd
copy scenes\upgrades_screen.tscn src\ui\screens\upgrades_screen.tscn

# UI Components
copy scenes\ui_animations.gd src\ui\components\ui_animations.gd
copy scenes\ui_animations.tscn src\ui\components\ui_animations.tscn
copy scenes\upgrade_effect.gd src\ui\components\upgrade_effect.gd
copy scenes\upgrade_effect.tscn src\ui\components\upgrade_effect.tscn

# Core
copy scenes\screen_shake.gd src\core\screen_shake.gd

# Autoloads
copy scenes\save_manager.gd src\autoload\save_manager.gd
copy scenes\save_manager.tscn src\autoload\save_manager.tscn
copy scenes\transition.gd src\autoload\transition.gd
copy scenes\transition.tscn src\autoload\transition.tscn
copy scripts\game_assets.gd src\autoload\game_assets.gd
copy scripts\timer_manager.gd src\core\timer_manager.gd
```

### 3. Update File References

1. Open the Godot project
2. Open the Script Editor
3. Load the `src/update_paths.gd` script
4. Click the "Run" button in the Script Editor toolbar
5. Check the output in the "Output" panel to confirm all paths were updated

### 4. Update Project Settings

1. Open Project → Project Settings
2. Go to the Autoload tab
3. Update the autoload paths:
   - SaveManager: `res://src/autoload/save_manager.tscn`
   - GameAssets: `res://src/autoload/game_assets.gd`
   - Transition: `res://src/autoload/transition.tscn`

4. Go to Application → Run
5. Update Main Scene to `res://src/ui/screens/start_screen.tscn`

### 5. Verification

1. Load the `src/verify_project.gd` script in the Script Editor
2. Click the "Run" button
3. Check the output to ensure all expected files and directories are present

### 6. Test the Game

1. Run the game to verify that everything works correctly
2. Test all core functionalities:
   - Start screen navigation
   - Car selection
   - Gameplay mechanics
   - Power-up functionality
   - Score tracking
   - Game over screen

### 7. Clean Up (Optional)

Once you've confirmed everything is working correctly, you can remove the old files:

```
# Be careful with this step! Make sure to back up your project first.
# Only proceed after verifying the new structure works correctly.

rm -r scenes
rm -r scripts
```

## Troubleshooting

If you encounter issues:

1. **Broken references**: Check that all file paths in scripts and scenes were updated correctly. Look for "res://scenes/" or "res://scripts/" paths that might have been missed.

2. **Missing files**: Use the verify_project.gd script to identify missing files and copy them to the appropriate locations.

3. **Autoload errors**: Double-check that all autoloads are correctly configured in the Project Settings.

4. **Scene loading errors**: Ensure that scene paths in scripts using `preload()` or `load()` functions have been updated.

## Benefits of New Structure

- Better organization with files grouped by function
- Improved scalability for adding new features
- Enhanced maintainability for finding and fixing issues
- Clearer dependency management
- Easier collaboration for team work 
