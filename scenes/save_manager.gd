extends Node

# Save file location in the project directory
const SAVE_FILE = "res://save_data/game_save.json"

var game_data = {
	"total_coins": 0,
	"unlocked_cars": {
		"car1": true,
		"car2": false,
		"car3": false,
		"car4": false,
		"car5": false,
		"car6": false,  # lambo-1
		"car7": false,  # lambo-2
		"car8": false   # lambo-3
	},
	"upgrades": {
		"fuel_tank_size": 1,
		"coin_efficiency": 1,
		"car_speed": 1,
		"car_handling": 1,
		"power_up_slots": 1,
		"fire_rate": 1,        # New upgrade for firing rate
		"projectile_speed": 1, # New upgrade for projectile speed
		"run_time": 1          # New upgrade for maximum run time
	},
	"selected_car": "car1"
}

var current_game_coins: int = 0
var is_initialized: bool = false

func _ready():
	print("SaveManager node path: " + str(get_path()))
	
	# Create save directory if it doesn't exist
	var dir = DirAccess.open("res://")
	if not dir.dir_exists("save_data"):
		dir.make_dir("save_data")
	
	# Load all saved data
	load_game_data()
	
	# Ensure total_coins is an integer (fix for potential float values in save)
	game_data.total_coins = int(game_data.total_coins)
	
	# Ensure all upgrade levels are integers
	for upgrade in game_data.upgrades.keys():
		game_data.upgrades[upgrade] = int(game_data.upgrades[upgrade])
	
	# Add new upgrades if they don't exist in saved data
	_ensure_upgrade_exists("fire_rate", 1)
	_ensure_upgrade_exists("projectile_speed", 1)
	_ensure_upgrade_exists("run_time", 1)
	
	# Force a save to ensure the file exists
	save_game_data()
	
	is_initialized = true
	print("SaveManager: Initialized with %d total coins" % game_data.total_coins)

# Ensure an upgrade exists in the saved data
func _ensure_upgrade_exists(upgrade_name: String, default_value: int):
	if not game_data.upgrades.has(upgrade_name):
		game_data.upgrades[upgrade_name] = default_value
		print("SaveManager: Added missing upgrade: %s = %d" % [upgrade_name, default_value])

func save_game_data():
	# Ensure total_coins is an integer before saving
	game_data.total_coins = int(game_data.total_coins)
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(game_data)
		file.store_string(json_string)
		file.close()
		print("SaveManager: Game data saved successfully to project directory")
	else:
		print("SaveManager ERROR: Failed to save game data - Error code: ", FileAccess.get_open_error())

func load_game_data():
	if FileAccess.file_exists(SAVE_FILE):
		var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			
			if json_string.is_empty():
				print("SaveManager WARNING: Save file exists but is empty. Creating new data.")
				file.close()
				save_game_data()
				return
				
			print("SaveManager: Loading save file from project directory")
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			if parse_result == OK:
				var loaded_data = json.get_data()
				# Make sure all required keys exist in the loaded data
				for key in game_data.keys():
					if key in loaded_data:
						game_data[key] = loaded_data[key]
				
				# Make sure all car entries exist in the loaded data
				if "unlocked_cars" in loaded_data:
					for car_id in game_data.unlocked_cars.keys():
						if not car_id in loaded_data.unlocked_cars:
							# Add any new cars that weren't in the saved data
							loaded_data.unlocked_cars[car_id] = game_data.unlocked_cars[car_id]
							game_data.unlocked_cars[car_id] = loaded_data.unlocked_cars[car_id]
				
				print("SaveManager: Game data loaded successfully")
			else:
				print("SaveManager ERROR: JSON parse error - ", json.get_error_message())
				print("SaveManager: Creating new save file instead")
				file.close()
				save_game_data()
				return
			file.close()
	else:
		print("SaveManager: No save file found, creating new game data")
		save_game_data()  # Create initial save file

func get_total_coins() -> int:
	if !is_initialized:
		print("SaveManager WARNING: Accessed before initialization!")
	return int(game_data.total_coins)

func add_coins(amount: int):
	game_data.total_coins = int(game_data.total_coins) + amount
	save_game_data()
	print("SaveManager: Added %d coins. Total: %d" % [amount, game_data.total_coins])

func get_coins() -> int:
	return int(game_data.total_coins)

func spend_coins(amount: int) -> bool:
	if int(game_data.total_coins) >= amount:
		game_data.total_coins = int(game_data.total_coins) - amount
		save_game_data()
		return true
	return false

func is_car_unlocked(car_name: String) -> bool:
	return game_data.unlocked_cars.get(car_name, false)

func unlock_car(car_name: String):
	game_data.unlocked_cars[car_name] = true
	save_game_data()

func get_upgrade_level(upgrade_name: String) -> int:
	return int(game_data.upgrades.get(upgrade_name, 1))

func upgrade(upgrade_name: String):
	var current_level = int(game_data.upgrades.get(upgrade_name, 1))
	game_data.upgrades[upgrade_name] = current_level + 1
	save_game_data()

func get_selected_car() -> String:
	return game_data.selected_car

func set_selected_car(car_name: String):
	game_data.selected_car = car_name
	save_game_data()
	print("SaveManager: Selected car set to " + car_name)

# Set coins for current game session (not saved until game over)
func set_current_game_coins(amount: int):
	current_game_coins = amount

# Get coins for the current game session
func get_current_game_coins() -> int:
	return current_game_coins 
