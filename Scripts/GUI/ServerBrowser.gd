extends Control

export var server_display_scene : PackedScene

onready var server_listener = $ServerListener
onready var server_ip_text = $BackgroundPanel/ServerIP
onready var server_container = $BackgroundPanel/VBoxContainer
onready var lan_browser = $BackgroundPanel/BrowseLAN

func _ready():
	server_container.hide()

func _on_ServerListener_new_server(server_info):
	var server_node = GlobalUtils.instance_node(server_display_scene, server_container)
	server_node.text = "%s - %s" % [server_info.ip, server_info.name]
	server_node.ip_address = str(server_info.ip)
	
func _on_ServerListener_remove_server(server_ip):
	for server_node in server_container.get_children():
		if server_node.is_in_group("ServerDisplay"):
			if server_node.ip == server_ip:
				server_node.queue_free()
				break


func _on_BrowseLAN_pressed():
	if lan_browser.text != "Manual Entry":
		server_ip_text.text = ""
		server_container.show()
		lan_browser.text = "Manual Entry"
		server_ip_text.hide()
	else:
		server_ip_text.show()
		lan_browser.text = "Browse LAN"
		server_container.hide()
		server_ip_text.call_deferred("grab_focus")


func _on_JoinServer_pressed():
	Network.ip_address = server_ip_text.text
	hide()
	Network.join_server()


func _on_GoBack_pressed():
	get_tree().reload_current_scene()
