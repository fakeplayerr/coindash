extends Control

@onready var back_button = $BackButton
@onready var total_coins_label = $TotalCoins

# Reference to the GameManager
var game_manager

func _ready():
	print("UpgradesScreen: Initializing")
	
	# Get reference to GameManager
	game_manager = get_node("/root/GameManager")
	if not game_manager:
		print("UpgradesScreen ERROR: GameManager not found!")
		return
	
	# Connect button signals
	back_button.pressed.connect(_on_back_pressed)
	
	# Set initial coin display
	update_ui()
	
	# Connect upgrade buttons - only connect to buttons that exist
	if has_node("ScrollContainer/UpgradesList/FuelUpgrades/FuelTankSize/UpgradeButton"):
		$ScrollContainer/UpgradesList/FuelUpgrades/FuelTankSize/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("fuel_tank_size"))
	
	# Only connect to buttons that exist in the scene
	if has_node("ScrollContainer/UpgradesList/CarUpgrades/Speed/UpgradeButton"):
		$ScrollContainer/UpgradesList/CarUpgrades/Speed/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("car_speed"))
	
	if has_node("ScrollContainer/UpgradesList/CarUpgrades/Handling/UpgradeButton"):
		$ScrollContainer/UpgradesList/CarUpgrades/Handling/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("car_handling"))
	
	if has_node("ScrollContainer/UpgradesList/PowerUps/PowerUpSlot/UpgradeButton"):
		$ScrollContainer/UpgradesList/PowerUps/PowerUpSlot/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("power_up_slots"))
	
	# Connect weapon upgrade buttons
	if has_node("ScrollContainer/UpgradesList/WeaponUpgrades/FireRate/UpgradeButton"):
		$ScrollContainer/UpgradesList/WeaponUpgrades/FireRate/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("fire_rate"))
	
	if has_node("ScrollContainer/UpgradesList/WeaponUpgrades/ProjectileSpeed/UpgradeButton"):
		$ScrollContainer/UpgradesList/WeaponUpgrades/ProjectileSpeed/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("projectile_speed"))
	
	if has_node("ScrollContainer/UpgradesList/GameUpgrades/RunTime/UpgradeButton"):
		$ScrollContainer/UpgradesList/GameUpgrades/RunTime/UpgradeButton.pressed.connect(
			_on_upgrade_pressed.bind("run_time"))

func update_ui():
	if not game_manager:
		return
		
	total_coins_label.text = "Total Coins: %d" % game_manager.get_coins()
	print("UpgradesScreen: Updated UI with %d coins" % game_manager.get_coins())
	
	# Update upgrade buttons - only update buttons that exist
	_update_upgrade_button("fuel_tank_size")
	_update_upgrade_button("car_speed")
	_update_upgrade_button("car_handling")
	_update_upgrade_button("power_up_slots")
	_update_upgrade_button("fire_rate")
	_update_upgrade_button("projectile_speed")
	_update_upgrade_button("run_time")

func _update_upgrade_button(upgrade_name: String):
	if not game_manager:
		return
		
	var button = _get_upgrade_button(upgrade_name)
	if button:
		var cost = game_manager.upgrades_manager.get_upgrade_cost(upgrade_name)
		var current_level = game_manager.upgrades_manager.get_upgrade_level(upgrade_name)
		var max_level = game_manager.upgrades_manager.base_upgrades.MAX_LEVEL
		
		if current_level >= max_level:
			button.text = "MAX LEVEL"
			button.disabled = true
		else:
			button.text = "Upgrade (%d coins) - Level %d/%d" % [cost, current_level, max_level]
			button.disabled = game_manager.get_coins() < cost

func _get_upgrade_button(upgrade_name: String) -> Button:
	match upgrade_name:
		"fuel_tank_size":
			return $ScrollContainer/UpgradesList/FuelUpgrades/FuelTankSize/UpgradeButton
		"car_speed":
			return $ScrollContainer/UpgradesList/CarUpgrades/Speed/UpgradeButton
		"car_handling":
			return $ScrollContainer/UpgradesList/CarUpgrades/Handling/UpgradeButton
		"power_up_slots":
			return $ScrollContainer/UpgradesList/PowerUps/PowerUpSlot/UpgradeButton
		"fire_rate":
			return $ScrollContainer/UpgradesList/WeaponUpgrades/FireRate/UpgradeButton
		"projectile_speed":
			return $ScrollContainer/UpgradesList/WeaponUpgrades/ProjectileSpeed/UpgradeButton
		"run_time":
			return $ScrollContainer/UpgradesList/GameUpgrades/RunTime/UpgradeButton
	return null

func _on_upgrade_pressed(upgrade_name: String):
	if not game_manager:
		return
		
	var cost = game_manager.upgrades_manager.get_upgrade_cost(upgrade_name)
	
	if game_manager.spend_coins(cost):
		if game_manager.upgrades_manager.apply_upgrade(upgrade_name):
			# Apply the upgrade effects to the inventory
			game_manager.upgrades_manager.apply_upgrade_effects(game_manager.inventory)
			
			# Save the game after upgrading
			game_manager.save_game()
			
			# Update the UI
			update_ui()
			
			print("UpgradesScreen: Upgraded %s to level %d" % [
				upgrade_name, 
				game_manager.upgrades_manager.get_upgrade_level(upgrade_name)
			])
		else:
			# Refund the coins if upgrade couldn't be applied
			game_manager.add_coins(cost)
			print("UpgradesScreen: Failed to apply upgrade %s" % upgrade_name)
	else:
		print("UpgradesScreen: Not enough coins for upgrade %s" % upgrade_name)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn") 
