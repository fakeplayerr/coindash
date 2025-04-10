extends Node2D

# Spawn configuration
const SPAWN_INTERVAL := 1.0  # Spawn every second
const MIN_SPAWN_DISTANCE := 40.0  # Minimum distance between coins

# Spawned coins tracking
var spawned_coins: Array[Node] = []
var spawn_timer: Timer

# Coin template
var coin_template: Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_spawn_timer()
	_setup_coin_template()
	_spawn_initial_coins()

func _setup_spawn_timer() -> void:
	spawn_timer = Timer.new()
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.one_shot = false
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)
	spawn_timer.start()

func _setup_coin_template() -> void:
	# Get the Coin node as template
	coin_template = $Coin
	if not coin_template:
		push_error("Bogatie: Coin template not found!")

func _spawn_initial_coins() -> void:
	# Get the number of coins from GameManager
	
	var initial_coin_count = min(GameManager.get_coins(), 200)
	
	# Spawn the initial number of coins
	for i in range(initial_coin_count):
		var pos := _generate_random_position()
		# Keep trying to find a valid position
		var attempts := 0
		const MAX_ATTEMPTS := 10
		while not _is_position_valid(pos) and attempts < MAX_ATTEMPTS:
			pos = _generate_random_position()
			attempts += 1
		if attempts < MAX_ATTEMPTS:  # Only spawn if we found a valid position
			_spawn_coin_at_position(pos)

func _generate_random_color() -> Color:
	# Generate a random color with full alpha
	return Color(
		randf_range(0.5, 1.0),  # Keep colors bright by starting at 0.5
		randf_range(0.5, 1.0),
		randf_range(0.5, 1.0),
		1.0
	)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_spawn_coin_at_position(event.position)

func _spawn_coin_at_position(pos: Vector2) -> void:
	if not coin_template:
		return
		
	# Check if position is valid (not too close to other coins)
	if not _is_position_valid(pos):
		return
		
	var new_coin := coin_template.duplicate() as RigidBody2D
	new_coin.position = pos
	new_coin.rotation = randf_range(15.0,120.0)
	new_coin.angular_velocity = 40.0
	
	# Apply random colors to the shader material
	var sprite := new_coin.get_node("Sprite") as Sprite2D
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
	
	add_child(new_coin)
	spawned_coins.append(new_coin)

func _is_position_valid(pos: Vector2) -> bool:
	for coin in spawned_coins:
		if coin.position.distance_to(pos) < MIN_SPAWN_DISTANCE:
			return false
	return true

func _generate_random_position() -> Vector2:
	# Get the viewport size
	var viewport_size := get_viewport_rect().size
	# Generate random position within viewport bounds
	return Vector2(
		randf_range(0, viewport_size.x),
		randf_range(0, viewport_size.y)
	)

func _on_spawn_timer_timeout() -> void:
	var pos := _generate_random_position()
	_spawn_coin_at_position(pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
