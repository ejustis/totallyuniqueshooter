extends KinematicBody2D

var hp: int = 100 setget set_hp
var walk_speed: int = 350
var sprint_speed: int = 500
var max_stamina: float = 60
var stamina: float = max_stamina
var can_sprint: bool = true

var can_shoot: bool = false
var is_reloading: bool = false

var velocity: Vector2 = Vector2(0, 0)
var move_speed: int = walk_speed

export var bullet_preload : PackedScene
export var username_preload : PackedScene

var username: String setget username_set
var username_text_instance = null

var damager_collisions: Array = []

puppet var puppet_hp: int setget puppet_hp_set
puppet var puppet_position: Vector2 = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity: Vector2 = Vector2()
puppet var puppet_move_speed: int = 0
puppet var puppet_rotation: float = 0
puppet var puppet_username: String setget puppet_username_set

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $ReloadTimer
onready var bullet_spawn = $BulletSpawn
onready var hit_timer = $HitTimer

# Called when the node enters the scene tree for the first time.
func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_network_peer_connected")
	
	username_text_instance = GlobalUtils.intance_node_at_location(username_preload, PersistentNodes, global_position)
	username_text_instance.player_following = self
	update_shoot_mode(false)
	GlobalUtils.players_alive.append(self)
	
	yield(get_tree(), "idle_frame")
	if get_tree().has_network_peer():
		if is_network_master():
			GlobalUtils.player_master = self

func _process(delta):
	if username_text_instance != null:
		username_text_instance.name = "username" + name
		
	if get_tree().has_network_peer():
		if is_network_master() and visible:
			var x_input = int(Input.is_action_pressed("Right")) - int(Input.is_action_pressed("Left"))
			var y_input = int(Input.is_action_pressed("Down")) - int(Input.is_action_pressed("Up"))
			
			if Input.is_action_pressed("Sprint") and can_sprint:
				move_speed = sprint_speed
				stamina -= 0.5
			else:
				move_speed = walk_speed
				stamina += 0.3
		
			stamina = clamp(stamina, 0, max_stamina)
			
			if stamina <= 0.5 and can_sprint:
				$StaminaBurnTimer.start()
				can_sprint = false
				print("Can't sprint")
				
			velocity = Vector2(x_input, y_input).normalized()
			velocity = move_and_slide(velocity * move_speed)
			
			look_at(get_global_mouse_position())
			
			if Input.is_action_just_pressed("Shoot") and can_shoot and not is_reloading:
				rpc("instance_bullet", get_tree().get_network_unique_id())
				is_reloading = true
				reload_timer.start()
				
			for area in damager_collisions:
				rpc("hit_by_damager", area.get_parent().get_damage())
				
		else:
			rotation = GlobalUtils.lerp_angle(rotation, puppet_rotation, delta*8)
			
			if not tween.is_active():
# warning-ignore:return_value_discarded
				move_and_slide(puppet_velocity * puppet_move_speed)
	if hp <= 0:
		if username_text_instance != null:
			username_text_instance.visible = false
		if get_tree().has_network_peer():
			if get_tree().is_network_server():
				rpc("destroy")

sync func instance_bullet(id):
	var bullet_instance = GlobalUtils.intance_node_at_location(bullet_preload, PersistentNodes, bullet_spawn.global_position)
	bullet_instance.name = "Bullet" + name + str(Network.networked_object_name_index)
	
	bullet_instance.set_network_master(id)
	bullet_instance.player_rotation = rotation
	bullet_instance.player_owner = id
	Network.networked_object_name_index += 1
	
sync func update_postion(pos):
	global_position = pos
	puppet_position = pos

func update_shoot_mode(shoot_mode):
	if not shoot_mode:
		#Change to no weapon
		pass
	else:
		#Change to weapon
		pass
	
	can_shoot = shoot_mode

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	
	tween.interpolate_property(self, "global_position", global_position, puppet_position, 0.1)
	tween.start()

func _on_StaminaBurnTimer_timeout():
	can_sprint = true
	print("Can sprint again")
	
func _network_peer_connected(id):
	rset_id(id, "puppet_username", username)

func _on_NetworkTickRate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rpc("_update_Puppet_State", global_position, rotation, move_speed, velocity)
#			rset_unreliable("puppet_position", global_position)
#			rset_unreliable("puppet_rotation", rotation)
#			rset_unreliable("puppet_move_speed", move_speed)
#			rset_unreliable("puppet_velocity", velocity)

puppet func _update_Puppet_State(p_pos: Vector2, p_rot: float, p_speed: int, p_vel: Vector2) -> void:
	puppet_position_set(p_pos)
	puppet_rotation = p_rot
	puppet_move_speed = p_speed
	puppet_velocity = p_vel

func _on_ReloadTimer_timeout():
	is_reloading = false

func set_hp(new_value):
	hp = new_value
	if get_tree().has_network_peer():
		if is_network_master():
			rset("puppet_hp", hp)
		
func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master():
			hp = puppet_hp
		
func username_set(new_value):
	username = new_value
	
	if get_tree().has_network_peer():
		if is_network_master() and username_text_instance != null:
			username_text_instance.text = username
			rset("puppet_username", username)

func puppet_username_set(new_value):
	puppet_username = new_value
	
	if get_tree().has_network_peer():
		if not is_network_master() and username_text_instance != null:
			username_text_instance.text = puppet_username
		
func _on_HitTimer_timeout():
	# Note good with bloom
	#modulate = Color(1,1,1,1)
	pass

func _on_HitBox_area_entered(area):
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if area.is_in_group("Damager") or area.is_in_group("Enemy"):
				if not damager_collisions.has(area):
					damager_collisions.append(area)
				
func _on_HitBox_area_exited(area):
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			if area.is_in_group("Damager") or area.is_in_group("Enemy"):
				if damager_collisions.has(area):
					damager_collisions.erase(area)
			
sync func hit_by_damager(damage):
	print("I was hit!")
	hp -= damage
	# Modulate looks bad with bloom
	#modulate = Color(5,5,5,1)
	hit_timer.start()

sync func enable():
	hp = 100
	can_shoot = false
	update_shoot_mode(false)
	username_text_instance.visible = true
	visible = true
	$CollisionShape2D.disabled = false
	$HitBox/CollisionShape2D.disabled = false
	
	if get_tree().has_network_peer():
		if is_network_master():
			GlobalUtils.player_master = self
		
	if not GlobalUtils.players_alive.has(self):
		GlobalUtils.players_alive.append(self)
		
sync func destroy():
	username_text_instance.visible = false
	visible = false
	$CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.disabled = true
	GlobalUtils.players_alive.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			GlobalUtils.player_master = null

func _exit_tree():
	GlobalUtils.players_alive.erase(self)
	if get_tree().has_network_peer():
		if is_network_master():
			GlobalUtils.player_master = null

