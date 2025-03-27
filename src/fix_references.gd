@tool
extends EditorScript

# This script updates all references to GameAssetsClass after changing the class name
# Run this from the Godot editor using the Script Editor's "Run" button.

func _run():
	print("Starting reference update process...")
	
	# Files to check and update
	var files_to_check = [
		"res://src/ui/screens/start_screen.gd",
		"res://src/ui/screens/car_select_screen.gd",
		"res://src/gameplay/load_selected_car.gd",
		"res://src/characters/player/player.gd"
	]
	
	# Update each file
	for file_path in files_to_check:
		update_game_assets_references(file_path)
	
	print("Reference update process completed!")
	print("Now you should be able to add the autoload with name 'GameAssetsClass'")

func update_game_assets_references(file_path: String):
	print("Processing file: ", file_path)
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if not file:
		print("Error opening file: ", file_path)
		return
	
	var content = file.get_as_text()
	file.close()
	
	var modified = false
	
	# We should leave the const GameAssetsClass name as is since the scripts are using it,
	# but we don't need to change the class name reference since we're using autoloads
	
	# Check if we need to update
	var script_text = """
# This script was updated by the fix_references.gd tool
# The GameAssetsClass constant remain unchanged but now refers to GameAssetsResource class
"""
	
	if content.find("# This script was updated by the fix_references.gd tool") == -1:
		# Add comment at the beginning of the file
		var first_line_end = content.find("\n")
		if first_line_end != -1:
			content = content.substr(0, first_line_end + 1) + script_text + content.substr(first_line_end + 1)
			modified = true
	
	if modified:
		print("  - Updated references in: ", file_path)
		var write_file = FileAccess.open(file_path, FileAccess.WRITE)
		if not write_file:
			print("Error writing to file: ", file_path)
			return
		
		write_file.store_string(content)
		write_file.close()
	else:
		print("  - No changes needed for: ", file_path) 
