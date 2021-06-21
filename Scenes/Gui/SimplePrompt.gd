extends Control

func _on_Ok_pressed():
	get_tree().change_scene("res://Scenes/Main/Lobby.tscn")

func set_text(text):
	$Label.text = text
