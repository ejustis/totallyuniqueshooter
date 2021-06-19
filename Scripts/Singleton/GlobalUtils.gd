extends Node

func intance_node_at_location(node: Object, parent: Object, global_location: Vector2) -> Object:
	var node_instance = instance_node(node, parent)
	node_instance.global_position = global_location
	return node_instance

func instance_node(node: Object, parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance
