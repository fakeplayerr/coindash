extends Camera2D

# Camera controller for the main game.
# Controls follow behavior, boundaries, and screen shake effects.

@export var target_node_path: NodePath
@export var shake_amount: float = 5.0
@export var shake_decay: float = 0.8
@export var offset_from_player: Vector2 = Vector2(0, -300)  # Camera offset from player
@export var fixed_horizontal_position: float = 540.0  # Default horizontal position (center of 1080 width screen)

var target = null
var shake_strength: float = 0.0
var original_offset: Vector2
var rng = RandomNumberGenerator.new()

func _ready():
	print("Camera controller initializing...")
	
	# Initialize random number generator
	rng.randomize()
	
	# Store original offset for restoration after shake
	original_offset = offset
	
	# Get viewport size and set default horizontal position if not specified
	var viewport = get_viewport()
	if viewport:
		fixed_horizontal_position = viewport.get_visible_rect().size.x / 2
	
	# Get target if path is set
	if target_node_path:
		target = get_node(target_node_path)
		print("Camera found target: ", target)
		
		# For immediate following without interpolation, set position directly
		if target and is_instance_valid(target):
			# Use fixed X position but follow target's Y with offset
			global_position = Vector2(fixed_horizontal_position, target.global_position.y + offset_from_player.y)
			print("Camera initialized at fixed X position: ", fixed_horizontal_position)
	
	# Disable smoothing - we'll handle positioning directly
	position_smoothing_enabled = false
	rotation_smoothing_enabled = false
	
	print("Camera controller ready!")

# Process is called every frame
func _process(delta):
	# Target following - if we have a valid target
	if target and is_instance_valid(target):
		# HORIZONTAL FIXED, VERTICAL FOLLOWING:
		# Keep X position fixed at the center of the screen
		# Only follow the player's Y position with offset
		global_position.x = fixed_horizontal_position  # Stay fixed horizontally
		global_position.y = target.global_position.y + offset_from_player.y  # Follow vertically
		
		# Debug output every few frames
		if Engine.get_frames_drawn() % 60 == 0: # Once per second
			print("Camera position: ", global_position, " Target position: ", target.global_position)
	else:
		# Try to find the player if target is lost
		var player = get_node_or_null("/root/MainGame/Player")
		if player:
			target = player
			print("Camera reconnected to player")
			# Jump immediately to player with offset (fixed X position)
			global_position = Vector2(fixed_horizontal_position, player.global_position.y + offset_from_player.y)
	
	# Process camera shake effect (this doesn't affect the base position)
	if shake_strength > 0:
		# Apply shake effect to offset
		offset = original_offset + Vector2(
			rng.randf_range(-shake_strength, shake_strength),
			rng.randf_range(-shake_strength, shake_strength)
		)
		
		# Decay shake strength
		shake_strength = max(0, shake_strength * shake_decay)
		
		# Reset offset when shake is done
		if shake_strength < 0.01:
			shake_strength = 0
			offset = original_offset

# Method to set a new target to follow
func set_target(new_target):
	target = new_target
	print("Camera target set to: ", target)
	
	# Immediately update camera position to target with offset
	if target and is_instance_valid(target):
		global_position = Vector2(fixed_horizontal_position, target.global_position.y + offset_from_player.y)

# Method to apply screen shake effect
func apply_shake(strength = shake_amount):
	shake_strength = strength

# Method to set camera boundaries
func set_camera_limits(left, top, right, bottom):
	limit_left = left
	limit_top = top
	limit_right = right
	limit_bottom = bottom
	limit_smoothed = false 