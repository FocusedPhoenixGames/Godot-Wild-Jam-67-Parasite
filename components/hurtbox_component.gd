extends Area2D
class_name HurtboxComponent

@export var healthComponent: Node
@export var myHitboxComponent: HitboxComponent
@export var sprite: Sprite2D

@onready var whiteMaterialRes: ShaderMaterial = preload("res://assets/shaders/damage_flash_material.tres")
var whitenMaterial: ShaderMaterial
var shaderTween: Tween

func _ready():
	area_entered.connect(on_area_entered)
	if sprite != null:
		sprite.material = whiteMaterialRes.duplicate()
		whitenMaterial = sprite.material as ShaderMaterial

func on_area_entered(otherArea: Area2D):
	if not otherArea is HitboxComponent:
		return
	
	if healthComponent == null:
		return
	
	var hitboxComponent = otherArea as HitboxComponent
	if hitboxComponent.get_parent() == get_parent():
		return
	
	if hitboxComponent.isEnemy and myHitboxComponent.isEnemy:
		return
	
	if healthComponent.dead:
		return
	
	healthComponent.damage(hitboxComponent.damage)
	hitboxComponent.start_attack_cooldown()
	damage_flash()

func damage_flash():
	#if whitenMaterial == null:
		#return
	whitenMaterial = sprite.material #return hacky way to fix issue on boss for rn
	
	whitenMaterial.set_shader_parameter("whiten", 0.8)
	
	if shaderTween != null:
		shaderTween.kill()
	shaderTween = get_tree().create_tween()
	shaderTween.tween_property(whitenMaterial, "shader_parameter/whiten", 0.0, 0.3)
