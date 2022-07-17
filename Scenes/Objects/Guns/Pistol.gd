extends Node2D

export var ammo_max : int = 8
var ammo_count : int
export var reload_speed : float = 1.0
export var attack_rate : float = 0.4

export var bullet_preload : PackedScene

onready var bullet_spawn = $BulletSpawn

# Called when the node enters the scene tree for the first time.
func _ready():
	ammo_count = ammo_max

sync func attack(id):
	if ammo_count > 0:
		var bullet_instance = GlobalUtils.intance_node_at_location(bullet_preload, PersistentNodes, bullet_spawn.global_position)
		bullet_instance.name = "Bullet" + str(Network.networked_object_name_index)
		
		bullet_instance.set_network_master(id)
		bullet_instance.player_rotation = global_rotation
		bullet_instance.player_owner = id
		Network.rpc("increment_networked_object_count")
		
		ammo_count -= 1
