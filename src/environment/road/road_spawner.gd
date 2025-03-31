extends Node2D

# Settings
var segment_height = 600
var min_obstacles = 0
var max_obstacles = 1
var spawn_humans = true
var spawn_human_chance = 0.9
var human_limit = 50
var min_powerups = 0
var max_powerups = 2
var spawn_powerup_chance = 0.3

# Settings for human speed (can be set by game mode manager)
var human_speed = 50.0
var spawn_rate_multiplier = 1.0

# Tracking
var current_segment_top_y = 0
var segments = []
var camera_ref = null
var active_humans = 0
var powerup_manager = null
var road_segment_count = 0

# Scenes
@onready var road_segment_scene = preload("res://src/environment/road/road_segment.tscn")
@onready var powerup_scene = preload("res://src/powerups/power_up.tscn")

# NPC Spawner reference
var npc_spawner = null

# Called when the node enters the tree for the first time.
func _ready():
	if get_parent().has_node("PowerUpManager"):
		powerup_manager = get_parent().get_node("PowerUpManager")
	
	# Initialize NPC spawner
	initialize_npc_spawner()
	
	print("RoadSpawner initialized")
	current_segment_top_y = 0

# Initialize or get the NPC spawner
func initialize_npc_spawner():
	# Try to find an existing NPC spawner in the parent
	npc_spawner = get_parent().get_node_or_null("NPCSpawner")
	
	# If not found, create a new one
	if not npc_spawner:
		var NpcSpawnerScene = load("res://src/characters/npcs/npc_spawner.tscn")
		npc_spawner = NpcSpawnerScene.instantiate()
		get_parent().add_child(npc_spawner)
		print("Created new NPC spawner")
	
	# Set initial settings
	npc_spawner.set_npc_speed(human_speed)
	npc_spawner.set_npc_limit(human_limit)
	
	# Connect to the npc_died signal
	npc_spawner.connect("npc_died", _on_npc_died)

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
				# Before removing, check if there are humans on this segment that should be respawned
				respawn_humans_from_segment(segment)
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

# Alias for backward compatibility
func generate_initial_segments():
	print("RoadSpawner: generate_initial_segments called (using force_spawn_initial_road_segments)")
	force_spawn_initial_road_segments()

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
	if spawn_humans and npc_spawner and npc_spawner.active_npcs < npc_spawner.npc_limit:
		var spawn_points = segment.get_node("HumanSpawnPoints").get_children()
		
		# Adjust based on spawn rate multiplier
		var adjusted_chance = spawn_human_chance * spawn_rate_multiplier
		
		for point in spawn_points:
			if randf() < adjusted_chance / spawn_points.size():
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

# Respawn humans from a segment that's about to be deleted
func respawn_humans_from_segment(segment):
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
			spawn_human(spawn_point.global_position)

# Spawn a human at a given position
func spawn_human(position):
	if not npc_spawner:
		return
	
	# Use NPC spawner to create a random NPC
	var npc = npc_spawner.spawn_npc(position)
	get_parent().add_child(npc)
	npc_spawner.active_npcs += 1
	active_humans += 1  # Keep old counter for compatibility

# Spawn a powerup at a given position
func spawn_powerup(position):
	if powerup_manager == null:
		return
		
	var powerup = powerup_scene.instantiate()
	var powerup_type = powerup_manager.get_random_powerup_type()
	powerup.global_position = position
	powerup.setup(powerup_type, powerup_manager.get_powerup_color(powerup_type), powerup_manager.get_powerup_duration(powerup_type))
	get_parent().add_child(powerup)

# Called when an NPC dies - respawn after delay
func _on_npc_died():
	# Decrement old counter for compatibility
	active_humans -= 1
	
	# Always spawn a new NPC when one dies (after a delay)
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = 1.0  # Reduced from 2.0 to 1.0 seconds
	timer.timeout.connect(func(): 
		# Clean up the timer
		timer.queue_free()
		
		# Find a segment to spawn in
		if segments.size() > 0:
			var random_segment = segments[randi() % segments.size()]
			if random_segment and is_instance_valid(random_segment):
				var spawn_points = random_segment.get_node("HumanSpawnPoints").get_children()
				if spawn_points.size() > 0:
					var point = spawn_points[randi() % spawn_points.size()]
					spawn_human(point.global_position)
	)
	add_child(timer)
	timer.start()

# Set human speed - affects NPCs spawned after this call
func set_human_speed(speed):
	human_speed = speed
	if npc_spawner:
		npc_spawner.set_npc_speed(speed)

# Log the current state (for debugging)
func log_state():
	print("Road generator state:")
	print("- Current segment top Y: ", current_segment_top_y)
	print("- Active segments: ", segments.size())
	print("- Active humans: ", active_humans)
	print("- Human speed: ", human_speed)
	print("- Spawn rate multiplier: ", spawn_rate_multiplier)
	if camera_ref != null:
		print("- Camera position: ", camera_ref.global_position)
		print("- Camera top edge: ", get_camera_top_edge())
		print("- Camera bottom edge: ", get_camera_bottom_edge()) 
