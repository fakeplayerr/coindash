extends Node

# Add the signal for upgrade changes
signal upgrades_changed

var config = ConfigFile.new()

@export var inventory: Inventory = Inventory.new()
@export var car_manager: CarManager
@export var upgrades_manager: UpgradesManager

# Passive income variables
var passive_income_timer: Timer
var is_passive_income_active: bool = false

# Global game settings
const MAX_SPEED := 2000.0

func _ready() -> void:
	print("Game Manager loaded")
	print("loading game:...")
	load_game()
	
	# Setup passive income timer
	setup_passive_income()

# Handle notifications including quit events
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Application quit requested - saving game")
		save_game()
		get_tree().quit() # Default behavior

# Setup the passive income system with a timer
func setup_passive_income() -> void:
	passive_income_timer = Timer.new()
	passive_income_timer.name = "PassiveIncomeTimer"
	passive_income_timer.wait_time = 1.0  # 1 second interval
	passive_income_timer.autostart = false
	passive_income_timer.timeout.connect(process_passive_income)
	add_child(passive_income_timer)
	
	# Start passive income generation
	start_passive_income()
	print("Passive income system initialized")

# Start passive income generation
func start_passive_income() -> void:
	if !is_passive_income_active and inventory.girls_collected > 0:
		passive_income_timer.start()
		is_passive_income_active = true
		print("Passive income generation started")
	elif inventory.girls_collected <= 0:
		print("No girls collected yet, passive income not started")

# Stop passive income generation
func stop_passive_income() -> void:
	if is_passive_income_active:
		passive_income_timer.stop()
		is_passive_income_active = false
		print("Passive income generation stopped")

# Process passive income - add 1 coin per girl per second
func process_passive_income() -> void:
	if inventory.girls_collected > 0:
		var coins_to_add = inventory.girls_collected
		add_coins(coins_to_add)
		# print("Passive income: Added %d coins from %d girls" % [coins_to_add, inventory.girls_collected])
		
		# Save game every 10 seconds (approximately)
		if Engine.get_process_frames() % 600 == 0:
			save_game()
			print("Passive income: Auto-saved game")
	
	# If girls count changes to 0, stop the timer
	if inventory.girls_collected <= 0 and is_passive_income_active:
		stop_passive_income()

func initialize_player(player: Node) -> void:
	if player and player.base_player:
		var selected_car = car_manager.get_selected_car()
		if selected_car:
			player.base_player.car = selected_car
			player._update_car_texture()
			print("Player initialized with car: ", selected_car.name)
		else:
			print("ERROR: No selected car found for player initialization")

func save_game():
	# Save inventory stats
	config.set_value("inventory", "coins", inventory.coins)
	config.set_value("inventory", "girls_collected", inventory.girls_collected)
	config.set_value("inventory", "fuel", inventory.fuel)
	config.set_value("inventory", "speed", inventory.speed)
	config.set_value("inventory", "fuel_tank_size", inventory.fuel_tank_size)
	config.set_value("inventory", "fire_rate", inventory.fire_rate)
	config.set_value("inventory", "projectile_speed", inventory.projectile_speed)
	
	# Save player progress - car data
	car_manager.save_cars(config)
	
	# Save upgrades
	upgrades_manager.save_upgrades(config)

	var save_path = "res://save_data/config.cfg"
	var err = config.save(save_path)

	if err == OK:
		print("Game saved successfully at: ", save_path)
	else:
		print("Error saving game! Error code: ", err)

func load_game():
	var load_path = "res://save_data/config.cfg"

	if config.load(load_path) == OK:
		# Load inventory stats
		inventory.coins = config.get_value("inventory", "coins", 0)
		inventory.girls_collected = config.get_value("inventory", "girls_collected", 0)
		inventory.fuel = config.get_value("inventory", "fuel", 100.0)
		inventory.speed = config.get_value("inventory", "speed", 0.0)
		inventory.fuel_tank_size = config.get_value("inventory", "fuel_tank_size", 1000.0)
		inventory.fire_rate = config.get_value("inventory", "fire_rate", 1000.0)
		inventory.projectile_speed = config.get_value("inventory", "projectile_speed", 1000.0)
		
		# Load car data
		car_manager.load_cars(config)
		
		# Load upgrades
		upgrades_manager.load_upgrades(config)
		
		# Apply upgrade effects to inventory
		upgrades_manager.apply_upgrade_effects(inventory)

		print("Game loaded successfully!")
		print("Inventory Stats:")
		print("- Coins:", inventory.coins)
		print("- Girls Collected:", inventory.girls_collected)
		print("- Fuel:", inventory.fuel)
		print("- Speed:", inventory.speed)
		print("- Fuel Tank Size:", inventory.fuel_tank_size)
		print("- Fire Rate:", inventory.fire_rate)
		print("- Projectile Speed:", inventory.projectile_speed)
		print("Car Data:")
		print("- Selected Car Index:", car_manager.selected_car_index)
		print("- Unlocked Cars:", car_manager.unlocked_cars)
	else:
		print("No save file found or failed to load.")

func reset_game() -> void:
	# Reset inventory to default values
	inventory = Inventory.new()
	# Reset car manager
	car_manager.reset()
	
	# Reset upgrades
	upgrades_manager.reset()
	
	# Save the reset state
	save_game()
	print("Game has been reset to default values")

# Car-related helper functions
func get_selected_car() -> BaseCar:
	return car_manager.get_selected_car()

func select_car(index: int) -> bool:
	var result = car_manager.select_car(index)
	if result:
		save_game()  # Save changes immediately
	return result

func is_car_unlocked(index: int) -> bool:
	return car_manager.is_car_unlocked(index)

func unlock_car(index: int) -> bool:
	var result = car_manager.unlock_car(index)
	if result:
		save_game()  # Save changes immediately
	return result

func get_car_cost(index: int) -> int:
	return car_manager.get_car_cost(index)

func get_car_count() -> int:
	return car_manager.get_car_count()

func get_car(index: int) -> BaseCar:
	return car_manager.get_car(index)

# Helper functions for managing inventory values
func add_fuel(amount: float) -> void:
	inventory.fuel = min(inventory.fuel + amount, inventory.fuel_tank_size)

func remove_fuel(amount: float) -> void:
	inventory.fuel = max(inventory.fuel - amount, 0.0)

func update_speed(new_speed: float) -> void:
	inventory.speed = new_speed
	emit_signal("upgrades_changed")

func update_fuel_tank_size(new_size: float) -> void:
	inventory.fuel_tank_size = new_size
	# Ensure current fuel doesn't exceed new tank size
	inventory.fuel = min(inventory.fuel, new_size)
	emit_signal("upgrades_changed")

func update_fire_rate(new_rate: float) -> void:
	inventory.fire_rate = new_rate
	emit_signal("upgrades_changed")

func update_projectile_speed(new_speed: float) -> void:
	inventory.projectile_speed = new_speed
	emit_signal("upgrades_changed")

func get_fuel() -> float:
	return inventory.fuel

func get_fuel_tank_size() -> float:
	return inventory.fuel_tank_size

func get_speed() -> float:
	return inventory.speed

func get_fire_rate() -> float:
	return inventory.fire_rate

func get_projectile_speed() -> float:
	return inventory.projectile_speed

func get_coins():
	return inventory.coins
	
func add_coins(amount: int, should_save: bool = false):
	inventory.coins += amount
	if should_save:
		save_game()
	
func spend_coins(amount: int) -> bool:
	if inventory.coins >= amount:
		inventory.coins -= amount
		save_game()  # Save after spending coins
		return true
	return false

# Purchase and apply an upgrade
func purchase_upgrade(upgrade_name: String) -> bool:
	var cost = upgrades_manager.get_upgrade_cost(upgrade_name)
	
	if spend_coins(cost):
		var success = upgrades_manager.apply_upgrade(upgrade_name)
		if success:
			# Apply upgrade effects to inventory
			upgrades_manager.apply_upgrade_effects(inventory)
			save_game()
			emit_signal("upgrades_changed")
		return success
	
	return false

func get_girls_collected():
	return inventory.girls_collected
	
func add_girls_collected(amount: int):
	inventory.girls_collected += amount
	
	# Start passive income if not already active and we now have girls
	if !is_passive_income_active and inventory.girls_collected > 0:
		start_passive_income()
		
	save_game()  # Save after adding girls
