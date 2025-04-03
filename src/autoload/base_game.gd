extends Node
class_name BaseGame

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

@export var inventory : Inventory

# Car textures dictionary
static var car_textures : Dictionary = {
	"coins": "0",
}

@export var energy = 0:
	set(value):
		energy = value
		update_configuration_warnings()

func _get_configuration_warnings():
	if energy < 0:
		return ["Energy must be 0 or greater."]
	else:
		return []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
