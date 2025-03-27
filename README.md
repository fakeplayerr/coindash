# CoinDash

A 2D vertical scrolling racing game built with Godot 4, where players control a car that moves forward endlessly along a road, collecting coins and avoiding obstacles.

## Project Structure

The project has been reorganized using a modular structure to improve maintainability and scalability:

```
coindash/
├── assets/                      # Game assets (textures, sounds, etc.)
├── src/                         # Main source code folder
│   ├── autoload/                # Autoloaded singleton scripts
│   ├── core/                    # Core game systems
│   ├── ui/                      # User interface components
│   ├── characters/              # Character-related components
│   ├── projectiles/             # Projectile systems
│   ├── powerups/                # Power-up system
│   ├── environment/             # Level and environment components
│   ├── gameplay/                # Game mechanics and managers
│   └── update_paths.gd          # Utility to update file references
```

## Getting Started

1. Open the project in Godot 4.x
2. Update the autoload paths in Project Settings:
   - Go to Project → Project Settings → Autoload
   - Update the following autoloads to point to their new locations:
     - SaveManager: `res://src/autoload/save_manager.tscn`
     - GameAssets: `res://src/autoload/game_assets.gd`
     - Transition: `res://src/autoload/transition.tscn`

3. Update the main scene in Project Settings:
   - Go to Project → Project Settings → Application → Run
   - Set Main Scene to `res://src/ui/screens/start_screen.tscn`

4. Run the update_paths.gd script to fix references:
   - Open the `src/update_paths.gd` script in the editor
   - Click on the "Run" button in the script editor to execute it
   - This will scan all files and update references to match the new structure

5. Test your game to ensure everything works correctly

## Game Features

- Vertical scrolling gameplay with endless road generation
- Player-controlled car that can move left and right
- Coin collection and shooting mechanism
- Obstacle avoidance with collision detection
- Power-up system with various effects
- Score tracking and persistence
- Human NPCs to encounter on the road

## Credits

Created with Godot Engine 4.x 