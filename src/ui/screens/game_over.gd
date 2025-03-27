extends Control

@onready var score_label = $Panel/ScoreLabel
@onready var coins_collected_label = $Panel/CoinsCollectedLabel
@onready var total_coins_label = $Panel/TotalCoinsLabel
@onready var main_menu_button = $Panel/MainMenuButton
@onready var play_again_button = $Panel/PlayAgainButton

# Add new label for mode display
@onready var mode_label = $Panel/ModeLabel

func _ready():
	print("Game Over Screen: Initializing")
	
	# Connect button signals
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	play_again_button.pressed.connect(_on_play_again_pressed)
	
	# Display scores from SaveManager
	var save_manager = get_node_or_null("/root/SaveManager")
	var game_mode_manager = get_node_or_null("/root/GameModeManager")
	
	if save_manager:
		var current_game_coins = save_manager.get_current_game_coins()
		
		# Add current game coins to total coins
		save_manager.add_coins(current_game_coins)
		var total_coins = save_manager.get_total_coins()
		
		# Set the score labels
		score_label.text = "Score: %d" % (current_game_coins * 10)
		coins_collected_label.text = "Coins: %d" % current_game_coins
		total_coins_label.text = "Total Coins: %d" % total_coins
		
		# Show game mode information if available
		if game_mode_manager and mode_label:
			var mode_name = game_mode_manager.get_mode_name()
			mode_label.text = "Mode: %s" % mode_name
			
			# Add challenge completed info if applicable
			if game_mode_manager.current_mode == game_mode_manager.GameMode.CHALLENGE:
				var challenge = game_mode_manager.challenge_objective
				if challenge:
					mode_label.text += "\nChallenge: %s" % challenge.get("name", "Unknown")
					
					# Add challenge reward if completed
					var reward = challenge.get("reward_coins", 0)
					if reward > 0:
						mode_label.text += "\nBonus Coins: %d" % reward
		
		print("Game Over: Showing final score (%d coins, %d total)" % [current_game_coins, total_coins])
	else:
		print("Game Over: SaveManager not found")

func _on_main_menu_pressed():
	print("Game Over: Returning to main menu")
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn")

func _on_play_again_pressed():
	print("Game Over: Restarting game")
	get_tree().change_scene_to_file("res://src/gameplay/main_game.tscn")

# Process input directly as a backup approach
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Input event detected in game over screen: " + str(event.position))
		
		# Check if mouse is over main menu button
		if main_menu_button and main_menu_button.get_global_rect().has_point(event.position):
			print("Mouse clicked on main menu button")
			_on_main_menu_pressed()
		
		# Check if mouse is over play again button
		if play_again_button and play_again_button.get_global_rect().has_point(event.position):
			print("Mouse clicked on play again button")
			_on_play_again_pressed()

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		print("Mouse entered game over screen")
	elif what == NOTIFICATION_MOUSE_EXIT:
		print("Mouse exited game over screen") 
