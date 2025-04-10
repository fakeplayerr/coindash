extends CharacterBody2D

@export var base_player : BasePlayer

var coin_projectile = preload("res://src/projectiles/coin_projectile.tscn")
var coin_bullet_resource = preload("res://src/projectiles/coin_small_bullet.tres")

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
	#if not is_on_floor():
		#velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = base_player.JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if direction:
		velocity.x = direction.x * base_player.SPEED
		velocity.y = direction.y * base_player.SPEED
	else:
		velocity.x = move_toward(direction.normalized().x, 0, base_player.SPEED)
		velocity.y = move_toward(direction.normalized().y, 0, base_player.SPEED)

	move_and_slide()
	
	# Handle coin shooting
	if Input.is_action_just_pressed("ui_select") or Input.is_action_just_pressed("shoot"):
		shoot_coin()

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
			
			# Create coin projectile
			var coin_instance = coin_projectile.instantiate()
			coin_instance.projectile_resource = coin_bullet_resource
			coin_instance.shot_by_player = true
			
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
