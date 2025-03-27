extends Node

class_name GameAssetsResource

# Car textures dictionary
static var car_textures = {
	"car1": "res://assets/general/PNG/Cars/car_red_1.png",
	"car2": "res://assets/general/PNG/Cars/car_blue_1.png",
	"car3": "res://assets/general/PNG/Cars/car_green_1.png",
	"car4": "res://assets/general/PNG/Cars/car_yellow_1.png",
	"car5": "res://assets/general/PNG/Cars/car_black_1.png",
	"car6": "res://assets/general/PNG/Cars/lambo-1.png",
	"car7": "res://assets/general/PNG/Cars/lambo-2.png",
	"car8": "res://assets/general/PNG/Cars/lambo-3.png"
}

# Function to get car texture path
static func get_car_texture_path(car_id: String) -> String:
	return car_textures.get(car_id, car_textures["car1"])

# Function to load car texture with error handling
static func load_car_texture(car_id: String) -> Texture2D:
	var path = get_car_texture_path(car_id)
	
	# Check if file exists
	if not FileAccess.file_exists(path):
		print("ERROR: Car texture not found at path: " + path)
		
		# Try a fallback texture
		var fallback_paths = [
			"res://assets/general/PNG/Cars/car_red_1.png",
			"res://assets/general/PNG/Cars/lambo-1.png",
			"res://assets/general/PNG/Cars/car_red_small_1.png",
			"res://assets/general/PNG/Cars/car_blue_1.png"
		]
		
		# Try each fallback path
		for fallback_path in fallback_paths:
			if FileAccess.file_exists(fallback_path):
				print("Using fallback texture: " + fallback_path)
				return load(fallback_path)
		
		# If all fallbacks fail, return null
		print("CRITICAL: All car texture fallbacks failed!")
		return null
	
	return load(path)
	
# Function to add a new car texture
static func add_car_texture(car_id: String, texture_path: String):
	car_textures[car_id] = texture_path
	print("Added car texture: " + car_id + " -> " + texture_path)

# Function to get all car IDs
static func get_car_ids() -> Array:
	return car_textures.keys()

# Function to get total number of cars
static func get_car_count() -> int:
	return car_textures.size() 
