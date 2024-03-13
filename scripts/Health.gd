extends Node
class_name Health

@export var health: int = 100

func damage(amount: int):
	health -= amount
	if health <= 0:
		on_death()

func on_death():
	pass
