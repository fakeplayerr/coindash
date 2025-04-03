extends Node2D

var speed = BaseGame.BASE_SPEED

@onready var rb = $RigidBody2D

@onready var walls = $Walls

var max_speed = 600
var acceleration = 50  # Adjust acceleration per frame

func _ready():
	BaseGame.load_game()

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		rb.linear_velocity.y = max(rb.linear_velocity.y - acceleration * delta, -max_speed)  
		walls.linear_velocity.y = max(walls.linear_velocity.y + acceleration * delta, -max_speed)
		BaseGame.coins += 1
	if Input.is_action_pressed("shoot"):
		BaseGame.save_game()
	if Input.is_action_pressed("ui_down"):
		BaseGame.load_game()

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
