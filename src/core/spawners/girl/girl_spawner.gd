extends Node

# Array to hold the girl scenes to spawn
@export var girl_scenes: Array[PackedScene] = []

# Time between spawns (in seconds)
@export var spawn_interval: float = 2.0

# Area within which to spawn girls (width, height)
@export var spawn_area: Vector2 = Vector2(1000, 100)

var timer: Timer

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.connect("timeout", Callable(self, "spawn_girls"))
	timer.autostart = true
	add_child(timer)

# Function to spawn girls
func spawn_girls() -> void:
	# Check if there are any girl scenes to spawn
	if girl_scenes.size() == 0:
		return
	
	# Choose a random girl scene from the array
	var girl_scene = girl_scenes[randi() % girl_scenes.size()]
	
	# Create an instance of the selected girl scene
	var girl_instance = girl_scene.instantiate()
	
	# Set random position within the spawn area
	var rand_x = randf_range(50, spawn_area.x)
	var rand_y = randf_range(50, spawn_area.y)
	girl_instance.position = Vector2(rand_x, rand_y)
	
	# Add the girl instance to the scene
	add_child(girl_instance)
