extends BossState


func enter():
	super.enter()
	animation_player.play("wakeup")
	animation_player.animation_finished.connect(_on_animation_finish)

func _on_animation_finish(body):
	animation_player.animation_finished.disconnect(_on_animation_finish)
	get_parent().change_state("Idle")
