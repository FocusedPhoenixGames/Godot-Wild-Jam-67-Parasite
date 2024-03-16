extends Area2D
class_name HitboxComponent

@export var damage: int = 1
@export var cooldown: float = 0.0

@onready var collisionShape: CollisionShape2D = $CollisionShape2D

func start_attack_cooldown():
	if cooldown > 0.0:
		call_deferred("disable_collider")

func disable_collider():
	collisionShape.disabled = true
	get_tree().create_timer(cooldown).timeout.connect(reset_collider)

func reset_collider():
	collisionShape.disabled = false
	for area in get_overlapping_areas():
		if area is HurtboxComponent:
			var hurtbox = area as HurtboxComponent
			hurtbox.on_area_entered(self)
