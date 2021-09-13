extends Node

export var default_weapon : PackedScene

var primary_weapon : Node
export var primary_ammo : int = 0 

var secondary_weapon : Node
export var secondary_ammo : int = 10

var optional_tool : Node
export var optional_ammo : int = 0 

var current_weapon : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	secondary_weapon = GlobalUtils.intance_node_at_location(default_weapon, self, get_owner().find_node("GunPosition").global_position)
	current_weapon = secondary_weapon
	
func get_current_ammo_store():
	if current_weapon == primary_weapon:
		return primary_ammo
	elif current_weapon == secondary_weapon:
		return secondary_ammo
	elif current_weapon == optional_tool:
		return optional_ammo
	else:
		return 0
		
func remove_from_ammo_store(value : int):
	if current_weapon == primary_weapon:
		primary_ammo -= value
	elif current_weapon == secondary_weapon:
		secondary_ammo -= value
	elif current_weapon == optional_tool:
		optional_ammo -= value
		
func get_current_ammo():
	return current_weapon.ammo_count

func set_current_ammo(new_count : int):
	current_weapon.ammo_count = new_count

func get_current_ammo_max():
	return current_weapon.ammo_max
	
	
