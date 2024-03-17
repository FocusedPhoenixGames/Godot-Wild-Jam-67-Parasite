extends CanvasLayer


func _ready():
	$Timer.timeout.connect(on_timer_timeout)


func on_timer_timeout():
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
