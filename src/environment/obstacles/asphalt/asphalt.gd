extends Node2D

var speed = GameManager.BASE_SPEED

@onready var rb = $RigidBody2D
@onready var player = $Player
#@onready var walls = $Walls

var max_speed = 600
var acceleration = 50  # Adjust acceleration per frame

func _ready():
	GameManager.initialize_player(player)
	

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		rb.linear_velocity.y = max(rb.linear_velocity.y - acceleration * delta, -max_speed)  
		#walls.linear_velocity.y = max(walls.linear_velocity.y + acceleration * delta, -max_speed)
		GameManager.coins += 1
	#if Input.is_action_pressed("shoot"):
		#GameManager.save_game()
	#if Input.is_action_pressed("ui_down"):
		#GameManager.load_game()
