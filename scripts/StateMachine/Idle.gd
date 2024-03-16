extends StateMachine


@onready var collision: Area2D = $%PlayerDetection

var player_entered: bool = false:
	set(value):
		player_entered = value
		collision.set_deferred("disabled", value)

func _ready():
	collision.body_entered.connect(_on_player_detection_body_entered)

func transition():
	if player_entered:
		get_parent().change_state("Chase")
	else:
		animation_player.play("idle")

func _on_player_detection_body_entered(body):
	player_entered = true
	transition()


