extends Node

# Game mode definitions
enum GameMode {
	CLASSIC,       # Standard game with time and fuel
	ENDLESS,       # No time limit, just fuel
	TIME_ATTACK,   # Only time limit, no fuel concerns
	SURVIVAL,      # Harder enemies, faster depletion
	CHALLENGE      # Special challenges with objectives
}

# Current active game mode
var current_mode: int = GameMode.CLASSIC
var challenge_objective: Dictionary = {}

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

func _ready():
	# Initialize with default game mode
	set_game_mode(GameMode.CLASSIC)

# Set the current game mode
func set_game_mode(mode: int):
	current_mode = mode
	print("Game Mode Manager: Set mode to " + game_mode_settings[mode]["name"])

# Get current game mode settings
func get_current_mode_settings() -> Dictionary:
	return game_mode_settings[current_mode]

# Get game mode name
func get_mode_name(mode: int = -1) -> String:
	if mode == -1:
		mode = current_mode
	return game_mode_settings[mode]["name"]

# Get game mode description
func get_mode_description(mode: int = -1) -> String:
	if mode == -1:
		mode = current_mode
	return mode_descriptions[mode]

# Get random challenge objective
func get_random_challenge() -> Dictionary:
	if challenge_objectives.size() > 0:
		var index = randi() % challenge_objectives.size()
		challenge_objective = challenge_objectives[index]
		return challenge_objective
	return {}

# Check if a challenge is complete
func is_challenge_complete(stats: Dictionary) -> bool:
	if challenge_objective.is_empty():
		return false
		
	match challenge_objective["type"]:
		"coins":
			return stats.get("coins", 0) >= challenge_objective["target"]
		"time":
			return stats.get("time", 0) >= challenge_objective["target"]
		"humans":
			return stats.get("humans_hit", 0) >= challenge_objective["target"]
	
	return false

# Apply game mode settings to main game
func apply_settings_to_game(game: Node):
	var settings = get_current_mode_settings()
	
	# Set time limit
	if game.has_method("set_max_game_time"):
		game.set_max_game_time(settings["time_limit"])
	elif "max_game_time" in game:
		game.max_game_time = settings["time_limit"]
	
	# Set fuel usage
	if "use_fuel" in game:
		game.use_fuel = settings["use_fuel"]
	
	# Set fuel consumption rate
	if "fuel_consumption_rate" in game:
		game.fuel_consumption_rate = settings["fuel_consumption_rate"]
	
	# Set human speed through road spawner
	var road_spawner = game.get_node_or_null("RoadSpawner")
	if road_spawner and "human_speed" in road_spawner:
		road_spawner.human_speed = settings["human_speed"]
	
	# Set spawn rate
	if road_spawner and "spawn_rate_multiplier" in road_spawner:
		road_spawner.spawn_rate_multiplier = settings["spawn_rate"]
	
	print("Game Mode Manager: Applied settings for " + settings["name"] + " mode to game") 