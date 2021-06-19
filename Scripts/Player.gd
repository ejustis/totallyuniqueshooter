extends KinematicBody2D

var hp = 100 setget set_hp
var walk_speed = 350
var sprint_speed = 500
var max_stamina = 60
var stamina = max_stamina
var can_sprint = true

var can_shoot = true
var is_reloading = false

var velocity = Vector2(0, 0)
var move_speed = walk_speed

puppet var puppet_hp setget puppet_hp_set
puppet var puppet_position = Vector2(0, 0) setget puppet_position_set
puppet var puppet_velocity = Vector2()
puppet var puppet_move_speed = 0
puppet var puppet_rotation = 0

var bullet_preload = load("res://Scenes/Objects/Bullet.tscn")

onready var tween = $Tween
onready var sprite = $Sprite
onready var reload_timer = $ReloadTimer
onready var bullet_spawn = $BulletSpawn
onready var hit_timer = $HitTimer

# Called when the node enters the scene tree for the first time.
func _ready():
	update_shoot_mode(true)

func _process(delta):
	if is_network_master():
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
	else:
		rotation = lerp_angle(rotation, puppet_rotation, delta*8)
		
		if not tween.is_active():
			move_and_slide(puppet_velocity * puppet_move_speed)
	
	if hp <= 0:
		if get_tree().is_network_server():
			rpc("destroy")

sync func instance_bullet(id):
	var bullet_instance = GlobalUtils.intance_node_at_location(bullet_preload, PersistentNodes, bullet_spawn.global_position)
	bullet_instance.name = "Bullet" + name + str(Network.networked_object_name_index)
	
	bullet_instance.set_network_master(id)
	bullet_instance.player_rotation = rotation
	bullet_instance.player_owner = id
	Network.networked_object_name_index += 1

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

func lerp_angle(from, to, weight):
	return from + short_angle_dist(from, to) * weight
	
func short_angle_dist(from, to):
	var max_angle = PI * 2
	var difference = fmod(to - from, max_angle)
	return fmod(2 * difference, max_angle) - difference

func _on_StaminaBurnTimer_timeout():
	can_sprint = true
	print("Can sprint again")

func _on_NetworkTickRate_timeout():
	if get_tree().has_network_peer():
		if is_network_master():
			rset_unreliable("puppet_position", global_position)
			rset_unreliable("puppet_rotation", rotation)
			rset_unreliable("puppet_move_speed", move_speed)
			rset_unreliable("puppet_velocity", velocity)

func _on_ReloadTimer_timeout():
	is_reloading = false

func set_hp(new_value):
	hp = new_value
	
	if is_network_master():
		rset("puppet_hp", hp)
		
func puppet_hp_set(new_value):
	puppet_hp = new_value
	
	if not is_network_master():
		hp = puppet_hp

func _on_HitTimer_timeout():
	modulate = Color(1,1,1,1)

func _on_HitBox_area_entered(area):
	if get_tree().is_network_server():
		if area.is_in_group("PlayerDamage") and area.get_parent().player_owner != int(name):
			rpc("hit_by_damager", area.get_parent().damage)
			
			area.get_parent().rpc("destroy")

sync func hit_by_damager(damage):
	hp -= damage
	modulate = Color(5,5,5,1)
	hit_timer.start()

sync func destroy():
	visible = false
	$CollisionShape2D.disabled = true
	$HitBox/CollisionShape2D.disabled = true
