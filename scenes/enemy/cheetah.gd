extends CharacterBody2D

var speed : float = 100.0 * 60
var direction : Vector2

@export var flying_enemy: bool = false

@onready var player = get_tree().root.get_node("Game").get_node("Player")
@onready var sprite = $Sprite2D
@onready var stateMachine = $FiniteStateMachine
@onready var chaseState = $FiniteStateMachine/Chase

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _process(delta):
	flip_sprite()

func _physics_process(delta):
	if not is_on_floor() and not flying_enemy:
		velocity.y += gravity * delta
	
	if stateMachine.current_state != chaseState:
		velocity.x = 0.0
	elif not flying_enemy:
		velocity.x = direction.normalized().x * speed * delta
	else:
		velocity = direction.normalized() * speed * delta
	move_and_slide()

func flip_sprite():
	if player == null:
		return
	
	else:
		direction = player.position - position
		
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
