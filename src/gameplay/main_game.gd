extends Node2D

# Reference to the module classes
const PowerUpManagerClass = preload("res://src/powerups/power_up_manager.gd")
const TimerManagerClass = preload("res://src/core/timer_manager.gd")
const SpawnManagerClass = preload("res://src/core/spawners/spawn_manager.gd")

var game_time: float = 0.0
var max_game_time: float = 60.0
var coins: int = 0
var fuel: float = 100.0
var max_fuel: float = 100.0
var is_game_over: bool = false
var is_paused: bool = false
var combo: int = 0
var combo_timer: float = 0.0
var combo_timeout: float = 2.0

# Game mode settings
var use_fuel: bool = true
var humans_hit: int = 0
var mode_stats: Dictionary = {}

# Base fuel consumption rate
var fuel_consumption_rate: float = 5.0
# Base coin multiplier
var coin_multiplier: float = 1.0
# Power-up slots available
var power_up_slots: int = 1
# Active power-ups
var active_power_ups = []

# Game systems
var timer_manager: TimerManagerClass = null
var powerup_manager = null
var spawn_manager: SpawnManagerClass = null

# Powerup state variables
var player_speed_modifier: float = 1.0
var player_fire_rate_modifier: float = 1.0
var projectile_speed_modifier: float = 1.0

@onready var player = $Player
@onready var fuel_bar = $UI/TopBar/FuelBar
@onready var time_label = $UI/TopBar/TimeLabel
@onready var coin_label = $UI/TopBar/CoinLabel
@onready var camera = $MainCamera
@onready var pause_button = $UI/BottomBar/PauseButton

# Global reference for the main game
static var current_instance = null

# Save manager
var save_manager = null

# Game mode manager
var game_mode_manager = null

# Screen size variables
var screen_width: float = 0.0
var screen_height: float = 0.0

# Global references to key nodes

func _ready():
	# Store global reference
	current_instance = self
	
	# Reset the pause state
	get_tree().paused = false
	
	# Setup initial screen size reference for all systems
	var viewport_size = get_viewport_rect().size
	screen_width = viewport_size.x
	screen_height = viewport_size.y
	
	# Make sure the player exists before accessing it
	player = $Player
	if !player:
		player = get_node_or_null("Player")
		print("Warning: Player not directly under main_game, attempting to find via get_node")
		if !player:
			print("ERROR: Player node not found!")
			return
	print("Main game found player: ", player)
	
	# Find and set up the camera reference explicitly
	camera = $MainCamera
	if !camera:
		camera = get_node_or_null("MainCamera")
		print("Warning: Camera not directly under main_game, attempting to find via get_node")
		if !camera:
			print("ERROR: Camera node not found!")
			return
	print("Main game found camera: ", camera)
	
	# Additional failsafe check
	var camera_script = camera.get_script()
	if camera_script == null:
		print("ERROR: Camera has no script attached")
		return
	
	print("Setting up camera...")
	# Ensure the camera's script has the required properties and methods
	if "offset_from_player" in camera:
		camera.offset_from_player = Vector2(0, -300)
		print("Set camera offset to (0, -300)")
	else:
		print("ERROR: Camera script missing offset_from_player property")
	
	if camera.has_method("set_target"):
		print("Setting camera target to player...")
		camera.set_target(player)
	else:
		print("ERROR: Camera script missing set_target method")
	
	# Explicit force of camera position
	var fixed_x = screen_width / 2
	if "fixed_horizontal_position" in camera:
		camera.fixed_horizontal_position = fixed_x
		print("Set camera fixed horizontal position to:", fixed_x)
		
	camera.global_position = Vector2(fixed_x, player.global_position.y - 300)
	print("FORCED camera position to:", camera.global_position)
	
	# Directly check important nodes after setup
	print("VERIFY: Camera position after setup: ", camera.global_position)
	print("VERIFY: Player position after setup: ", player.global_position)
	print("VERIFY: Camera-Player offset: ", camera.global_position - player.global_position)
	
	# Connect a frame timer to double-check camera position after first frame
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = true
	timer.connect("timeout", check_camera_position)
	timer.start()
	
	# Set up the road spawner
	#if road_spawner:
		## Use set_camera method instead of direct property assignment
		#if road_spawner.has_method("set_camera"):
			#road_spawner.set_camera(camera)
			#print("Camera reference set in RoadSpawner")
		#else:
			#print("WARNING: RoadSpawner missing set_camera method")
		#
		## Handle initial road segments
		#if road_spawner.has_method("force_spawn_initial_road_segments"):
			#road_spawner.force_spawn_initial_road_segments()
		#else:
			#print("WARNING: RoadSpawner missing force_spawn_initial_road_segments")
	#
	# Initialize SaveManager - robust way
		()
	
	# Initialize GameModeManager
	initialize_game_mode_manager()
	
	# Apply game mode settings
	apply_game_mode_settings()
	
	# Initialize game systems
	initialize_game_systems()
	
	# Configure time-related UI
	setup_time_ui()
	
	# Apply upgrades from save data
	apply_upgrades()
	
	# Initialize game state
	update_ui()
	
	# Connect signals
	if player:
		player.connect_speed_signal(_on_player_speed_changed)
	
	# Connect UI signals
	pause_button.pressed.connect(_on_pause_button_pressed)

func _exit_tree():
	# Clear global reference when scene is removed
	if current_instance == self:
		current_instance = null

func _process(delta):
	if is_game_over or is_paused:
		return
	
	# Update game time
	game_time += delta
	
	# Update mode statistics
	update_mode_stats()
	
	# Check if time has run out (main game over condition) - only if using time limit
	if max_game_time > 0 and game_time >= max_game_time:
		game_over()
		return
		
	# Check if fuel has run out (alternative game over condition) - only if using fuel
	if use_fuel and fuel <= 0:
		game_over()
		return
	
	update_ui()
	
	# Update combo timer
	if combo > 0:
		combo_timer += delta
		if combo_timer >= combo_timeout:
			combo = 0
			combo_timer = 0.0
			update_ui()
	
	# Update active power-ups
	update_power_ups(delta)
	
	# Fuel consumption - only if using fuel
	if use_fuel:
		consume_fuel(delta)

func _on_player_speed_changed(speed: float):
	# No need to adjust scroll speed anymore since humans move on their own
	pass

func consume_fuel(delta: float):
	# Calculate fuel consumption based on rate, with a minimum consumption
	var consumption = delta * fuel_consumption_rate
	
	# Apply fuel consumption
	fuel = max(0.0, fuel - consumption)
	
	# Update fuel UI
	var fuel_percentage = (fuel / max_fuel) * 100
	var fuel_bar = $UI/TopBar/FuelBar
	if fuel_bar:
		fuel_bar.value = fuel_percentage
		
		# Change bar color based on remaining fuel
		if fuel_percentage < 20:
			fuel_bar.modulate = Color(1, 0, 0, 1)  # Red when low
		elif fuel_percentage < 50:
			fuel_bar.modulate = Color(1, 1, 0, 1)  # Yellow when medium
		else:
			fuel_bar.modulate = Color(0, 1, 0, 1)  # Green when high

func update_ui():
	# Update time remaining as a percentage for the time bar
	var time_remaining = max(0, max_game_time - game_time)
	var time_percentage = (time_remaining / max_game_time) * 100
	
	# Update the time bar
	var time_bar = $UI/TopBar/TimeBar
	if time_bar:
		time_bar.value = time_percentage
		
		# Change bar color based on remaining time
		if time_percentage < 20:
			time_bar.modulate = Color(1, 0, 0, 1)  # Red when low
		elif time_percentage < 50:
			time_bar.modulate = Color(1, 1, 0, 1)  # Yellow when medium
		else:
			time_bar.modulate = Color(0, 1, 0, 1)  # Green when high
	
	# Update fuel bar
	var fuel_percentage = (fuel / max_fuel) * 100
	if fuel_bar:
		fuel_bar.value = fuel_percentage
		
		# Change bar color based on remaining fuel
		if fuel_percentage < 20:
			fuel_bar.modulate = Color(1, 0, 0, 1)  # Red when low
		elif fuel_percentage < 50:
			fuel_bar.modulate = Color(1, 1, 0, 1)  # Yellow when medium
		else:
			fuel_bar.modulate = Color(0, 1, 0, 1)  # Green when high
	
	# Update time label to show time remaining instead of elapsed time
	# Format as MM:SS for better readability
	var minutes = int(time_remaining / 60)
	var seconds = int(time_remaining) % 60
	time_label.text = "%02d:%02d" % [minutes, seconds]
	
	coin_label.text = "Coins: %d" % coins
	if combo > 0:
		coin_label.text += " (x%d)" % combo

func add_coins(amount: int):
	# Update combo
	combo += 1
	combo_timer = 0.0
	
	# Calculate bonus coins based on combo
	var combo_bonus = 1 + (combo - 1) * 0.1  # 10% bonus per combo level
	
	# Apply coin multiplier from upgrades
	var total_bonus = combo_bonus * coin_multiplier
	var coins_to_add = int(amount * total_bonus)
	
	coins += coins_to_add
	update_ui()
	
	# Screen shake when collecting coins
	start_camera_shake(0.5, 0.2)
	
	# Show combo text
	show_combo_text()
	
	# Save coins in real-time (optional)
	if save_manager:
		save_manager.set_current_game_coins(coins)

func show_combo_text():
	var combo_text = Label.new()
	combo_text.text = "x%d" % combo
	combo_text.position = Vector2(randf_range(-100, 100), -50)
	combo_text.add_theme_font_size_override("font_size", 32)
	$UI.add_child(combo_text)
	
	# Animate combo text
	var tween = create_tween()
	tween.tween_property(combo_text, "position:y", -100, 0.5)
	tween.parallel().tween_property(combo_text, "modulate:a", 0.0, 0.5)
	tween.tween_callback(combo_text.queue_free)

func game_over():
	if is_game_over:
		return
		
	is_game_over = true
	
	# Save final score
	if save_manager:
		save_manager.set_current_game_coins(coins)
	
	# Dramatic camera shake
	start_camera_shake(5.0, 0.5)
	
	# Delay game over screen
	await get_tree().create_timer(1.0).timeout
	
	# Change to game over scene (use direct path reference)
	get_tree().change_scene_to_file("res://src/ui/screens/game_over.tscn")

func _on_pause_button_pressed():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_button.text = "Resume" if is_paused else "Pause"
	
# Screen shake functionality
func start_camera_shake(intensity: float, duration: float):
	if camera and camera.has_method("apply_shake"):
		camera.apply_shake(intensity)
	elif camera:
		print("Camera controller missing apply_shake method")
	else:
		print("Camera reference is null")

func setup_mobile_controls():
	# Set up mobile-specific controls
	if OS.get_name() == "Android" or OS.get_name() == "iOS":
		# Adjust UI for mobile
		pause_button.custom_minimum_size = Vector2(80, 60)
		
		# Set up touch controls if needed
		# TODO: Add touch controls for player movement 

# Apply upgrades from save data
func apply_upgrades():
	if save_manager:
		print("Applying upgrades from SaveManager...")
		
		# Apply fuel tank size upgrade
		var fuel_tank_level = save_manager.get_upgrade_level("fuel_tank_size")
		max_fuel = 100.0 + (fuel_tank_level - 1) * 20.0  # Each level adds 20 max fuel
		fuel = max_fuel  # Start with full tank
		print("Applied fuel tank upgrade: Level %d - Max fuel: %.1f" % [fuel_tank_level, max_fuel])
		
		# Apply coin efficiency upgrade
		var coin_efficiency_level = save_manager.get_upgrade_level("coin_efficiency")
		coin_multiplier = 1.0 + (coin_efficiency_level - 1) * 0.2  # Each level adds 20% more coins
		print("Applied coin efficiency upgrade: Level %d - Multiplier: %.1f" % [coin_efficiency_level, coin_multiplier])
		
		# Apply run time upgrade
		var run_time_level = save_manager.get_upgrade_level("run_time")
		var base_time = 60.0
		var time_bonus = (run_time_level - 1) * 10.0  # Each level adds 10 seconds
		var max_time = base_time + time_bonus
		
		if timer_manager:
			timer_manager.set_max_time(max_time)
			print("Applied run time upgrade: Level %d - Max time: %.1f seconds" % [run_time_level, max_time])
		
		# Apply power-up spawn rate based on upgrades
		var power_up_level = save_manager.get_upgrade_level("power_up_slots")
		if spawn_manager:
			# More power-up slots = faster spawning
			var min_spawn_time = max(3.0, 8.0 - (power_up_level - 1) * 0.5)
			var max_spawn_time = max(8.0, 15.0 - (power_up_level - 1) * 0.5)
			spawn_manager.set_spawn_interval(min_spawn_time, max_spawn_time)
			print("Adjusted power-up spawn interval: %.1f-%.1f seconds" % [min_spawn_time, max_spawn_time])
		
		# Apply fuel consumption reduction based on upgrades
		fuel_consumption_rate = 5.0 / (1.0 + (fuel_tank_level - 1) * 0.1)  # Each fuel tank level reduces consumption by 10%
		print("Adjusted fuel consumption rate: %.2f" % fuel_consumption_rate)
		
		# Apply player-specific upgrades
		if player and player.has_method("apply_upgrades"):
			player.apply_upgrades()
	else:
		print("SaveManager not found, using default values")

# Simulate a power-up for testing (will be replaced with actual power-up spawning later)
func _unhandled_input(event):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_P and not is_game_over and not is_paused:
			add_random_power_up()

# Add a random power-up if slots are available
func add_random_power_up():
	if active_power_ups.size() >= power_up_slots:
		print("Maximum power-ups reached (%d/%d)" % [active_power_ups.size(), power_up_slots])
		return
		
	var power_up_types = ["shield", "fuel", "speed_boost", "coin_magnet", "time"]
	var random_type = power_up_types[randi() % power_up_types.size()]
	
	var power_up = {
		"type": random_type,
		"duration": 10.0,  # 10 seconds
		"time_left": 10.0,
		"effect_multiplier": 2.0
	}
	
	active_power_ups.append(power_up)
	
	# Show power-up effect
	show_power_up_effect(power_up.type)
	
	print("Power-up activated: %s (%d/%d slots used)" % [power_up.type, active_power_ups.size(), power_up_slots])
	
	# Apply immediate effect for certain power-ups
	match power_up.type:
		"fuel":
			fuel = min(max_fuel, fuel + max_fuel * 0.3)  # Restore 30% of max fuel
			update_ui()
		"speed_boost":
			if player:
				player.speed *= 1.5  # 50% speed boost
		"time":
			game_time = max(0, game_time - 10.0)  # Add 10 seconds
			update_ui()
				
	# Update UI to show active power-ups
	update_power_up_ui()

# Update all active power-ups
func update_power_ups(delta):
	var i = 0
	while i < active_power_ups.size():
		var power_up = active_power_ups[i]
		power_up.time_left -= delta
		
		if power_up.time_left <= 0:
			# Power-up expired
			deactivate_power_up(power_up)
			active_power_ups.remove_at(i)
			update_power_up_ui()
		else:
			i += 1

# Deactivate a power-up when it expires
func deactivate_power_up(power_up):
	match power_up.type:
		"speed_boost":
			if player:
				# Reset speed to base value with upgrades
				var save_manager = get_node_or_null("/root/SaveManager")
				if save_manager:
					var car_speed_level = save_manager.get_upgrade_level("car_speed")
					var base_speed = 300.0
					var speed_bonus = (car_speed_level - 1) * 30.0
					player.speed = base_speed + speed_bonus
	
	print("Power-up deactivated: %s" % power_up.type)

# Update UI to display active power-ups
func update_power_up_ui():
	# This is a placeholder - will implement actual UI when power-up system is tested
	pass

# Show a visual effect when a power-up is activated
func show_power_up_effect(power_up_type: String):
	# Create a brief visual feedback for the power-up activation
	var label = Label.new()
	label.text = power_up_type.capitalize() + " Activated!"
	
	# Get viewport size
	var viewport_size = get_viewport_rect().size
	label.position = Vector2(randf_range(50, viewport_size.x - 50), randf_range(50, viewport_size.y - 50))
	
	label.add_theme_font_size_override("font_size", 24)
	label.modulate = Color(1, 0.5, 0, 1)  # Orange color
	$UI.add_child(label)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(label, "position:y", label.position.y - 50, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0, 0.8)
	tween.tween_callback(label.queue_free)

# Called when a human is hit by a projectile
func on_human_hit(position: Vector2):
	# Add coins
	add_coins(10)
	
	# Increment humans hit counter for challenges
	humans_hit += 1
	
	# Maybe spawn a power-up (small chance)
	if randf() < 0.1:  # 10% chance
		if spawn_manager:
			var powerup_type = powerup_manager.get_random_powerup_type()
			spawn_manager.spawn_powerup_at(position, powerup_type)
			print("Spawned powerup at human hit position")
		else:
			print("No spawn manager available for powerup spawn")

# Collect a power-up (called from power-up instances)
func collect_power_up(power_up_type):
	# Create an instance if we don't already have one
	if not powerup_manager:
		powerup_manager = PowerUpManagerClass.new()
		add_child(powerup_manager)
	
	print("MainGame: Power-up collected: %s" % power_up_type)
	
	# Handle global power-ups (player handles its own power-ups)
	match power_up_type:
		"time":
			# Add time to the game (subtract from elapsed time)
			var time_bonus = 10.0  # Default time bonus
			game_time = max(0, game_time - time_bonus)  # Subtract from elapsed time
			
			# Show time bonus text
			show_time_bonus_text(time_bonus)
			
			print("Added %.1f seconds to timer" % time_bonus)
		"fuel":
			# Restore fuel
			var fuel_bonus = max_fuel * 0.3  # Restore 30% of max fuel
			fuel = min(max_fuel, fuel + fuel_bonus)
			
			# Show fuel bonus text
			show_fuel_bonus_text(fuel_bonus)
			
			print("Added %.1f fuel" % fuel_bonus)
		"speed", "fire_rate":
			# Forward to player
			if player and player.has_method("collect_power_up"):
				player.collect_power_up(power_up_type)
		_:
			# Pass other power-ups to player
			if player and player.has_method("collect_power_up"):
				player.collect_power_up(power_up_type)

# Timer signal handlers
func _on_time_up():
	print("Time's up!")
	game_over()

func _on_time_updated(time_left: float, max_time: float):
	# Update time display
	if time_label:
		time_label.text = "Time: " + timer_manager.get_time_string()
	
	# Maybe update a progress bar if we have one
	# $UI/TopBar/TimeBar.value = timer_manager.get_time_percentage() * 100.0

func _on_time_added(amount: float):
	# Show a visual effect for time bonus
	var time_bonus_text = Label.new()
	time_bonus_text.text = "+%.0fs" % amount
	time_bonus_text.position = Vector2(time_label.position.x + 100, time_label.position.y)
	time_bonus_text.add_theme_font_size_override("font_size", 24)
	time_bonus_text.modulate = Color(0, 1, 0, 1)  # Green
	$UI.add_child(time_bonus_text)
	
	# Animate
	var tween = create_tween()
	tween.tween_property(time_bonus_text, "position:y", time_bonus_text.position.y - 50, 1.0)
	tween.parallel().tween_property(time_bonus_text, "modulate:a", 0.0, 1.0)
	tween.tween_callback(time_bonus_text.queue_free)

func initialize_game_systems():
	# Initialize timer with default 60 seconds
	timer_manager = TimerManagerClass.new(max_game_time)
	add_child(timer_manager)
	
	# Initialize PowerUpManager
	powerup_manager = PowerUpManagerClass.new()
	add_child(powerup_manager)
	
	# Initialize spawn manager
	spawn_manager = SpawnManagerClass.new()
	spawn_manager.name = "SpawnManager"
	add_child(spawn_manager)
	
	# Set references for spawn manager
	if player:
		spawn_manager.set_player(player)
	
	if camera:
		spawn_manager.set_camera(camera)
	
	# Configure spawners through the spawn manager
	var human_params = {
		"npc_limit": 50,
		"base_speed": 50.0,
		"spawn_chance": 0.9,
		"spawn_rate_multiplier": 1.0,
		"respawn_delay": 1.0
	}
	spawn_manager.update_human_parameters(human_params)
	
	var powerup_params = {
		"spawn_interval_min": 8.0,
		"spawn_interval_max": 15.0,
		"spawn_distance": 800.0,
		"spawn_width_percentage": 0.8,
		"spawn_chance": 0.3,
		"min_powerups": 0,
		"max_powerups": 2
	}
	spawn_manager.update_powerup_parameters(powerup_params)
	
	var road_params = {
		"segment_height": 600,
		"min_obstacles": 0,
		"max_obstacles": 1
	}
	spawn_manager.update_road_parameters(road_params)
	
	# Enable/disable spawners based on game mode
	spawn_manager.set_road_enabled(true)
	spawn_manager.set_humans_enabled(true)
	spawn_manager.set_powerups_enabled(true)
	
	print("Main Game: Game systems initialized")

func add_time(amount):
	game_time = max(0, game_time - amount)
	update_ui()

func get_player_speed_modifier():
	return player_speed_modifier

func get_player_fire_rate_modifier():
	return player_fire_rate_modifier

func get_projectile_speed_modifier():
	return projectile_speed_modifier

static func get_current():
	return current_instance

# Ensure SaveManager is properly initialized
func initialize_save_manager():
	# Try to get global SaveManager first
	save_manager = get_node_or_null("/root/SaveManager")
	
	if save_manager == null:
		# Try direct loading
		var SaveManagerClass = load("res://src/save_manager.gd")
		if SaveManagerClass:
			save_manager = SaveManagerClass.new()
			print("Created local SaveManager instance")
		else:
			print("WARNING: Could not load SaveManager script!")

# Force spawn initial road segments if the spawner didn't do it
func force_spawn_initial_road_segments():
	if spawn_manager and spawn_manager.road_spawner:
		print("Main Game: Forcing initial road segment generation")
		spawn_manager.road_spawner.initialize()
	else:
		print("Main Game: ERROR - Road spawner not found for initial segments")

# Show visual effect for time bonus
func show_time_bonus_text(amount: float):
	var time_bonus_text = Label.new()
	time_bonus_text.text = "+%.0fs" % amount
	time_bonus_text.position = Vector2(time_label.position.x + 100, time_label.position.y)
	time_bonus_text.add_theme_font_size_override("font_size", 24)
	time_bonus_text.modulate = Color(0, 1, 0, 1)  # Green
	$UI.add_child(time_bonus_text)
	
	# Animate
	var tween = create_tween()
	tween.tween_property(time_bonus_text, "position:y", time_bonus_text.position.y - 50, 1.0)
	tween.parallel().tween_property(time_bonus_text, "modulate:a", 0.0, 1.0)
	tween.tween_callback(time_bonus_text.queue_free)

# Show visual effect for fuel bonus
func show_fuel_bonus_text(amount: float):
	var fuel_bonus_text = Label.new()
	fuel_bonus_text.text = "+%.0f Fuel" % amount
	fuel_bonus_text.position = Vector2(fuel_bar.position.x + 100, fuel_bar.position.y)
	fuel_bonus_text.add_theme_font_size_override("font_size", 24)
	fuel_bonus_text.modulate = Color(0, 0.8, 1, 1)  # Blue
	$UI.add_child(fuel_bonus_text)
	
	# Animate
	var tween = create_tween()
	tween.tween_property(fuel_bonus_text, "position:y", fuel_bonus_text.position.y - 50, 1.0)
	tween.parallel().tween_property(fuel_bonus_text, "modulate:a", 0.0, 1.0)
	tween.tween_callback(fuel_bonus_text.queue_free)

# Setup time-related UI for better visibility
func setup_time_ui():
	# We need separate bars for fuel and time
	if fuel_bar:
		# Configure fuel bar appearance
		fuel_bar.min_value = 0
		fuel_bar.max_value = 100
		fuel_bar.value = 100
		fuel_bar.add_theme_color_override("fill_mode", 0)  # Left to right
		
		# Add a label to clarify it's a fuel bar
		var fuel_label = Label.new()
		fuel_label.text = "FUEL"
		fuel_label.position = Vector2(fuel_bar.position.x, fuel_bar.position.y - 25)
		fuel_label.add_theme_font_size_override("font_size", 18)
		$UI/TopBar.add_child(fuel_label)
	
	# Create a separate time bar
	var time_bar = ProgressBar.new()
	time_bar.name = "TimeBar"
	time_bar.min_value = 0
	time_bar.max_value = 100
	time_bar.value = 100
	time_bar.add_theme_color_override("fill_mode", 0)  # Left to right
	time_bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	
	# Position the time bar below the fuel bar
	if fuel_bar:
		time_bar.position = Vector2(fuel_bar.position.x, fuel_bar.position.y + 40)
		time_bar.size = fuel_bar.size
	else:
		time_bar.position = Vector2(20, 20)
		time_bar.size = Vector2(1040, 40)
	
	$UI/TopBar.add_child(time_bar)
	
	# Add a label to clarify it's a time bar
	var time_bar_label = Label.new()
	time_bar_label.text = "TIME"
	time_bar_label.position = Vector2(time_bar.position.x, time_bar.position.y - 25)
	time_bar_label.add_theme_font_size_override("font_size", 18)
	$UI/TopBar.add_child(time_bar_label)

# Extra verification function
func check_camera_position():
	if camera and player:
		print("FIRST FRAME CHECK: Camera pos: ", camera.global_position)
		print("FIRST FRAME CHECK: Player pos: ", player.global_position)
		print("FIRST FRAME CHECK: Offset: ", camera.global_position - player.global_position)
		
		# Force camera position again to be absolutely sure
		var fixed_x = screen_width / 2
		if "fixed_horizontal_position" in camera:
			camera.fixed_horizontal_position = fixed_x
			print("Set camera fixed horizontal position to:", fixed_x)
			
		camera.global_position = Vector2(fixed_x, player.global_position.y - 300)
		print("FORCED camera position to:", camera.global_position)
	else:
		print("FIRST FRAME CHECK: Camera or player reference lost!")
	
	# Setup periodic camera position check
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 1.0
	timer.connect("timeout", monitor_camera_position)
	timer.start()

# Periodic camera monitor to ensure it's following correctly
func monitor_camera_position():
	if camera and player and is_instance_valid(camera) and is_instance_valid(player):
		var offset = camera.global_position - player.global_position
		print("MONITOR: Camera-Player offset:", offset)
		
		# Calculate correct position (fixed X, follow Y with offset)
		var fixed_x = screen_width / 2
		if "fixed_horizontal_position" in camera:
			fixed_x = camera.fixed_horizontal_position
			
		# If the offset is severely wrong, force correction
		if abs(offset.y - (-300)) > 50 or abs(camera.global_position.x - fixed_x) > 10:
			print("CORRECTING: Camera position was wrong!")
			camera.global_position = Vector2(fixed_x, player.global_position.y - 300)
	else:
		print("MONITOR: Camera or player reference invalid")

# Initialize GameModeManager
func initialize_game_mode_manager():
	# Try to get global GameModeManager
	game_mode_manager = get_node_or_null("/root/GameModeManager")
	
	if game_mode_manager == null:
		print("WARNING: GameModeManager not found!")

# Apply current game mode settings
func apply_game_mode_settings():
	if game_mode_manager:
		print("Applying game mode settings...")
		game_mode_manager.apply_settings_to_game(self)
	else:
		print("No GameModeManager, using default settings")

# Update mode statistics for challenges
func update_mode_stats():
	mode_stats = {
		"coins": coins,
		"time": game_time,
		"humans_hit": humans_hit
	}
	
	# Check if challenge is complete
	if game_mode_manager and game_mode_manager.current_mode == game_mode_manager.GameMode.CHALLENGE:
		if game_mode_manager.is_challenge_complete(mode_stats):
			# Add bonus coins
			var challenge = game_mode_manager.challenge_objective
			coins += challenge.get("reward_coins", 0)
			
			# Show success message
			show_challenge_complete()
			
			# End the game
			game_over()

# Set max game time (used by game mode manager)
func set_max_game_time(time: float):
	max_game_time = time
	print("Set max game time to: ", max_game_time)

# Show challenge complete notification
func show_challenge_complete():
	var message = Label.new()
	message.text = "Challenge Complete!"
	message.position = Vector2(get_viewport_rect().size.x/2 - 150, get_viewport_rect().size.y/2)
	message.add_theme_font_size_override("font_size", 48)
	message.modulate = Color(0, 1, 0, 1)  # Green
	$UI.add_child(message)
	
	# Animate
	var tween = create_tween()
	tween.tween_property(message, "position:y", message.position.y - 100, 1.5)
	tween.tween_property(message, "modulate:a", 0, 1.0)
	tween.tween_callback(message.queue_free)
