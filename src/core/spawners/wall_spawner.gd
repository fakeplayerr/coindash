extends Node2D
class_name WallSpawner

@export var wall_scene: PackedScene
@export var num_walls_above: int = 2
@export var num_walls_below: int = 2
@export var vertical_gap: float = 50.0
@export var wall_speed: float = 100.0 # Speed for the walls to move downwards

# NOTE: This height is estimated based on the visual layout in walls.tscn (312 - 104).
# A more robust solution might calculate this dynamically or use collision shapes.
const WALL_SECTION_HEIGHT: float = 208.0

var initial_spawn_complete: bool = false
var total_walls_to_maintain: int = 0
var current_wall_count: int = 0
var topmost_wall_y: float = 0.0 # Keep track of the highest wall position


func _ready() -> void:
	if wall_scene == null:
		printerr("WallSpawner: 'wall_scene' is not set in the inspector!")
		return
		
	total_walls_to_maintain = num_walls_above + num_walls_below + 1 # Including the initial one
	spawn_initial_walls()
	initial_spawn_complete = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

# Renamed from spawn_walls to avoid confusion
func spawn_initial_walls() -> void:
	if wall_scene == null:
		printerr("WallSpawner: Cannot spawn walls, 'wall_scene' is not set.")
		return
		
	var total_vertical_offset = WALL_SECTION_HEIGHT + vertical_gap
	
	# Spawn the "center" wall (relative to the spawner's position)
	spawn_single_wall(position)
	topmost_wall_y = position.y # Initialize topmost_wall_y

	# Spawn walls above
	for i in range(1, num_walls_above + 1):
		var spawn_position = position + Vector2(0, -i * total_vertical_offset)
		spawn_single_wall(spawn_position)
		if spawn_position.y < topmost_wall_y:
			topmost_wall_y = spawn_position.y

	# Spawn walls below
	for i in range(1, num_walls_below + 1):
		var spawn_position = position + Vector2(0, i * total_vertical_offset)
		spawn_single_wall(spawn_position)
		# No need to update topmost_wall_y here
		
	print("Initial walls spawned. Target count: ", total_walls_to_maintain, " Current count: ", current_wall_count)


func spawn_single_wall(spawn_position: Vector2) -> void:
	if wall_scene == null:
		printerr("WallSpawner: 'wall_scene' not set.")
		return
		
	var wall_instance = wall_scene.instantiate()
	if wall_instance is RigidBody2D:
		wall_instance.position = spawn_position
		# Set the speed on the wall instance
		wall_instance.speed = wall_speed
		# Connect the wall_destroyed signal
		if wall_instance.has_signal("wall_destroyed"):
			wall_instance.wall_destroyed.connect(_on_wall_destroyed)
		else:
			printerr("Wall instance does not have 'wall_destroyed' signal.")
			
		add_child(wall_instance)
		current_wall_count += 1
		# print("Spawned wall at: ", spawn_position, " Count: ", current_wall_count) # Debug
	else:
		printerr("WallSpawner: Instantiated wall scene root is not a RigidBody2D or derived type.")
		if wall_instance is Node:
			wall_instance.free()


func _on_wall_destroyed() -> void:
	current_wall_count -= 1
	# print("Wall destroyed. Count: ", current_wall_count) # Debug

	# Find the new topmost wall position among remaining children
	var new_topmost_y = INF
	var found_wall = false
	for child in get_children():
		if child is RigidBody2D and child.has_method("get_instance_id"): # Basic check if it's likely a wall
			new_topmost_y = min(new_topmost_y, child.position.y)
			found_wall = true
			
	if found_wall:
		topmost_wall_y = new_topmost_y
	else:
		# If no walls left (e.g., during scene changes), reset 
		topmost_wall_y = position.y # Or some default starting position
		printerr("Spawner: No walls left after destruction?")
		# Consider respawning initial set if desired in this case
		return

	# Spawn a new wall above the current topmost one
	var total_vertical_offset = WALL_SECTION_HEIGHT + vertical_gap
	var new_spawn_position = Vector2(position.x, topmost_wall_y - total_vertical_offset)
	spawn_single_wall(new_spawn_position)
	topmost_wall_y = new_spawn_position.y # Update topmost immediately
	
	# Ensure we don't accidentally exceed the target count due to timing
	while current_wall_count > total_walls_to_maintain:
		printerr("Correcting excess wall count.")
		# Find and remove the lowest wall (should be rare)
		var lowest_wall = null
		var lowest_y = -INF
		for child in get_children():
			if child is RigidBody2D and child.has_method("get_instance_id"):
				if child.position.y > lowest_y:
					lowest_y = child.position.y
					lowest_wall = child
		if lowest_wall:
			lowest_wall.queue_free() # This should trigger _on_wall_destroyed again
			current_wall_count -= 1 # Decrement here too to avoid potential loops
		else:
			break # Should not happen


# Optional: Clear function might need update if used
# func clear_walls() -> void:
# 	for child in get_children():
# 		if wall_scene != null and child.scene_file_path == wall_scene.resource_path:
# 			child.queue_free()
# 	current_wall_count = 0
# 	topmost_wall_y = position.y

# Remove old spawn_walls function if it exists
# func spawn_walls(initial_position: Vector2) -> void:
# 	if wall_scene == null:
# 		printerr("WallSpawner: Cannot spawn walls, 'wall_scene' is not set.")
# 		return
# 
# 	var total_vertical_offset = WALL_SECTION_HEIGHT + vertical_gap
# 
# 	# Spawn walls above
# 	for i in range(1, num_walls_above + 1):
# 		var wall_instance = wall_scene.instantiate()
# 		if wall_instance is Node2D:
# 			var spawn_position = initial_position + Vector2(0, -i * total_vertical_offset)
# 			wall_instance.position = spawn_position
# 			add_child(wall_instance)
# 		else:
# 			printerr("WallSpawner: Instantiated wall scene root is not a Node2D.")
# 			if wall_instance is Node:
# 				wall_instance.free()
# 
# 
# 	# Spawn walls below
# 	for i in range(1, num_walls_below + 1):
# 		var wall_instance = wall_scene.instantiate()
# 		if wall_instance is Node2D:
# 			var spawn_position = initial_position + Vector2(0, i * total_vertical_offset)
# 			wall_instance.position = spawn_position
# 			add_child(wall_instance)
# 		else:
# 			printerr("WallSpawner: Instantiated wall scene root is not a Node2D.")
# 			if wall_instance is Node:
# 				wall_instance.free()
