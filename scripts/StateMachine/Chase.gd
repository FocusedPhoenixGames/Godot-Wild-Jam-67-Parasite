extends StateMachine


func enter():
	super.enter()
	#owner.set_physics_process(true)
	animation_player.play("walk")

func exit():
	super.exit()
	#owner.set_physics_process(false)

func transition():
	var distance = owner.direction.length()
	
	if distance < 20.0:
		get_parent().change_state("Attack")




