extends Weapon

@onready var attackDelay = $AttackDelay

#func _ready():
	#collisionShape.disabled = false

func _physics_process(delta):
	super._physics_process(delta)
	for body in get_overlapping_bodies():
		print("hit")

func use():
	if attackDelay.time_left == 0.0:
		print("attack")
		#collisionShape.disabled = false
		attackDelay.start()
		get_tree().create_timer(0.2).timeout.connect(reset_attack_area)

#func _on_body_entered(body):
	#print("hit")

func reset_attack_area():
	print("stop")
	#collisionShape.disabled = true
