extends Node

class_name ISpawner

# Abstract methods that must be implemented by concrete spawners
func initialize() -> void:
	push_error("initialize() method must be implemented by derived class")
	pass

func spawn_at_position(position: Vector2) -> Node:
	push_error("spawn_at_position() method must be implemented by derived class")
	return null

func set_spawn_parameters(parameters: Dictionary) -> void:
	push_error("set_spawn_parameters() method must be implemented by derived class")
	pass

func enable() -> void:
	set_process(true)
	set_physics_process(true)

func disable() -> void:
	set_process(false)
	set_physics_process(false)

# Common helper methods can be implemented here
func log_debug(message: String) -> void:
	if OS.is_debug_build():
		print("[%s] %s" % [get_class(), message])
