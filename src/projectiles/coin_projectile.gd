extends Node2D

@export var projectile_resource: BaseProjectile

func _ready():
	if projectile_resource:
		$Sprite2D.texture = projectile_resource.image
		$Sprite2D.scale = Vector2.ONE * projectile_resource.size * 0.5  # Scale based on size
		$Area2D/CollisionShape2D.scale = Vector2.ONE * projectile_resource.size * 0.5

func _on_area_2d_body_entered(body):
	if body.is_in_group("player"):
		GameManager.add_coins(projectile_resource.size)   # Size as coin value
		queue_free()

#extends Area2D
#
#var direction: Vector2 = Vector2.ZERO
#var speed: float = 600.0  # Base speed
#var max_distance: float = 1000.0
#var distance_traveled: float = 0.0
#var rotation_speed: float = 10.0  # Rotation speed in radians per second
#var coin_value: int = 10
#
#@onready var sprite = $Sprite2D
#
#func _ready():
	#body_entered.connect(_on_body_entered)
	#$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exited)
	#
	## Set random initial rotation
	#rotation = randf_range(0, TAU)
#
#func set_direction(dir: Vector2, speed_multiplier: float = 1.0):
	#direction = dir.normalized()
	#speed = 600.0 * speed_multiplier  # Apply speed multiplier
	#var rand_scale = randf_range(0.5, 2.0)
	#sprite.apply_scale(Vector2(rand_scale,rand_scale))
	#
	## Set initial rotation based on direction
	#sprite.rotation = direction.angle() + PI/2
#
#func _process(delta):
	## Move in the set direction
	#position += direction * speed * delta
	#
	## Rotate the coin
	#sprite.rotation += rotation_speed * delta
	#
	## Update distance traveled
	#distance_traveled += speed * delta
	#
	#
	## Destroy if gone too far
	#if distance_traveled > max_distance:
		#queue_free()
#
#func _on_body_entered(body):
	#if body.is_in_group("humans"):
		#if body.has_method("hit"):
			#body.hit()
		#collect()
		#queue_free()
#
#func collect():
	## Spawn collection effect
	##var effect = coin_collect_effect.instantiate()
	##get_parent().add_child(effect)
	##effect.position = position
	#
	## Add coins to the game
	#var main_game = get_node("/root/MainGame")
	#if main_game:
		#main_game.add_coins(coin_value)
	#
	## Remove the coin
	#queue_free()
#
#func _on_screen_exited():
	#queue_free() 
