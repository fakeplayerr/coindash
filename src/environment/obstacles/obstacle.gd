extends StaticBody2D

# Movement variables
var velocity = Vector2.ZERO
var size_factor = Vector2(1.0, 1.0)

# Called when the node enters the scene tree for the first time
func _ready():
	# Add obstacle to the environment group
	add_to_group("environment")
	
	# Set StaticBody2D collision properties
	collision_layer = 8  # Layer 4 for obstacles
	collision_mask = 2   # Detect player (typically layer 2)
	
	# Set up the area for collision detection if not present
	if not has_node("HitArea"):
		var area = Area2D.new()
		area.name = "HitArea"
		
		# Set Area2D collision properties to detect both bodies and areas
		area.collision_layer = 8  # Same as the StaticBody2D
		area.collision_mask = 7   # Detect player and projectiles (layers 1-3)
		
		# Copy the collision shape from the StaticBody2D
		for child in get_children():
			if child is CollisionShape2D or child is CollisionPolygon2D:
				var new_shape = child.duplicate()
				area.add_child(new_shape)
		
		# Connect signals for both body and area detection
		area.connect("body_entered", Callable(self, "_on_body_entered"))
		area.connect("area_entered", Callable(self, "_on_area_entered"))
		add_child(area)
	
	# Add screen notifier if not present
	if not has_node("VisibleOnScreenNotifier2D"):
		var notifier = VisibleOnScreenNotifier2D.new()
		# Adjust notifier size based on obstacle's size
		var base_size = 50.0
		notifier.rect = Rect2(-base_size, -base_size, base_size * 2, base_size * 2)
		add_child(notifier)
		notifier.connect("screen_exited", Callable(self, "_on_screen_exited"))

# Called every frame to move the obstacle
func _process(delta):
	position += velocity * delta

# Store the size factor for reference
func set_size_factor(factor: Vector2):
	size_factor = factor
	
	# Adjust the visible area notifier based on size
	if has_node("VisibleOnScreenNotifier2D"):
		var notifier = get_node("VisibleOnScreenNotifier2D")
		var base_size = 50.0 * max(factor.x, factor.y)
		notifier.rect = Rect2(-base_size, -base_size, base_size * 2, base_size * 2)

# When the player collides with the obstacle
func _on_body_entered(body):
	if body.is_in_group("player"):
		# End the game/round with failure
		var current_levels = get_tree().get_nodes_in_group("current_level")
		for level_manager in current_levels:
			if level_manager.has_method("handle_player_died"):
				level_manager.handle_player_died()
				return
			# Fallback to game_over if handle_player_died doesn't exist
			elif level_manager.has_method("game_over"):
				level_manager.game_over(false)

# When an Area2D (like a coin projectile) enters the obstacle
func _on_area_entered(area):
	# No action needed here - the coin will destroy itself
	# This is just to ensure the collision is detected
	pass

# Clean up when the obstacle leaves the screen
func _on_screen_exited():
	queue_free() 
