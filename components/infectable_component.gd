extends Node
class_name InfectableComponent

@export var enemy: Node
@export var healthPercentage = 33.4

@onready var button: Button = $Button
@onready var outlineMaterialRes: ShaderMaterial = preload("res://assets/shaders/outline.tres")

var healthComponent: HealthComponent
var interactSprite: Sprite2D

var hovered = false

func _ready():
	healthComponent = enemy.get_node("HealthComponent")
	healthComponent.connect("health_changed", on_health_changed)
	
	var sprite = enemy.get_node("Sprite2D")
	button.size = sprite.get_rect().size * sprite.scale
	button.global_position = sprite.global_position - button.size / 2
	interactSprite = button.get_node("Sprite2D")
	interactSprite.global_position = sprite.global_position
	
	button.mouse_entered.connect(on_enter_hover)
	button.mouse_exited.connect(on_exit_hover)

func _process(delta):
	if not hovered:
		return
	
	if Input.is_action_just_pressed("interact"):
		print("take control")

func on_health_changed():
	var currentPercent = healthComponent.currentHealth as float / healthComponent.maxHealth
	if currentPercent <= healthPercentage / 100.0:
		button.disabled = false
		button.visible = true
	else:
		button.disabled = true
		button.visible = false

func on_enter_hover():
	hovered = true
	interactSprite.visible = true

func on_exit_hover():
	hovered = false
	interactSprite.visible = false
