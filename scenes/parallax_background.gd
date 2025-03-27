extends ParallaxBackground

var scroll_speed: float = 0.0
var base_speed: float = 50.0

func _ready():
	# Initialize parallax layers
	for i in range(3):
		var layer = ParallaxLayer.new()
		var sprite = Sprite2D.new()
		# TODO: Set sprite texture when assets are ready
		sprite.scale = Vector2(2, 2)
		layer.motion_scale = Vector2(0.2 * (i + 1), 0.2 * (i + 1))
		layer.add_child(sprite)
		add_child(layer)

func _process(delta):
	# Update scroll offset for each layer
	for layer in get_children():
		if layer is ParallaxLayer:
			layer.motion_offset += Vector2(scroll_speed * delta, 0)

func _on_player_speed_changed(speed: float):
	scroll_speed = base_speed + (speed * 0.5) 