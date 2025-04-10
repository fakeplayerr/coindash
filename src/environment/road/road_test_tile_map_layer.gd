extends TileMapLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_enabler_2d_screen_entered() -> void:
	var newTile = self.duplicate()
	newTile.position.y = position.y - 512
	get_parent().add_child(newTile)


func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()
