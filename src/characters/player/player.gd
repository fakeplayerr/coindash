extends CharacterBody2D

# This script was updated by the fix_references.gd tool
# The GameAssetsClass constant remain unchanged but now refers to GameAssetsResource class

# Reference to GameAssets class
const GameAssetsClass = preload("res://src/autoload/game_assets.gd")
const PowerUpManagerClass = preload("res://src/powerups/power_up_manager.gd")

signal speed_changed(speed: float)
signal coin_collected

var speed: float = 300.0
var handling_multiplier: float = 1.0
var coin_scene = preload("res://src/projectiles/coin_projectile.tscn")
var coin_spawn_point: Node2D
var coin_shoot_cooldown: float = 0.0
var coin_shoot_delay: float = 0.5  # Base delay between shots
var target_detection_radius: float = 500.0
var projectile_speed_multiplier: float = 1.0  # Base projectile speed multiplier
var forward_speed: float = 300.0  # Base forward speed for constant movement
var max_forward_speed: float = 500.0  # Maximum forward speed
var min_forward_speed: float = 200.0  # Minimum forward speed

# Power-up manager reference
var power_up_manager: PowerUpManagerClass = null

@onready var sprite = $Sprite2D
@onready var trail = $Trail

# Default screen boundaries (will be updated in _ready)
var screen_width: float = 1080
var screen_height: float = 1920
var wall_padding: float = 80.0

# Car selection
var selected_car: String = "blue"

# Powerup status
var fire_rate: float = 0.5
var projectile_speed: float = 400.0

# Physics state
var screen_size: Vector2
var car_size: Vector2
var can_move: bool = true

func _ready():
	coin_spawn_point = $CoinSpawnPoint
	
	# Get actual viewport size
	var viewport_size = get_viewport_rect().size
	if viewport_size.x > 0 and viewport_size.y > 0:
		screen_width = viewport_size.x
		screen_height = viewport_size.y
	
	# Load the selected car texture
	load_selected_car()
	
	# Start trail effect
	if trail:
		trail.emitting = true
	
	# Initialize power-up manager
	power_up_manager = PowerUpManagerClass.new()
	add_child(power_up_manager)

	# Connect power-up signals
	power_up_manager.connect("powerup_activated", _on_power_up_collected)
	power_up_manager.connect("powerup_deactivated", _on_power_up_expired)
	
	# Set the car pointing upward (top-down view)
	sprite.rotation_degrees = 0  # Set to 0 degrees to face upward

func load_selected_car():
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		var selected_car = save_manager.get_selected_car()
		print("Player: Loading selected car: " + selected_car)
		
		# Use GameAssets class to load texture
		var texture = GameAssetsClass.load_car_texture(selected_car)
		if texture and sprite:
			sprite.texture = texture
			print("Player: Car texture loaded successfully")
			car_size = texture.get_size() * sprite.scale
			
			# Check if texture needs to be rotated or flipped to face upward
			# Most car sprites are designed to face right or down, so they may need adjustment
			# If the car appears to face left when it should face up, flip it horizontally
			sprite.flip_h = false  # Reset any flipping
			sprite.flip_v = false   # Flip vertically to make it face upward
			
			print("Player: Applied sprite orientation adjustments")
		else:
			print("Player: Failed to load texture")
			fallback_car_texture()
	else:
		# Fallback to default car if SaveManager not available
		print("Player: SaveManager not found, using default car")
		fallback_car_texture()

# Fallback to ensure car is always visible
func fallback_car_texture():
	print("Player: Using fallback car texture")
	var texture = GameAssetsClass.load_car_texture("car1")
	if texture == null:
		# Hard fallback if GameAssets also fails
		var car_texture_path = "res://assets/cars/car_red_small_1.png"
		texture = load(car_texture_path)
		if texture == null:
			print("Player: WARNING - Could not load fallback texture!")
			return
	
	if sprite:
		sprite.texture = texture
		car_size = texture.get_size() * sprite.scale
		
		# Apply the same orientation adjustments as in load_selected_car
		sprite.flip_h = false
		sprite.flip_v = true
		print("Player: Applied orientation adjustments to fallback car")

func _physics_process(delta):
	if not can_move:
		return
	
	# Calculate movement input (horizontal only)
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Only use horizontal input for steering
	var direction = Vector2(input_dir.x, 0)
	
	# Set horizontal velocity based on input and handling
	velocity.x = direction.x * speed * handling_multiplier
	
	# CRITICAL FIX: Always use a fixed forward speed (negative Y is up in Godot)
	velocity.y = -forward_speed
	
	# Apply car rotation based on horizontal movement
	if direction.x != 0:
		# Tilting the car based on horizontal movement
		var target_rotation = (direction.x * 15.0) # Small tilt when turning
		sprite.rotation_degrees = target_rotation
	else:
		# Reset rotation to upward when not turning
		sprite.rotation_degrees = 0
	
	# Move the character
	move_and_slide()
	
	# Only clamp the player horizontally - allow free vertical movement
	position.x = clamp(position.x, wall_padding, screen_width - wall_padding)
	
	# DIRECT CAMERA UPDATE: Ensure camera follows player directly
	update_camera_position()
	
	# Debug movement info
	if Engine.get_frames_drawn() % 60 == 0: # Once per second
		print("Player pos:", position, " velocity:", velocity)
	
	# Get current fire rate (apply power-up if active)
	var current_fire_delay = coin_shoot_delay
	if power_up_manager and power_up_manager.is_powerup_active("fire_rate"):
		current_fire_delay = coin_shoot_delay * 0.5  # 50% faster fire rate when power-up active
	
	# Handle automatic coin shooting
	if coin_shoot_cooldown > 0:
		coin_shoot_cooldown -= delta
	
	if coin_shoot_cooldown <= 0:
		var target = find_closest_human()
		if target:
			shoot_at_target(target)
			coin_shoot_cooldown = current_fire_delay
	
	# Update trail effect based on speed
	if trail:
		var speed_factor = velocity.length() / 300.0
		trail.emitting = speed_factor > 0.1
		
		# Only set amount if emitting (must be at least 1)
		if trail.emitting:
			trail.amount = max(1, int(20 * speed_factor))
	
	# Update speed and emit signal
	emit_signal("speed_changed", velocity.length())
	
	# Update power-ups
	if power_up_manager:
		# Call the update method only if it exists
		if power_up_manager.has_method("update"):
			power_up_manager.update(delta)

func find_closest_human() -> Node2D:
	var closest_human = null
	var closest_distance = target_detection_radius
	
	# Get all humans in the scene
	var humans = get_tree().get_nodes_in_group("humans")
	
	for human in humans:
		var distance = global_position.distance_to(human.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_human = human
	
	return closest_human

func shoot_at_target(target: Node2D):
	var coin = coin_scene.instantiate()
	get_parent().add_child(coin)
	coin.position = coin_spawn_point.global_position
	
	# Calculate direction to target
	var target_direction = (target.global_position - coin_spawn_point.global_position).normalized()
	
	# Set direction and apply projectile speed multiplier if active
	var current_speed_multiplier = projectile_speed_multiplier
	if power_up_manager and power_up_manager.is_powerup_active("speed"):
		current_speed_multiplier = projectile_speed_multiplier * 1.5  # 50% faster projectile speed
	
	coin.set_direction(target_direction, current_speed_multiplier)

func connect_speed_signal(callback: Callable):
	connect("speed_changed", callback)

# Set the handling multiplier
func set_handling(multiplier: float):
	handling_multiplier = max(1.0, multiplier)
	print("Player: Handling set to " + str(handling_multiplier))

# Apply upgrades from SaveManager
func apply_upgrades():
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		# Apply fire rate upgrade
		var fire_rate_level = save_manager.get_upgrade_level("fire_rate")
		coin_shoot_delay = 0.5 / (1.0 + (fire_rate_level - 1) * 0.1)  # Each level reduces delay by 10%
		print("Player: Applied fire rate upgrade: Level %d - Delay: %.2f" % [fire_rate_level, coin_shoot_delay])
		
		# Apply projectile speed upgrade
		var projectile_speed_level = save_manager.get_upgrade_level("projectile_speed")
		projectile_speed_multiplier = 1.0 + (projectile_speed_level - 1) * 0.1  # Each level adds 10% speed
		print("Player: Applied projectile speed upgrade: Level %d - Multiplier: %.1f" % 
			[projectile_speed_level, projectile_speed_multiplier])
		
		# Apply car speed upgrade 
		var car_speed_level = save_manager.get_upgrade_level("car_speed")
		forward_speed = 200.0 + (car_speed_level - 1) * 25.0  # Each level adds 25 speed
		max_forward_speed = 400.0 + (car_speed_level - 1) * 30.0  # Each level adds 30 max speed
		print("Player: Applied car speed upgrade: Level %d - Speed: %.1f" % [car_speed_level, forward_speed])
		
		# Apply power-up slots upgrade
		var power_up_slots = save_manager.get_upgrade_level("power_up_slots")
		if power_up_manager:
			power_up_manager.set_max_slots(power_up_slots)

# Called when a power-up is collected
func collect_power_up(type):
	if power_up_manager:
		power_up_manager.activate_powerup(type)

# Called when a power-up is collected (signal handler)
func _on_power_up_collected(type, duration):
	print("Player: Collected power-up: %s for %.1f seconds" % [type, duration])
	
	# Apply immediate effects for certain power-ups
	match type:
		"speed":
			forward_speed *= 1.5  # 50% speed boost
			max_forward_speed *= 1.5
			print("Player: Speed boosted to %.1f" % forward_speed)
		"fire_rate":
			print("Player: Fire rate boosted")
			# Effect is handled in _physics_process

# Called when a power-up expires (signal handler)
func _on_power_up_expired(type):
	print("Player: Power-up expired: %s" % type)
	
	# Reset stats when power-ups expire
	match type:
		"speed":  # Now using string name instead of enum
			# Reset to base speed with upgrades
			var save_manager = get_node_or_null("/root/SaveManager")
			if save_manager:
				var car_speed_level = save_manager.get_upgrade_level("car_speed")
				forward_speed = 200.0 + (car_speed_level - 1) * 25.0
				max_forward_speed = 400.0 + (car_speed_level - 1) * 30.0
				print("Player: Speed reset to %.1f" % forward_speed)

# Called when an upgrade is purchased
func apply_upgrade(upgrade_type: String, value: float):
	match upgrade_type:
		"speed":
			speed += value
		"acceleration":
			forward_speed += value
		"fire_rate":
			fire_rate -= value
		"projectile_speed":
			projectile_speed += value

# Apply temporary speed boost from powerup
func apply_speed_powerup(multiplier: float):
	forward_speed = speed * multiplier

# Called when the car collides with a coin or other collectible
func _on_body_entered(body):
	if body.is_in_group("coin"):
		emit_signal("coin_collected")
		body.collect()

# New function to directly update camera position from player
func update_camera_position():
	var camera = get_node_or_null("/root/MainGame/MainCamera")
	if camera and is_instance_valid(camera):
		# Get the fixed horizontal position value if available 
		var fixed_x = 540.0  # Default center of a 1080 width screen
		if "fixed_horizontal_position" in camera:
			fixed_x = camera.fixed_horizontal_position
			
		# Keep camera fixed horizontally, follow vertically with offset
		camera.global_position = Vector2(fixed_x, global_position.y - 300)
		
		# Verify camera position occasionally
		if Engine.get_frames_drawn() % 120 == 0:  # Every 2 seconds
			var offset = camera.global_position - global_position
			if abs(offset.y - (-300)) > 10:
				print("Player enforcing camera position, offset was: ", offset)
