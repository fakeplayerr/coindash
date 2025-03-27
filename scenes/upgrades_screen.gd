extends Control

var save_manager: Node

var upgrade_costs = {
	"fuel_tank_size": 100,
	"coin_efficiency": 300,
	"car_speed": 200,
	"car_handling": 200,
	"power_up_slots": 800,
	"fire_rate": 250,
	"projectile_speed": 200,
	"run_time": 500
}

@onready var back_button = $BackButton
@onready var total_coins_label = $TotalCoins

func _ready():
	print("UpgradesScreen: Initializing")
	
	# Connect button signals
	back_button.pressed.connect(_on_back_pressed)
	
	# Set initial coin display to loading
	total_coins_label.text = "Total Coins: Loading..."
	
	# Connect upgrade buttons
	$ScrollContainer/UpgradesList/FuelUpgrades/FuelTankSize/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("fuel_tank_size"))
	$ScrollContainer/UpgradesList/FuelUpgrades/CoinEfficiency/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("coin_efficiency"))
	$ScrollContainer/UpgradesList/CarUpgrades/Speed/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("car_speed"))
	$ScrollContainer/UpgradesList/CarUpgrades/Handling/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("car_handling"))
	$ScrollContainer/UpgradesList/PowerUps/PowerUpSlot/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("power_up_slots"))
	
	# Connect new upgrade buttons
	$ScrollContainer/UpgradesList/WeaponUpgrades/FireRate/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("fire_rate"))
	$ScrollContainer/UpgradesList/WeaponUpgrades/ProjectileSpeed/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("projectile_speed"))
	$ScrollContainer/UpgradesList/GameUpgrades/RunTime/UpgradeButton.pressed.connect(
		_on_upgrade_pressed.bind("run_time"))
	
	# Get access to SaveManager through Autoload
	var autoload = get_node("/root/Autoload")
	if autoload:
		if autoload.save_manager and is_instance_valid(autoload.save_manager):
			print("UpgradesScreen: SaveManager found in Autoload")
			save_manager = autoload.save_manager
			update_ui()
		else:
			print("UpgradesScreen: Waiting for SaveManager to be ready")
			autoload.connect("save_manager_ready", _on_save_manager_ready)
	else:
		print("UpgradesScreen ERROR: Autoload singleton not found!")

func _on_save_manager_ready():
	print("UpgradesScreen: SaveManager ready signal received")
	var autoload = get_node("/root/Autoload")
	if autoload:
		save_manager = autoload.save_manager
		update_ui()

func update_ui():
	if save_manager:
		var coins = save_manager.get_total_coins()
		total_coins_label.text = "Total Coins: %d" % coins
		print("UpgradesScreen: Updated UI with %d coins" % coins)
		
		# Update upgrade buttons
		_update_upgrade_button("fuel_tank_size")
		_update_upgrade_button("coin_efficiency")
		_update_upgrade_button("car_speed")
		_update_upgrade_button("car_handling")
		_update_upgrade_button("power_up_slots")
		
		# Update new upgrade buttons
		_update_upgrade_button("fire_rate")
		_update_upgrade_button("projectile_speed")
		_update_upgrade_button("run_time")
	else:
		print("UpgradesScreen ERROR: SaveManager not available when updating UI")

func _update_upgrade_button(upgrade_name: String):
	var button = _get_upgrade_button(upgrade_name)
	if button and save_manager:
		var cost = upgrade_costs[upgrade_name]
		var current_level = save_manager.get_upgrade_level(upgrade_name)
		button.text = "Upgrade (%d coins) - Level %d" % [cost, current_level]
		button.disabled = save_manager.get_total_coins() < cost

func _get_upgrade_button(upgrade_name: String) -> Button:
	match upgrade_name:
		"fuel_tank_size":
			return $ScrollContainer/UpgradesList/FuelUpgrades/FuelTankSize/UpgradeButton
		"coin_efficiency":
			return $ScrollContainer/UpgradesList/FuelUpgrades/CoinEfficiency/UpgradeButton
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
	if save_manager:
		var cost = upgrade_costs[upgrade_name]
		if save_manager.spend_coins(cost):
			save_manager.upgrade(upgrade_name)
			update_ui()
			print("UpgradesScreen: Upgraded %s to level %d" % [upgrade_name, save_manager.get_upgrade_level(upgrade_name)])

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn") 
