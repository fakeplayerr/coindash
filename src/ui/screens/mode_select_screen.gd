extends Control

# Game mode container
@onready var mode_container = $ModeContainer
@onready var mode_description = $ModeDescription
@onready var back_button = $BackButton

# Game mode manager reference
var game_mode_manager = null

func _ready():
	print("Mode Select Screen: Initializing")
	
	# Connect the back button signal
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Get access to GameModeManager
	game_mode_manager = get_node_or_null("/root/GameModeManager")
	if not game_mode_manager:
		print("Mode Select Screen ERROR: GameModeManager not found!")
		return
	
	# Create mode buttons dynamically
	create_mode_buttons()

func create_mode_buttons():
	# Clear any existing children
	for child in mode_container.get_children():
		child.queue_free()
	
	# Create buttons for each game mode
	for mode in game_mode_manager.GameMode.values():
		var mode_button = Button.new()
		mode_button.text = game_mode_manager.get_mode_name(mode)
		mode_button.custom_minimum_size = Vector2(200, 60)
		mode_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Create a unique ID for each button
		var button_id = mode
		
		# Connect button pressed signal
		mode_button.pressed.connect(_on_mode_button_pressed.bind(button_id))
		
		# Add button to container
		mode_container.add_child(mode_button)
		
		# Add mouse enter/exit signals for tooltips
		mode_button.mouse_entered.connect(_on_button_mouse_entered.bind(button_id))
		mode_button.mouse_exited.connect(_on_button_mouse_exited)
	
	# Update description with current mode
	update_description(game_mode_manager.current_mode)

func update_description(mode_id: int):
	if game_mode_manager:
		mode_description.text = game_mode_manager.get_mode_description(mode_id)

func _on_mode_button_pressed(mode_id: int):
	if game_mode_manager:
		# Set the selected game mode
		game_mode_manager.set_game_mode(mode_id)
		
		# Update description
		update_description(mode_id)
		
		# Load the main game scene (handles challenge objective selection if needed)
		if mode_id == game_mode_manager.GameMode.CHALLENGE:
			# Maybe show challenge selection UI first
			show_challenge_selection()
		elif mode_id == game_mode_manager.GameMode.SURVIVAL:
			show_survavil_selection()
		else:
			# Go directly to game
			get_tree().change_scene_to_file("res://src/gameplay/main_game.tscn")

func show_survavil_selection():
	get_tree().change_scene_to_file("res://src/gameplay/modes/survival.tscn")

func show_challenge_selection():
	# For now, just select a random challenge and start the game
	var challenge = game_mode_manager.get_random_challenge()
	print("Selected challenge: ", challenge["name"])
	
	# Show challenge info dialog
	var dialog = AcceptDialog.new()
	dialog.title = "Challenge: " + challenge["name"]
	dialog.dialog_text = challenge["description"] + "\n\nReward: " + str(challenge["reward_coins"]) + " coins"
	dialog.size = Vector2(400, 200)
	add_child(dialog)
	
	# Connect the confirmed signal to start the game
	dialog.confirmed.connect(func(): get_tree().change_scene_to_file("res://src/gameplay/main_game.tscn"))
	
	# Show the dialog
	dialog.popup_centered()

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn")

func _on_button_mouse_entered(mode_id: int):
	update_description(mode_id)

func _on_button_mouse_exited():
	# Restore description to current mode
	if game_mode_manager:
		update_description(game_mode_manager.current_mode) 
