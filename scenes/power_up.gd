extends Area2D

signal collected(type)

var type = "speed"
var duration = 5.0
var is_collected = false
var color = Color(0, 1, 0)  # Default green color
var velocity = Vector2.ZERO
var rotation_speed = 2.0

@onready var sprite = $Sprite2D
@onready var label = $Label
@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var particles = $CPUParticles2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
	if animation_player:
		animation_player.play("hover")
	
	if sprite:
		sprite.modulate = color
	
	if label:
		label.text = type

func _process(delta):
	# Rotate the power-up
	if sprite:
		sprite.rotation += rotation_speed * delta
	
	# Apply velocity
	position += velocity * delta

# Setup the power-up with a specific type and appearance
func setup(new_type, new_color, new_duration):
	type = new_type
	color = new_color
	duration = new_duration
	
	if sprite:
		sprite.modulate = color
	
	if label:
		label.text = type

# Called when a body enters the power-up's area
func _on_body_entered(body):
	if is_collected:
		return
	
	if body.is_in_group("player"):
		collect()

# Collect the power-up
func collect():
	if is_collected:
		return
	
	is_collected = true
	
	# Emit collected signal
	emit_signal("collected", type)
	
	# Play collection animation
	if animation_player and animation_player.has_animation("collect"):
		animation_player.play("collect")
		await animation_player.animation_finished
		queue_free()
	else:
		# If no animation, just destroy
		queue_free()

# Set movement velocity
func set_velocity(vel):
	velocity = vel

# Get power-up type
func get_type():
	return type

# Get power-up duration
func get_duration():
	return duration 