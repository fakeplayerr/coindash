extends Resource
class_name BaseUpgrades

# Upgrade levels for each upgrade type
@export var fuel_tank_size_level: int = 1
@export var coin_efficiency_level: int = 1
@export var car_speed_level: int = 1
@export var car_handling_level: int = 1
@export var power_up_slots_level: int = 1
@export var fire_rate_level: int = 1
@export var projectile_speed_level: int = 1
@export var run_time_level: int = 1

# Base costs for each upgrade type
const FUEL_TANK_SIZE_COST: int = 100
const COIN_EFFICIENCY_COST: int = 150
const CAR_SPEED_COST: int = 200
const CAR_HANDLING_COST: int = 175
const POWER_UP_SLOTS_COST: int = 300
const FIRE_RATE_COST: int = 250
const PROJECTILE_SPEED_COST: int = 200
const RUN_TIME_COST: int = 225

# Cost multiplier for each level (cost increases by this percentage per level)
const COST_MULTIPLIER: float = 1.5

# Maximum level for each upgrade
const MAX_LEVEL: int = 10

# Get the cost for a specific upgrade at its current level
func get_upgrade_cost(upgrade_name: String) -> int:
	var base_cost: int = 0
	var current_level: int = 1
	
	match upgrade_name:
		"fuel_tank_size":
			base_cost = FUEL_TANK_SIZE_COST
			current_level = fuel_tank_size_level
		"coin_efficiency":
			base_cost = COIN_EFFICIENCY_COST
			current_level = coin_efficiency_level
		"car_speed":
			base_cost = CAR_SPEED_COST
			current_level = car_speed_level
		"car_handling":
			base_cost = CAR_HANDLING_COST
			current_level = car_handling_level
		"power_up_slots":
			base_cost = POWER_UP_SLOTS_COST
			current_level = power_up_slots_level
		"fire_rate":
			base_cost = FIRE_RATE_COST
			current_level = fire_rate_level
		"projectile_speed":
			base_cost = PROJECTILE_SPEED_COST
			current_level = projectile_speed_level
		"run_time":
			base_cost = RUN_TIME_COST
			current_level = run_time_level
	
	# Calculate cost based on current level
	return int(base_cost * pow(COST_MULTIPLIER, current_level - 1))

# Get the current level for a specific upgrade
func get_upgrade_level(upgrade_name: String) -> int:
	match upgrade_name:
		"fuel_tank_size":
			return fuel_tank_size_level
		"coin_efficiency":
			return coin_efficiency_level
		"car_speed":
			return car_speed_level
		"car_handling":
			return car_handling_level
		"power_up_slots":
			return power_up_slots_level
		"fire_rate":
			return fire_rate_level
		"projectile_speed":
			return projectile_speed_level
		"run_time":
			return run_time_level
	return 1

# Check if an upgrade can be upgraded further
func can_upgrade(upgrade_name: String) -> bool:
	return get_upgrade_level(upgrade_name) < MAX_LEVEL

# Apply an upgrade to the specified upgrade type
func apply_upgrade(upgrade_name: String) -> bool:
	if not can_upgrade(upgrade_name):
		return false
		
	match upgrade_name:
		"fuel_tank_size":
			fuel_tank_size_level += 1
		"coin_efficiency":
			coin_efficiency_level += 1
		"car_speed":
			car_speed_level += 1
		"car_handling":
			car_handling_level += 1
		"power_up_slots":
			power_up_slots_level += 1
		"fire_rate":
			fire_rate_level += 1
		"projectile_speed":
			projectile_speed_level += 1
		"run_time":
			run_time_level += 1
	
	return true 
