extends "res://src/characters/base_npc.gd"

# Girl NPCs need animation support
func _ready():
	# Girl NPCs have animation
	has_animation = true
	
	# Call parent _ready to initialize common properties
	super._ready() 
