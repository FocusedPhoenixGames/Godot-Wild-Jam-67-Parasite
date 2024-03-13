extends Area2D
class_name HurtboxComponent

@export var healthComponent: Node


func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(otherArea: Area2D):
	if not otherArea is HitboxComponent:
		return
	
	if healthComponent == null:
		return
	
	var hitboxComponent = otherArea as HitboxComponent
	healthComponent.damage(hitboxComponent.damage)
	
