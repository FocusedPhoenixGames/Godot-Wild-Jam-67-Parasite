extends CanvasLayer

var optionsScene = preload("res://scenes/menus/options_screen.tscn")


func _ready():
	MusicPlayer.play_music(1)
	$%PlayButton.pressed.connect(on_play_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	$%PlayButton.grab_focus()


func on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/game/game.tscn")


func on_options_pressed():
	var optionsInstance = optionsScene.instantiate()
	add_child(optionsInstance)
	optionsInstance.back_pressed.connect(on_options_closed.bind(optionsInstance))


func on_quit_pressed():
	get_tree().quit()


func on_options_closed(optionsInstance: Node):
	optionsInstance.queue_free()
	$%OptionsButton.grab_focus()
