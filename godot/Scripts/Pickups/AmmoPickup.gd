extends Node2D

export var type : int = 1 # 1 = primary, 2 = Secondary, 3 = Tool
export var amount : int = 20
 
func _ready():
	pass # Replace with function body.

func get_ammo_amount():
	return amount
	
func get_ammo_type():
	return type

sync func destroy():
	queue_free()

func _on_Area2D_area_entered(_area):
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("destroy")
