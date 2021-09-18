extends Node

var player = load("res://Scenes/Objects/Player.tscn")

onready var start_game = $UI/StartGame
onready var pending_start = $UI/PendingStart

# Called when the node enters the scene tree for the first time.
func _ready():
	print("Loading Lobby scene")
	$MultiplayerSetup.show()
	
	var _error = get_tree().connect("network_peer_connected", self, "_player_connected")
	_error = get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	_error = get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	if get_tree().network_peer != null:
		$MultiplayerSetup.hide()
		var screen_rect = OS.get_window_safe_area()
		
		if get_tree().is_network_server():
			Network.reset_for_new_game()
		
			for player_instance in PersistentNodes.get_children():
				if player_instance.is_in_group("Player"):
					var spawn_point = Vector2(rand_range(0,  screen_rect.end.x) , rand_range(0,  screen_rect.end.y))
					player_instance.rpc("update_position", spawn_point)
					player_instance.rpc("enable")
	else:
		start_game.hide()
		pending_start.hide()
		
func _process(_delta):
	if get_tree().network_peer != null:
		if get_tree().is_network_server():
			start_game.show()
			pending_start.hide()
		else:
			start_game.hide()
			pending_start.show()
			
func _player_connected(id):
	print("Player " + str(id) + " has connected")
	
	instance_player(id)

func _player_disconnected(id):
	print("Player " + str(id) + " has disconnected")
	
	#Destroy player on disconnect
	if PersistentNodes.has_node(str(id)):
		PersistentNodes.get_node(str(id)).username_text_instance.queue_free()
		PersistentNodes.get_node(str(id)).queue_free()

func _on_HostButton_pressed():
	var max_players = 0
	
	var username = $MultiplayerSetup/UIHolder/Username.text
	if username != "":
		$MultiplayerSetup.hide()
		Network.current_player_username = username
		Network.create_server(max_players)
		
		instance_player(get_tree().get_network_unique_id())

func _on_JoinButton_pressed():
	var username = $MultiplayerSetup/UIHolder/Username.text
	if username != "":
		Network.current_player_username = username
		$MultiplayerSetup.hide()
		#$MultiplayerSetup/UIHolder/Username.hide()
		
		var _instance = GlobalUtils.instance_node(load("res://Scenes/Main/Lobby/ServerBrowser.tscn"), self)
		
func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.15), "timeout")
	instance_player(get_tree().get_network_unique_id())
		
func instance_player(id) -> void:
	var screen_rect = OS.get_window_safe_area()
	var player_instance = GlobalUtils.intance_node_at_location(
		player, 
		PersistentNodes, 
		Vector2(rand_range(0,  screen_rect.end.x) , rand_range(0,  screen_rect.end.y))
		)
	
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = $MultiplayerSetup/UIHolder/Username.text

func _on_StartGame_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	for child in PersistentNodes.get_children():
		if child.is_in_group("Player"):
			child.update_shoot_mode(true)
	
	var _error = get_tree().change_scene("res://Scenes/Main/Levels/TestWorld.tscn")
