extends Control

@onready var play_button = $MainMenu/PlayButton
@onready var upgrades_button = $MainMenu/UpgradesButton
@onready var car_select_button = $MainMenu/CarSelectButton
@onready var reset_save_button = $ResetSaveButton
@onready var quit_button = $MainMenu/QuitButton
@onready var total_coins = $TotalCoins
@onready var girls_working = $"GirlsWorking"
@onready var passive_income = $"PassiveIncome"
@onready var add_coins_button = $AddCoins
@onready var car_sprite = $CarPreview/CarSprite

@onready var load_game_button = $LoadGame
@onready var save_game_button = $SaveGame

# Timer for periodic UI updates to show real-time coin accumulation
var update_timer: Timer

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
	
	# Create and start timer for periodic UI updates
	setup_update_timer()
	
	# Update UI with current values right away
	update_ui()
	
	# Set initial coin display to loading
	total_coins.text = "Coins: " + str(GameManager.get_coins())

func setup_update_timer():
	update_timer = Timer.new()
	update_timer.wait_time = 0.5  # Update every half second
	update_timer.autostart = true
	update_timer.timeout.connect(_on_update_timer_timeout)
	add_child(update_timer)

func _on_update_timer_timeout():
	# Update just the coins display for real-time updates
	if total_coins:
		var current_coins = GameManager.get_coins()
		total_coins.text = "Coins: %d" % current_coins
		
		# Flash the passive income label if girls are generating income
		if GameManager.get_girls_collected() > 0:
			flash_passive_income_label()

# Create a simple flash effect for the passive income label
func flash_passive_income_label():
	if passive_income:
		# Store original color
		var original_color = passive_income.modulate
		
		# Flash to highlight color
		passive_income.modulate = Color(1.5, 1.5, 0.5, 1)  # Gold/yellow tint
		
		# Create a tween to animate back to normal
		var tween = create_tween()
		tween.tween_property(passive_income, "modulate", original_color, 0.4)

func _on_save_manager_ready():
	print("SaveManager is ready, updating UI now")
	update_ui()
	
func _on_add_coins_button_pressed():
	GameManager.add_coins(10000000)
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
		GameManager.reset_game()
		# Update UI to show reset values
		update_ui()
		
	

func _on_quit_pressed():
	get_tree().quit()

func update_ui():
	# Update girls count
	# Update passive income display
	passive_income.text = "Passive Income: %d coins/sec" % GameManager.get_girls_collected()
	
	# Update coins count
	total_coins.text = "Coins: %d" % GameManager.get_coins()
	print("Updated UI with %d coins" % GameManager.get_coins())
	
	# Update car preview
	var texture = GameManager.car_manager.get_selected_car().image
	if texture and car_sprite:
		car_sprite.texture = texture
