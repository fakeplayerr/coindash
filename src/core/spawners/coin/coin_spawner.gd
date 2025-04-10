extends Node

@export var projectiles: Array[BaseProjectile] = []
@export var spawn_interval: float = 2.0  # Time between spawns
@export var spawn_area: Vector2 = Vector2(1000, 100)  # Area in which to spawn projectiles
@export var projectile_speed: float = 1000.0  # Speed of projectiles
@export var fire_rate: float = 1000.0  # Fire rate affects spawn interval

var timer: Timer
var coin_scene = preload("res://src/projectiles/coin_projectile.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Initialize timer
	timer = Timer.new()
	update_spawn_interval()
	timer.connect("timeout", Callable(self, "spawn_projectiles"))
	timer.autostart = true
	add_child(timer)
	
	# Initialize with GameManager values
	projectile_speed = GameManager.get_projectile_speed()
	fire_rate = GameManager.get_fire_rate()
	update_spawn_interval()
	print("CoinSpawner initialized with projectile speed: ", projectile_speed)
	print("CoinSpawner initialized with fire rate: ", fire_rate)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Update spawn interval based on fire rate
func update_spawn_interval() -> void:
	var adjusted_interval = spawn_interval * (100.0 / fire_rate)
	timer.wait_time = adjusted_interval

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
	var rand_x = randf_range(50, spawn_area.x)
	var rand_y = randf_range(50, spawn_area.y)
	coin_instance.position = Vector2(rand_x, rand_y)
	coin_instance.rotation = randf_range(0, 90 + randf())
	
	# Set downward velocity
	#coin_instance.set_speed(randf_range(projectile_speed/2, projectile_speed))
	coin_instance.set_velocity(Vector2(0, randf_range(projectile_speed/2, projectile_speed)))  # Moving downward
	
	# Add to scene
	add_child(coin_instance)

# Set projectile speed from upgrades
func set_projectile_speed(speed: float) -> void:
	projectile_speed = speed
	print("CoinSpawner projectile speed set to: ", speed)

# Set fire rate from upgrades
func set_fire_rate(rate: float) -> void:
	fire_rate = rate
	update_spawn_interval()
	print("CoinSpawner fire rate set to: ", rate, ", new interval: ", timer.wait_time)
