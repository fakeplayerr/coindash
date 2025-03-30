extends Node2D

# A test script to ensure girl characters work correctly
# Can be attached to a scene with multiple girls to test them

func _ready():
	# Get all girl nodes
	for child in get_children():
		if child.name.begins_with("Girl"):
			# Start animation
			var sprite = child.get_node_or_null("AnimatedSprite2D")
			if sprite:
				sprite.play("run")
			
			# Set up movement
			var speed = 50.0
			var direction = Vector2(randf_range(-0.5, 0.5), 1).normalized()
			
			# Store values on the node
			child.set_meta("speed", speed)
			child.set_meta("direction", direction)
			child.set_meta("sway_time", randf() * PI)  # Random start time for animation variability
			
			print("Initialized " + child.name)

func _process(delta):
	for child in get_children():
		if child.name.begins_with("Girl") and child.has_meta("speed"):
			var speed = child.get_meta("speed")
			var sway_time = child.get_meta("sway_time")
			
			# Update sway time
			sway_time += delta
			child.set_meta("sway_time", sway_time)
			
			# Calculate sideways sway
			var sway_amount = 0.3
			var sway = sin(sway_time * 2) * sway_amount
			
			# Move the character
			var movement = Vector2(sway, 1).normalized() * speed * delta
			child.position += movement
			
			# Flip sprite based on movement direction
			var sprite = child.get_node_or_null("AnimatedSprite2D")
			if sprite:
				if movement.x < -0.05:
					sprite.flip_h = true
				elif movement.x > 0.05:
					sprite.flip_h = false

# For debugging: Create both girl types
func create_girls():
	var girl1_scene = load("res://src/characters/npcs/girl1.tscn")
	var girl2_scene = load("res://src/characters/npcs/girl2.tscn")
	
	var girl1 = girl1_scene.instantiate()
	girl1.position = Vector2(200, 100)
	add_child(girl1)
	
	var girl2 = girl2_scene.instantiate()
	girl2.position = Vector2(400, 100)
	add_child(girl2)
	
	# Initialize them
	_ready() 