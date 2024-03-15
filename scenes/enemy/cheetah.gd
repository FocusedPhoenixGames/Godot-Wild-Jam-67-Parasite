extends CharacterBody2D

var speed : float = 100
var direction : Vector2

@onready var player = get_parent().find_child("player")
@onready var sprite = $Sprite2D


func _ready():
	set_physics_process(false)

func _process(delta):
	direction = player.position - position
	
	if direction.x < 0:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func _physics_process(delta):
	velocity = direction.normalized() * speed
	move_and_collide(velocity * delta)
