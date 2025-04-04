extends CharacterBody2D

@export var base_player : BasePlayer

func _ready() -> void:
	# Connect to base_player's car property changes
	if base_player and base_player.car:
		base_player.car.changed.connect(_on_car_changed)
		_update_car_texture()

func _on_car_changed() -> void:
	_update_car_texture()

func _update_car_texture() -> void:
	if base_player and base_player.car and base_player.car.image:
		$Car.texture = base_player.car.image

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
