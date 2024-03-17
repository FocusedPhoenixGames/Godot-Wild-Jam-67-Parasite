extends Node2D
class_name BossState

@onready var debug = owner.find_child("debug")
@onready var player = get_tree().root.get_node("Game").get_node("Player")
@onready var animation_player = owner.find_child("AnimationPlayer")
var rng = RandomNumberGenerator.new()

func _ready():
	set_physics_process(false)

func enter():
	set_physics_process(true)

func exit():
	set_physics_process(false)

func transition(delta):
	pass

func _physics_process(delta):
	transition(delta)
	#debug.text = name

