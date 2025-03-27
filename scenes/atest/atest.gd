extends Node2D

const SPEED := 50

var girls = []

func _ready():
	randomize()
	for girl in get_children():
		girls.append({
			"node": girl,
			"direction": random_direction()
		})

func _process(delta):
	for girl_data in girls:
		var girl = girl_data["node"]
		var dir = girl_data["direction"]

		# Move
		girl.position += dir * SPEED * delta

		# Get sprite
		var sprite = girl.get_node("AnimatedSprite2D")

		# Flip sprite based on x direction
		if dir.x < 0:
			sprite.flip_h = true
		elif dir.x > 0:
			sprite.flip_h = false

		# Play animation
		if not sprite.is_playing():
			sprite.play()

		# Occasionally pick a new direction
		if randi() % 100 < 2:
			girl_data["direction"] = random_direction()


func random_direction() -> Vector2:
	var x = [-1, 0, 1].pick_random()
	var y = [-1, 0, 1].pick_random()
	return Vector2(x, y).normalized()
