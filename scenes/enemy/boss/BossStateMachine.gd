extends Node2D

var current_state: BossState
var previous_state: BossState

func _ready():
	current_state = get_node("Sleep") as BossState
	print("state: ", current_state)
	previous_state = current_state
	current_state.enter()

func change_state(state):
	print("state: ", state)
	current_state = find_child(state) as BossState
	current_state.enter()
	
	previous_state.exit()
	previous_state = current_state
