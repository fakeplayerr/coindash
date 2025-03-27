extends GPUParticles2D

var min_speed: float = 50.0
var max_speed: float = 200.0
var base_emission_rate: float = 20.0

func _ready():
	# Start emitting
	emitting = true

func update_trail(speed: float):
	# Adjust emission rate based on speed
	var speed_factor = (speed - min_speed) / (max_speed - min_speed)
	amount = int(base_emission_rate * speed_factor)
	
	# Adjust particle size based on speed
	var scale_factor = 1.0 + speed_factor * 0.5
	scale = Vector2(scale_factor, scale_factor) 