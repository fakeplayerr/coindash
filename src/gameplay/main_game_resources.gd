extends Resource
class_name BaseLevel

signal coins_updated(new_coin_count)

@export var time : float = 0.0
@export var coins: int = 0
#@export var road_spawner
#@export var human_spawner


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Add coins to the level and emit signal
func add_coins(amount: int) -> void:
	coins += amount
	emit_signal("coins_updated", coins)

# Get current coin count
func get_coins() -> int:
	return coins
