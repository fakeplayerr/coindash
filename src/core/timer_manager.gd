extends Node

class_name TimerManager

# Signal for when the timer reaches zero
signal time_up
# Signal for when the timer is updated
signal time_updated(time_left, max_time)
# Signal for when time is added
signal time_added(amount)

# Maximum game time in seconds
var max_game_time: float = 60.0  # Default 60 seconds
# Current time left
var time_left: float = max_game_time
# Whether the timer is running
var is_running: bool = false
# Whether the timer has ended
var is_ended: bool = false

# Constructor with optional parameter for maximum time
func _init(max_time: float = 60.0):
	max_game_time = max_time
	time_left = max_time

# Start the timer
func start():
	if is_ended:
		reset()
	is_running = true
	print("TimerManager: Timer started with %.1f seconds" % time_left)

# Stop the timer
func stop():
	is_running = false
	print("TimerManager: Timer stopped with %.1f seconds remaining" % time_left)

# Reset the timer to max time
func reset():
	time_left = max_game_time
	is_running = false
	is_ended = false
	emit_signal("time_updated", time_left, max_game_time)
	print("TimerManager: Timer reset to %.1f seconds" % time_left)

# Update the timer (call this from _process)
func update(delta: float):
	if not is_running or is_ended:
		return
		
	time_left -= delta
	
	# Ensure time doesn't go below zero
	if time_left <= 0:
		time_left = 0
		is_running = false
		is_ended = true
		emit_signal("time_up")
		print("TimerManager: Time's up!")
	
	# Emit the time updated signal
	emit_signal("time_updated", time_left, max_game_time)

# Add time to the timer
func add_time(seconds: float):
	if is_ended:
		return
		
	time_left += seconds
	print("TimerManager: Added %.1f seconds" % seconds)
	emit_signal("time_added", seconds)
	emit_signal("time_updated", time_left, max_game_time)

# Get the current time left as a string (formatted as MM:SS)
func get_time_string() -> String:
	var minutes = int(time_left) / 60
	var seconds = int(time_left) % 60
	return "%02d:%02d" % [minutes, seconds]

# Get the percentage of time left (0.0 to 1.0)
func get_time_percentage() -> float:
	return time_left / max_game_time

# Set the maximum game time (for upgrades)
func set_max_time(seconds: float):
	var old_max = max_game_time
	max_game_time = seconds
	
	# If time was at max before, set it to new max
	if time_left == old_max:
		time_left = max_game_time
	else:
		# Otherwise, add the difference to current time
		time_left += (max_game_time - old_max)
	
	emit_signal("time_updated", time_left, max_game_time)
	print("TimerManager: Max time set to %.1f seconds" % max_game_time) 