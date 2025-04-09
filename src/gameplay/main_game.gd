extends Node2D

@export var level1 : BaseLevel
@onready var player = $Player
@onready var coin_spawner = $CoinSpawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.initialize_player(player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


	
