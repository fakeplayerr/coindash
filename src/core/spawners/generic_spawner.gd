extends Node

# Constants for spawn area configuration
const MIN_SPAWN_DISTANCE := 40.0
const MAX_SPAWN_ATTEMPTS := 10

# Spawn area markers
@onready var marker_1: Marker2D = $Point1
@onready var marker_2: Marker2D = $Point2
@onready var marker_3: Marker2D = $Point3
@onready var marker_4: Marker2D = $Point4

# Spawn configuration
@export var spawn_scene: PackedScene
@export var initial_spawn_count: int = 0
@export var spawn_timer: float = 0.0  # If > 0, spawns indefinitely at this interval

# Spawned instances tracking
var spawned_instances: Array[Node] = []
var spawn_timer_node: Timer

# Spawn area bounds
var spawn_bounds: Dictionary = {
	"min_x": 0.0,
	"max_x": 0.0,
	"min_y": 0.0,
	"max_y": 0.0
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_initialize_spawn_bounds()
	_spawn_initial_instances()
	_setup_spawn_timer()

# Spawn initial instances based on configuration
func _spawn_initial_instances() -> void:
	if initial_spawn_count > 0 and spawn_scene:
		spawn_multiple(initial_spawn_count)

# Setup spawn timer if configured
func _setup_spawn_timer() -> void:
	if spawn_timer > 0 and spawn_scene:
		spawn_timer_node = Timer.new()
		spawn_timer_node.wait_time = spawn_timer
		spawn_timer_node.one_shot = false
		spawn_timer_node.timeout.connect(_on_spawn_timer_timeout)
		add_child(spawn_timer_node)
		spawn_timer_node.start()

# Initialize the spawn area bounds based on marker positions
func _initialize_spawn_bounds() -> void:
	if not _validate_markers():
		push_error("GenericSpawner: Invalid marker configuration")
		return
		
	spawn_bounds = {
		"min_x": min(marker_1.position.x, marker_3.position.x),
		"max_x": max(marker_2.position.x, marker_4.position.x),
		"min_y": min(marker_1.position.y, marker_2.position.y),
		"max_y": max(marker_3.position.y, marker_4.position.y)
	}

# Validate that all markers exist and are properly configured
func _validate_markers() -> bool:
	return marker_1 != null and marker_2 != null and marker_3 != null and marker_4 != null

# Generate a random position within the spawn bounds
func _generate_random_position() -> Vector2:
	return Vector2(
		randf_range(spawn_bounds.min_x, spawn_bounds.max_x),
		randf_range(spawn_bounds.min_y, spawn_bounds.max_y)
	)

# Check if a position is too close to existing instances
func _is_position_valid(pos: Vector2) -> bool:
	for instance in spawned_instances:
		if instance.position.distance_to(pos) < MIN_SPAWN_DISTANCE:
			return false
	return true

# Find a valid spawn position
func _find_valid_spawn_position() -> Vector2:
	var attempts := 0
	var pos: Vector2
	
	while attempts < MAX_SPAWN_ATTEMPTS:
		pos = _generate_random_position()
		if _is_position_valid(pos):
			return pos
		attempts += 1
	
	# If no valid position found, return the last generated position
	push_warning("GenericSpawner: Could not find ideal spawn position after %d attempts" % MAX_SPAWN_ATTEMPTS)
	return pos

# Spawn a single instance
func spawn_instance() -> Node:
	if not spawn_scene:
		push_error("GenericSpawner: No spawn scene configured")
		return null
		
	var instance := spawn_scene.instantiate()
	var spawn_pos := _find_valid_spawn_position()
	
	instance.position = spawn_pos
	add_child(instance)
	spawned_instances.append(instance)
	_customize_instance(instance)
	
	return instance

# Spawn multiple instances
func spawn_multiple(count: int) -> Array[Node]:
	var instances: Array[Node] = []
	
	for i in count:
		var instance := spawn_instance()
		if instance:
			instances.append(instance)
	
	return instances

# Timer callback for continuous spawning
func _on_spawn_timer_timeout() -> void:
	spawn_instance()

# Remove an instance from tracking
func remove_instance(instance: Node) -> void:
	if instance in spawned_instances:
		spawned_instances.erase(instance)

# Clear all spawned instances
func clear_spawned_instances() -> void:
	for instance in spawned_instances:
		if is_instance_valid(instance):
			instance.queue_free()
	spawned_instances.clear()

# Get current spawn area bounds
func get_spawn_bounds() -> Dictionary:
	return spawn_bounds.duplicate()

# Get current number of spawned instances
func get_spawned_count() -> int:
	return spawned_instances.size()

# Override this method to add custom spawn logic
func _customize_instance(instance: Node) -> void:
	# To be implemented by child classes
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
