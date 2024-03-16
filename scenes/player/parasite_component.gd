extends Node
class_name ParasiteComponent

signal abilities_changed

var sprite: Sprite2D
var animationPlayer: AnimationPlayer
var originalSprite: Sprite2D
#var originalAnimationPlayer: AnimationPlayer

var abilities = []

func _ready():
	sprite = get_parent().get_node("Sprite2D")
	originalSprite = sprite.duplicate()
	animationPlayer = get_parent().get_node("AnimationPlayer")
	#originalAnimationPlayer = animationPlayer.duplicate()

func _process(delta):
	if abilities.is_empty():
		return
	
	if Input.is_action_just_pressed("exit_enemy"):
		reset()

func infect(infectable: InfectableComponent):
	var oldEnemyPlayer = get_parent().get_node_or_null("EnemyPlayer") as AnimationPlayer
	if oldEnemyPlayer:
		print("freeed: ", oldEnemyPlayer.get_instance_id())
		oldEnemyPlayer.name = "OldEnemyPlayer"
		oldEnemyPlayer.queue_free()
	
	#await get_tree().create_timer(1.0).timeout
	
	var enemySprite = infectable.enemy.get_node("Sprite2D").duplicate() as Sprite2D
	sprite.texture = enemySprite.texture
	sprite.scale = enemySprite.scale
	sprite.get_rect().size = enemySprite.get_rect().size
	sprite.hframes = enemySprite.hframes
	sprite.vframes = enemySprite.vframes
	sprite.frame = enemySprite.frame
	
	var enemyPlayer = infectable.enemy.get_node("AnimationPlayer").duplicate() as AnimationPlayer
	enemyPlayer.name = "EnemyPlayer"
	#enemyPlayer.root_node = get_parent()
	
	get_parent().add_child(enemyPlayer)
	
	print("new: ", enemyPlayer.name)
	
	#var oldAnimPlayer = get_parent().get_node("AnimationPlayer") as AnimationPlayer
	if animationPlayer.is_playing():
		animationPlayer.stop()
	
	#enemyPlayer.root_node = get_parent().get_node("Sprite2D")
	
	#var enemyPlayer = infectable.enemy.get_node("AnimationPlayer") as AnimationPlayer
	#animationPlayer.current_animation = enemyPlayer.current_animation
	
	get_parent().global_position = infectable.enemy.global_position
	abilities = infectable.abilities
	abilities_changed.emit()

func reset():
	sprite.texture = originalSprite.texture
	sprite.scale = originalSprite.scale
	sprite.get_rect().size = originalSprite.get_rect().size
	sprite.hframes = originalSprite.hframes
	sprite.vframes = originalSprite.vframes
	sprite.frame = originalSprite.frame
	#animationPlayer = originalAnimationPlayer
	
	var oldEnemyPlayer = get_parent().get_node("EnemyPlayer")
	if oldEnemyPlayer:
		oldEnemyPlayer.queue_free()
	
	abilities = []
	abilities_changed.emit()
