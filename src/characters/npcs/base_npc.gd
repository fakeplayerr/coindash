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

# Keep track of NPC type
var npc_type: String = "human"

func _ready():
	# Set random initial direction
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Set initial wander time
	wander_time = randf_range(0, wander_duration)
	
	# Add to humans group - all NPCs use this group for consistency
	add_to_group("humans")
	
	# Initialize sprite if this is not a human
	if npc_type != "human":
		var sprite = get_node_or_null("AnimatedSprite2D")
		if sprite and sprite.has_animation("run"):
			sprite.play("run")

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
	if npc_type != "human":
		var sprite = get_node_or_null("AnimatedSprite2D")
		if sprite:
			if direction.x < -0.05:
				sprite.flip_h = true
			elif direction.x > 0.05:
				sprite.flip_h = false

# Called when hit by a projectile
func hit():
	# Disable collision
	var collision = get_node_or_null("CollisionShape2D")
	if collision:
		collision.set_deferred("disabled", true)
	
	# Let the main game know an NPC was hit
	var main_game = get_node("/root/MainGame")
	if main_game and main_game.has_method("on_human_hit"):
		main_game.on_human_hit(global_position)
	
	# Spawn coins
	spawn_coins()
	
	# Emit died signal before being removed
	emit_signal("died")
	
	# Queue for removal
	queue_free()

# Spawn coins when hit
func spawn_coins():
	var coin_scene = load("res://src/projectiles/coin_projectile.tscn")
	var coin_count = randi_range(1, 3)  # Random number of coins
	
	for i in range(coin_count):
		var coin = coin_scene.instantiate()
		get_parent().add_child(coin)
		
		# Position slightly randomly around the NPC
		var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
		coin.global_position = global_position + offset
		
		# Set random direction for the coin
		var random_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
		if coin.has_method("set_direction"):
			coin.set_direction(random_direction) 
