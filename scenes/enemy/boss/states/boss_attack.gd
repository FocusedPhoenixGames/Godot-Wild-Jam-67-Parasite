extends BossState


@onready var boss = $"../.."

func enter():
	super.enter()
	var dist: Vector2 = boss.global_position - player.global_position
	
	if rng.randi_range(1, 4) == 1:
		get_parent().change_state("RangedAttack")
		return
	
	if dist.length() > 250.0:
		get_parent().change_state("RangedAttack")
	else:
		get_parent().change_state("NearAttack")
