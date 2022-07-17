extends Panel

var is_paused : bool = false setget set_is_paused

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (Network.in_game or Network.in_lobby) and Input.is_action_just_pressed("ui_pause"):
		toggle_visibility()
		
func set_is_paused(value):
	toggle_visibility()
	is_paused = value
	
func toggle_visibility():
	visible = !visible
	
func _on_Continue_button_down():
	is_paused = false

func _on_Exit_button_down():
	Network.leave_game()
	is_paused = false
	
