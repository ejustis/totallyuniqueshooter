extends Panel

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Network.in_game or Network.in_lobby) and Input.is_action_just_pressed("ui_pause"):
		toggle_visibility()
		
func toggle_visibility():
	visible = !visible
	
func _on_Continue_button_down():
	visible = false

func _on_Exit_button_down():
	visible = false
	Network.leave_game()
	
