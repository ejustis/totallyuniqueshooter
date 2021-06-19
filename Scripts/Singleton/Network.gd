extends Node

#const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT = 20666
const MAX_PLAYERS = 8

var server = null
var client = null
var ip_address = ""
var current_player_username = ""

var networked_object_name_index = 0 setget networked_object_name_index_set
puppet var puppet_networked_object_name_index = 0 setget puppet_networked_object_name_index_set

func _ready():
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	get_tree().connect("server_disconnected", self, "_server_disconnected")

func create_server(max_players):
	if max_players <= 1:
		max_players = MAX_PLAYERS
	
	server = NetworkedMultiplayerENet.new()
	server.create_server(DEFAULT_PORT, max_players)
	get_tree().set_network_peer(server)
	print("Created server on port %d" % DEFAULT_PORT)
	GlobalUtils.instance_node(load("res://Scenes/Main/ServerAdvertiser.tscn"), get_tree().current_scene)

func join_server():
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, DEFAULT_PORT)
	get_tree().set_network_peer(client)
	
func _connected_to_server():
	print("Successfully connected to server")
	
func _server_disconnected():
	print("Disconnected from server")

func networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
	
	if get_tree().is_network_server():
		rset("puppet_networked_object_name_index", networked_object_name_index)
	
func puppet_networked_object_name_index_set(new_value):
	networked_object_name_index = new_value
