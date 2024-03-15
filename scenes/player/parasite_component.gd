extends Node
class_name ParasiteComponent

signal abilities_changed

var sprite: Sprite2D
var originalSprite: Sprite2D

var abilities = []

func _ready():
	sprite = get_parent().get_node("Sprite2D")
	originalSprite = sprite.duplicate()

func _process(delta):
	if abilities.is_empty():
		return
	
	if Input.is_action_just_pressed("exit_enemy"):
		reset()

func infect(infectable: InfectableComponent):
	var enemySprite = infectable.enemy.get_node("Sprite2D") as Sprite2D
	sprite.texture = enemySprite.texture
	sprite.scale = enemySprite.scale
	get_parent().global_position = infectable.enemy.global_position
	abilities = infectable.abilities
	abilities_changed.emit()

func reset():
	sprite.texture = originalSprite.texture
	sprite.scale = originalSprite.scale
	abilities = []
	abilities_changed.emit()
