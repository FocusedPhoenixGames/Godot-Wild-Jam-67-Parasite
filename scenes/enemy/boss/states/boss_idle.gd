extends BossState


func enter():
	super.enter()
	animation_player.play("idle")
	get_tree().create_timer(rng.randf_range(1.0, 2.0)).timeout.connect(_switch_to_attack)

func _switch_to_attack():
	get_parent().change_state("Attack")
