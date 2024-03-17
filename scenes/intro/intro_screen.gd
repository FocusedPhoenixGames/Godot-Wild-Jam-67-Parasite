extends CanvasLayer

@onready var intro: Array[TextureRect] = [$%Intro2, $%Intro3, $%Intro4, $%Intro5]
@onready var timer: Timer = $%Timer
var number: int = 0


func _ready():
	timer.timeout.connect(on_timer_timeout)

func on_timer_timeout() -> void:
	if number == 4:
		get_tree().change_scene_to_file("res://scenes/game/game.tscn")
	
	else: 
		intro[number].visible = true
		number += 1
		timer.start()
