extends Control

@onready var play_button = $MainMenu/PlayButton
@onready var upgrades_button = $MainMenu/UpgradesButton
@onready var car_select_button = $MainMenu/CarSelectButton
@onready var reset_save_button = $ResetSaveButton
@onready var quit_button = $MainMenu/QuitButton
@onready var total_coins = $TotalCoins
@onready var add_coins_button = $AddCoins
@onready var car_sprite = $CarPreview/CarSprite

@onready var load_game_button = $LoadGame
@onready var save_game_button = $SaveGame

func _on_load_game_button_pressed():
	GameManager.load_game()
	update_ui()
	
func _on_save_game_button_pressed():
	GameManager.save_game()
	
func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	car_select_button.pressed.connect(_on_car_select_pressed)
	reset_save_button.pressed.connect(_on_reset_save_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	add_coins_button.pressed.connect(_on_add_coins_button_pressed)
	
	load_game_button.pressed.connect(_on_load_game_button_pressed)
	save_game_button.pressed.connect(_on_save_game_button_pressed)
	
	
	# Set initial coin display to loading
	total_coins.text = "Total Coins: Loading..."
	
	# Wait for SaveManager to be ready
	var autoload = get_node_or_null("/root/Autoload")
	if autoload:
		if autoload.save_manager and is_instance_valid(autoload.save_manager):
			print("SaveManager already available, updating UI")
			update_ui()
		else:
			print("Waiting for SaveManager to be ready")
			autoload.connect("save_manager_ready", _on_save_manager_ready)
	else:
		# Fallback if Autoload is not found
		await get_tree().create_timer(0.5).timeout
		update_ui()

func _on_save_manager_ready():
	print("SaveManager is ready, updating UI now")
	update_ui()
	
func _on_add_coins_button_pressed():
	GameManager.add_coins(100)
	update_ui()

func _on_play_pressed():
	# Transition to main game
	print("Changing scene to main game")
	get_tree().change_scene_to_file("res://src/gameplay/main_game.tscn")

func _on_game_modes_pressed():
	# Transition to game modes screen
	print("Changing scene to game modes screen")
	get_tree().change_scene_to_file("res://src/ui/screens/mode_select_screen.tscn")

func _on_upgrades_pressed():
	# Transition to upgrades screen
	print("Changing scene to upgrades screen")
	get_tree().change_scene_to_file("res://src/ui/screens/upgrades_screen.tscn")

func _on_car_select_pressed():
	# Transition to car selection screen
	print("Changing scene to car select screen")
	get_tree().change_scene_to_file("res://src/ui/screens/car_select_screen.tscn")

func _on_reset_save_pressed():
	# Create confirmation dialog
	var confirm_dialog = ConfirmationDialog.new()
	confirm_dialog.title = "Reset Save Data"
	confirm_dialog.dialog_text = "Are you sure you want to reset all save data?\nThis will reset your coins, unlocked cars, and upgrades.\nThis action cannot be undone!"
	confirm_dialog.size = Vector2(400, 200)
	
	# Connect the confirmed signal
	confirm_dialog.confirmed.connect(_reset_save_data_confirmed)
	
	# Add to scene and show
	add_child(confirm_dialog)
	confirm_dialog.popup_centered()

func _reset_save_data_confirmed():
	# Get save manager
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		# Reset save data
		save_manager.reset_save_data()
		
		# Update UI to show reset values
		update_ui()
		
		# Show message
		var message = Label.new()
		message.text = "Save data reset to default values!"
		message.position = Vector2(get_viewport_rect().size.x/2 - 150, get_viewport_rect().size.y/2)
		message.add_theme_font_size_override("font_size", 24)
		message.modulate = Color(1, 0.5, 0, 1)  # Orange
		add_child(message)
		
		# Animate and remove
		var tween = create_tween()
		tween.tween_property(message, "position:y", message.position.y - 100, 1.5)
		tween.parallel().tween_property(message, "modulate:a", 0, 1.5)
		tween.tween_callback(message.queue_free)
	else:
		print("SaveManager not found when trying to reset save data")

func _on_quit_pressed():
	get_tree().quit()

func update_ui():
	total_coins.text = "Total Coins: %d" % GameManager.get_coins()
	print("Updated UI with %d coins" % GameManager.get_coins())
	
	# Update car preview
	var texture = GameManager.car_manager.get_selected_car().image
	if texture and car_sprite:
		car_sprite.texture = texture
