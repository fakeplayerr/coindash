extends Node2D

var speed: float = 100.0
var direction: Vector2 = Vector2.RIGHT
var coin_value: int = 10
var coin_drop_chance: float = 0.3
var coin_scene = preload("res://scenes/coin_projectile.tscn")

@onready var coin_spawn_point = $CoinSpawnPoint

func _ready():
	# Randomize initial direction
	direction = Vector2.RIGHT if randf() > 0.5 else Vector2.LEFT
	rotation = direction.angle()

func _process(delta):
	# Move in current direction
	position += direction * speed * delta
	
	# Randomly drop coins
	if randf() < coin_drop_chance * delta:
		drop_coin()

func drop_coin():
	var coin = coin_scene.instantiate()
	get_parent().add_child(coin)
	coin.position = coin_spawn_point.global_position
	coin.set_direction(Vector2.DOWN)  # Drop coin downward

func _on_area_entered(area: Area2D):
	# Change direction when hitting obstacles
	if area.is_in_group("obstacles"):
		direction = -direction
		rotation = direction.angle() 
