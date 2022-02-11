extends Node

#const DEFAULT_IP = '127.0.0.1'
const DEFAULT_PORT: int = 20666
const MAX_PLAYERS: int = 8

var server = null
var client = null
var ip_address = ""
var current_player_username = ""

var in_lobby: bool = false
var in_game: bool = false

var networked_object_name_index: int = 0

var networked_enemy_name_index: int = 0

func _ready():
	var _error = get_tree().connect("connected_to_server", self, "_connected_to_server")
	_error =  get_tree().connect("server_disconnected", self, "_server_disconnected")
	_error =  get_tree().connect("connection_failed", self, "_connection_failed")
	_error = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
		
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
	in_game = false
	in_lobby = false
	
	for child in PersistentNodes.get_children():
		child.queue_free()
			
	networked_object_name_index = 0
	networked_enemy_name_index = 0
	
	if server:
		server.close_connection()
	elif client:
		client.close_connection()
	
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func _connected_to_server():
	print("Successfully connected to server")
	in_lobby = true
	
func _server_disconnected():
	print("Disconnected from server")
	
	reset_network_connection()
	
	if GlobalUtils.ui != null:
		var prompt = GlobalUtils.instance_node(load("res://Scenes/Gui/SimplePrompt.tscn"), GlobalUtils.ui)
		prompt.set_text("Disconnected from server")

func _connection_failed():
	print("Connection to server failed")
	
	reset_network_connection()
	
	if GlobalUtils.ui != null:
		var prompt = GlobalUtils.instance_node(load("res://Scenes/Gui/SimplePrompt.tscn"), GlobalUtils.ui)
		prompt.set_text("Disconnected from server")

func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	#Destroy player on disconnect
	if PersistentNodes.has_node(str(id)):
		var player_node = PersistentNodes.get_node(str(id))
		if GlobalUtils.players_alive.has(player_node):
			GlobalUtils.players_alive.erase(player_node)
		player_node.username_text_instance.queue_free()
		player_node.queue_free()
	
func leave_game():
	reset_network_connection()
	get_tree().change_scene("res://Scenes/Main/Lobby/Lobby.tscn")
	
sync func increment_networked_object_count():
	networked_object_name_index += 1

sync func increment_networked_enemy_count():
	networked_enemy_name_index += 1

sync func reset_for_new_game():
	networked_object_name_index = 0
	networked_enemy_name_index = 0
