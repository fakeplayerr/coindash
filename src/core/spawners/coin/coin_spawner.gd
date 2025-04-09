extends Node2D

@export var projectile_types: Array[BaseProjectile] = []  # Array of coin types to spawn
@export var spawn_points: Array[Vector2] = [Vector2(100, 0), Vector2(300, 0), Vector2(500, 0)]  # Configurable spawn points
@export var min_spawn_interval: float = 0.5  # Minimum time between spawns (seconds)
@export var max_spawn_interval: float = 2.0  # Maximum time between spawns (seconds)


var coin_scene = preload("res://src/projectiles/coin_projectile.tscn")
func _ready():
	start_spawning()
	

func start_spawning():
	print("Starting")
	var timer : Timer = Timer.new()
	timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	add_child(timer)
	timer.start()

func _on_timer_timeout():
	print("timeout")
	spawn_coin()
	var timer : Timer = Timer.new()
	timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	add_child(timer)
	timer.start()

func spawn_coin():
	print("Spawn")
	
	var coin = coin_scene.instantiate()
	coin.projectile_resource = projectile_types[randi() % projectile_types.size()]  # Random coin type
	var spawn_point = spawn_points[randi() % spawn_points.size()]  # Random spawn point
	coin.position = spawn_point
	get_parent().add_child(coin)  # Add to the game level scene
