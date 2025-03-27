# CoinDash Project Restructuring - Final Checklist

## 1. Fixed Paths and Files

- [x] Fixed the update_paths.gd script to correctly map from old paths to new paths
- [x] Copied missing game_assets.gd to src/autoload
- [x] Copied missing timer_manager.gd to src/core
- [x] Copied missing power_up_manager.gd to src/powerups
- [x] Copied missing power_up_spawner.gd to src/powerups
- [x] Copied missing road_tile.gd to src/environment/road
- [x] Moved old unused files to old_files directory for reference
- [x] Changed class_name in game_assets.gd from GameAssets to GameAssetsResource to avoid conflicts

## 2. In-Godot Steps to Complete

### Run the Updated Path Scripts
1. Open the Godot editor
2. Open the script editor
3. Load and open src/update_paths.gd
4. Click the "Run" button in the script editor toolbar
5. Check the console output to verify paths were updated
6. Load and open src/fix_references.gd (to fix GameAssetsClass references)
7. Click the "Run" button to execute it
8. Check the console output to verify references were updated

### Update Project Settings
1. Go to Project → Project Settings → Autoload
2. Update these autoload paths:
   - SaveManager: `res://src/autoload/save_manager.tscn` (Node name: SaveManager)
   - GameAssetsClass: `res://src/autoload/game_assets.gd` (Node name: GameAssetsClass)
   - Transition: `res://src/autoload/transition.tscn` (Node name: Transition)
3. Go to Application → Run
4. Set Main Scene to `res://src/ui/screens/start_screen.tscn`

### Run the Verification Script
1. Load and open src/verify_project.gd
2. Click the "Run" button in the script editor toolbar
3. Check the console output to ensure all files and directories are present

### Test the Game
1. Run the game (F5)
2. Verify all key features work:
   - Menu navigation
   - Car selection
   - Gameplay mechanics
   - Power-ups functionality
   - Collisions and scoring
   - Game over and restart

## 3. Important Notes About Changes

### GameAssets Class Name Change
- The `game_assets.gd` script's class name has been changed from `GameAssets` to `GameAssetsResource`
- The autoload node name should be set to `GameAssetsClass` to match the references in code
- This resolves the "Invalid name. Must not collide with an existing global script class name" error

### File Path References
- The update_paths.gd script has been modified to handle references from old_files directory
- Make sure to run both update_paths.gd and fix_references.gd scripts

## 4. Project Structure Benefits

- **Better Organization**: Files are grouped by function (UI, characters, gameplay, etc.)
- **Improved Scalability**: Easier to add new features without cluttering
- **Enhanced Maintainability**: Logical separation makes it easier to find and fix issues
- **Clearer Dependencies**: Project structure makes dependencies between components clearer
- **Easier Collaboration**: Team members can work on different parts without conflicts

## 5. Final Cleanup (Optional)

Once you've verified the game works correctly with the new structure, you can:

1. Backup the project
2. Remove the old_files directory entirely
3. Remove the temporary migration files:
   - src/update_paths.gd
   - src/fix_references.gd
   - src/verify_project.gd
   - project_plan.md
   - migration_guide.md
   - final_checklist.md (this file) 