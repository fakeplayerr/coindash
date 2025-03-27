extends Camera2D

# Camera target (usually the player)
var target: Node2D = null

# Camera vertical tracking parameters
var vertical_offset: float = 400.0
var vertical_tracking_speed: float = 5.0  # Increased for faster response
var min_y_position: float = -100000.0  # Effectively unlimited upward movement

# Last known target position
var last_target_y: float = 0.0
var initial_setup_done: bool = false

# Maximum shake amount
var max_shake_amount: float = 3.0
var current_shake_amount: float = 0.0
var shake_decay: float = 5.0
var shake_random = RandomNumberGenerator.new()

# Debug mode
var debug_mode: bool = true

func _ready():
	# Get the player reference
	target = get_parent().get_node_or_null("Player")
	
	if target:
		# Initialize camera position based on target
		global_position.x = 540  # Center of screen
		global_position.y = target.global_position.y - vertical_offset
		last_target_y = target.global_position.y
		
		if debug_mode:
			print("Camera: Found player at position ", target.global_position)
	else:
		if debug_mode:
			print("Camera: WARNING - Player not found!")
	
	# Initialize random number generator for shake
	shake_random.randomize()
	
	# Give one frame to get everything set up
	call_deferred("initial_setup")

func initial_setup():
	if not target:
		# Try again to find player
		target = get_parent().get_node_or_null("Player")
		if not target:
			target = get_tree().get_first_node_in_group("player")
	
	if target:
		# Force camera to correct position
		global_position.x = 540
		global_position.y = target.global_position.y - vertical_offset
		last_target_y = target.global_position.y
		
		if debug_mode:
			print("Camera: Initial setup complete. Camera at ", global_position)
	
	initial_setup_done = true

func _physics_process(delta):
	if target == null:
		# Try to get player reference again
		target = get_parent().get_node_or_null("Player")
		if target == null:
			if debug_mode:
				print("Camera: Still can't find player")
			return
	
	# Keep the x position centered
	global_position.x = 540  # Center of the screen (1080/2)
	
	# Always track vertical movement (not just when moving up)
	var target_y = target.global_position.y - vertical_offset
	global_position.y = lerp(global_position.y, target_y, vertical_tracking_speed * delta)
	
	# Update the last target position
	last_target_y = target.global_position.y
	
	# Process camera shake if active
	if current_shake_amount > 0:
		# Apply random offset for shake effect
		offset.x = shake_random.randf_range(-current_shake_amount, current_shake_amount)
		offset.y = shake_random.randf_range(-current_shake_amount, current_shake_amount)
		
		# Decrease shake amount over time
		current_shake_amount = max(0, current_shake_amount - shake_decay * delta)
		
		# Reset offset when shake is complete
		if current_shake_amount <= 0:
			offset = Vector2.ZERO

# Apply shake effect to the camera
func shake(amount: float = 1.0, duration: float = 0.5):
	current_shake_amount = min(amount, max_shake_amount)
	
	# Use a timer to limit shake duration
	var timer = get_tree().create_timer(duration)
	await timer.timeout
	
	# Start decaying the shake
	current_shake_amount = 0.0
	offset = Vector2.ZERO

# Shake the camera (can be called from other scripts)
func start_shake(intensity: float, duration: float):
	shake(intensity, duration) 