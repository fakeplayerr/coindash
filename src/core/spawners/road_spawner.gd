extends ISpawner

class_name RoadSpawner

# Scene references
var road_segment_scene = preload("res://src/environment/road/road_segment.tscn")

# Settings
var segment_height: float = 600
var min_obstacles: int = 0
var max_obstacles: int = 1

# Tracking
var current_segment_top_y: float = 0
var segments: Array = []
var camera_ref = null
var road_segment_count: int = 0

# References to other spawners
var human_spawner: HumanSpawner = null
var powerup_spawner: PowerupSpawner = null

signal segment_created(segment, position)
signal segment_removed(segment)

func _init():
	# Set default name
	name = "RoadSpawner"

func _ready():
	# Initialize on ready
	initialize()

func _process(_delta):
	if not is_processing():
		return
		
	update_segments()

# Implementation of ISpawner interface
func initialize() -> void:
	log_debug("Initialized")
	current_segment_top_y = 0
	
	# Create initial segments
	var viewport_size = get_viewport().get_visible_rect().size
	var segments_needed = ceil(viewport_size.y / segment_height) + 3
	
	for i in range(segments_needed):
		spawn_road_segment(current_segment_top_y)
		current_segment_top_y += segment_height

# Set camera reference
func set_camera(camera) -> void:
	camera_ref = camera
	log_debug("Camera reference set")

# Set human spawner reference
func set_human_spawner(spawner: HumanSpawner) -> void:
	human_spawner = spawner
	log_debug("Human spawner reference set")

# Set powerup spawner reference
func set_powerup_spawner(spawner: PowerupSpawner) -> void:
	powerup_spawner = spawner
	log_debug("Powerup spawner reference set")

# Implement spawn_at_position (though road segments are usually spawned at specific Y positions)
func spawn_at_position(position: Vector2) -> Node:
	return spawn_road_segment(position.y)

# Spawn a road segment at a specific Y position
func spawn_road_segment(y_position: float) -> Node:
	var segment = road_segment_scene.instantiate()
	segment.global_position = Vector2(0, y_position)
	add_child(segment)
	segments.append(segment)
	road_segment_count += 1
	
	# Add obstacles
	if max_obstacles > 0:
		var num_obstacles = randi() % (max_obstacles - min_obstacles + 1) + min_obstacles
		segment.generate_obstacles(num_obstacles)
	
	# Add humans if spawner is available
	if human_spawner:
		spawn_humans_on_segment(segment)
	
	# Add powerups if spawner is available
	if powerup_spawner:
		spawn_powerups_on_segment(segment)
	
	# Emit signal that a new segment was created
	emit_signal("segment_created", segment, segment.global_position)
	
	log_debug("Spawned road segment at y=%.1f (total: %d)" % [y_position, road_segment_count])
	
	return segment

# Spawn humans on a segment
func spawn_humans_on_segment(segment) -> void:
	if not human_spawner:
		return
		
	var spawn_points = segment.get_node("HumanSpawnPoints").get_children()
	
	# Calculate adjusted chance based on the human spawner's parameters
	var adjusted_chance = human_spawner.spawn_chance * human_spawner.spawn_rate_multiplier
	
	for point in spawn_points:
		if randf() < adjusted_chance / spawn_points.size():
			human_spawner.spawn_at_position(point.global_position)

# Spawn powerups on a segment
func spawn_powerups_on_segment(segment) -> void:
	if not powerup_spawner:
		return
		
	if powerup_spawner.max_powerups <= 0 or randf() >= powerup_spawner.spawn_chance:
		return
		
	var num_powerups = randi() % (powerup_spawner.max_powerups - powerup_spawner.min_powerups + 1) + powerup_spawner.min_powerups
	var spawn_points = segment.get_node("PowerupSpawnPoints").get_children()
	
	if spawn_points.size() == 0:
		return
		
	for i in range(min(num_powerups, spawn_points.size())):
		var point = spawn_points[randi() % spawn_points.size()]
		spawn_points.erase(point)
		powerup_spawner.spawn_at_position(point.global_position)

# Implement set_spawn_parameters
func set_spawn_parameters(parameters: Dictionary) -> void:
	if parameters.has("segment_height"):
		segment_height = parameters.segment_height
		
	if parameters.has("min_obstacles"):
		min_obstacles = parameters.min_obstacles
		
	if parameters.has("max_obstacles"):
		max_obstacles = parameters.max_obstacles
	
	log_debug("Spawn parameters updated")

# Update segments based on camera position
func update_segments() -> void:
	if camera_ref == null:
		return
		
	# Get camera view boundaries
	var top_edge = get_camera_top_edge()
	var bottom_edge = get_camera_bottom_edge()
	var visible_height = get_camera_visible_height()
	
	# Spawn segments ahead if needed
	while current_segment_top_y > top_edge - (segment_height * 2):
		spawn_road_segment(current_segment_top_y - segment_height)
		current_segment_top_y -= segment_height
	
	# Remove segments that are too far behind
	var max_behind_distance = visible_height * 1.5
	for segment in segments:
		if segment != null and is_instance_valid(segment):
			if segment.global_position.y > bottom_edge + max_behind_distance:
				# Before removing, check if there are humans on this segment that should be respawned
				if human_spawner:
					respawn_humans_from_segment(segment)
				segments.erase(segment)
				emit_signal("segment_removed", segment)
				segment.queue_free()

# Respawn humans from a segment that's about to be deleted
func respawn_humans_from_segment(segment) -> void:
	if not human_spawner:
		return
		
	# Find segments that are still visible
	var visible_segments = []
	for s in segments:
		if s != segment and is_instance_valid(s):
			visible_segments.append(s)
	
	if visible_segments.size() == 0:
		return  # No valid segments to respawn on
	
	# Get humans attached to this segment
	var humans_to_respawn = []
	for child in segment.get_children():
		if child.is_in_group("humans") and is_instance_valid(child):
			humans_to_respawn.append(child)
	
	# Respawn each human on a visible segment
	for human in humans_to_respawn:
		var target_segment = visible_segments[randi() % visible_segments.size()]
		var spawn_points = target_segment.get_node("HumanSpawnPoints").get_children()
		
		if spawn_points.size() > 0:
			var spawn_point = spawn_points[randi() % spawn_points.size()]
			human_spawner.spawn_at_position(spawn_point.global_position)

# Alias for backward compatibility
func force_spawn_initial_road_segments() -> void:
	log_debug("Force spawning initial road segments")
	initialize()

# Alias for backward compatibility
func generate_initial_segments() -> void:
	log_debug("Generating initial segments (alias for initialize)")
	initialize()

# Get the camera's visible height
func get_camera_visible_height() -> float:
	if camera_ref == null:
		log_debug("WARNING: Camera reference is null in get_camera_visible_height")
		return 1200  # Default fallback
	
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera_ref.zoom.y
	return viewport_size.y / zoom

# Get the camera's top edge position
func get_camera_top_edge() -> float:
	if camera_ref == null:
		log_debug("WARNING: Camera reference is null in get_camera_top_edge")
		return 0
	
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera_ref.zoom.y
	return camera_ref.global_position.y - (viewport_size.y / (2 * zoom))

# Get the camera's bottom edge position
func get_camera_bottom_edge() -> float:
	if camera_ref == null:
		log_debug("WARNING: Camera reference is null in get_camera_bottom_edge")
		return 1200
	
	var viewport_size = get_viewport().get_visible_rect().size
	var zoom = camera_ref.zoom.y
	return camera_ref.global_position.y + (viewport_size.y / (2 * zoom))

# Provide a spawn point for human spawner respawns
func get_random_spawn_point() -> Vector2:
	if segments.size() == 0:
		return Vector2.ZERO
		
	var random_segment = segments[randi() % segments.size()]
	if random_segment and is_instance_valid(random_segment):
		var spawn_points = random_segment.get_node("HumanSpawnPoints").get_children()
		if spawn_points.size() > 0:
			var point = spawn_points[randi() % spawn_points.size()]
			return point.global_position
			
	return Vector2.ZERO

# Log the current state (for debugging)
func log_state() -> void:
	log_debug("Road generator state:")
	log_debug("- Current segment top Y: %f" % current_segment_top_y)
	log_debug("- Active segments: %d" % segments.size())
	if camera_ref != null:
		log_debug("- Camera position: %s" % str(camera_ref.global_position))
		log_debug("- Camera top edge: %f" % get_camera_top_edge())
		log_debug("- Camera bottom edge: %f" % get_camera_bottom_edge()) 
