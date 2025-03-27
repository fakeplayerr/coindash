@tool
extends EditorScript

# This script helps update file paths in the restructured project.
# Run this from the Godot editor using the Script Editor's "Run" button.

func _run():
	print("Starting path update process...")
	
	# Dictionary of old paths to new paths
	var path_mapping = {
		# Generic path prefixes (these don't work well with dictionary lookups)
		# We'll handle more specific paths first
		
		# Player characters
		"res://scenes/player.tscn": "res://src/characters/player/player.tscn",
		"res://scenes/player.gd": "res://src/characters/player/player.gd",
		"res://scenes/player_trail.tscn": "res://src/characters/player/player_trail.tscn",
		"res://scenes/player_trail.gd": "res://src/characters/player/player_trail.gd",
		
		# NPC characters
		"res://scenes/human.tscn": "res://src/characters/npcs/human.tscn",
		"res://scenes/human.gd": "res://src/characters/npcs/human.gd",
		"res://scenes/human_npc.tscn": "res://src/characters/npcs/human_npc.tscn",
		"res://scenes/human_npc.gd": "res://src/characters/npcs/human_npc.gd",
		
		# Projectiles
		"res://scenes/coin_projectile.tscn": "res://src/projectiles/coin_projectile.tscn",
		"res://scenes/coin_projectile.gd": "res://src/projectiles/coin_projectile.gd",
		
		# Power-ups
		"res://scenes/power_up.tscn": "res://src/powerups/power_up.tscn",
		"res://scenes/power_up.gd": "res://src/powerups/power_up.gd",
		"res://scenes/power_up_manager.gd": "res://src/powerups/power_up_manager.gd",
		"res://scenes/power_up_spawner.gd": "res://src/powerups/power_up_spawner.gd",
		"res://scripts/power_up_manager.gd": "res://src/powerups/power_up_manager.gd",
		"res://scripts/power_up_spawner.gd": "res://src/powerups/power_up_spawner.gd",
		
		# Environment - Road
		"res://scenes/road_segment.tscn": "res://src/environment/road/road_segment.tscn",
		"res://scenes/road_segment.gd": "res://src/environment/road/road_segment.gd",
		"res://scenes/road_tile.tscn": "res://src/environment/road/road_tile.tscn",
		"res://scenes/road_tile.gd": "res://src/environment/road/road_tile.gd",
		"res://scenes/road_generator.gd": "res://src/environment/road/road_generator.gd",
		"res://scenes/road_spawner.gd": "res://src/environment/road/road_spawner.gd",
		
		# Gameplay
		"res://scenes/main_game.tscn": "res://src/gameplay/main_game.tscn",
		"res://scenes/main_game.gd": "res://src/gameplay/main_game.gd",
		"res://scenes/load_selected_car.gd": "res://src/gameplay/load_selected_car.gd",
		
		# Camera
		"res://scenes/camera_controller.gd": "res://src/gameplay/camera/camera_controller.gd",
		"res://scenes/camera_controller.tscn": "res://src/gameplay/camera/camera_controller.tscn",
		
		# UI - Screens
		"res://scenes/start_screen.tscn": "res://src/ui/screens/start_screen.tscn",
		"res://scenes/start_screen.gd": "res://src/ui/screens/start_screen.gd",
		"res://scenes/car_select_screen.tscn": "res://src/ui/screens/car_select_screen.tscn",
		"res://scenes/car_select_screen.gd": "res://src/ui/screens/car_select_screen.gd",
		"res://scenes/game_over.tscn": "res://src/ui/screens/game_over.tscn",
		"res://scenes/game_over.gd": "res://src/ui/screens/game_over.gd",
		"res://scenes/upgrades_screen.tscn": "res://src/ui/screens/upgrades_screen.tscn",
		"res://scenes/upgrades_screen.gd": "res://src/ui/screens/upgrades_screen.gd",
		
		# UI - Components
		"res://scenes/ui_animations.tscn": "res://src/ui/components/ui_animations.tscn",
		"res://scenes/ui_animations.gd": "res://src/ui/components/ui_animations.gd",
		"res://scenes/upgrade_effect.tscn": "res://src/ui/components/upgrade_effect.tscn",
		"res://scenes/upgrade_effect.gd": "res://src/ui/components/upgrade_effect.gd",
		"res://scenes/coin_collect_effect.tscn": "res://src/ui/components/coin_collect_effect.tscn",
		"res://scenes/coin_collect_effect.gd": "res://src/ui/components/coin_collect_effect.gd",
		
		# Core systems
		"res://scenes/screen_shake.gd": "res://src/core/screen_shake.gd",
		"res://scripts/timer_manager.gd": "res://src/core/timer_manager.gd",
		
		# Autoload
		"res://scenes/save_manager.tscn": "res://src/autoload/save_manager.tscn",
		"res://scenes/save_manager.gd": "res://src/autoload/save_manager.gd",
		"res://scenes/transition.tscn": "res://src/autoload/transition.tscn",
		"res://scenes/transition.gd": "res://src/autoload/transition.gd",
		"res://scenes/autoload.tscn": "res://src/autoload/autoload.tscn",
		"res://scenes/autoload.gd": "res://src/autoload/autoload.gd",
		"res://scripts/game_assets.gd": "res://src/autoload/game_assets.gd",
		
		# Environment - Parallax
		"res://scenes/parallax_background.tscn": "res://src/environment/parallax_background.tscn",
		"res://scenes/parallax_background.gd": "res://src/environment/parallax_background.gd"
	}
	
	# Get all script and scene files in the src directory
	var src_dir = "res://src"
	process_directory(src_dir, path_mapping)
	
	print("Path update process completed!")
	print("Don't forget to update your autoloads and main scene in Project Settings!")

func process_directory(dir_path: String, path_mapping: Dictionary):
	var dir = DirAccess.open(dir_path)
	if not dir:
		print("Error opening directory: ", dir_path)
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		var full_path = dir_path + "/" + file_name
		
		if dir.current_is_dir() and file_name != "." and file_name != "..":
			# Process subdirectory
			process_directory(full_path, path_mapping)
		elif file_name.ends_with(".tscn") or file_name.ends_with(".gd"):
			# Process script or scene file
			update_file_paths(full_path, path_mapping)
		
		file_name = dir.get_next()
	
	dir.list_dir_end()

func update_file_paths(file_path: String, path_mapping: Dictionary):
	print("Processing file: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error opening file: ", file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	var modified = false
	
	# Replace specific path mappings first
	for old_path in path_mapping:
		if content.find(old_path) != -1:
			content = content.replace(old_path, path_mapping[old_path])
			modified = true
			print("  - Replaced: ", old_path, " → ", path_mapping[old_path])
	
	# After specific replacements, try to catch any remaining "res://scenes/" or "res://scripts/" references
	if content.find("res://scenes/") != -1:
		print("  - Found remaining res://scenes/ references")
		# Don't do a blind replacement as it could cause issues - log it for manual review
	
	if content.find("res://scripts/") != -1:
		print("  - Found remaining res://scripts/ references")
		# Don't do a blind replacement as it could cause issues - log it for manual review
	
	if modified:
		print("  - Updated paths in: ", file_path)
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		if not write_file:
			print("Error writing to file: ", file_path)
			return
		
		write_file.store_string(content)
		write_file.close()
	else:
		print("  - No changes needed for: ", file_path) 
