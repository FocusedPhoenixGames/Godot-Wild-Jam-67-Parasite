extends Health
class_name PlayerHealth

@export var invincibility_time = 1.0
var last_hit_time


func damage(amount: int):
	if last_hit_time:
		var currentTime = Time.get_ticks_msec()
		var elapsed = (currentTime - last_hit_time) / 1000
		if elapsed < invincibility_time:
			return
	print("damage: ", amount)
	last_hit_time = Time.get_ticks_msec()
	super.damage(amount)

func on_death():
	print("Player died")
