extends Control

export var server_display_scene : PackedScene

onready var server_ip_text = $BackgroundPanel/ServerIP

func _ready():
	pass

func _on_JoinServer_pressed():
	Network.ip_address = server_ip_text.text
	hide()
	Network.join_server()

func _on_GoBack_pressed():
	var _error = get_tree().reload_current_scene()
