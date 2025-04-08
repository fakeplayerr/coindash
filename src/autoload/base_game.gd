extends Node

var config = ConfigFile.new()
# Game mode definitions
enum GameMode {
	CLASSIC, # Standard game with time and fuel
	ENDLESS, # No time limit, just fuel
	TIME_ATTACK, # Only time limit, no fuel concerns
	SURVIVAL, # Harder enemies, faster depletion
	CHALLENGE # Special challenges with objectives
}

# Current active game mode
var current_mode: int = GameMode.CLASSIC
var challenge_objective: Dictionary = {}

@export var inventory: Inventory = Inventory.new()
@export var car_manager: CarManager

# Mode-specific settings
var game_mode_settings = {
	GameMode.CLASSIC: {
		"name": "Classic",
		"description": "Beat the clock and manage your fuel",
		"time_limit": 60.0,
		"use_fuel": true,
		"fuel_consumption_rate": 5.0,
		"human_speed": 50.0,
		"spawn_rate": 1.0
	},
	GameMode.ENDLESS: {
		"name": "Endless",
		"description": "No time limit, just manage your fuel",
		"time_limit": 0.0,  # No time limit
		"use_fuel": true,
		"fuel_consumption_rate": 7.0,  # Faster fuel consumption
		"human_speed": 60.0,
		"spawn_rate": 1.2
	},
	GameMode.TIME_ATTACK: {
		"name": "Time Attack",
		"description": "Race against the clock to collect coins",
		"time_limit": 30.0,  # Shorter time
		"use_fuel": false,   # No fuel concerns
		"human_speed": 70.0, # Faster humans
		"spawn_rate": 1.5    # More humans
	},
	GameMode.SURVIVAL: {
		"name": "Survival",
		"description": "Survive as long as possible with limited resources",
		"time_limit": 90.0,  # Longer time
		"use_fuel": true,
		"fuel_consumption_rate": 10.0,  # Much faster fuel consumption
		"human_speed": 80.0, # Much faster humans
		"spawn_rate": 2.0    # Many more humans
	},
	GameMode.CHALLENGE: {
		"name": "Challenge",
		"description": "Complete special objectives",
		"time_limit": 60.0,
		"use_fuel": true,
		"fuel_consumption_rate": 5.0,
		"human_speed": 60.0,
		"spawn_rate": 1.0
	}
}

# Game mode descriptions for UI
var mode_descriptions = {
	GameMode.CLASSIC: "The standard game mode with time and fuel limits. Collect coins and upgrade your car.",
	GameMode.ENDLESS: "Play without time pressure. Just manage your fuel and collect as many coins as possible.",
	GameMode.TIME_ATTACK: "Race against the clock! Collect as many coins as possible before time runs out. No fuel worries.",
	GameMode.SURVIVAL: "Resources are scarce! Fuel depletes faster and humans move quicker. How long can you survive?",
	GameMode.CHALLENGE: "Complete specific objectives to earn bonus rewards and unlock special content."
}

# Challenge objectives
var challenge_objectives = [
	{
		"name": "Coin Collector",
		"description": "Collect 50 coins in 45 seconds",
		"type": "coins",
		"target": 50,
		"time_limit": 45.0,
		"reward_coins": 100
	},
	{
		"name": "Fuel Efficiency",
		"description": "Survive for 60 seconds with minimal fuel consumption",
		"type": "time",
		"target": 60,
		"fuel_limit": 50.0,
		"reward_coins": 150
	},
	{
		"name": "Speed Demon",
		"description": "Hit 30 humans in 30 seconds",
		"type": "humans",
		"target": 30,
		"time_limit": 30.0,
		"reward_coins": 200
	}
]


# Global game settings
const BASE_SPEED := 200.0
const MAX_SPEED := 1000.0

var player_speed := BASE_SPEED
var coins := 0
var fuel := 100.0
var unlocked_cars := [false, false, false] # First car unlocked, others locked

func initialize_player(player: Node) -> void:
	if player and player.base_player and inventory.selected_car:
		player.base_player.car = inventory.selected_car
		player._update_car_texture()
		print("Player initialized with car: ", player.base_player.car.name)

# Set the current game mode
func set_game_mode(mode: int):
	current_mode = mode
	print("Game Mode Manager: Set mode to " + game_mode_settings[mode]["name"])

# Function to reset game state
func reset_game():
	coins = 0
	fuel = 100.0
	player_speed = BASE_SPEED

func save_game():
	var config = ConfigFile.new()
	config.set_value("player", "coins", coins)
	config.set_value("player", "fuel", fuel)
	config.set_value("player", "unlocked_cars", unlocked_cars)

	var save_path = "user://save_data/config.cfg"  # Use user:// instead of res:// for writable storage
	var err = config.save(save_path)

	if err == OK:
		print("Game saved successfully at: ", save_path)
	else:
		print("Error saving game! Error code: ", err)

func load_game():
	var config = ConfigFile.new()
	var load_path = "user://save_data/config.cfg"

	if config.load(load_path) == OK:
		coins = config.get_value("player", "coins", 0)
		fuel = config.get_value("player", "fuel", 100.0)
		unlocked_cars = config.get_value("player", "unlocked_cars", [false, false, false])

		print("Game loaded successfully!")
		print("Coins:", coins)
		print("Fuel:", fuel)
		print("Unlocked Cars:", unlocked_cars)
	else:
		print("No save file found or failed to load.")

#@export var energy = 0:
	#set(value):
		#energy = value
		#update_configuration_warnings()
#
#func _get_configuration_warnings():
	#if energy < 0:
		#return ["Energy must be 0 or greater."]
	#else:
		#return []
