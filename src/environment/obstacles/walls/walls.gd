extends RigidBody2D

var speed: float = 0.0 # Set by the spawner
signal wall_destroyed

@onready var notifier = $VisibleOnScreenNotifier2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect signals programmatically
	if notifier:
		notifier.screen_entered.connect(_on_screen_entered)
		notifier.screen_exited.connect(_on_screen_exited)
	else:
		printerr("VisibleOnScreenNotifier2D node not found in Walls scene!")


# Called every physics frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	# Simple downward movement based on speed
	# Since it's a RigidBody2D, applying velocity might be better,
	# but direct position manipulation works for constant speed kinematic-like movement.
	# If physics interactions are needed, switch to linear_velocity.
	position.y += speed * delta


func _on_screen_entered() -> void:
	# We could potentially enable the notifier here if it started disabled,
	# but for now, let's assume it's always enabled.
	# print("Wall entered screen") # Optional: for debugging
	pass


func _on_screen_exited() -> void:
	# Emitted just before the wall is removed
	emit_signal("wall_destroyed")
	# print("Wall exited screen, queuing free.") # Optional: for debugging
	queue_free()


# Remove the old function if it exists, as we connect signals in _ready now
# func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
#	pass
#	#queue_free()
