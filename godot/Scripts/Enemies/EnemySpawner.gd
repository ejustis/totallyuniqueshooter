extends Node

export(PackedScene) var enemy_scene
export var timer_timeout : float = 1
export var max_spawn : int = 10

var can_spawn = false
var is_spawning = false
var cur_spawn = 0
var spawn_points = []
var rng = RandomNumberGenerator.new()

onready var spawn_timer = $SpawnTimer

func _ready():
	spawn_timer.wait_time = timer_timeout
	for child in get_children():
		if child is Position2D:
			spawn_points.append(child)
	#print("Spawn time: " + str(spawn_timer.wait_time))
	
func _process(_delta):
	if can_spawn and not is_spawning:
		print("Starting spawn timer")
		spawn_timer.start()
		is_spawning = true

func _on_SpawnTimer_timeout():
	#print("Spawning timer is up")
	#Only spawn any enemy when the server says so
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			is_spawning = false
			rpc("instance_enemy", get_tree().get_network_unique_id())
		
	
sync func instance_enemy(id):
	if get_tree().has_network_peer():
		if GlobalUtils.get_current_enemies_spawned().size() + 1 <= GlobalUtils.max_spawned_enemies:
			#print("Creating enemy instance")
			var spawn_loc = spawn_points[rng.randi_range(0, len(spawn_points)-1)]
			
			var enemy_instance = GlobalUtils.intance_node_at_location(enemy_scene, PersistentNodes, spawn_loc.global_position)
			enemy_instance.name += str(Network.networked_enemy_name_index)
			enemy_instance.set_network_master(id)
			
			Network.networked_enemy_name_index += 1
			cur_spawn += 1
