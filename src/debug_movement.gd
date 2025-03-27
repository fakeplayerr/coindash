extends Node

# Debug tool to monitor player and camera movement
# Attach this to any scene to get real-time feedback on movement

var player = null
var camera = null
var last_player_pos = Vector2.ZERO
var last_camera_pos = Vector2.ZERO
var frames_since_start = 0

func _ready():
	print("Debug movement monitor starting...")
	
	# Wait for scene to fully initialize
	await get_tree().process_frame
	
	# Find player and camera references
	player = get_node_or_null("/root/MainGame/Player") 
	camera = get_node_or_null("/root/MainGame/MainCamera")
	
	if player:
		print("Debug: Found player at ", player.global_position)
		last_player_pos = player.global_position
	else:
		print("Debug: Player not found")
	
	if camera:
		print("Debug: Found camera at ", camera.global_position)
		last_camera_pos = camera.global_position
	else:
		print("Debug: Camera not found")
		
	print("Debug: Camera should be positioned above the player by ~300 units")

func _process(delta):
	frames_since_start += 1
	
	# Only monitor at intervals to avoid console spam
	if frames_since_start % 30 != 0:
		return
		
	if player and is_instance_valid(player):
		var current_pos = player.global_position
		var velocity = (current_pos - last_player_pos) / delta
		print("PLAYER: Position: ", current_pos, " Vel: ", velocity)
		last_player_pos = current_pos
		
		# Report Y movement (should be moving upward/negative Y)
		if velocity.y > 0:
			print("WARNING: Player moving DOWN instead of UP!")
		elif velocity.y < -10:
			print("✓ Player moving upward correctly")
	
	if camera and is_instance_valid(camera):
		var current_pos = camera.global_position
		var velocity = (current_pos - last_camera_pos) / delta
		print("CAMERA: Position: ", current_pos, " Vel: ", velocity)
		last_camera_pos = current_pos
		
		# Report on player-camera relationship if both exist
		if player and is_instance_valid(player):
			var offset = camera.global_position - player.global_position
			print("OFFSET: Camera-to-player: ", offset, " (should be approx 0, -300)")
			
			if offset.y > -100:
				print("ERROR: Camera too close to or behind player!")
			elif offset.y < -400:
				print("WARNING: Camera too far ahead of player")
			else:
				print("✓ Camera offset looks good") 