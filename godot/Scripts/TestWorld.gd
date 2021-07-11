extends Node2D

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

onready var enemy_spawners = $EnemySpawners

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	if get_tree().is_network_server():
		setup_player_positions()
		
	if get_tree().is_network_server():
		activate_spawners()
		
func _process(delta):
	check_for_no_survivors()
		
func setup_player_positions():
	for player in PersistentNodes.get_children():
		if player.is_in_group("Player"):
			for spawn_loc in $SpawnLocations.get_children():
				if int(spawn_loc.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
					player.rpc("update_position", spawn_loc.global_position)
					current_spawn_location_instance_number += 1
					current_player_for_spawn_location_number = player
					
func activate_spawners():
	for spawner in enemy_spawners.get_children():
		print(spawner)
		spawner.can_spawn = true

func _player_disconnected(id):
	if PersistentNodes.has_node(str(id)):
		PersistentNodes.get_node(str(id)).username_text_instance.queue_free()
		PersistentNodes.get_node(str(id)).queue_free()

func check_for_no_survivors():
	if GlobalUtils.players_alive.size() == 0:
		if get_tree().has_network_peer():
			if get_tree().is_network_server():
				rpc("return_to_lobby")
		else:
			return_to_lobby()

sync func return_to_lobby():
	for child in PersistentNodes.get_children():
		if child.is_in_group("Enemy"):
			child.queue_free()
#		else:
#			child.queue_free()
	
	get_tree().change_scene("res://Scenes/Main/Lobby/Lobby.tscn")
