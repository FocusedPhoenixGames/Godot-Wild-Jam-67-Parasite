extends Node
class_name HealthComponent

signal died
signal health_changed

@export var maxHealth: int = 10
@onready var deathParticles: PackedScene = preload("res://scenes/particles/death_particles.tscn")

var currentHealth: int
var dead: bool = false


func _ready():
	currentHealth = maxHealth


func damage(damageAmount: int):
	currentHealth = clamp(currentHealth - damageAmount, 0, maxHealth)
	health_changed.emit()
	
	Callable(check_death).call_deferred()


func heal(healAmount: int):
	damage(-healAmount)


func check_death():
	if currentHealth == 0:
		dead = true
		died.emit()
		if owner is Player:
			#owner.queue_free()
			#get_tree().change_scene_to_file("res://scenes/menus/title_screen.tscn")
			pass
		else:
			var particles = deathParticles.instantiate()
			get_tree().root.add_child(particles)
			particles.global_position = owner.global_position
			particles.emitting = true
			particles.finished.connect(queue_free)
			owner.queue_free()
