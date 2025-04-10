extends Node

# Array to hold the obstacle scenes to spawn
@export var obstacle_scenes: Array[PackedScene] = []

# Time between spawns (in seconds)
@export var spawn_interval: float = 5.0

# Area within which to spawn obstacles (width, height)
@export var spawn_area: Vector2 = Vector2(1000, 100)

# Speed of obstacles
@export var obstacle_speed: float = 300.0  # Slower than coins

# Define 5 different obstacle size types (scale factors)
var obstacle_sizes = [
	Vector2(1.0, 1.0),    # Default size (100%)
	Vector2(1.2, 1.2),    # 120% of default
	Vector2(1.5, 1.5),    # 150% of default
	Vector2(1.8, 1.8),    # 180% of default
	Vector2(2.2, 2.2)     # 220% of default (more than double)
]

var timer: Timer
var obstacle_script = preload("res://src/environment/obstacles/obstacle.gd")

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.connect("timeout", Callable(self, "spawn_obstacle"))
	timer.autostart = true
	add_child(timer)
	
	# Initialize with GameManager values if available
	if GameManager.has_method("get_projectile_speed"):
		#obstacle_speed = GameManager.get_projectile_speed() * 0.5  # Half speed of coins
		obstacle_speed = GameManager.get_projectile_speed() # Half speed of coins
	
	print("ObstacleSpawner initialized with speed: ", obstacle_speed)

# Function to spawn obstacles
func spawn_obstacle() -> void:
	# Check if there are any obstacle scenes to spawn
	if obstacle_scenes.size() == 0:
		return
	
	# Choose a random obstacle scene from the array
	var obstacle_scene = obstacle_scenes[randi() % obstacle_scenes.size()]
	
	# Create an instance of the selected obstacle scene
	var obstacle_instance = obstacle_scene.instantiate()
	
	# Set random position within the spawn area
	var rand_x = randf_range(50, spawn_area.x)
	var rand_y = randf_range(50, spawn_area.y)
	obstacle_instance.position = Vector2(rand_x, rand_y)
	
	# Configure the obstacle for movement and game-ending collision
	configure_obstacle(obstacle_instance)
	
	# Add the obstacle instance to the scene
	add_child(obstacle_instance)

# Configure the obstacle with the necessary components for movement and collision
func configure_obstacle(obstacle: Node2D) -> void:
	# Apply the obstacle script and set velocity
	if obstacle is StaticBody2D:
		# Change collision layer for proper interaction
		obstacle.collision_layer = 8  # Using a different layer for obstacles
		obstacle.collision_mask = 2   # Player is typically on layer 2
		
		# Apply our dedicated obstacle script
		obstacle.set_script(obstacle_script)
		
		# Choose a random size from our defined sizes
		var size_index = randi() % obstacle_sizes.size()
		var obstacle_size = obstacle_sizes[size_index]
		
		# Apply the size to all relevant nodes
		apply_size_to_obstacle(obstacle, obstacle_size)
		
		# Set the movement velocity (downward like coins)
		obstacle.velocity = Vector2(0, obstacle_speed)
		
		# Make sure the HitArea has the right collision properties
		if obstacle.has_node("HitArea"):
			var hit_area = obstacle.get_node("HitArea")
			hit_area.collision_layer = 8
			hit_area.collision_mask = 7  # Detect player (2) and projectiles (4+1)

# Apply size scaling to all relevant parts of the obstacle
func apply_size_to_obstacle(obstacle: Node2D, size: Vector2) -> void:
	# Set size property on the obstacle for reference
	obstacle.set_meta("size_factor", size)
	
	# Scale the entire obstacle node
	obstacle.scale = size
	
	# Store the size for potential use in the obstacle script
	if obstacle.has_method("set_size_factor"):
		obstacle.call("set_size_factor", size)

# Set obstacle speed (can be called externally for scaling difficulty)
func set_obstacle_speed(speed: float) -> void:
	obstacle_speed = speed
	print("ObstacleSpawner speed set to: ", speed)

# Set spawn interval (can be called externally for scaling difficulty)
func set_spawn_interval(interval: float) -> void:
	spawn_interval = interval
	timer.wait_time = interval
	print("ObstacleSpawner interval set to: ", interval) 
