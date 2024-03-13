extends Node
class_name HealthComponent

signal died
signal health_changed

@export var maxHealth: int = 10

var currentHealth: int


func _ready():
	currentHealth = maxHealth


func damage(damageAmount: int):
	currentHealth = clamp(currentHealth - damageAmount, 0, maxHealth)
	health_changed.emit()
	
	print(currentHealth)
	Callable(check_death).call_deferred()


func heal(healAmount: int):
	damage(-healAmount)


func check_death():
	if currentHealth == 0:
		died.emit()
		owner.queue_free()
