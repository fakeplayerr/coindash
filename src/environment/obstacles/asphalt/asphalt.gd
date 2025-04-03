extends Node2D

@onready var rb = $RigidBody2D

@onready var wall2 = $Walls2

var max_speed = 600
var acceleration = 50  # Adjust acceleration per frame

func _ready():
	pass

func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		rb.linear_velocity.y = max(rb.linear_velocity.y - acceleration * delta, -max_speed)  
		wall2.linear_velocity.y = max(wall2.linear_velocity.y + acceleration * delta, -max_speed)
		

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	pass # Replace with function body.


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
