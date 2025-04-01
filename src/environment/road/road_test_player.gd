extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var can_move = true;

var speed = 50.0
var handling = 20.0

func _physics_process(delta: float) -> void:
	# Add the gravity.
	
	if not can_move:
		return
	
	# Calculate movement input (horizontal only)
	var horizontal_input = Input.get_vector("ui_left", "ui_right","ui_up", "ui_down")
	
	
	# Only use horizontal input for steering
	var direction = Vector2(horizontal_input.x, horizontal_input.y)
	
	# Set horizontal velocity based on input and handling
	velocity.x = direction.x * speed * handling
	
	velocity.y = direction.y * speed * handling
	
	if direction.x != 0:
		# Tilting the car based on horizontal movement
		var target_rotation = (direction.x * 15.0) # Small tilt when turning
		$Sprite2D.rotation_degrees = target_rotation
	else:
		# Reset rotation to upward when not turning
		$Sprite2D.rotation_degrees = 0
	
	# Move the character
	move_and_slide()
	#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#if direction:
		#velocity.x = direction * SPEED
	#else:
		#velocity.x = move_toward(velocity.x, 0, SPEED)
#
	#move_and_slide()
