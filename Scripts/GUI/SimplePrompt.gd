extends Control

export var lobby_scene : String

func _on_Ok_pressed():
	get_tree().change_scene(lobby_scene)

func set_text(text):
	$Label.text = text
