extends Control

# This script was updated by the fix_references.gd tool
# The GameAssetsClass constant remain unchanged but now refers to GameAssetsResource class

# Reference to GameAssets class
const GameAssetsClass = preload("res://src/autoload/game_assets.gd")

@onready var car_grid = $CarGrid
@onready var back_button = $BackButton
@onready var coin_label = $TotalCoins if has_node("TotalCoins") else null

var save_manager: Node

# Car unlock costs
var car_costs = {
	"car1": 0,     # Default car (free)
	"car2": 500,   # Blue car
	"car3": 1000,  # Green car
	"car4": 1500,  # Yellow car
	"car5": 2000,  # Black car
	"car6": 5000,  # Lambo 1
	"car7": 7500,  # Lambo 2
	"car8": 10000  # Lambo 3
}

func _ready():
	print("CarSelectScreen: Initializing")
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Set initial coin display if we have a coin label
	if coin_label:
		coin_label.text = "Total Coins: Loading..."
	
	# Get access to SaveManager through Autoload
	var autoload = get_node("/root/Autoload")
	if autoload:
		if autoload.save_manager and is_instance_valid(autoload.save_manager):
			print("CarSelectScreen: SaveManager found in Autoload")
			save_manager = autoload.save_manager
			create_car_buttons()
			update_coin_display()
		else:
			print("CarSelectScreen: Waiting for SaveManager to be ready")
			autoload.connect("save_manager_ready", _on_save_manager_ready)
	else:
		print("CarSelectScreen ERROR: Autoload singleton not found!")

func _on_save_manager_ready():
	print("CarSelectScreen: SaveManager ready signal received")
	var autoload = get_node("/root/Autoload")
	if autoload:
		save_manager = autoload.save_manager
		create_car_buttons()
		update_coin_display()

func update_coin_display():
	if coin_label and save_manager:
		var coins = save_manager.get_total_coins()
		coin_label.text = "Total Coins: %d" % coins
		print("CarSelectScreen: Updated coins display with %d coins" % coins)

func create_car_buttons():
	# Clear any existing buttons first
	for child in car_grid.get_children():
		car_grid.remove_child(child)
		child.queue_free()
	
	print("CarSelectScreen: Creating car buttons, save_manager valid: " + str(is_instance_valid(save_manager)))
	
	# Using static method to get all car IDs
	var car_ids = GameAssetsClass.get_car_ids()
	for car_id in car_ids:
		var button = Button.new()
		button.custom_minimum_size = Vector2(200, 200)
		
		var texture = GameAssetsClass.load_car_texture(car_id)
		var texture_rect = TextureRect.new()
		texture_rect.texture = texture
		texture_rect.expand_mode = 1  # EXPAND_KEEP_ASPECT
		texture_rect.custom_minimum_size = Vector2(180, 180)
		texture_rect.position = Vector2(10, 10)
		
		# Check if car is unlocked
		var is_unlocked = save_manager and save_manager.is_car_unlocked(car_id)
		var is_selected = save_manager and save_manager.get_selected_car() == car_id
		
		# Create label for price or status
		var label = Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
		label.custom_minimum_size = Vector2(200, 30)
		label.position = Vector2(0, 170)
		
		if is_unlocked:
			if is_selected:
				label.text = "SELECTED"
				label.add_theme_color_override("font_color", Color(0, 1, 0))
				button.add_theme_color_override("font_color", Color(1, 0.5, 0, 1))  # Orange highlight
			else:
				label.text = "UNLOCKED"
				button.pressed.connect(_on_car_selected.bind(car_id))
		else:
			label.text = "COST: " + str(car_costs[car_id]) + " COINS"
			if save_manager and save_manager.get_total_coins() >= car_costs[car_id]:
				label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green if can afford
				button.pressed.connect(_on_car_purchase.bind(car_id))
			else:
				label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red if can't afford
				button.disabled = true
				texture_rect.modulate = Color(0.5, 0.5, 0.5)  # Grayed out
		
		button.add_child(texture_rect)
		button.add_child(label)
		car_grid.add_child(button)
		
		print("CarSelectScreen: Added button for car " + car_id + 
			  " (unlocked: " + str(is_unlocked) + 
			  ", selected: " + str(is_selected) + ")")

func _on_car_purchase(car_id: String):
	print("CarSelectScreen: Attempting to purchase car: " + car_id)
	if save_manager:
		var cost = car_costs[car_id]
		if save_manager.spend_coins(cost):
			save_manager.unlock_car(car_id)
			save_manager.set_selected_car(car_id)
			print("CarSelectScreen: Purchased and selected car: " + car_id)
			# Recreate buttons to reflect changes
			create_car_buttons()
			update_coin_display()

func _on_car_selected(car_id: String):
	print("CarSelectScreen: Car selected: " + car_id + ", save_manager valid: " + str(is_instance_valid(save_manager)))
	if save_manager:
		save_manager.set_selected_car(car_id)
		print("CarSelectScreen: Selected car set to: " + car_id)
		# Recreate buttons to reflect changes
		create_car_buttons()
	else:
		# Try to get SaveManager from Autoload as a fallback
		var autoload = get_node("/root/Autoload")
		if autoload and autoload.save_manager:
			save_manager = autoload.save_manager
			save_manager.set_selected_car(car_id)
			print("CarSelectScreen: Selected car set to: " + car_id + " (fallback method)")
			create_car_buttons()
		else:
			print("CarSelectScreen ERROR: SaveManager not found when selecting car")

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn")
