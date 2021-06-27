extends Node

export var max_health = 100
var cur_health = 0 
export var walk_speed = 75
export var run_speed = 95
export var base_damage = 12

signal killed

func _ready():
	var cur_health = max_health

func reduce_health(_damage):
	cur_health -= _damage
	if(cur_health <= 0):
		emit_signal("killed")
