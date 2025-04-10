extends Node

class_name SpawnManager

# References to spawner classes
const HumanSpawnerClass = preload("res://src/core/spawners/human_spawner.gd")
const PowerupSpawnerClass = preload("res://src/core/spawners/powerup_spawner.gd")

# References to spawner instances
var human_spawner: HumanSpawner = null
var powerup_spawner: PowerupSpawner = null

# Game references
var player: Node2D = null
var camera: Node2D = null

# Configuration
var road_enabled: bool = true
var humans_enabled: bool = true
var powerups_enabled: bool = true

func _ready():
	initialize_spawners()
	
# Initialize all spawners
func initialize_spawners() -> void:
	if road_enabled:
		initialize_road_spawner()
	
	if humans_enabled:
		initialize_human_spawner()
	
	if powerups_enabled:
		initialize_powerup_spawner()
	
	# Connect spawners
	connect_spawners()
	
	print("SpawnManager: All spawners initialized")

# Initialize the road spawner
func initialize_road_spawner() -> void:

		
	# Initialize with defaults
	var road_params = {
		"segment_height": 600,
		"min_obstacles": 0,
		"max_obstacles": 1
	}
	
	print("SpawnManager: Road spawner initialized")

# Initialize the human spawner
func initialize_human_spawner() -> void:
	# Create if it doesn't exist
	if not human_spawner:
		human_spawner = HumanSpawnerClass.new()
		human_spawner.name = "HumanSpawner"
		add_child(human_spawner)
	
	# Set parent node to main scene
	human_spawner.set_parent_node(get_parent())
	
	# Initialize with defaults
	var human_params = {
		"npc_limit": 50,
		"base_speed": 50.0,
		"spawn_chance": 0.9,
		"spawn_rate_multiplier": 1.0,
		"respawn_delay": 1.0
	}
	human_spawner.set_spawn_parameters(human_params)
	
	print("SpawnManager: Human spawner initialized")

# Initialize the powerup spawner
func initialize_powerup_spawner() -> void:
	# Create if it doesn't exist
	if not powerup_spawner:
		powerup_spawner = PowerupSpawnerClass.new()
		powerup_spawner.name = "PowerupSpawner"
		add_child(powerup_spawner)
	
	# Set player reference if available
	if player:
		powerup_spawner.set_player(player)
	
	# Set parent node to main scene
	powerup_spawner.set_parent_node(get_parent())
	
	# Initialize with defaults
	var powerup_params = {
		"spawn_interval_min": 8.0,
		"spawn_interval_max": 15.0,
		"spawn_distance": 800.0,
		"spawn_width_percentage": 0.8,
		"spawn_chance": 0.3,
		"min_powerups": 0,
		"max_powerups": 2
	}
	powerup_spawner.set_spawn_parameters(powerup_params)
	
	print("SpawnManager: Powerup spawner initialized")

# Connect spawners to each other
func connect_spawners() -> void:
	
	print("SpawnManager: Spawners connected")

# Set player reference
func set_player(player_node: Node2D) -> void:
	player = player_node
	
	# Update existing spawners
	if powerup_spawner:
		powerup_spawner.set_player(player)
	
	print("SpawnManager: Player reference set")

# Set camera reference
func set_camera(camera_node: Node2D) -> void:
	camera = camera_node
	

	
	print("SpawnManager: Camera reference set")

# Enable/disable road spawner
func set_road_enabled(enabled: bool) -> void:
	road_enabled = enabled
	
	
	print("SpawnManager: Road spawner %s" % ("enabled" if enabled else "disabled"))

# Enable/disable human spawner
func set_humans_enabled(enabled: bool) -> void:
	humans_enabled = enabled
	
	if human_spawner:
		if enabled:
			human_spawner.enable()
		else:
			human_spawner.disable()
	elif enabled:
		# Create if it was disabled but now needed
		initialize_human_spawner()
	
	print("SpawnManager: Human spawner %s" % ("enabled" if enabled else "disabled"))

# Enable/disable powerup spawner
func set_powerups_enabled(enabled: bool) -> void:
	powerups_enabled = enabled
	
	if powerup_spawner:
		if enabled:
			powerup_spawner.enable()
		else:
			powerup_spawner.disable()
	elif enabled:
		# Create if it was disabled but now needed
		initialize_powerup_spawner()
	
	print("SpawnManager: Powerup spawner %s" % ("enabled" if enabled else "disabled"))

# Update human spawner parameters
func update_human_parameters(parameters: Dictionary) -> void:
	if human_spawner:
		human_spawner.set_spawn_parameters(parameters)
	
	print("SpawnManager: Human spawner parameters updated")

# Update powerup spawner parameters
func update_powerup_parameters(parameters: Dictionary) -> void:
	if powerup_spawner:
		powerup_spawner.set_spawn_parameters(parameters)
	
	print("SpawnManager: Powerup spawner parameters updated")

# Update road spawner parameters
func update_road_parameters(parameters: Dictionary) -> void:
	
	print("SpawnManager: Road spawner parameters updated")

# Set powerup spawn interval (convenience method)
func set_spawn_interval(min_time: float, max_time: float) -> void:
	if powerup_spawner:
		powerup_spawner.set_spawn_interval(min_time, max_time)
		print("SpawnManager: Powerup spawn interval set to %.1f-%.1f seconds" % [min_time, max_time])
	else:
		print("SpawnManager: Cannot set spawn interval - powerup spawner not initialized")

# Force spawn a human at a specific position
func spawn_human_at(position: Vector2) -> Node:
	if human_spawner:
		return human_spawner.spawn_at_position(position)
	return null

# Force spawn a powerup at a specific position
func spawn_powerup_at(position: Vector2, type = null) -> Node:
	if powerup_spawner:
		if type:
			return powerup_spawner.spawn_specific_powerup(type, position)
		else:
			return powerup_spawner.spawn_at_position(position)
	return null 
