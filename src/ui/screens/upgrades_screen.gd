extends Control

@onready var back_button = $BackButton
@onready var total_coins_label = $TotalCoins

func _ready():
	print("UpgradesScreen: Initializing")
	
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
		
	total_coins_label.text = "Coins: %d" % GameManager.get_coins()
	print("UpgradesScreen: Updated UI with %d coins" % GameManager.get_coins())
	
	# Update upgrade buttons - only update buttons that exist
	_update_upgrade_button("fuel_tank_size")
	_update_upgrade_button("car_speed")
	_update_upgrade_button("car_handling")
	_update_upgrade_button("power_up_slots")
	_update_upgrade_button("fire_rate")
	_update_upgrade_button("projectile_speed")
	_update_upgrade_button("run_time")

func _update_upgrade_button(upgrade_name: String):
		
	var button = _get_upgrade_button(upgrade_name)
	if button:
		var cost = GameManager.upgrades_manager.get_upgrade_cost(upgrade_name)
		var current_level = GameManager.upgrades_manager.get_upgrade_level(upgrade_name)
		var max_level = GameManager.upgrades_manager.base_upgrades.MAX_LEVEL
		
		if current_level >= max_level:
			button.text = "MAX LEVEL"
			button.disabled = true
		else:
			button.text = "Upgrade (%d coins) - Level %d/%d" % [cost, current_level, max_level]
			button.disabled = GameManager.get_coins() < cost

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

		
	var cost = GameManager.upgrades_manager.get_upgrade_cost(upgrade_name)
	
	if GameManager.spend_coins(cost):
		if GameManager.upgrades_manager.apply_upgrade(upgrade_name):
			# Apply the upgrade effects to the inventory
			GameManager.upgrades_manager.apply_upgrade_effects(GameManager.inventory)
			
			# Save the game after upgrading
			GameManager.save_game()
			
			# Update the UI
			update_ui()
			
			print("UpgradesScreen: Upgraded %s to level %d" % [
				upgrade_name, 
				GameManager.upgrades_manager.get_upgrade_level(upgrade_name)
			])
		else:
			# Refund the coins if upgrade couldn't be applied
			GameManager.add_coins(cost)
			print("UpgradesScreen: Failed to apply upgrade %s" % upgrade_name)
	else:
		print("UpgradesScreen: Not enough coins for upgrade %s" % upgrade_name)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://src/ui/screens/start_screen.tscn") 
