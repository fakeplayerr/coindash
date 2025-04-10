extends CharacterBody2D

@export var base_player : BasePlayer
@export var shoot_sound : AudioStream
@export var idle_sound : AudioStream  # Sound that plays continuously
@export var moving_sound : AudioStream  # Sound when moving upward

var coin_projectile = preload("res://src/projectiles/coin_projectile.tscn")
var coin_bullet_resource = preload("res://src/projectiles/coin_small_bullet.tres")

var engine_audio : AudioStreamPlayer2D  # Persistent audio player for idle sound
var moving_audio : AudioStreamPlayer2D  # Separate player for moving sound

func _ready() -> void:
	# Connect to base_player's car property changes
	if base_player and base_player.car:
		base_player.car.changed.connect(_on_car_changed)
		_update_car_texture()
	
	# Setup idle audio player (always playing)
	engine_audio = AudioStreamPlayer2D.new()
	add_child(engine_audio)
	if idle_sound:
		engine_audio.stream = idle_sound
		engine_audio.play()
	
	# Setup moving audio player (plays only when moving up)
	moving_audio = AudioStreamPlayer2D.new()
	moving_audio.volume_db = -10.0
	add_child(moving_audio)
	if moving_sound:
		moving_audio.stream = moving_sound

func _on_car_changed() -> void:
	_update_car_texture()

func _update_car_texture() -> void:
	if base_player and base_player.car and base_player.car.image:
		$Car.texture = base_player.car.image

func _physics_process(delta: float) -> void:
	# Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = base_player.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity.x = direction.x * base_player.SPEED
		velocity.y = direction.y * base_player.SPEED
		
		# Play moving sound only when moving upward (negative y direction)
		if direction.y < 0 and moving_sound and not moving_audio.playing:
			moving_audio.play()
			moving_audio.volume_db = linear_to_db(-direction.y)  # Volume based on upward speed
	else:
		velocity.x = move_toward(velocity.x, 0, base_player.SPEED)
		velocity.y = move_toward(velocity.y, 0, base_player.SPEED)
		
		# Stop moving sound when not going up
		if moving_audio.playing:
			moving_audio.stop()
	
	# Ensure idle sound keeps playing
	if idle_sound and not engine_audio.playing:
		engine_audio.play()

	move_and_slide()
	
	# Handle coin shooting
	if Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("shoot"):
		shoot_coin()

func _generate_random_color() -> Color:
	# Generate a random color with full alpha
	return Color(
		randf_range(0.5, 1.0),  # Keep colors bright by starting at 0.5
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0),
		1.0
	)

func shoot_coin() -> void:
	# Find the current level to check coin count
	var current_levels = get_tree().get_nodes_in_group("current_level")
	for level_manager in current_levels:
		print("shoot: ", level_manager.name)
		
		if level_manager.has_method("handle_coin_collected"):
			var coins = level_manager.level1.get_coins()
			
			# Check if player has coins to shoot
			if coins <= 0:
				return
				
			# Subtract a coin
			level_manager.handle_coin_collected(-1)
			
			# Play shoot sound if assigned
			if shoot_sound:
				var audio_player = AudioStreamPlayer2D.new()
				audio_player.stream = shoot_sound
				add_child(audio_player)
				audio_player.play()
				# Clean up audio player when finished
				audio_player.finished.connect(audio_player.queue_free)
			
			# Create coin projectile
			var coin_instance = coin_projectile.instantiate()
			coin_instance.projectile_resource = coin_bullet_resource
			coin_instance.shot_by_player = true
			
			# Add shader material to coin sprite
			var sprite := coin_instance.get_node("Sprite2D") as Sprite2D
			if sprite and sprite.material:
				# Create a new shader material instance
				var new_material := ShaderMaterial.new()
				new_material.shader = sprite.material.shader
				
				# Copy the known shader parameters from the original material
				var original_material := sprite.material as ShaderMaterial
				new_material.set_shader_parameter("speed", original_material.get_shader_parameter("speed"))
				new_material.set_shader_parameter("width", original_material.get_shader_parameter("width"))
				new_material.set_shader_parameter("left_width", original_material.get_shader_parameter("left_width"))
				new_material.set_shader_parameter("right_width", original_material.get_shader_parameter("right_width"))
				
				# Set random color for both base and glow
				var random_color := _generate_random_color()
				new_material.set_shader_parameter("base_color", random_color)
				new_material.set_shader_parameter("glow_color", random_color)
				
				# Apply the new material to the sprite
				sprite.material = new_material
			
			# Position at spawn point
			coin_instance.global_position = $CoinSpawnPoint.global_position
			
			# Calculate direction to mouse position
			var mouse_pos = get_global_mouse_position()
			var direction = (mouse_pos - global_position).normalized()
			
			# Set velocity towards mouse position
			coin_instance.set_velocity(direction * coin_instance.speed)
			
			# Add to scene
			get_tree().root.add_child(coin_instance)
			break
