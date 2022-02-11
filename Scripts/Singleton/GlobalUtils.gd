extends Node

var player_master = null
var ui = null
var max_spawned_enemies = 10
var players_alive = []

func intance_node_at_location(node: Object, parent: Object, global_location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = global_location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
	
func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight
	
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference
	
func get_current_enemies_spawned():
	var enemies = []
	for child in PersistentNodes.get_children():
		if child.is_in_group("Enemy"):
			enemies.append(child)
	
	return enemies

