extends Node2D

@export var SPEED : Speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Parallax2D.autoscroll = Vector2(0,SPEED.value)
	
