extends Node
class_name ParasiteComponent

signal abilities_changed

const Ability = preload("res://scripts/ability_constants.gd").Ability

var sprite: Sprite2D
var animationPlayer: AnimationPlayer
var originalSprite: Sprite2D

@onready var abilityTooltip: RichTextLabel = $"../CanvasLayer/AbilityTooltip"

var abilities = []

func _ready():
	sprite = get_parent().get_node("Sprite2D")
	originalSprite = sprite.duplicate()
	animationPlayer = get_parent().get_node("AnimationPlayer")

func _process(delta):
	if abilities.is_empty():
		return
	
	if Input.is_action_just_pressed("exit_enemy"):
		reset()

func infect(infectable: InfectableComponent):
	var oldEnemyPlayer = get_parent().get_node_or_null("EnemyPlayer") as AnimationPlayer
	if oldEnemyPlayer:
		oldEnemyPlayer.name = "OldEnemyPlayer" # Frees the name while we wait for queue_free()
		oldEnemyPlayer.queue_free()
	
	var enemySprite = infectable.enemy.get_node("Sprite2D").duplicate() as Sprite2D
	if infectable.infectedTexture:
		sprite.texture = infectable.infectedTexture
	else:
		sprite.texture = enemySprite.texture
	sprite.scale = enemySprite.scale
	sprite.get_rect().size = enemySprite.get_rect().size
	sprite.hframes = enemySprite.hframes
	sprite.vframes = enemySprite.vframes
	sprite.frame = enemySprite.frame
	sprite.position.y += infectable.spriteOffsetY
	
	var enemyPlayer = infectable.enemy.get_node("AnimationPlayer").duplicate() as AnimationPlayer
	enemyPlayer.name = "EnemyPlayer"
	
	get_parent().add_child(enemyPlayer)
	
	if animationPlayer.is_playing():
		animationPlayer.stop()
	
	get_parent().global_position = infectable.enemy.global_position
	abilities = infectable.abilities
	abilities_changed.emit()
	show_ability_tooltip()

func reset():
	sprite.texture = originalSprite.texture
	sprite.scale = originalSprite.scale
	sprite.get_rect().size = originalSprite.get_rect().size
	sprite.hframes = originalSprite.hframes
	sprite.vframes = originalSprite.vframes
	sprite.frame = originalSprite.frame
	sprite.position.y = originalSprite.position.y
	
	var oldEnemyPlayer = get_parent().get_node("EnemyPlayer")
	if oldEnemyPlayer:
		oldEnemyPlayer.queue_free()
	
	abilities = []
	abilities_changed.emit()

func show_ability_tooltip():
	if abilities.has(Ability.DASH):
		abilityTooltip.text = "Press 'Shift' to dash"
	elif abilities.has(Ability.CLIMBING):
		abilityTooltip.text = "Hold 'L' to climb walls"
	else:
		return
	abilityTooltip.visible = true
	await get_tree().create_timer(5).timeout
	abilityTooltip.visible = false
