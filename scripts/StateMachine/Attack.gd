extends StateMachine


func enter():
	super.enter()
	animation_player.play("attack")

func transition():
	if owner.direction.length() > 1:
		get_parent().change_state("Chase")
