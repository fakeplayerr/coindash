extends ISpawner

class_name HumanSpawner

signal npc_died
signal request_spawn_point

# NPC scenes to spawn
var npc_scenes = {
	"human": preload("res://src/characters/npcs/human.tscn"),
	"girl1": preload("res://src/characters/npcs/girl1.tscn"),
	"girl2": preload("res://src/characters/npcs/girl2.tscn")
}

# Spawning parameters
var spawn_chance: float = 0.9
var spawn_rate_multiplier: float = 1.0
var respawn_delay: float = 1.0

# Track active NPCs
var active_npcs: int = 0
var npc_limit: int = 50

# Speed settings
var base_speed: float = 50.0
var speed_variation: float = 10.0

# Parent node to add NPCs to
var parent_node: Node = null

func _init():
	# Set default name
	name = "HumanSpawner"

func _ready():
	# Initialize on ready
	initialize()

# Implementation of ISpawner interface
func initialize() -> void:
	# If parent node is not set, use the current parent
	if parent_node == null:
		parent_node = get_parent()
	
	log_debug("Initialized with NPC limit: %d" % npc_limit)

# Spawn an NPC at the given position
func spawn_at_position(position: Vector2) -> Node:
	if active_npcs >= npc_limit:
		log_debug("Cannot spawn: NPC limit reached (%d/%d)" % [active_npcs, npc_limit])
		return null
	
	# Choose a random NPC type
	var npc_types = npc_scenes.keys()
	var npc_type = npc_types[randi() % npc_types.size()]
	
	# Instantiate the chosen NPC
	var npc = npc_scenes[npc_type].instantiate()
	npc.global_position = position
	
	# Configure NPC speed with variation
	npc.speed = base_speed + randf_range(-speed_variation, speed_variation)
	
	# Connect the died signal
	if npc.has_signal("died"):
		npc.connect("died", _on_npc_died)
	
	# Add to parent node
	if parent_node:
		parent_node.add_child(npc)
	else:
		add_child(npc)
	
	# Track active NPCs count
	active_npcs += 1
	
	log_debug("Spawned NPC of type %s at position %s (%d/%d active)" % [
		npc_type, str(position), active_npcs, npc_limit
	])
	
	return npc

# Implement set_spawn_parameters
func set_spawn_parameters(parameters: Dictionary) -> void:
	if parameters.has("npc_limit"):
		npc_limit = parameters.npc_limit
		
	if parameters.has("base_speed"):
		base_speed = parameters.base_speed
		
	if parameters.has("spawn_chance"):
		spawn_chance = parameters.spawn_chance
		
	if parameters.has("spawn_rate_multiplier"):
		spawn_rate_multiplier = parameters.spawn_rate_multiplier
		
	if parameters.has("respawn_delay"):
		respawn_delay = parameters.respawn_delay
	
	log_debug("Spawn parameters updated")

# Set the parent node where NPCs will be added
func set_parent_node(node: Node) -> void:
	parent_node = node

# Set NPC speed
func set_npc_speed(speed: float) -> void:
	base_speed = speed
	log_debug("NPC base speed set to %.1f" % speed)

# Set NPC limit
func set_npc_limit(limit: int) -> void:
	npc_limit = limit
	log_debug("NPC limit set to %d" % limit)

# Track when an NPC dies
func _on_npc_died() -> void:
	active_npcs -= 1
	emit_signal("npc_died")
	
	# Schedule respawn if needed
	schedule_respawn()

# Schedule a respawn after delay
func schedule_respawn() -> void:
	if active_npcs >= npc_limit:
		return
		
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = respawn_delay
	timer.timeout.connect(func():
		timer.queue_free()
		request_spawn_at_random_position()
	)
	add_child(timer)
	timer.start()

# Request a spawn at a random position (to be implemented by road spawner)
func request_spawn_at_random_position() -> void:
	# This is a stub - the road spawner will actually find a valid position
	log_debug("Requesting a random spawn point")
	
	# Signal that we need a spawn point
	emit_signal("request_spawn_point") 
