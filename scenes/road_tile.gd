extends Node2D

@onready var spawn_points = $SpawnPoints

func get_spawn_points() -> Array[Marker2D]:
	return [
		spawn_points.get_node("Left"),
		spawn_points.get_node("Right")
	]

func get_random_spawn_point() -> Marker2D:
	var points = get_spawn_points()
	return points[randi() % points.size()] 