extends Label

sync func return_to_lobby():
	get_tree().change_scene("res://Scenes/Main/Lobby.tscn")

func _on_WinTimer_timeout():
	if get_tree().is_network_server():
		rpc("return_to_lobby")
