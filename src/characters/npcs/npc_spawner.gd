extends Node

# NPC scenes to spawn
var npc_scenes = {
	"human": preload("res://src/characters/npcs/human.tscn"),
	"girl1": preload("res://src/characters/npcs/girl1.tscn"),
	"girl2": preload("res://src/characters/npcs/girl2.tscn")
}

# Track active NPCs
var active_npcs = 0
var npc_limit = 50

# Speed settings - can be adjusted by game mode manager
var base_speed = 50.0
var speed_variation = 10.0  # Random variation in speed

signal npc_died

# Spawn an NPC at the given position
func spawn_npc(position: Vector2) -> Node2D:
	# Choose a random NPC type
	var npc_types = npc_scenes.keys()
	var npc_type = npc_types[randi() % npc_types.size()]
	
	# Instantiate the chosen NPC
	var npc = npc_scenes[npc_type].instantiate()
	npc.global_position = position
	
	# Configure NPC speed
	npc.speed = base_speed + randf_range(-speed_variation, speed_variation)
	
	# Connect the died signal
	if npc.has_signal("died"):
		npc.connect("died", _on_npc_died)
	
	# Track active NPCs count
	active_npcs += 1
	
	return npc

# Track when an NPC dies
func _on_npc_died() -> void:
	active_npcs -= 1
	emit_signal("npc_died")

# Set the speed for all NPCs
func set_npc_speed(speed: float) -> void:
	base_speed = speed

# Set the limit for active NPCs
func set_npc_limit(limit: int) -> void:
	npc_limit = limit 
