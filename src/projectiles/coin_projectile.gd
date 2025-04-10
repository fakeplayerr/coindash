extends Node2D

@export var projectile_resource: BaseProjectile
@export var audio_stream: AudioStream  # Add this to expose audio in editor

@export var velocity: Vector2 = Vector2.ZERO
@export_range(0, 1000, 10) var speed: float = 200
@onready var coin_explosion: CPUParticles2D = $CPUParticles2D
var shot_by_player: bool = false

func _ready():
	if projectile_resource:
		$Sprite2D.texture = projectile_resource.image
		$Sprite2D.scale = Vector2.ONE * projectile_resource.size * 0.5  # Scale based on size
		$CollisionShape2D.scale = Vector2.ONE * projectile_resource.size * 0.5
		
	# Start animation if it exists
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("rotate")
		
	# Connect screen exited signal
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_visible_on_screen_notifier_2d_screen_exited"))

func _process(delta):
	# Move according to velocity
	position += velocity * delta

func set_velocity(vel: Vector2):
	velocity = vel

func set_speed(spd: float):
	speed = spd
	
func _on_area_2d_body_entered(body):
	# Skip if this is a player-shot coin and it hits the player
	if shot_by_player and body.is_in_group("player"):
		return
	if body.is_in_group("player"):
		# Play audio if we have one
		if audio_stream:
			var audio_player = AudioStreamPlayer2D.new()
			audio_player.stream = audio_stream
			audio_player.volume_db = -10.0
			get_tree().root.add_child(audio_player)  # Add to root so sound persists
			audio_player.play()
		
		# Find the current level and handle coin collection
		var current_levels = get_tree().get_nodes_in_group("current_level")
		for level_manager in current_levels:
			if level_manager.has_method("handle_coin_collected"):
				level_manager.handle_coin_collected(projectile_resource.amount)
		
		# Show explosion and cleanup
		queue_free()

	elif body.is_in_group("enemies") and shot_by_player:
		body.hit()  # Call the hit function on the enemy
		explode_and_free()  # Show explosion and cleanup
	elif body.is_in_group("environment"):
		# Destroy coin when hitting obstacles
		explode_and_free()

# When colliding with another area (like an obstacle's HitArea)
func _on_area_entered(area):
	var parent = area.get_parent()
	if parent and parent.is_in_group("environment"):
		# Destroy coin when hitting obstacles
		explode_and_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	explode_and_free()  # Show explosion and cleanup

# Helper function to show explosion and then free the node
func explode_and_free():
	# Stop movement
	velocity = Vector2.ZERO
	
	# Hide the sprite and collision shape so only the explosion shows
	$Sprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	#$CollisionShape2D.disabled = true
	
	# Start the particle explosion
	coin_explosion.emitting = true
	
	# Wait for the particle lifetime before freeing
	await get_tree().create_timer(coin_explosion.lifetime).timeout
	queue_free()
