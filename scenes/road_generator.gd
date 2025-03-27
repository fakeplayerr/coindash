extends Node2D

class_name RoadSpawner

# Settings
var segment_height = 600
var min_obstacles = 0
var max_obstacles = 3
var spawn_humans = true
var spawn_human_chance = 0.5
var human_limit = 10
var min_powerups = 0
var max_powerups = 2
var spawn_powerup_chance = 0.3

# Tracking
var current_segment_top_y = 0
var segments = []
var camera_ref: Camera2D = null
var active_humans = 0
var powerup_manager = null
var road_segment_count = 0

# Scenes
@onready var road_segment_scene = preload("res://scenes/road_segment.tscn")
@onready var human_scene = preload("res://scenes/human.tscn")
@onready var powerup_scene = preload("res://scenes/power_up.tscn")

# Called when the node enters the tree for the first time.
func _ready():
	if get_parent().has_node("PowerUpManager"):
		powerup_manager = get_parent().get_node("PowerUpManager")
	print("RoadSpawner initialized")
	current_segment_top_y = 0

# Set the camera reference
func set_camera(camera):
	camera_ref = camera
	print("Camera reference set in RoadSpawner")

# Get the camera's visible height
func get_camera_visible_height():
	if camera_ref == null:
		print("WARNING: Camera reference is null in get_camera_visible_height")
		return 1200  # Default fallback
	
	var viewport_size = get_viewport_rect().size
	var zoom = camera_ref.zoom.y
	return viewport_size.y / zoom

# Get the camera's top edge position
func get_camera_top_edge():
	if camera_ref == null:
		print("WARNING: Camera reference is null in get_camera_top_edge")
		return 0
	
	var viewport_size = get_viewport_rect().size
	var zoom = camera_ref.zoom.y
	return camera_ref.global_position.y - (viewport_size.y / (2 * zoom))

# Get the camera's bottom edge position
func get_camera_bottom_edge():
	if camera_ref == null:
		print("WARNING: Camera reference is null in get_camera_bottom_edge")
		return 1200
	
	var viewport_size = get_viewport_rect().size
	var zoom = camera_ref.zoom.y
	return camera_ref.global_position.y + (viewport_size.y / (2 * zoom))

# Process for spawning and removing segments
func _process(_delta):
	update_segments()

# Update segments based on camera position
func update_segments():
	if camera_ref == null:
		return
		
	# Get camera view boundaries
	var top_edge = get_camera_top_edge()
	var bottom_edge = get_camera_bottom_edge()
	var visible_height = get_camera_visible_height()
	
	# Calculate how many segments we need ahead of the camera
	var segments_needed = ceil((bottom_edge - top_edge) / segment_height) + 2
	
	# Spawn segments ahead if needed
	while current_segment_top_y > top_edge - (segment_height * 2):
		spawn_road_segment(current_segment_top_y - segment_height)
		current_segment_top_y -= segment_height
	
	# Remove segments that are too far behind
	var max_behind_distance = visible_height * 1.5
	for segment in segments:
		if segment != null and is_instance_valid(segment):
			if segment.global_position.y > bottom_edge + max_behind_distance:
				segments.erase(segment)
				segment.queue_free()

# Force spawn initial road segments
func force_spawn_initial_road_segments():
	print("Generating initial road segments")
	
	# Determine how many segments we need
	var visible_height = 1200  # Default if camera not set
	if camera_ref != null:
		visible_height = get_camera_visible_height()
	
	var segments_needed = ceil(visible_height / segment_height) + 3
	
	# Reset tracking
	current_segment_top_y = 0
	for segment in segments:
		if segment != null and is_instance_valid(segment):
			segment.queue_free()
	segments.clear()
	
	# Spawn initial segments
	for i in range(segments_needed):
		spawn_road_segment(current_segment_top_y)
		current_segment_top_y += segment_height

# Spawn a single road segment
func spawn_road_segment(y_position):
	var segment = road_segment_scene.instantiate()
	segment.global_position = Vector2(0, y_position)
	add_child(segment)
	segments.append(segment)
	road_segment_count += 1
	
	# Add obstacles
	if max_obstacles > 0:
		var num_obstacles = randi() % (max_obstacles - min_obstacles + 1) + min_obstacles
		segment.generate_obstacles(num_obstacles)
	
	# Add humans
	if spawn_humans and active_humans < human_limit:
		var spawn_points = segment.get_node("HumanSpawnPoints").get_children()
		for point in spawn_points:
			if randf() < spawn_human_chance / spawn_points.size():
				spawn_human(point.global_position)
	
	# Add powerups
	if max_powerups > 0 and powerup_manager != null and randf() < spawn_powerup_chance:
		var num_powerups = randi() % (max_powerups - min_powerups + 1) + min_powerups
		var spawn_points = segment.get_node("PowerupSpawnPoints").get_children()
		for i in range(min(num_powerups, spawn_points.size())):
			var point = spawn_points[randi() % spawn_points.size()]
			spawn_points.erase(point)
			spawn_powerup(point.global_position)
	
	return segment

# Spawn a human at a given position
func spawn_human(position):
	var human = human_scene.instantiate()
	human.global_position = position
	get_parent().add_child(human)
	active_humans += 1
	human.connect("died", Callable(self, "_on_human_died"))

# Spawn a powerup at a given position
func spawn_powerup(position):
	if powerup_manager == null:
		return
		
	var powerup = powerup_scene.instantiate()
	var powerup_type = powerup_manager.get_random_powerup_type()
	powerup.global_position = position
	powerup.setup(powerup_type, powerup_manager.get_powerup_color(powerup_type), powerup_manager.get_powerup_duration(powerup_type))
	get_parent().add_child(powerup)

# Called when a human dies
func _on_human_died():
	active_humans -= 1

# Log the current state (for debugging)
func log_state():
	print("Road generator state:")
	print("- Current segment top Y: ", current_segment_top_y)
	print("- Active segments: ", segments.size())
	print("- Active humans: ", active_humans)
	if camera_ref != null:
		print("- Camera position: ", camera_ref.global_position)
		print("- Camera top edge: ", get_camera_top_edge())
		print("- Camera bottom edge: ", get_camera_bottom_edge()) 
