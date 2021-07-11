extends Label

export var lobby_scene : String

sync func return_to_lobby():
	get_tree().change_scene(lobby_scene)

func _on_WinTimer_timeout():
	if get_tree().is_network_server():
		rpc("return_to_lobby")
