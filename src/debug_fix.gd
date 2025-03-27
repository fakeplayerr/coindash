@tool
extends EditorScript

# Debug and Fix Script
# This script should be run from the Godot editor
# It will diagnose and fix common issues with the project

func _run():
	print("======= DEBUG AND FIX SCRIPT STARTING =======")
	
	# 1. Check for existing autoloads and verify paths
	check_autoloads()
	
	# 2. Verify critical scenes and files
	verify_critical_files()
	
	# 3. Check for path issues
	check_paths()
	
	# 4. Test loading resources
	test_resource_loading()
	
	print("======= DEBUG AND FIX SCRIPT COMPLETED =======")
	print("Open the Godot editor and configure the autoloads in Project Settings:")
	print("- SaveManager: res://src/autoload/save_manager.tscn (Node name: SaveManager)")
	print("- GameAssetsClass: res://src/autoload/game_assets.gd (Node name: GameAssetsClass)")
	print("- Transition: res://src/autoload/transition.tscn (Node name: Transition)")
	print("- Autoload: res://src/autoload/autoload.tscn (Node name: Autoload)")
	print("Set the Main Scene to: res://src/ui/screens/start_screen.tscn")

func check_autoloads():
	print("\n--- Checking Autoloads ---")
	var autoload_files = {
		"SaveManager": "res://src/autoload/save_manager.tscn",
		"GameAssetsClass": "res://src/autoload/game_assets.gd",
		"Transition": "res://src/autoload/transition.tscn",
		"Autoload": "res://src/autoload/autoload.tscn"
	}
	
	for autoload_name in autoload_files:
		var file_path = autoload_files[autoload_name]
		if FileAccess.file_exists(file_path):
			print("✅ " + autoload_name + " file exists at: " + file_path)
		else:
			print("❌ " + autoload_name + " file NOT FOUND at: " + file_path)
			# If it's a missing .tscn file, try to find in original locations
			if file_path.ends_with(".tscn"):
				var original_path = "res://scenes/" + file_path.get_file()
				if FileAccess.file_exists(original_path):
					print("   Found at original path: " + original_path)
					print("   Please copy or move this file to: " + file_path)

func verify_critical_files():
	print("\n--- Verifying Critical Files ---")
	var critical_files = [
		"res://src/ui/screens/start_screen.tscn",
		"res://src/ui/screens/car_select_screen.tscn",
		"res://src/ui/screens/upgrades_screen.tscn",
		"res://src/ui/screens/game_over.tscn",
		"res://src/gameplay/main_game.tscn",
		"res://src/characters/player/player.tscn",
		"res://src/gameplay/camera/camera_controller.tscn"
	]
	
	for file_path in critical_files:
		if FileAccess.file_exists(file_path):
			print("✅ " + file_path + " exists")
		else:
			print("❌ " + file_path + " NOT FOUND")
			# Try to find the file in the original structure
			var original_path = "res://scenes/" + file_path.get_file()
			if FileAccess.file_exists(original_path):
				print("   Found at original path: " + original_path)

func check_paths():
	print("\n--- Checking Critical Path References ---")
	
	# Check car_select_screen.gd for incorrect paths
	var car_select_path = "res://src/ui/screens/car_select_screen.gd"
	if FileAccess.file_exists(car_select_path):
		print("Checking: " + car_select_path)
		var file = FileAccess.open(car_select_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		if content.find("res://src/start_screen.tscn") != -1:
			print("❌ Found incorrect path: res://src/start_screen.tscn")
			print("   Should be: res://src/ui/screens/start_screen.tscn")
		else:
			print("✅ No incorrect start screen path found")
	
	# Check upgrades_screen.gd for incorrect paths
	var upgrades_path = "res://src/ui/screens/upgrades_screen.gd"
	if FileAccess.file_exists(upgrades_path):
		print("Checking: " + upgrades_path)
		var file = FileAccess.open(upgrades_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		if content.find("res://src/start_screen.tscn") != -1:
			print("❌ Found incorrect path: res://src/start_screen.tscn")
			print("   Should be: res://src/ui/screens/start_screen.tscn")
		else:
			print("✅ No incorrect start screen path found")
	
	# Check main_game.gd for incorrect paths
	var main_game_path = "res://src/gameplay/main_game.gd"
	if FileAccess.file_exists(main_game_path):
		print("Checking: " + main_game_path)
		var file = FileAccess.open(main_game_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		if content.find("res://src/game_over.tscn") != -1:
			print("❌ Found incorrect path: res://src/game_over.tscn")
			print("   Should be: res://src/ui/screens/game_over.tscn")
		else:
			print("✅ No incorrect game over path found")

func test_resource_loading():
	print("\n--- Testing Resource Loading ---")
	
	# Test car textures
	print("Testing car texture loading:")
	var car_texture_path = "res://assets/general/PNG/Cars/car_red_1.png"
	if FileAccess.file_exists(car_texture_path):
		print("✅ Found car texture: " + car_texture_path)
	else:
		print("❌ Car texture NOT FOUND: " + car_texture_path)
		# Try to find cars in alternative locations
		var alt_paths = [
			"res://assets/Cars/car_red_1.png",
			"res://assets/general/Cars/car_red_1.png",
			"res://assets/textures/Cars/car_red_1.png"
		]
		
		for path in alt_paths:
			if FileAccess.file_exists(path):
				print("   Found at alternative path: " + path)
				print("   Your game_assets.gd needs to be updated with this path!")
				break 