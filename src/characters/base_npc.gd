extends CharacterBody2D

# Common signal for when the NPC is killed
signal died

# Movement settings
var speed: float = 50.0
var direction: Vector2 = Vector2.ZERO
var wander_time: float = 0.0
var wander_duration: float = 2.0
var sway_amount: float = 0.3
var sway_time: float = 0.0
var sway_speed: float = 1.0
var screen_width: float = 1080
var wall_padding: float = 80.0
@export var death_sound: AudioStream
var has_animation: bool = false
# Keep track of NPC type
func _ready():
	# Set random initial direction
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Set initial wander time
	wander_time = randf_range(0, wander_duration)
	
	# Initialize sway time with random value for variety
	sway_time = randf() * PI
	
	# Add to humans group (for compatibility with existing code)
	add_to_group("enemies")  # Add to enemies group for projectile collision
	
	# Start animation if the NPC has one
	if has_animation:
		var animated_sprite = get_node_or_null("AnimatedSprite2D")
		if animated_sprite:
			animated_sprite.play("run")

func _process(delta):
	# Update wander time
	wander_time += delta
	
	# Change direction randomly
	if wander_time >= wander_duration:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		wander_time = 0
	
	# For AnimatedSprite handling
	update_sprite_direction()

func _physics_process(delta):
	# Calculate sideways sway using sine wave
	sway_time += delta * sway_speed
	var sway = sin(sway_time * 2) * sway_amount
	
	# Combine downward movement with sideways sway
	direction = Vector2(sway, 1).normalized()
	velocity = direction * speed
	
	# Handle movement based on node type
	move_and_slide()
	
	# Keep within screen bounds manually as a fallback
	if position.x < wall_padding:
		position.x = wall_padding
		direction.x = abs(direction.x)  # Bounce right
		sway_time += PI / 2  # Offset the sine wave
	elif position.x > screen_width - wall_padding:
		position.x = screen_width - wall_padding
		direction.x = -abs(direction.x)  # Bounce left
		sway_time += PI / 2  # Offset the sine wave
	
	# If we hit a wall, bounce away slightly
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is StaticBody2D:
			direction.x = -direction.x
			sway_time += PI / 2  # Offset the sine wave

# Update sprite direction based on movement
func update_sprite_direction():
	var sprite = get_node_or_null("AnimatedSprite2D")
	if sprite:
		if direction.x < -0.05:
			sprite.flip_h = true
		elif direction.x > 0.05:
			sprite.flip_h = false

func hit():
	# Disable collision
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Play death sound if one is assigned
	if death_sound:
		var audio_player = AudioStreamPlayer2D.new()
		audio_player.stream = death_sound
		audio_player.volume_db = -10.0
		get_tree().root.add_child(audio_player)  # Add to root so it persists after girl is freed
		audio_player.play()
	
	# Emit died signal before being removed
	emit_signal("died")
	
	# Queue for removal
	queue_free()
