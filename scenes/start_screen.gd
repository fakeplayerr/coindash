extends Control

# Reference to GameAssets class
const GameAssetsClass = preload("res://scripts/game_assets.gd")

@onready var play_button = $MainMenu/PlayButton
@onready var upgrades_button = $MainMenu/UpgradesButton
@onready var car_select_button = $MainMenu/CarSelectButton
@onready var quit_button = $MainMenu/QuitButton
@onready var total_coins = $TotalCoins
@onready var car_sprite = $CarPreview/CarSprite

func _ready():
	# Connect button signals
	play_button.pressed.connect(_on_play_pressed)
	upgrades_button.pressed.connect(_on_upgrades_pressed)
	car_select_button.pressed.connect(_on_car_select_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
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

func _on_play_pressed():
	# Transition to main game
	var main_game_scene = preload("res://scenes/main_game.tscn")
	get_tree().change_scene_to_packed(main_game_scene)

func _on_upgrades_pressed():
	# Transition to upgrades screen
	var upgrades_scene = preload("res://scenes/upgrades_screen.tscn")
	get_tree().change_scene_to_packed(upgrades_scene)

func _on_car_select_pressed():
	# Transition to car selection screen
	var car_select_scene = preload("res://scenes/car_select_screen.tscn")
	get_tree().change_scene_to_packed(car_select_scene)

func _on_quit_pressed():
	get_tree().quit()

func update_ui():
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		var coins = save_manager.get_total_coins()
		total_coins.text = "Total Coins: %d" % coins
		print("Updated UI with %d coins" % coins)
		
		# Update car preview
		var selected_car = save_manager.get_selected_car()
		var texture = GameAssetsClass.load_car_texture(selected_car)
		if texture and car_sprite:
			car_sprite.texture = texture
	else:
		print("SaveManager not found when updating UI") 
