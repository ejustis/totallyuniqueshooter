extends Node2D

var player_following = null
var text = "" setget text_set

onready var label = $Label

func _process(_delta):
	if player_following != null:
		global_position = player_following.global_position

func text_set(new_value):
	text = new_value
	label.text = text
