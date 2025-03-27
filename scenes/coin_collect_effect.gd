extends Node2D

func _ready():
	# Create a simple animation tween
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(2.0, 2.0), 0.2)
	tween.parallel().tween_property($Sprite2D, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free) 
