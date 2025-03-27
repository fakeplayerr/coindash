extends ColorRect

signal transition_completed

var transition_duration: float = 0.5
var target_scene: String = ""

func _ready():
	# Make sure the transition is on top
	show()
	z_index = 100

func start_transition(scene_path: String):
	target_scene = scene_path
	
	# Fade in
	var tween = create_tween()
	tween.tween_property(self, "color:a", 1.0, transition_duration / 2)
	tween.tween_callback(_on_fade_in_completed)

func _on_fade_in_completed():
	# Change scene
	get_tree().change_scene_to_file(target_scene)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "color:a", 0.0, transition_duration / 2)
	tween.tween_callback(_on_fade_out_completed)

func _on_fade_out_completed():
	emit_signal("transition_completed") 