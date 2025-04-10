extends Resource
class_name UpgradesManager

# Reference to the base upgrades resource
@export var base_upgrades: BaseUpgrades = BaseUpgrades.new()

# Apply upgrade effects to the inventory
func apply_upgrade_effects(inventory: Inventory) -> void:
	# Apply fuel tank size upgrade
	var base_inventory = Inventory.new()
	inventory.fuel_tank_size = base_inventory.fuel_tank_size * (1.0 + (base_upgrades.fuel_tank_size_level - 1) * 0.2)
	
	# Apply coin efficiency upgrade (increases coin value)
	# This would be applied when collecting coins
	
	# Apply car speed upgrade - enhanced to give more noticeable progression
	inventory.speed = base_inventory.speed * (1.0 + (base_upgrades.car_speed_level - 1) * 0.25)
	
	# Apply fire rate upgrade
	inventory.fire_rate = base_inventory.fire_rate * (1.0 + (base_upgrades.fire_rate_level - 1) * 0.2)
	
	# Apply projectile speed upgrade - enhanced to give more noticeable progression
	inventory.projectile_speed = base_inventory.projectile_speed * (1.0 + (base_upgrades.projectile_speed_level - 1) * 0.3)
	
	# Other upgrades would be applied in their respective systems

# Get the cost for a specific upgrade
func get_upgrade_cost(upgrade_name: String) -> int:
	return base_upgrades.get_upgrade_cost(upgrade_name)

# Get the current level for a specific upgrade
func get_upgrade_level(upgrade_name: String) -> int:
	return base_upgrades.get_upgrade_level(upgrade_name)

# Check if an upgrade can be upgraded further
func can_upgrade(upgrade_name: String) -> bool:
	return base_upgrades.can_upgrade(upgrade_name)

# Apply an upgrade to the specified upgrade type
func apply_upgrade(upgrade_name: String) -> bool:
	var result = base_upgrades.apply_upgrade(upgrade_name)
	
	if result:
		# Apply upgrade effects to the GameManager's inventory
		apply_upgrade_effects(GameManager.inventory)
		
		# Emit signal if GameManager has the upgrades_changed signal
		if GameManager.has_signal("upgrades_changed"):
			GameManager.emit_signal("upgrades_changed")
	
	return result

# Save upgrades to the config file
func save_upgrades(config: ConfigFile) -> void:
	config.set_value("upgrades", "fuel_tank_size_level", base_upgrades.fuel_tank_size_level)
	config.set_value("upgrades", "coin_efficiency_level", base_upgrades.coin_efficiency_level)
	config.set_value("upgrades", "car_speed_level", base_upgrades.car_speed_level)
	config.set_value("upgrades", "car_handling_level", base_upgrades.car_handling_level)
	config.set_value("upgrades", "power_up_slots_level", base_upgrades.power_up_slots_level)
	config.set_value("upgrades", "fire_rate_level", base_upgrades.fire_rate_level)
	config.set_value("upgrades", "projectile_speed_level", base_upgrades.projectile_speed_level)
	config.set_value("upgrades", "run_time_level", base_upgrades.run_time_level)

# Load upgrades from the config file
func load_upgrades(config: ConfigFile) -> void:
	base_upgrades.fuel_tank_size_level = config.get_value("upgrades", "fuel_tank_size_level", 1)
	base_upgrades.coin_efficiency_level = config.get_value("upgrades", "coin_efficiency_level", 1)
	base_upgrades.car_speed_level = config.get_value("upgrades", "car_speed_level", 1)
	base_upgrades.car_handling_level = config.get_value("upgrades", "car_handling_level", 1)
	base_upgrades.power_up_slots_level = config.get_value("upgrades", "power_up_slots_level", 1)
	base_upgrades.fire_rate_level = config.get_value("upgrades", "fire_rate_level", 1)
	base_upgrades.projectile_speed_level = config.get_value("upgrades", "projectile_speed_level", 1)
	base_upgrades.run_time_level = config.get_value("upgrades", "run_time_level", 1)

# Reset all upgrades to their default levels
func reset() -> void:
	base_upgrades = BaseUpgrades.new()
