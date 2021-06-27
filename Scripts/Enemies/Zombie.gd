extends KinematicBody2D

var velocity = Vector2()
var target = null
var time_to_recalculate = true
#var last_position = Vector2()

var puppet_target setget puppet_target_set
var puppet_position setget puppet_position_set

onready var stats = $Stats

func _ready():
	stats.cur_health = stats.max_health
	#last_position = global_position
	
func _process(delta):
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			var new_target
			if target == null or not GlobalUtils.players_alive.has(target) or time_to_recalculate:
				# Loop through the list of players that are alive and choose closest target
				var closest_distance = null
				for child in GlobalUtils.players_alive:
					var distance_to_next_player = global_position.distance_to(child.global_position)
					if closest_distance == null or distance_to_next_player < closest_distance:
						new_target = child
						closest_distance = distance_to_next_player
				
				target = new_target
				rpc("puppet_target", new_target)
				
				time_to_recalculate = false
				$NewTarget.stop()
				$NewTarget.start()
			else:
				rpc("puppet_position", global_position)
		
func _physics_process(delta):
	if target != null:
		if get_tree().has_network_peer():
			if get_tree().is_network_server():
				#TODO: make smooth turn
				look_at(target.global_position)
				velocity = global_position.direction_to(target.global_position).normalized()
				
				velocity = velocity * stats.walk_speed
				velocity = move_and_slide(velocity)
			else:
				look_at(puppet_target.global_position)
				global_position = puppet_position
			

func _on_NewTarget_timeout():
	time_to_recalculate = true
	
sync func destroy():
	queue_free()

func _on_Stats_killed():
	destroy() # Replace with function body.

func puppet_target_set(new_target):
	puppet_target = new_target
	
func puppet_position_set(pos):
	puppet_position = pos

func _on_HitBox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("Damager") or area.is_in_group("Bullet"):
			rpc("hit_by_damager", area.get_parent().get_damage())
			
			if area.is_in_group("Bullet"):
				area.get_parent().rpc("destroy")
				
func get_damage():
	return stats.base_damage

sync func hit_by_damager(damage):
	print(name + "; Hit for: " + str(damage))
	stats.reduce_health(damage)
