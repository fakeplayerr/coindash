extends CharacterBody2D

@export var base_player : BasePlayer

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = base_player.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * base_player.SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, base_player.SPEED)

	move_and_slide()


func _on_car_texture_changed() -> void:
	print("texture_changed")
	$Car.texture = base_player.car
