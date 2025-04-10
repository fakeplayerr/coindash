extends Node2D

@export_range(0, 1000, 10) var speed  = 100.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = GameManager.get_speed()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
