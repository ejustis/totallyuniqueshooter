extends CanvasLayer

onready var win_timer = $Control/Winner/WinTimer
onready var win_label = $Control/Winner

func _ready():
	win_label.hide()

func _process(delta):
	if GlobalUtils.players_alive.size() <= 0 and get_tree().has_network_peer():
		#if GlobalUtils.players_alive[0].name == str(get_tree().get_network_unique_id()):
		#	win_label.show()

		#if win_timer.time_left <= 0:
		#	win_timer.start()
		pass
