extends Node

signal save_manager_ready

var save_manager: Node

func _ready():
	print("Autoload: Initializing")
	
	# Get the SaveManager that's already registered in project settings
	save_manager = get_node_or_null("/root/SaveManager")
	
	if save_manager:
		print("Autoload: Found SaveManager at path: " + str(save_manager.get_path()))
		
		# Wait for SaveManager to be fully initialized
		await get_tree().process_frame
		await get_tree().process_frame
		
		# Notify other nodes that the save manager is ready
		emit_signal("save_manager_ready")
		print("Autoload: save_manager_ready signal emitted")
	else:
		print("Autoload ERROR: SaveManager not found at /root/SaveManager!")
	
	#var ui_animations = preload("res://scenes/ui_animations.tscn").instantiate()
	#get_tree().root.add_child.call_deferred(ui_animations)
	
	
	
	# Wait for next frame to ensure everything is initialized
	#await get_tree().process_frame
	# Create and add SaveManager
	
	# Create and add UI Animations
	
