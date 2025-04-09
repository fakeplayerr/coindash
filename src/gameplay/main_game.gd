extends Node2D

@export var level1 : BaseLevel
@onready var player = $Player
@onready var coin_spawner = $CoinSpawner
@onready var coin_label = $UI/TopBar/CoinLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.initialize_player(player)
	
	# Add to current_level group to make it findable by other nodes
	add_to_group("current_level")
	
	# Connect to level1 signals
	if level1:
		level1.connect("coins_updated", Callable(self, "_on_coins_updated"))
		# Initialize UI with current values
		update_coin_ui(level1.get_coins())
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Handle when a coin is collected (group-based approach)
# This is called directly by the coin projectile
func handle_coin_collected(value: int) -> void:
	if level1:
		level1.add_coins(value)

# Handler for when coins are updated in the level
func _on_coins_updated(new_coin_count: int) -> void:
	update_coin_ui(new_coin_count)

# Update the coin UI with the current count
func update_coin_ui(coin_count: int) -> void:
	if coin_label:
		coin_label.text = "Coins: " + str(coin_count)


	
