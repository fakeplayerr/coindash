extends Control

@onready var score_label = $VBoxContainer/ScoreLabel
@onready var restart_button = $VBoxContainer/RestartButton
@onready var main_menu_button = $VBoxContainer/MainMenuButton

var final_score: int = 0

func _ready():
	print("Game Over Screen Ready")
	
	# Set this control to process even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Connect button signals
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	
	# Debug: Add direct button press monitoring
	if restart_button:
		print("Restart button connected")
		restart_button.process_mode = Node.PROCESS_MODE_ALWAYS
		restart_button.mouse_filter = Control.MOUSE_FILTER_STOP
		
	if main_menu_button:
		print("Main menu button connected")
		main_menu_button.process_mode = Node.PROCESS_MODE_ALWAYS
		main_menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Make sure our mouse filter allows us to capture clicks
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Update score label
	update_score_display()

func update_score_display():
	# If we already have a score set, use that
	if final_score > 0:
		score_label.text = "Score: %d" % final_score
	else:
		# Otherwise try to get it from the SaveManager
		var save_manager = get_node("/root/SaveManager")
		if save_manager:
			score_label.text = "Score: %d" % save_manager.get_current_game_coins()

func set_score(score: int):
	final_score = score
	update_score_display()

func _on_restart_pressed():
	print("RESTART BUTTON PRESSED")
	
	# Unpause the game first
	get_tree().paused = false
	print("Game unpaused")
	
	# Remove ourselves from the scene tree first
	queue_free()
	
	# Schedule the scene change to happen after we're removed
	call_deferred("_change_to_main_game")

func _on_main_menu_pressed():
	print("MAIN MENU BUTTON PRESSED")
	
	# Unpause the game first
	get_tree().paused = false
	print("Game unpaused")
	
	# Remove ourselves from the scene tree first
	queue_free()
	
	# Schedule the scene change to happen after we're removed
	call_deferred("_change_to_start_screen")

# These functions are called after the current frame has completed
func _change_to_main_game():
	var err = get_tree().change_scene_to_file("res://scenes/main_game.tscn")
	print("Scene change result: " + str(err))

func _change_to_start_screen():
	var err = get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
	print("Scene change result: " + str(err))

# Process input directly as a backup approach
func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		print("Input event detected in game over screen: " + str(event.position))
		
		# Check if mouse is over restart button
		if restart_button and restart_button.get_global_rect().has_point(event.position):
			print("Mouse clicked on restart button")
			_on_restart_pressed()
		
		# Check if mouse is over main menu button
		if main_menu_button and main_menu_button.get_global_rect().has_point(event.position):
			print("Mouse clicked on main menu button")
			_on_main_menu_pressed() 

func _notification(what):
	if what == NOTIFICATION_MOUSE_ENTER:
		print("Mouse entered game over screen")
	elif what == NOTIFICATION_MOUSE_EXIT:
		print("Mouse exited game over screen") 
