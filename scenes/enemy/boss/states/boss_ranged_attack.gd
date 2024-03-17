extends BossState


@onready var boss = $"../.."

func enter():
	super.enter()
	animation_player.play("rangedAttack")
	fire_projectiles()
	get_tree().create_timer(rng.randf_range(4.0, 6.0)).timeout.connect(_switch_to_idle)

func _switch_to_idle():
	get_parent().change_state("Idle")

func fire_projectiles():
	await get_tree().create_timer(0.8).timeout
	boss.shoot_projectile()
	await get_tree().create_timer(0.4).timeout
	boss.shoot_projectile()
	
	await get_tree().create_timer(0.4).timeout
	boss.shoot_projectile()
	await get_tree().create_timer(0.4).timeout
	boss.shoot_projectile()
	
	await get_tree().create_timer(0.4).timeout
	boss.shoot_projectile()
	await get_tree().create_timer(0.4).timeout
	boss.shoot_projectile()
