extends CharacterBody2D

@export var damage = 35
@onready var attackCheckTimer = $AttackCheckTimer
@onready var attackArea = $AttackArea


func _ready():
	attackCheckTimer.timeout.connect(check_for_player)

func check_for_player():
	if attackArea.has_overlapping_bodies():
		for body in attackArea.get_overlapping_bodies():
			_on_attack_area_body_entered(body)

func _on_attack_area_body_entered(body):
	var health = body.get_node_or_null("PlayerHealth")
	if health:
		health.damage(damage)
		attackCheckTimer.start()
