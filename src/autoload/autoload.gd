extends Node

signal save_manager_ready

# References to other autoload nodes/systems
var save_manager = null
var transition = null

func _ready():
	print("Autoload: Initializing...")
	
	# First check if other autoloads are already available
	_update_references()
	
	# Set a timer to check again after the scene tree is fully loaded
	call_deferred("_deferred_init")

func _deferred_init():
	print("Autoload: Running deferred initialization...")
	
	# Try to update references after a short delay
	get_tree().create_timer(0.1).timeout.connect(_update_references)
	get_tree().create_timer(0.5).timeout.connect(_update_references)
	get_tree().create_timer(1.0).timeout.connect(_update_references)
	
	# Also connect to scene tree changes to detect autoload nodes
	get_tree().node_added.connect(_on_node_added)
	
	# Debug print all nodes at root level
	print("Autoload: Current root nodes:")
	for node in get_tree().root.get_children():
		print(" - " + node.name)

func _on_node_added(node):
	# Check if this is an autoload node we're looking for
	if node.name == "SaveManager" or node.name == "Transition" or node.name == "GameAssetsClass":
		print("Autoload: Detected addition of: " + node.name)
		_update_references()

func _update_references():
	# Check for SaveManager
	if not save_manager or not is_instance_valid(save_manager):
		save_manager = get_node_or_null("/root/SaveManager")
		if save_manager:
			print("Autoload: Found SaveManager")
			emit_signal("save_manager_ready")
		else:
			# Try alternate approach if normal path fails
			for node in get_tree().root.get_children():
				if node.name == "SaveManager":
					save_manager = node
					print("Autoload: Found SaveManager via alternate method")
					emit_signal("save_manager_ready")
					break
	
	# Check for Transition
	if not transition or not is_instance_valid(transition):
		transition = get_node_or_null("/root/Transition") 
		if transition:
			print("Autoload: Found Transition")

# Provide direct access to SaveManager for any script
func get_save_manager():
	if save_manager:
		return save_manager
		
	# Try one more time to find it
	_update_references()
	return save_manager 
