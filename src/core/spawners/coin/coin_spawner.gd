extends Node

@export var projectiles: Array[BaseProjectile] = []
@export var spawn_interval: float = 2.0  # Time between spawns
@export var spawn_area: Vector2 = Vector2(1000, 600)  # Area in which to spawn projectiles
@export var projectile_speed: float = 200.0  # Speed of projectiles

var timer: Timer
var coin_scene = preload("res://src/projectiles/coin_projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = spawn_interval
	timer.connect("timeout", Callable(self, "spawn_projectiles"))
	timer.autostart = true
	add_child(timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func spawn_projectiles() -> void:
	if projectiles.size() == 0:
		return
		
	# Choose a random projectile from the array
	var projectile_resource = projectiles[randi() % projectiles.size()]
	
	# Create instance of the coin scene
	var coin_instance = coin_scene.instantiate()
	
	# Set the projectile resource
	coin_instance.projectile_resource = projectile_resource
	
	# Set random position within spawn area
	var rand_x = randf_range(-spawn_area.x/2, spawn_area.x/2)
	var rand_y = randf_range(-spawn_area.y/2, spawn_area.y/2)
	coin_instance.position = Vector2(rand_x, rand_y)
	
	# Set downward velocity
	coin_instance.set_speed(projectile_speed)
	coin_instance.set_velocity(Vector2(0, projectile_speed))  # Moving downward
	
	# Add to scene
	add_child(coin_instance)
