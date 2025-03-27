extends Node

# This script is meant to be attached to the MainGame scene to load the selected car properly

# Reference to GameAssets class
const GameAssetsClass = preload("res://scripts/game_assets.gd")

func _ready():
	# Wait a short moment to ensure everything is loaded
	await get_tree().create_timer(0.1).timeout
	load_car()

func load_car():
	# Get the player node
	var player = get_parent().get_node_or_null("Player")
	if not player:
		print("LoadSelectedCar: Player node not found")
		return
		
	# Get the sprite
	var sprite = player.get_node_or_null("Sprite2D")
	if not sprite:
		print("LoadSelectedCar: Sprite2D not found")
		return
	
	# Get SaveManager and load selected car
	var save_manager = get_node_or_null("/root/SaveManager")
	if save_manager:
		var selected_car = save_manager.get_selected_car()
		print("LoadSelectedCar: Loading selected car: " + selected_car)
		
		# Use GameAssets class to load texture
		var texture = GameAssetsClass.load_car_texture(selected_car)
		if texture:
			sprite.texture = texture
			print("LoadSelectedCar: Car texture loaded successfully")
		else:
			print("LoadSelectedCar: Failed to load texture for car: " + selected_car)
	else:
		print("LoadSelectedCar: SaveManager not found") 