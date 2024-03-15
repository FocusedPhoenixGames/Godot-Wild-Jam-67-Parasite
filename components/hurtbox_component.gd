extends Area2D
class_name HurtboxComponent

@export var healthComponent: Node
@export var myHitboxComponent: HitboxComponent

func _ready():
	area_entered.connect(on_area_entered)


func on_area_entered(otherArea: Area2D):
	if not otherArea is HitboxComponent:
		return
	
	if healthComponent == null:
		return
	
	var hitboxComponent = otherArea as HitboxComponent
	if hitboxComponent == myHitboxComponent:
		return
	
	healthComponent.damage(hitboxComponent.damage)
	
