extends Resource
class_name CarManager

@export var cars : Array[BaseCar]
@export var selected_car_index: int = 0
@export var unlocked_cars: Array[bool] = []

# Car unlock costs
const CAR_COSTS = {
	0: 0,        # Default car (free)
	1: 250,      # Second car
	2: 500,      # Third car
	3: 1000,     # Fourth car
	4: 2000,     # Fifth car
	5: 5000,     # Sixth car
	6: 10000,    # Seventh car
	7: 20000,    # Eighth car
	8: 40000,    # Ninth car
	9: 80000,    # Tenth car
	10: 150000,  # Eleventh car
	11: 300000,  # Twelfth car
	12: 1000000  # Thirteenth car
}

func _init():
	# Initialize unlocked cars array if empty
	if unlocked_cars.size() == 0:
		# First car is free/unlocked by default
		unlocked_cars = [true]
		for i in range(1, 10):  # Support up to 10 cars (expandable)
			unlocked_cars.append(false)

# Get the selected car resource
func get_selected_car() -> BaseCar:
	if selected_car_index >= 0 and selected_car_index < cars.size():
		return cars[selected_car_index]
	return null

# Set the selected car by index
func select_car(index: int) -> bool:
	if index >= 0 and index < cars.size() and is_car_unlocked(index):
		selected_car_index = index
		return true
	return false
	
# Get car by index
func get_car(index: int) -> BaseCar:
	if index >= 0 and index < cars.size():
		return cars[index]
	return null

# Check if a car is unlocked
func is_car_unlocked(index: int) -> bool:
	if index >= 0 and index < unlocked_cars.size():
		return unlocked_cars[index]
	return false

# Unlock a car
func unlock_car(index: int) -> bool:
	if index >= 0 and index < unlocked_cars.size():
		unlocked_cars[index] = true
		return true
	return false

# Get the cost to unlock a car
func get_car_cost(index: int) -> int:
	return CAR_COSTS.get(index, 1000000)  # Default cost if not specified
	
# Get number of cars
func get_car_count() -> int:
	return cars.size()

# Save car data to config
func save_cars(config: ConfigFile) -> void:
	config.set_value("cars", "selected_car_index", selected_car_index)
	config.set_value("cars", "unlocked_cars", unlocked_cars)

# Load car data from config
func load_cars(config: ConfigFile) -> void:
	selected_car_index = config.get_value("cars", "selected_car_index", 0)
	var loaded_unlocked = config.get_value("cars", "unlocked_cars", [])
	
	# Make sure we have the right number of elements in unlocked_cars array
	if loaded_unlocked.size() > 0:
		unlocked_cars = loaded_unlocked
		# Ensure array is properly sized for all cars
		while unlocked_cars.size() < cars.size():
			unlocked_cars.append(false)
	else:
		# Initialize with default values
		unlocked_cars = [true]  # First car always unlocked
		for i in range(1, cars.size()):
			unlocked_cars.append(false)

# Reset all car data to default state
func reset() -> void:
	selected_car_index = 0
	unlocked_cars = [true]  # First car unlocked
	for i in range(1, cars.size()):
		unlocked_cars.append(false)
