extends CharacterBody2D

var speed : float = 100.0 * 60
var direction : Vector2

@export var projectile: PackedScene

@onready var player = get_tree().root.get_node("Game").get_node("Player")
@onready var stateMachine = $FiniteStateMachine
@onready var nearAttackState = $FiniteStateMachine/NearAttack

var switchDir: bool = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if stateMachine.current_state == nearAttackState:
		direction = player.position - position
		if switchDir:
			direction *= -1
		velocity.x = direction.normalized().x * speed * delta
	else:
		velocity.x = 0.0
	move_and_slide()

func shoot_projectile():
	var proj = projectile.instantiate()
	get_tree().root.add_child(proj)
	
	var dist: Vector2 = player.position - position
	var rangeAdj = 60.0
	if dist.x < 100.0:
		rangeAdj = 20.0
	
	var dir: Vector2 = dist.normalized()
	var offset = rng.randf_range(-20.0, 20.0)
	var x = ((dist.x/-2.0) + offset - rangeAdj) * dir.x
	
	proj.linear_velocity = Vector2(x, -300.0)
	proj.global_position = global_position + Vector2(0, -50)
