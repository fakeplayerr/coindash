extends Node

class_name PowerUpManager

signal powerup_activated(type, duration)
signal powerup_deactivated(type)

# Define power-up types
enum PowerUpType {
	SPEED,
	FIRE_RATE,
	TIME,
	SHIELD,
	MAGNET,
	SCORE_BOOST
}

# Power-up properties
var powerup_properties = {
	PowerUpType.SPEED: {
		"name": "speed",
		"color": Color(0, 1, 0),  # Green
		"duration": 5.0,
		"weight": 25  # Spawn weight
	},
	PowerUpType.FIRE_RATE: {
		"name": "fire_rate",
		"color": Color(1, 0, 0),  # Red
		"duration": 7.0,
		"weight": 25
	},
	PowerUpType.TIME: {
		"name": "time",
		"color": Color(0, 0, 1),  # Blue
		"duration": 10.0,  # This is the amount of time added
		"weight": 15
	},
	PowerUpType.SHIELD: {
		"name": "shield",
		"color": Color(1, 1, 0),  # Yellow
		"duration": 8.0,
		"weight": 15
	},
	PowerUpType.MAGNET: {
		"name": "magnet",
		"color": Color(1, 0, 1),  # Magenta
		"duration": 6.0,
		"weight": 10
	},
	PowerUpType.SCORE_BOOST: {
		"name": "score_x2",
		"color": Color(0, 1, 1),  # Cyan
		"duration": 10.0,
		"weight": 10
	}
}

# Active power-ups
var active_powerups = {}

# Total spawn weight
var total_spawn_weight = 0

# Maximum number of simultaneous power-ups
var max_slots = 1

func _ready():
	# Calculate total spawn weight
	for type in powerup_properties:
		total_spawn_weight += powerup_properties[type]["weight"]

# Get a random power-up type based on weights
func get_random_powerup_type():
	var random_value = randi() % total_spawn_weight
	var cumulative_weight = 0
	
	for type in powerup_properties:
		cumulative_weight += powerup_properties[type]["weight"]
		if random_value < cumulative_weight:
			return type
	
	# Fallback
	return PowerUpType.SPEED

# Get power-up color
func get_powerup_color(type):
	return powerup_properties[type]["color"]

# Get power-up name
func get_power_up_name(type):
	return powerup_properties[type]["name"]

# Get power-up duration
func get_powerup_duration(type):
	return powerup_properties[type]["duration"]

# Activate a power-up
func activate_powerup(type):
	# Check if we've reached the maximum number of active power-ups
	if active_powerups.size() >= max_slots:
		print("PowerUp: Cannot activate, maximum slots reached (%d/%d)" % [active_powerups.size(), max_slots])
		return false
	
	var type_int = int(type)  # Convert to int if it's a string
	var duration = powerup_properties[type_int]["duration"]
	var name = powerup_properties[type_int]["name"]
	
	# Store activation time and setup timer for deactivation
	active_powerups[type_int] = {
		"duration": duration,
		"timer": create_timer(duration, type_int)
	}
	
	print("PowerUp: Activated %s for %.1f seconds" % [name, duration])
	
	# Emit signal for other systems to handle
	emit_signal("powerup_activated", name, duration)
	return true

# Deactivate a power-up
func deactivate_powerup(type):
	var type_int = int(type)  # Convert to int if it's a string
	
	if active_powerups.has(type_int):
		active_powerups.erase(type_int)
		var name = powerup_properties[type_int]["name"]
		print("PowerUp: Deactivated %s" % name)
		
		# Emit signal for other systems to handle
		emit_signal("powerup_deactivated", name)

# Create a timer for power-up deactivation
func create_timer(duration, type):
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration
	timer.autostart = false
	
	# Connect timeout to deactivate the power-up
	timer.timeout.connect(func(): deactivate_powerup(type))
	
	add_child(timer)
	timer.start()
	
	return timer

# Check if a power-up is active
func is_powerup_active(type):
	var type_int = int(type)  # Convert to int if it's a string
	return active_powerups.has(type_int)

# Get remaining time for an active power-up
func get_powerup_remaining_time(type):
	var type_int = int(type)  # Convert to int if it's a string
	
	if active_powerups.has(type_int) and active_powerups[type_int]["timer"]:
		return active_powerups[type_int]["timer"].time_left
	
	return 0.0

# Process function to handle power-up timers
func _process(delta):
	# Additional processing if needed
	pass 

# Update function for backward compatibility (called from other scripts)
func update(delta):
	# Just a wrapper around _process for scripts that call update directly
	# No additional processing needed as timers handle the deactivation
	pass

# Set the maximum number of power-up slots (from upgrades)
func set_max_slots(slots: int):
	max_slots = max(1, slots)
	print("PowerUpManager: Maximum slots set to %d" % max_slots)

# Get the current maximum number of slots
func get_max_slots() -> int:
	return max_slots 
