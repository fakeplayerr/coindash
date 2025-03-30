extends ISpawner

class_name PowerupSpawner

# Reference to power-up scene
const PowerUp = preload("res://src/powerups/power_up.tscn")

# Spawning parameters
var spawn_interval_min: float = 8.0
var spawn_interval_max: float = 15.0
var spawn_timer: float = 0.0
var next_spawn_time: float = 10.0
var spawn_distance: float = 800.0
var spawn_width_percentage: float = 0.8
var spawn_chance: float = 0.3
var min_powerups: int = 0
var max_powerups: int = 2

# Reference to required dependencies
var player: Node2D = null
var power_up_manager = null
var parent_node: Node = null

# Reference to PowerUpManagerClass for instantiation if needed
const PowerUpManagerClass = preload("res://src/powerups/power_up_manager.gd")

signal powerup_collected(type)

func _init():
	# Set default name
	name = "PowerupSpawner"

func _ready():
	# Initialize on ready
	initialize()
	
func _process(delta):
	if not player or not is_processing():
		return
		
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_time:
		spawn_random_powerup()
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

# Implementation of ISpawner interface
func initialize() -> void:
	# If parent node is not set, use the current parent
	if parent_node == null:
		parent_node = get_parent()
		
	# Set initial spawn time
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Try to get power-up manager reference
	ensure_powerup_manager()
	
	log_debug("Initialized")

# Ensure we have a reference to the PowerUpManager
func ensure_powerup_manager() -> void:
	if power_up_manager != null:
		return
		
	# Try to find in parent
	if parent_node and parent_node.has_node("PowerUpManager"):
		power_up_manager = parent_node.get_node("PowerUpManager")
		log_debug("Found PowerUpManager in parent")
	# Try to find in root if it's a singleton
	elif get_node_or_null("/root/PowerUpManager"):
		power_up_manager = get_node("/root/PowerUpManager")
		log_debug("Using PowerUpManager singleton")
	# Create new instance
	else:
		power_up_manager = PowerUpManagerClass.new()
		add_child(power_up_manager)
		log_debug("Created new PowerUpManager instance")

# Set reference to player
func set_player(player_node: Node2D) -> void:
	player = player_node
	log_debug("Player reference set")

# Spawn a power-up at a given position
func spawn_at_position(position: Vector2) -> Node:
	ensure_powerup_manager()
	
	# Get a random power-up type
	var type = power_up_manager.get_random_powerup_type()
	
	# Create power-up instance
	var power_up = PowerUp.instantiate()
	power_up.global_position = position
	
	# Set power-up properties
	var color = power_up_manager.get_powerup_color(type)
	var duration = power_up_manager.get_powerup_duration(type)
	var name = power_up_manager.get_power_up_name(type)
	power_up.setup(name, color, duration)
	
	# Connect the collected signal
	power_up.connect("collected", _on_power_up_collected)
	
	# Add to parent node
	if parent_node:
		parent_node.add_child(power_up)
	else:
		add_child(power_up)
	
	log_debug("Spawned powerup of type %s at position %s" % [name, str(position)])
	
	return power_up

# Spawn a specific type of powerup at a position
func spawn_specific_powerup(type, position: Vector2) -> Node:
	ensure_powerup_manager()
	
	# Create power-up instance
	var power_up = PowerUp.instantiate()
	power_up.global_position = position
	
	# Set power-up properties
	var color = power_up_manager.get_powerup_color(type)
	var duration = power_up_manager.get_powerup_duration(type)
	var name = power_up_manager.get_power_up_name(type)
	power_up.setup(name, color, duration)
	
	# Connect the collected signal
	power_up.connect("collected", _on_power_up_collected)
	
	# Add to parent node
	if parent_node:
		parent_node.add_child(power_up)
	else:
		add_child(power_up)
	
	log_debug("Spawned specific powerup of type %s at position %s" % [name, str(position)])
	
	return power_up

# Spawn a random powerup ahead of the player
func spawn_random_powerup() -> Node:
	if not player:
		log_debug("Cannot spawn: Player reference not set")
		return null
		
	ensure_powerup_manager()
	
	# Position the power-up ahead of the player
	var viewport_size = get_viewport().get_visible_rect().size
	var x_pos = randf_range(viewport_size.x * (0.5 - spawn_width_percentage/2), 
						  viewport_size.x * (0.5 + spawn_width_percentage/2))
	var y_pos = player.global_position.y - spawn_distance
	
	return spawn_at_position(Vector2(x_pos, y_pos))

# Implement set_spawn_parameters
func set_spawn_parameters(parameters: Dictionary) -> void:
	if parameters.has("spawn_interval_min"):
		spawn_interval_min = parameters.spawn_interval_min
		
	if parameters.has("spawn_interval_max"):
		spawn_interval_max = parameters.spawn_interval_max
		
	if parameters.has("spawn_distance"):
		spawn_distance = parameters.spawn_distance
		
	if parameters.has("spawn_width_percentage"):
		spawn_width_percentage = parameters.spawn_width_percentage
		
	if parameters.has("spawn_chance"):
		spawn_chance = parameters.spawn_chance
		
	if parameters.has("min_powerups"):
		min_powerups = parameters.min_powerups
		
	if parameters.has("max_powerups"):
		max_powerups = parameters.max_powerups
	
	log_debug("Spawn parameters updated")

# Set the parent node where powerups will be added
func set_parent_node(node: Node) -> void:
	parent_node = node

# Set the spawn interval range (useful for upgrades)
func set_spawn_interval(min_time: float, max_time: float) -> void:
	spawn_interval_min = min_time
	spawn_interval_max = max_time
	log_debug("Spawn interval set to %.1f-%.1f seconds" % [min_time, max_time])

# Handle collected power-ups
func _on_power_up_collected(type) -> void:
	emit_signal("powerup_collected", type)
	
	# Forward to parent if it can handle it
	if parent_node and parent_node.has_method("collect_power_up"):
		parent_node.collect_power_up(type)
	# Otherwise try activating directly
	elif power_up_manager:
		var enum_type = type
		for type_enum in PowerUpManagerClass.PowerUpType:
			if power_up_manager.get_power_up_name(type_enum) == type:
				enum_type = type_enum
				break
		
		power_up_manager.activate_powerup(enum_type)
		log_debug("Activated %s directly through PowerUpManager" % type) 
