extends Node2D

# Segment dimensions
var segment_height: float = 600.0
var segment_width: float = 1080.0

# Obstacle properties
var obstacle_chance: float = 0.0  # Set to 0.0 to disable obstacles completely
var max_obstacles: int = 6
var obstacle_colors: Array = [
	Color.DARK_RED,
	Color.DARK_BLUE,
	Color.DARK_GREEN,
	Color.DARK_ORANGE
]

# Human spawning properties
var human_spawn_chance: float = 0.5
var max_humans: int = 3

# Node references
@onready var obstacles_container: Node2D = $ObstaclesContainer
@onready var obstacle_template: StaticBody2D = $ObstaclesContainer/ObstacleTemplate
@onready var human_spawn_points: Node2D = $HumanSpawnPoints
@onready var powerup_spawn_points: Node2D = $PowerupSpawnPoints

# Try multiple possible screen notifier names
@onready var screen_notifier = _get_screen_notifier()

# Preload the human scene
var human_scene = preload("res://scenes/human.tscn")

# Debug variables
var debug_enabled: bool = true
var creation_time: float = 0.0

var obstacle_size = Vector2(50, 50)
var min_obstacle_distance = 120
var screen_width = 1080
var wall_padding = 80

func _ready():
	# Add to road segments group
	add_to_group("road_segments")
	
	# Record creation time
	creation_time = Time.get_ticks_msec() / 1000.0
	
	# Randomize obstacle placement
	generate_obstacles(max_obstacles)
	
	# Connect screen notifier if found
	_connect_screen_notifier()
	
	# Hide the template object
	if obstacle_template:
		obstacle_template.visible = false
		
	# Fallback cleaner in case screen notifier fails
	if debug_enabled:
		print("RoadSegment: Initialized at y=", global_position.y)

func _get_screen_notifier() -> VisibleOnScreenNotifier2D:
	# Try different possible notifier names
	var notifier = get_node_or_null("ScreenNotifier")
	if notifier: return notifier
	
	notifier = get_node_or_null("VisibleOnScreenNotifier2D")
	if notifier: return notifier
	
	# Try deeper search
	for child in get_children():
		if child is VisibleOnScreenNotifier2D:
			return child
	
	# Create one as last resort
	if debug_enabled:
		print("RoadSegment: Creating fallback screen notifier")
	
	var new_notifier = VisibleOnScreenNotifier2D.new()
	new_notifier.name = "ScreenNotifier"
	new_notifier.rect = Rect2(-segment_width/2, -segment_height/2, segment_width, segment_height)
	add_child(new_notifier)
	return new_notifier

func _connect_screen_notifier():
	if screen_notifier:
		# Disconnect existing connections if any
		if screen_notifier.is_connected("screen_exited", _on_screen_exited):
			screen_notifier.disconnect("screen_exited", _on_screen_exited)
		
		# Connect the signal
		screen_notifier.connect("screen_exited", _on_screen_exited)
		
		if debug_enabled:
			print("RoadSegment: Connected screen notifier")
	else:
		if debug_enabled:
			print("RoadSegment: WARNING - No screen notifier found!")

func _process(delta):
	# Fallback cleanup in case screen notifier doesn't work
	var camera = get_viewport().get_camera_2d()
	if camera:
		var camera_y = camera.global_position.y
		var lifetime = Time.get_ticks_msec() / 1000.0 - creation_time
		
		# If we're too far below camera and have existed for a while
		if global_position.y > camera_y + 2000 and lifetime > 5.0:
			if debug_enabled:
				print("RoadSegment: Fallback cleanup at y=", global_position.y)
			queue_free()

# Generate a given number of obstacles for this segment
func generate_obstacles(num_obstacles):
	if num_obstacles <= 0 or obstacle_template == null:
		return
	
	var available_positions = []
	
	# Generate fewer available positions across the road width with even more spacing
	var road_width = segment_width - (wall_padding * 2)
	var step_size = road_width / 6  # Reduced number of potential positions
	
	# Use fewer positions along the y-axis for more spacing
	for x in range(wall_padding + step_size, segment_width - wall_padding, step_size):
		for y in range(200, 400, 200):  # Only positions in the middle of the segment
			available_positions.append(Vector2(x, y))
	
	# Shuffle positions
	available_positions.shuffle()
	
	# Only create at most 1 obstacle per segment
	if available_positions.size() > 0 and randf() < 0.7:  # 70% chance to have an obstacle
		var pos = available_positions[0]
		var obstacle = obstacle_template.duplicate()
		obstacle.visible = true
		obstacle.position = pos
		
		# Randomly adjust the obstacle shape
		var shape = obstacle.get_node("CollisionShape2D")
		var rect = obstacle.get_node("ColorRect")
		
		if randf() > 0.5:
			# Horizontal obstacle
			shape.shape.size = Vector2(100, 50)
			rect.size = Vector2(100, 50)
			rect.position = Vector2(-50, -25)
			
			# Make sure collision shape matches exactly
			shape.position = Vector2.ZERO
		else:
			# Vertical obstacle
			shape.shape.size = Vector2(50, 100)
			rect.size = Vector2(50, 100)
			rect.position = Vector2(-25, -50)
			
			# Make sure collision shape matches exactly
			shape.position = Vector2.ZERO
		
		# Change color for better visibility
		rect.color = Color(0.8, 0.2, 0.2, 0.8)  # Semi-transparent red
		
		# Ensure collision is enabled
		shape.disabled = false
		obstacle.collision_layer = 2
		obstacle.collision_mask = 2
		
		obstacles_container.add_child(obstacle)
		
		# Debug output to verify obstacle properties
		if debug_enabled:
			print("Obstacle created at ", pos, " with size ", shape.shape.size)

# Increase minimum distance between obstacles
func is_too_close(pos, existing_positions):
	for existing_pos in existing_positions:
		if pos.distance_to(existing_pos) < 150:  # Increased from 120
			return true
	return false

# Get available spawn points for humans
func get_human_spawn_points() -> Array:
	if human_spawn_points:
		return human_spawn_points.get_children()
	return []

# Get available spawn points for power-ups
func get_powerup_spawn_points() -> Array:
	if powerup_spawn_points:
		return powerup_spawn_points.get_children()
	return []

# Called when the segment exits the screen
func _on_screen_exited():
	if debug_enabled:
		print("RoadSegment: Screen exited at y=", global_position.y)
	# Queue for deletion once off-screen
	queue_free()

# Spawn humans at available spawn points
func spawn_humans():
	var spawn_points = get_human_spawn_points()
	if spawn_points.size() == 0:
		return
	
	# Calculate how many humans to spawn
	var humans_to_spawn = randi_range(0, max_humans)
	
	# Shuffle spawn points for randomness
	spawn_points.shuffle()
	
	# Spawn humans at random points
	for i in range(min(humans_to_spawn, spawn_points.size())):
		if randf() <= human_spawn_chance:
			var human = human_scene.instantiate()
			add_child(human)
			human.position = spawn_points[i].position 