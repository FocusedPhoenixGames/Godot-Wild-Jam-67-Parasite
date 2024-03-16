extends Node2D

var current_state: StateMachine
var previous_state: StateMachine

func _ready():
	current_state = get_child(0) as StateMachine
	previous_state = current_state
	print("current: ", current_state)
	current_state.enter()

func change_state(state):
	current_state = find_child(state) as StateMachine
	current_state.enter()
	print("changed: ", current_state)
	
	previous_state.exit()
	previous_state = current_state
