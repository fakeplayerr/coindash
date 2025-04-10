extends Node2D

@onready var tile_layer = $TileMapLayer # Path to your TileMapLayer scene
@export var tile_count: int = 6  # Number of tiles to spawn below
@export_range(0, 1000, 10) var speed  = 100.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed = GameManager.get_speed()
	# Assume the first child is the original TileMapLayer
	var original_tile = get_child(0)
	# Spawn 6 tiles below the original
	for i in range(tile_count):
		var newTile = tile_layer.duplicate()
		newTile.position.y = original_tile.position.y + (512 * (i + 1))
		add_child(newTile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.y += speed * delta
