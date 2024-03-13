extends Health
class_name EnemyHealth

func on_death():
	print("Killed enemy")
	get_parent().queue_free()
