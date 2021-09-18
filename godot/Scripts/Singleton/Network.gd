extends Node

#const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 20666
const MAX_PLAYERS = 8

var server = null
var client = null
var ip_address = ""
var current_player_username = ""

var networked_object_name_index = 0
#puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

var networked_enemy_name_index = 0
#puppet var puppet_networked_enemy_name_index = 0 setget puppet_networked_enemy_name_index_set

func _ready():
	var _error = get_tree().connect("connected_to_server", self, "_connected_to_server")
	_error =  get_tree().connect("server_disconnected", self, "_server_disconnected")
	_error =  get_tree().connect("connection_failed", self, "_connection_failed")
		
func create_server(max_players):
	if max_players <= 1:
		max_players = MAX_PLAYERS
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, max_players)
	get_tree().set_network_peer(server)
	print("Created server on port %d" % DEFAULT_PORT)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)

func reset_network_connection():
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func _connected_to_server():
	print("Successfully connected to server")
	
func _server_disconnected():
	print("Disconnected from server")

	for child in PersistentNodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if GlobalUtils.ui != null:
		var prompt = GlobalUtils.instance_node(load("res://Scenes/Gui/SimplePrompt.tscn"), GlobalUtils.ui)
		prompt.set_text("Disconnected from server")

func _connection_failed():
	print("onnection to server failed")
	
	for child in PersistentNodes.get_children():
		if child.is_in_group("Net"):
			child.queue_free()
	
	reset_network_connection()
	
	if GlobalUtils.ui != null:
		var prompt = GlobalUtils.instance_node(load("res://Scenes/Gui/SimplePrompt.tscn"), GlobalUtils.ui)
		prompt.set_text("Disconnected from server")
		
sync func increment_networked_object_count():
	networked_object_name_index += 1

sync func increment_networked_enemy_count():
	networked_enemy_name_index += 1

		
#func networked_object_name_index_set(new_value):
#	networked_object_name_index = new_value
#	
#	if get_tree().is_network_server():
#		rpc("puppet_networked_object_name_index_set", networked_object_name_index)
	
#func puppet_networked_object_name_index_set(new_value):
#	if not get_tree().is_network_server():
#		networked_object_name_index = new_value

#func networked_enemy_name_index_set(new_value):
#	networked_enemy_name_index = new_value
	
#	if get_tree().is_network_server():
#		rpc("puppet_networked_enemy_name_index_set", networked_enemy_name_index)
	
#func puppet_networked_enemy_name_index_set(new_value):
#	if not get_tree().is_network_server():
#		networked_enemy_name_index = new_value

sync func reset_for_new_game():
	networked_object_name_index = 0
	networked_enemy_name_index = 0
