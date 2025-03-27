extends Node2D

@onready var label = $Label
@onready var particles = $Particles

func _ready():
	# Start particles
	particles.emitting = true
	
	# Animate label
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2)
	tween.tween_property(label, "modulate:a", 0.0, 0.5)
	
	# Remove after animation
	await get_tree().create_timer(1.0).timeout
	queue_free() 