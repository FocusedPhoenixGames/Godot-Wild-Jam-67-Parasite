extends BossState

@onready var collision: Area2D = $%PlayerDetection


func _ready():
	collision.body_entered.connect(_on_player_detection_body_entered)
	animation_player.play("sleep")

func _on_player_detection_body_entered(body):
	collision.body_entered.disconnect(_on_player_detection_body_entered)
	get_parent().change_state("WakeUp")

