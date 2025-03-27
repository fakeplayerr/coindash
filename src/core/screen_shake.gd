extends Camera2D

signal position_changed()

var shake_amount: float = 0.0
var default_offset: Vector2 = Vector2.ZERO
var is_shaking: bool = false
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var player: Node2D = null
var follow_speed: float = 2.0
var min_follow_distance: float = 50.0
var last_position: Vector2 = Vector2.ZERO

func _ready():
	default_offset = offset
	
	# Try to find the player
	await get_tree().process_frame
	player = get_node_or_null("/root/MainGame/Player")
	if not player:
		player = get_tree().get_first_node_in_group("player")
	
	# Start normal processing for camera following
	set_process(true)
	last_position = global_position

func _process(delta):
	# Handle camera shake
	if is_shaking:
		shake_timer += delta
		
		# Generate random shake offset
		offset = default_offset + Vector2(
			randf_range(-1.0, 1.0) * shake_amount,
			randf_range(-1.0, 1.0) * shake_amount
		)
		
		# End shake when timer expires
		if shake_timer >= shake_duration:
			is_shaking = false
			shake_timer = 0.0
			offset = default_offset
	
	# Follow player vertically
	if player:
		# Only move camera when player is above a certain threshold
		var target_y = global_position.y
		var player_distance = player.global_position.y - global_position.y
		
		# If player is moving upward (negative Y direction)
		if player_distance < -min_follow_distance:
			target_y = lerp(global_position.y, player.global_position.y + min_follow_distance, delta * follow_speed)
		
		# Update camera position (only Y axis)
		global_position.y = target_y
		
		# Emit signal if position changed significantly
		if abs(global_position.y - last_position.y) > 1.0:
			last_position = global_position
			emit_signal("position_changed")

func start_shake(intensity: float, duration: float):
	if intensity > 0 and duration > 0:
		shake_amount = intensity
		shake_duration = duration
		shake_timer = 0.0
		is_shaking = true 