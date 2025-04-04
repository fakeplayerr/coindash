extends Node2D

var speed = GameManager.BASE_SPEED

@onready var rb = $RigidBody2D
@onready var player = $Player
@onready var walls = $Walls

var max_speed = 600
var acceleration = 50  # Adjust acceleration per frame

func _ready():
	GameManager.load_game()
	_initialize_player()

func _initialize_player():
	if player and player.base_player and GameManager.inventory.selected_car:
		# Set the car first
		player.base_player.car = GameManager.inventory.selected_car
		# Force an update of the car texture
		player._update_car_texture()
		print("Player initialized with car: ", player.base_player.car.name)

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		rb.linear_velocity.y = max(rb.linear_velocity.y - acceleration * delta, -max_speed)  
		walls.linear_velocity.y = max(walls.linear_velocity.y + acceleration * delta, -max_speed)
		GameManager.coins += 1
	if Input.is_action_pressed("shoot"):
		GameManager.save_game()
	if Input.is_action_pressed("ui_down"):
		GameManager.load_game()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
