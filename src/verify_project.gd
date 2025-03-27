@tool
extends EditorScript

# This script verifies that all essential files have been 
# properly copied to their new locations in the project structure.
# Run this from the Godot editor using the Script Editor's "Run" button.

func _run():
	print("Verifying project structure...")
	
	var expected_files = [
		# Characters - Player
		"res://src/characters/player/player.tscn",
		"res://src/characters/player/player.gd",
		"res://src/characters/player/player_trail.tscn",
		"res://src/characters/player/player_trail.gd",
		
		# Characters - NPCs
		"res://src/characters/npcs/human.tscn",
		"res://src/characters/npcs/human.gd",
		"res://src/characters/npcs/human_npc.tscn",
		"res://src/characters/npcs/human_npc.gd",
		
		# Projectiles
		"res://src/projectiles/coin_projectile.tscn",
		"res://src/projectiles/coin_projectile.gd",
		
		# PowerUps
		"res://src/powerups/power_up.tscn",
		"res://src/powerups/power_up.gd",
		
		# Environment - Road
		"res://src/environment/road/road_segment.tscn",
		"res://src/environment/road/road_segment.gd",
		"res://src/environment/road/road_tile.tscn",
		"res://src/environment/road/road_generator.gd",
		"res://src/environment/road/road_spawner.gd",
		
		# Gameplay
		"res://src/gameplay/main_game.tscn",
		"res://src/gameplay/main_game.gd",
		
		# UI
		"res://src/ui/screens/start_screen.tscn",
		"res://src/ui/screens/start_screen.gd",
	]
	
	var missing_files = []
	var all_present = true
	
	for file_path in expected_files:
		var file = FileAccess.open(file_path, FileAccess.READ)
		if not file:
			missing_files.append(file_path)
			all_present = false
	
	if all_present:
		print("All essential files are present in their new locations!")
	else:
		print("The following files are missing:")
		for missing_file in missing_files:
			print("  - ", missing_file)
		
		print("\nMake sure to run the necessary copy commands for these files.")
	
	# Check if project directories have been created
	var expected_dirs = [
		"res://src/autoload",
		"res://src/core",
		"res://src/ui/screens",
		"res://src/ui/components",
		"res://src/characters/player",
		"res://src/characters/npcs",
		"res://src/projectiles",
		"res://src/powerups",
		"res://src/environment/road",
		"res://src/environment/obstacles",
		"res://src/gameplay"
	]
	
	var missing_dirs = []
	for dir_path in expected_dirs:
		var dir = DirAccess.open(dir_path)
		if not dir:
			missing_dirs.append(dir_path)
	
	if missing_dirs.size() > 0:
		print("\nThe following directories are missing:")
		for missing_dir in missing_dirs:
			print("  - ", missing_dir)
		
		print("\nMake sure to create these directories.")
	else:
		print("All required directories have been created!")
	
	print("\nVerification completed!") 
