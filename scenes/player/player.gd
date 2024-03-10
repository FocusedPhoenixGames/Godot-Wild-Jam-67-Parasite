extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var resetPosition: Vector2

@onready var animation: AnimationPlayer = $AnimationPlayer


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		if animation.is_playing(): animation.stop()

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	update_animation()
	move_and_slide()


func update_animation() -> void:
	if velocity.length() == 0 && animation.is_playing():
		animation.stop()
	else:
		if velocity.x < 0: animation.play("walkLeft")
		elif velocity.x > 0: animation.play("walkRight")


func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	resetPosition = position
