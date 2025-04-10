extends Node2D

@export var level1 : BaseLevel
@export var round_time: float = 10.0  # 60 seconds per round
@onready var player = $Player
@onready var coin_spawner = $CoinSpawner
@onready var coin_label = $UI/TopBar/CoinLabel
@onready var time_label = $UI/TopBar/TimeLabel
@onready var gameover_dialog = $UI/GameOverDialog

var time_remaining: float
var is_game_over: bool = false
var girls_collected_this_round: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Make sure the game starts unpaused
	get_tree().paused = false
	
	GameManager.initialize_player(player)
	
	# Apply current upgrades to game elements
	apply_all_upgrades()
	
	# Connect to GameManager upgrade changes signal if it exists
	if GameManager.has_signal("upgrades_changed"):
		GameManager.connect("upgrades_changed", Callable(self, "apply_all_upgrades"))
	
	# Add to current_level group to make it findable by other nodes
	add_to_group("current_level")
	
	# Connect to level1 signals
	if level1:
		level1.connect("coins_updated", Callable(self, "_on_coins_updated"))
		# Initialize UI with current values
		update_coin_ui(level1.get_coins())
	
	# Initialize timer
	time_remaining = round_time
	update_time_ui()
	
	# Hide game over dialog at start
	if gameover_dialog:
		gameover_dialog.visible = false
		
	# Connect to all girl NPCs' died signals
	connect_to_girl_npcs()
	
	# Connect to the tree to detect when nodes are added
	get_tree().node_added.connect(_on_node_added)

# Connect to all existing girl NPCs in the scene
func connect_to_girl_npcs() -> void:
	var girl_npcs = get_tree().get_nodes_in_group("enemies")
	for npc in girl_npcs:
		if npc.get_script() != null and npc.get_script().resource_path.contains("girl_npc.gd") and not npc.died.is_connected(Callable(self, "_on_girl_collected")):
			npc.died.connect(_on_girl_collected)
			print("Connected to girl NPC:", npc.name)

# Called when a new node is added to the scene tree
func _on_node_added(node: Node) -> void:
	# Check if the node is a girl NPC
	if node.is_in_group("enemies") and node.get_script() != null and node.get_script().resource_path.contains("girl_npc.gd"):
		# Connect to its died signal if not already connected
		if not node.died.is_connected(Callable(self, "_on_girl_collected")):
			node.died.connect(_on_girl_collected)
			print("Connected to newly added girl NPC:", node.name)

# Called when a girl NPC is collected
func _on_girl_collected() -> void:
	girls_collected_this_round += 1
	print("Girl collected! Total this round: ", girls_collected_this_round)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_game_over:
		return
		
	# Update timer
	time_remaining -= delta
	update_time_ui()
	
	# Check for game over
	if time_remaining <= 0:
		time_remaining = 0
		update_time_ui()
		game_over()

# Update the time UI with current remaining time
func update_time_ui() -> void:
	if time_label:
		time_label.text = "Time: " + str(int(time_remaining))

# Handle game over state
func game_over() -> void:
	if is_game_over:
		return
		
	is_game_over = true
	
	# Pause the game
	get_tree().paused = true
	
	# Save coins and girls to GameManager
	GameManager.add_coins(level1.get_coins())
	GameManager.add_girls_collected(girls_collected_this_round)
	GameManager.save_game()
	
	# Show game over dialog
	if gameover_dialog:
		gameover_dialog.dialog_text = "Round Over!\n\nCoins collected: " + str(level1.get_coins()) + "\nGirls charmed: " + str(girls_collected_this_round)
		gameover_dialog.popup_centered()
		
		# Connect the dialog's close signal to return to menu if not already connected
		if not gameover_dialog.confirmed.is_connected(Callable(self, "_on_return_to_menu_pressed")):
			gameover_dialog.confirmed.connect(_on_return_to_menu_pressed)

# Called when the player clicks the "Return to Menu" button
func _on_return_to_menu_pressed() -> void:
	# Unpause the game before changing scenes
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn")

# Apply all current upgrades from GameManager to game elements
func apply_all_upgrades() -> void:
	apply_speed_upgrades()
	apply_projectile_upgrades()

# Apply speed-related upgrades to the player
func apply_speed_upgrades() -> void:
	if player and player.has_method("set_max_speed"):
		var speed_multiplier = 1.0 + (GameManager.upgrades_manager.get_upgrade_level("car_speed") - 1) * 0.15
		var base_speed = GameManager.get_speed()
		var new_speed = base_speed * speed_multiplier
		player.set_max_speed(new_speed)
		print("Applied speed upgrade: ", new_speed)

# Apply projectile-related upgrades
func apply_projectile_upgrades() -> void:
	# Set projectile speed on spawner if it has the method
	if coin_spawner and coin_spawner.has_method("set_projectile_speed"):
		var projectile_speed = GameManager.get_projectile_speed()
		coin_spawner.set_projectile_speed(projectile_speed)
		print("Applied projectile speed upgrade: ", projectile_speed)
	
	# Set fire rate on spawner if it has the method
	if coin_spawner and coin_spawner.has_method("set_fire_rate"):
		var fire_rate = GameManager.get_fire_rate()
		coin_spawner.set_fire_rate(fire_rate)
		print("Applied fire rate upgrade: ", fire_rate)

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


	
