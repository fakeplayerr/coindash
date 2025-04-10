extends Node2D

@export var projectile_resource: BaseProjectile

@export var velocity: Vector2 = Vector2.ZERO
@export_range(0, 1000, 10) var speed: float = 200
var shot_by_player: bool = false

func _ready():
	if projectile_resource:
		$Sprite2D.texture = projectile_resource.image
		$Sprite2D.scale = Vector2.ONE * projectile_resource.size * 0.5  # Scale based on size
		$CollisionShape2D.scale = Vector2.ONE * projectile_resource.size * 0.5
		
	# Start animation if it exists
	if has_node("AnimationPlayer"):
		$AnimationPlayer.play("rotate")
		
	# Connect screen exited signal
	if has_node("VisibleOnScreenNotifier2D"):
		$VisibleOnScreenNotifier2D.connect("screen_exited", Callable(self, "_on_visible_on_screen_notifier_2d_screen_exited"))

func _process(delta):
	# Move according to velocity
	position += velocity * delta

func set_velocity(vel: Vector2):
	velocity = vel

func set_speed(spd: float):
	speed = spd
	
func _on_area_2d_body_entered(body):
	# Skip if this is a player-shot coin and it hits the player
	if shot_by_player and body.is_in_group("player"):
		return
		
	if body.is_in_group("player"):
		# Find the current level through the group system
		var current_levels = get_tree().get_nodes_in_group("current_level")
		for level_manager in current_levels:
			if level_manager.has_method("handle_coin_collected"):
				level_manager.handle_coin_collected(projectile_resource.amount)
		
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()  # Clean up when leaving screen 
