extends Node2D

# Reference to the module classes
const PowerUpManagerClass = preload("res://scripts/power_up_manager.gd")
const TimerManagerClass = preload("res://scripts/timer_manager.gd")
const PowerUpSpawnerClass = preload("res://scripts/power_up_spawner.gd")

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
var power_up_spawner: PowerUpSpawnerClass = null
var powerup_manager = null

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
@onready var road_spawner = $RoadSpawner

# Global reference for the main game
static var current_instance = null

# Save manager
var save_manager = null

func _ready():
	# Register global instance
	current_instance = self
	
	# Initialize SaveManager - robust way
	initialize_save_manager()
	
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
	
	# Initialize road spawner with camera reference
	if road_spawner and camera:
		road_spawner.set_camera(camera)
		print("Main Game: Road spawner initialized with camera reference")
		
		# Configure road spawner parameters
		road_spawner.max_obstacles = 1  # Maximum 1 obstacle per segment
		road_spawner.spawn_human_chance = 0.9  # 90% chance to spawn humans at each point
		road_spawner.human_limit = 100  # Essentially unlimited humans
	else:
		print("Main Game: WARNING - Road spawner or camera not found!")
	
	# Force spawn initial road segments
	call_deferred("force_spawn_initial_road_segments")
	
	# Reset the pause state
	get_tree().paused = false

func _exit_tree():
	# Clear global reference when scene is removed
	if current_instance == self:
		current_instance = null

func _process(delta):
	if is_game_over or is_paused:
		return
		
	# Update game time
	game_time += delta
	
	# Check if time has run out (main game over condition)
	if game_time >= max_game_time:
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
	
	# Fuel is no longer a game over condition
	consume_fuel(delta)

func _on_player_speed_changed(speed: float):
	# No need to adjust scroll speed anymore since humans move on their own
	pass

func consume_fuel(delta: float):
	fuel = max(0.0, fuel - delta * fuel_consumption_rate)

func update_ui():
	# Update time remaining as a percentage for the time bar
	var time_remaining = max(0, max_game_time - game_time)
	var time_percentage = (time_remaining / max_game_time) * 100
	
	# Get the time bar with its new name
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
	print("Game over! Total coins: ", coins)
	
	# Stop timer
	if timer_manager:
		timer_manager.stop()
	
	# Screen shake on game over
	start_camera_shake(5.0, 0.5)
	
	# Show game over screen
	var game_over_scene = preload("res://scenes/game_over.tscn")
	var game_over_instance = game_over_scene.instantiate()
	
	# Make sure the game over UI can process input while paused
	game_over_instance.process_mode = Node.PROCESS_MODE_ALWAYS
	
	$UI.add_child(game_over_instance)
	
	# Set score in game over screen
	if game_over_instance.has_method("set_score"):
		game_over_instance.set_score(coins)
	
	# Save coins earned with a guaranteed save
	if save_manager:
		save_manager.add_coins(coins)
		print("Saved %d coins" % coins)
	
	# Pause the game
	get_tree().paused = true
	print("Game paused, game over screen should be interactive")

func _on_pause_button_pressed():
	is_paused = !is_paused
	get_tree().paused = is_paused
	pause_button.text = "Resume" if is_paused else "Pause"
	
# Screen shake functionality
func start_camera_shake(intensity: float, duration: float):
	if camera and camera.has_method("start_shake"):
		camera.start_shake(intensity, duration)

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
		if power_up_spawner:
			# More power-up slots = faster spawning
			var min_spawn_time = max(3.0, 8.0 - (power_up_level - 1) * 0.5)
			var max_spawn_time = max(8.0, 15.0 - (power_up_level - 1) * 0.5)
			power_up_spawner.set_spawn_interval(min_spawn_time, max_spawn_time)
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
		
	var power_up_types = ["shield", "fuel_boost", "speed_boost", "coin_magnet"]
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
		"fuel_boost":
			fuel = min(max_fuel, fuel + max_fuel * 0.3)  # Restore 30% of max fuel
			update_ui()
		"speed_boost":
			if player:
				player.speed *= 1.5  # 50% speed boost
				
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
	
	# Maybe spawn a power-up (small chance)
	if randf() < 0.1:  # 10% chance
		if power_up_spawner:
			# Create an instance if we don't already have one
			if not powerup_manager:
				powerup_manager = PowerUpManagerClass.new()
				add_child(powerup_manager)
			
			# Get a random powerup type from the instance
			var powerup_type = powerup_manager.get_random_powerup_type()
			power_up_spawner.force_spawn(powerup_type, position)

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
	
	# Initialize power-up spawner
	power_up_spawner = PowerUpSpawnerClass.new()
	add_child(power_up_spawner)
	
	# Set player reference for the spawner
	if player:
		power_up_spawner.set_player(player)

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
		var SaveManagerClass = load("res://scenes/save_manager.gd")
		if SaveManagerClass:
			save_manager = SaveManagerClass.new()
			print("Created local SaveManager instance")
		else:
			print("WARNING: Could not load SaveManager script!")

# Force spawn initial road segments if the spawner didn't do it
func force_spawn_initial_road_segments():
	if road_spawner:
		print("Main Game: Forcing initial road segment generation")
		road_spawner.generate_initial_segments()
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

# Setup time-related UI for better visibility
func setup_time_ui():
	# Rename the fuel bar to time bar for clarity
	if fuel_bar:
		fuel_bar.name = "TimeBar"
		var time_bar = $UI/TopBar/TimeBar
		
		# Configure appearance
		time_bar.min_value = 0
		time_bar.max_value = 100
		time_bar.value = 100
		
		# Set colors to indicate time (green to yellow to red)
		time_bar.add_theme_color_override("fill_mode", 0)  # Left to right
		
		# Add a label to clarify it's a time bar
		var bar_label = Label.new()
		bar_label.text = "TIME"
		bar_label.position = Vector2(time_bar.position.x, time_bar.position.y - 25)
		bar_label.add_theme_font_size_override("font_size", 18)
		$UI/TopBar.add_child(bar_label)
