extends Node2D
class_name PowerUpSpawner

# Reference to power-up scene and manager
const PowerUp = preload("res://src/powerups/power_up.tscn")
const PowerUpManagerClass = preload("res://src/powerups/power_up_manager.gd")

# Spawning parameters
var spawn_interval_min: float = 8.0  # Minimum time between spawns
var spawn_interval_max: float = 15.0  # Maximum time between spawns
var spawn_timer: float = 0.0          # Current spawn timer
var next_spawn_time: float = 10.0     # Time until next spawn
var spawn_distance: float = 800.0     # Distance ahead to spawn power-ups
var spawn_width: float = 0.8          # Percentage of screen width for spawning (0.0-1.0)

# Reference to player
var player: Node2D
var power_up_manager = null

# Called when the node enters the tree for the first time
func _ready():
	# Set initial spawn time
	next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)
	
	# Try to get power-up manager reference
	if get_parent() and get_parent().has_node("PowerUpManager"):
		power_up_manager = get_parent().get_node("PowerUpManager")
	
	print("PowerUpSpawner: Ready to spawn power-ups")

# Set reference to player
func set_player(player_node: Node2D):
	player = player_node
	print("PowerUpSpawner: Player reference set")

# Process function - update timer and spawn power-ups
func _process(delta):
	if not player:
		return
		
	spawn_timer += delta
	
	if spawn_timer >= next_spawn_time:
		spawn_power_up()
		spawn_timer = 0.0
		next_spawn_time = randf_range(spawn_interval_min, spawn_interval_max)

# Spawn a power-up at a random position ahead of the player
func spawn_power_up():
	# Ensure we have the power-up manager
	if not power_up_manager:
		if get_parent() and get_parent().has_node("PowerUpManager"):
			power_up_manager = get_parent().get_node("PowerUpManager")
		else:
			power_up_manager = PowerUpManagerClass.new()
			add_child(power_up_manager)
	
	# Get a random power-up type
	var type = power_up_manager.get_random_powerup_type()
	
	# Create power-up instance
	var power_up = PowerUp.instantiate()
	
	# Position the power-up ahead of the player
	var viewport_size = get_viewport_rect().size
	var x_pos = randf_range(viewport_size.x * (0.5 - spawn_width/2), viewport_size.x * (0.5 + spawn_width/2))
	var y_pos = player.global_position.y - spawn_distance
	
	power_up.global_position = Vector2(x_pos, y_pos)
	
	# Set power-up properties (using the new setup function)
	var color = power_up_manager.get_powerup_color(type)
	var duration = power_up_manager.get_powerup_duration(type)
	var name = power_up_manager.get_power_up_name(type)
	power_up.setup(name, color, duration)
	
	# Connect the collected signal
	power_up.connect("collected", Callable(self, "_on_power_up_collected"))
	
	# Add to scene
	add_child(power_up)
	
	print("PowerUpSpawner: Spawned %s at position (%d, %d)" % [
		name,
		x_pos, 
		y_pos
	])

# Set the spawn interval range (useful for upgrades)
func set_spawn_interval(min_time: float, max_time: float):
	spawn_interval_min = min_time
	spawn_interval_max = max_time
	print("PowerUpSpawner: Spawn interval set to %.1f-%.1f seconds" % [min_time, max_time])

# Force an immediate spawn of a specific power-up type
func force_spawn(type, position: Vector2 = Vector2.ZERO):
	# Ensure we have the power-up manager
	if not power_up_manager:
		if get_parent() and get_parent().has_node("PowerUpManager"):
			power_up_manager = get_parent().get_node("PowerUpManager")
		else:
			power_up_manager = PowerUpManagerClass.new()
			add_child(power_up_manager)
	
	# Create power-up instance
	var power_up = PowerUp.instantiate()
	
	# Position the power-up (use provided position or default ahead of player)
	if position == Vector2.ZERO and player:
		var viewport_size = get_viewport_rect().size
		var x_pos = randf_range(viewport_size.x * (0.5 - spawn_width/2), viewport_size.x * (0.5 + spawn_width/2))
		var y_pos = player.global_position.y - spawn_distance * 0.5
		power_up.global_position = Vector2(x_pos, y_pos)
	else:
		power_up.global_position = position
	
	# Set power-up properties
	var color = power_up_manager.get_powerup_color(type)
	var duration = power_up_manager.get_powerup_duration(type)
	var name = power_up_manager.get_power_up_name(type)
	power_up.setup(name, color, duration)
	
	# Connect the collected signal
	power_up.connect("collected", Callable(self, "_on_power_up_collected"))
	
	# Add to scene
	add_child(power_up)
	
	print("PowerUpSpawner: Force spawned %s" % name)

# Handle collected power-ups
func _on_power_up_collected(type):
	# Forward to parent (main game)
	if get_parent() and get_parent().has_method("collect_power_up"):
		get_parent().collect_power_up(type)
	
	# If no parent can handle it, try activating directly in PowerUpManager
	elif power_up_manager:
		# Convert string type to enum if needed
		var enum_type = type
		for type_enum in PowerUpManagerClass.PowerUpType:
			if power_up_manager.get_power_up_name(type_enum) == type:
				enum_type = type_enum
				break
		
		power_up_manager.activate_powerup(enum_type)
		print("PowerUpSpawner: Activated %s directly" % type) 
