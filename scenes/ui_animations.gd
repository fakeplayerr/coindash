extends Control

@onready var fuel_bar = $TopBar/FuelBar
@onready var coin_label = $TopBar/CoinLabel

func _ready():
	# Initialize UI elements
	fuel_bar.value = 100.0
	coin_label.text = "Coins: 0"

func update_fuel(value: float):
	# Animate fuel bar change
	var tween = create_tween()
	tween.tween_property(fuel_bar, "value", value, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Flash red when fuel is low
	if value < 20:
		flash_red(fuel_bar)

func update_coins(amount: int):
	# Animate coin label
	coin_label.text = "Coins: %d" % amount
	
	# Bounce animation
	var tween = create_tween()
	tween.tween_property(coin_label, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(coin_label, "scale", Vector2(1.0, 1.0), 0.1)

func flash_red(node: Control):
	var tween = create_tween()
	tween.tween_property(node, "modulate", Color(1, 0, 0, 1), 0.1)
	tween.tween_property(node, "modulate", Color(1, 1, 1, 1), 0.1) 
