extends CanvasLayer


@onready var panelContainer = $%PanelContainer

var optionsScreenScene = preload("res://scenes/menus/options_screen.tscn")
var isClosing


func _ready():
	get_tree().paused = true
	panelContainer.pivot_offset = panelContainer.size / 2
	
	$%ResumeButton.grab_focus()
	$%ResumeButton.pressed.connect(on_resume_pressed)
	$%OptionsButton.pressed.connect(on_options_pressed)
	$%QuitButton.pressed.connect(on_quit_pressed)
	
	#$AnimationPlayer.play("default")
	
	var tween = create_tween()
	tween.tween_property(panelContainer, "scale", Vector2.ZERO, 0)
	tween.tween_property(panelContainer, "scale", Vector2.ONE, 0.3)\
	.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		close()
		get_tree().root.set_input_as_handled()


func close():
	if isClosing:
		return
	
	isClosing = true
	#$AnimationPlayer.play_backwards("default")
	
	var tween = create_tween()
	tween.tween_property(panelContainer, "scale", Vector2.ONE, 0)
	tween.tween_property(panelContainer, "scale", Vector2.ZERO, 0.3)\
	.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	
	await tween.finished
	
	get_tree().paused = false
	queue_free()


func on_resume_pressed():
	close()


func on_options_pressed():
	var optionsScreenInstance = optionsScreenScene.instantiate()
	add_child(optionsScreenInstance)
	optionsScreenInstance.back_pressed.connect(on_options_back_pressed.bind(optionsScreenInstance))


func on_quit_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")


func on_options_back_pressed(optionsScreen: Node):
	optionsScreen.queue_free()
	$%OptionsButton.grab_focus()
