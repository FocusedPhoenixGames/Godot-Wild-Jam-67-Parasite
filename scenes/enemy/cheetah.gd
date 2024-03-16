extends CharacterBody2D

var speed : float = 100
var direction : Vector2

@onready var player = get_tree().root.get_node("Game").get_node("Player")
@onready var sprite = $Sprite2D


func _ready():
	set_physics_process(false)

func _process(delta):
	flip_sprite()

func _physics_process(delta):
	velocity = direction.normalized() * speed
	move_and_collide(velocity * delta)

func flip_sprite():
	if player == null:
		return
	
	else:
		direction = player.position - position
		
		if direction.x < 0:
			sprite.flip_h = false
		else:
			sprite.flip_h = true
