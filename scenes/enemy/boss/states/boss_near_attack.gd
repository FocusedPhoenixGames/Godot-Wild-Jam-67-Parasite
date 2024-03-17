extends BossState


@onready var boss = $"../.."

func enter():
	super.enter()
	animation_player.play("closeAttack")
	boss.switchDir = false
	get_tree().create_timer(rng.randf_range(1.2, 2.0)).timeout.connect(_switch_dir)
	get_tree().create_timer(rng.randf_range(8.0, 12.0)).timeout.connect(_switch_to_idle)

func _switch_to_idle():
	boss.velocity.x = 0.0
	boss.move_and_slide()
	get_parent().change_state("Idle")

func _switch_dir():
	boss.switchDir = !boss.switchDir
	get_tree().create_timer(rng.randf_range(1.2, 2.0)).timeout.connect(_switch_dir)
