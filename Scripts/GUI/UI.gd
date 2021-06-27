extends CanvasLayer

func _ready():
	GlobalUtils.ui = self

func _exit_tree():
	GlobalUtils.ui = null
