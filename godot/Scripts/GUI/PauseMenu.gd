extends Control

var is_paused : bool = false setget set_is_paused

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") and GlobalUtils.player_master and GlobalUtils.player_master.can_shoot:
		self.is_paused = !is_paused

func set_is_paused(value):
	is_paused = value
	visible = is_paused

func _on_Continue_button_down():
	self.is_paused = false

func _on_Exit_button_down():
	GlobalUtils.exit_current_game()
	self.is_paused = false
