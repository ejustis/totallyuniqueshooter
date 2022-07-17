extends Camera2D

var target_player = null

func _ready():
	target_player = GlobalUtils.player_master
	
func _process(_delta):
	if GlobalUtils.player_master != null and is_instance_valid(GlobalUtils.player_master):
		global_position = GlobalUtils.player_master.global_position
