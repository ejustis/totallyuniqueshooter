extends Node2D

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

func _ready():
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	
	if get_tree().is_network_server():
		setup_player_positions()

func setup_player_positions():
	for player in PersistentNodes.get_children():
		if player.is_in_group("Player"):
			for spawn_loc in $SpawnLocations.get_children():
				if int(spawn_loc.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
					player.rpc("update_position", spawn_loc.global_position)
					current_spawn_location_instance_number += 1
					current_player_for_spawn_location_number = player

func _player_disconnected(id):
	if PersistentNodes.has_node(str(id)):
		PersistentNodes.get_node(str(id)).username_text_instance.queue_free()
		PersistentNodes.get_node(str(id)).queue_free()
