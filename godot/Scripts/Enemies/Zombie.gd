extends KinematicBody2D

var velocity = Vector2()
var target = null
var time_to_recalculate = true
#var last_position = Vector2()

puppet var puppet_target_pos setget puppet_target_pos_set
puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity setget puppet_velocity_set

onready var stats = $Stats
onready var tween = $Tween

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
				
				time_to_recalculate = false
				$NewTarget.stop()
				$NewTarget.start()
			else:
				#TODO: make smooth turn
				look_at(target.global_position)
				velocity = global_position.direction_to(target.global_position).normalized()
				
				velocity = velocity * stats.walk_speed
				velocity = move_and_slide(velocity)
		else:
			if puppet_position != null and puppet_target_pos != null:
				look_at(puppet_target_pos)

				velocity = puppet_position.direction_to(puppet_target_pos).normalized()
				
				if not tween.is_active():
					move_and_slide(velocity * stats.walk_speed)

func _on_NewTarget_timeout():
	time_to_recalculate = true
	
sync func destroy():
	queue_free()

func _on_Stats_killed():
	destroy() # Replace with function body.

func puppet_target_pos_set(new_target_pos):
	puppet_target_pos = new_target_pos
	#target = new_target
	
func puppet_position_set(pos):
	puppet_position = pos
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func puppet_velocity_set(vel):
	puppet_velocity = vel

func _on_HitBox_area_entered(area):
	if get_tree().has_network_peer():
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

func _on_NetworkTickRate_timeout():
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_target_pos", target.global_position)
			rset_unreliable("puppet_velocity", velocity)
