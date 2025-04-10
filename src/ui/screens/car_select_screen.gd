extends Control

# This script was updated by the fix_references.gd tool
# The GameAssetsClass constant remain unchanged but now refers to GameAssetsResource class

# Reference to GameAssets class
const GameAssetsClass = preload("res://src/autoload/game_assets.gd")

@onready var car_grid = $VBoxContainer/CenterContainer/CarGrid
@onready var back_button = $VBoxContainer/CenterContainer3/BackButton
@onready var coin_label = $VBoxContainer/HBoxContainer/CenterContainer2/TotalCoins

func _ready():
	print("CarSelectScreen: Initializing")
	back_button.pressed.connect(_on_back_button_pressed)
	
	# Set initial coin display
	update_coin_display()
	
	# Create car selection buttons
	create_car_buttons()

func update_coin_display():
	if coin_label:
		var coins = GameManager.get_coins()
		coin_label.text = "Total Coins: %d" % coins
		print("CarSelectScreen: Updated coins display with %d coins" % coins)

func create_car_buttons():
	# Clear any existing buttons first
	for child in car_grid.get_children():
		car_grid.remove_child(child)
		child.queue_free()
	
	print("CarSelectScreen: Creating car buttons")
	
	# Check the number of cars available
	var car_count = GameManager.get_car_count()
	print("CarSelectScreen: Found %d cars" % car_count)
	
	for i in range(car_count):
		var car = GameManager.get_car(i)
		if car:
			var button = Button.new()
			
			button.custom_minimum_size = Vector2(200, 380)
			
			var texture_rect = TextureRect.new()
			
			# Check if car image is valid
			if car.image:
				texture_rect.texture = car.image
				print("CarSelectScreen: Loaded texture for car %d" % i)
			else:
				# Create a placeholder colored rect as fallback
				print("CarSelectScreen: No texture for car %d, using fallback" % i)
				var placeholder = ColorRect.new()
				placeholder.color = Color(0.8, 0.2, 0.2)
				placeholder.custom_minimum_size = Vector2(180, 360)
				placeholder.position = Vector2(10, 10)
				button.add_child(placeholder)
			
			texture_rect.expand_mode = 1  # EXPAND_KEEP_ASPECT
			texture_rect.custom_minimum_size = Vector2(180, 360)
			texture_rect.position = Vector2(10, 10)
			
			# Check if car is unlocked
			var is_unlocked = GameManager.is_car_unlocked(i)
			var is_selected = GameManager.get_selected_car() == car
			
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
				else:
					label.text = "SELECT"
					button.pressed.connect(_on_car_selected.bind(i))
			else:
				var cost = GameManager.get_car_cost(i)
				label.text = "COST: " + str(cost) + " COINS"
				if GameManager.get_coins() >= cost:
					label.add_theme_color_override("font_color", Color(0, 1, 0))  # Green if can afford
					button.pressed.connect(_on_car_purchase.bind(i))
				else:
					label.add_theme_color_override("font_color", Color(1, 0, 0))  # Red if can't afford
					button.disabled = true
					if texture_rect.texture:
						texture_rect.modulate = Color(0.5, 0.5, 0.5)  # Grayed out
			
			if texture_rect.texture:
				button.add_child(texture_rect)
			button.add_child(label)
			car_grid.add_child(button)
			
			print("CarSelectScreen: Added button for car %d - %s (unlocked: %s, selected: %s)" % 
				[i, car.name, str(is_unlocked), str(is_selected)])

func _on_car_purchase(index: int):
	print("CarSelectScreen: Attempting to purchase car index: " + str(index))
	var cost = GameManager.get_car_cost(index)
	
	if GameManager.spend_coins(cost):
		GameManager.unlock_car(index)
		GameManager.select_car(index)
		print("CarSelectScreen: Purchased and selected car index: " + str(index))
		
		# Update UI
		create_car_buttons()
		update_coin_display()
	else:
		print("CarSelectScreen: Not enough coins to purchase car index: " + str(index))

func _on_car_selected(index: int):
	print("CarSelectScreen: Selecting car index: " + str(index))
	if GameManager.select_car(index):
		print("CarSelectScreen: Selected car index: " + str(index))
		create_car_buttons()
	else:
		print("CarSelectScreen: Failed to select car index: " + str(index))

func _on_back_button_pressed():
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn")
