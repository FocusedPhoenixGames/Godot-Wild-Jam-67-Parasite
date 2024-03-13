extends Area2D
class_name Weapon

@onready var collisionShape = $CollisionShape2D

func _physics_process(delta):
	if Input.is_action_just_pressed("left_click"):
		use()

func use():
	pass

func _on_body_entered(body):
	pass
