extends StateMachine


func enter():
	super.enter()
	animation_player.play("walk")

func exit():
	super.exit()

func transition():
	var distance = owner.direction.length()
	
	if distance < 20.0:
		get_parent().change_state("Attack")




