extends CharacterBody2D
class_name Player

enum Ability { WALL_JUMP, CLIMBING, DASH }
enum State { NORMAL, JUMPING, CLIMBING, WALL_JUMPING, WALL_JUMP_DECLINE }

#region Variables
@export var speed: float = 140.0 * 60 # Physic Updates
@export var climbSpeed: float = 80.0
@export var jumpVelocity: float = -250.0 -15.625
@export var jumpBufferTime: float = 0.1

@export var wallJumpCooldown: float = 0.2
@export var attackCooldown: float = 0.2

@export var fallMultiplier: float = 0.4
@export var lowJumpMultiplier: float = 0.5

# Whether jumping off a wall without climbing pushes the player away from wall
@export var wallJumpsPushAway: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var coyoteTimer: Timer = $Timers/CoyoteTimer
@onready var wallCoyoteTimer: Timer = $Timers/WallCoyoteTimer
@onready var wallJumpTimer: Timer = $Timers/WallJumpTimer
@onready var wallJumpPauseTimer: Timer = $Timers/WallJumpPauseTimer
@onready var wallJumpDeclineTimer: Timer = $Timers/WallJumpDeclineTimer
@onready var ghostTimer: Timer = $Timers/DashTrailTimer
@onready var damageIntervalTimer: Timer = $Timers/DamageIntervalTimer
@onready var attackTimer: Timer = $Timers/AttackTimer
@onready var groundDetector: Area2D = $GroundDetector
@onready var wallDetectorRight: Area2D = $WallDetectors/WallDetectorRight
@onready var wallDetectorLeft: Area2D = $WallDetectors/WallDetectorLeft
@onready var bottomRightCast: RayCast2D = $NudgeCasts/BottomRightCast
@onready var topRightCast: RayCast2D = $NudgeCasts/TopRightCast
@onready var bottomLeftCast: RayCast2D = $NudgeCasts/BottomLeftCast
@onready var topLeftCast: RayCast2D = $NudgeCasts/TopLeftCast
@onready var healthComponent: HealthComponent = $HealthComponent
@onready var hitboxComponent: HitboxComponent = $HitboxComponent
@onready var hurtboxComponent: HurtboxComponent = $HurtboxComponent
@onready var parasiteComponent: ParasiteComponent = $ParasiteComponent
@onready var animation: AnimationPlayer = $AnimationPlayer

var jumpBuffered: bool = false
var jumpStartTime: float = 0.0
var facingDir = 1
var wallDir = 0
var wallJumpDir = 0
var coyoteWallDir = 0

var dashBuffered: bool = false
var dashAvailable: bool = false
var isDashing: bool = false
var dashStartTime: float = 0.0
var dashDir: Vector2 = Vector2.ZERO
var dashDistance: float = 5000.0
var attackAvailable: bool = true

var isTouchingWall: bool = false
var isGrabbingWall: bool = false
var isOnFloor: bool = false
var wasOnFloor: bool = false
var isOnWall: bool = false
var wasOnWall: bool = false
var isAttachedToWall: bool = true

var state = State.NORMAL
var abilities = []

var ghost_scene = preload("res://scenes/player/dash_trail.tscn")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var resetPosition: Vector2
#endregion

func _ready():
	wallJumpPauseTimer.timeout.connect(active_wall_jump_decline)
	wallJumpDeclineTimer.timeout.connect(switch_to_normal_state)
	ghostTimer.timeout.connect(on_ghost_timer_timeout)
	damageIntervalTimer.timeout.connect(on_damage_interval_timer_timeout)
	healthComponent.health_changed.connect(on_health_changed)
	attackTimer.timeout.connect(reset_attack)
	parasiteComponent.abilities_changed.connect(update_abilities)

func _physics_process(delta):
	state = get_updated_state()
	#print(state)
	
	match state:
		State.NORMAL,State.WALL_JUMPING,State.WALL_JUMP_DECLINE,State.JUMPING:
			normal_state(delta)
		State.CLIMBING:
			climbing_state(delta)

#region States and Abilities
func is_near_wall() -> bool:
	if facingDir == 1:
		if wallDetectorRight.has_overlapping_bodies():
			wallDir = 1
			return true
	else:
		if wallDetectorLeft.has_overlapping_bodies():
			wallDir = -1
			return true
	wallDir = 0
	return false

func get_updated_state():
	isOnWall = is_near_wall()
	
	if state == State.WALL_JUMPING || state == State.WALL_JUMP_DECLINE:
		return state
	
	if abilities.has(Ability.CLIMBING):
		if isOnWall and Input.is_action_pressed("climb"):
			return State.CLIMBING
	
	if state == State.JUMPING:
		return state
	
	return State.NORMAL

func normal_state(delta):
	apply_gravity(delta)
	isOnFloor = is_on_floor() || groundDetector.has_overlapping_bodies()
	if isOnFloor and state == State.JUMPING:
		state = State.NORMAL
	
	wasOnFloor = isOnFloor
	wasOnWall = isOnWall
	handle_attack()
	handle_buffers()
	handle_jump(delta)
	handle_movement(delta)
	handle_dash(delta)
	update_sprite()
	
	extra_gravity(delta)
	nudge_onto_edge()
	move_and_slide()
	update_coyote_data()

func climbing_state(delta):
	attach_to_wall()
	handle_wall_jump()
	handle_wall_movement(delta)
	nudge_onto_edge()
	move_and_slide()

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

func extra_gravity(delta):
	var currentTime = Time.get_ticks_msec()
	var timeSinceJump = (currentTime - jumpStartTime) / 1000.0
	
	if velocity.y > 0 and state == State.WALL_JUMP_DECLINE: # If player is falling, apply more gravity
		velocity.y += gravity * (fallMultiplier) * delta
		
	elif velocity.y > 0: # If player is falling, apply more gravity
		velocity.y += gravity * fallMultiplier * delta
		
	elif velocity.y < 0 && !Input.is_action_pressed("jump"): # If player did small jump, apply more gravity
		if timeSinceJump < 0.2:
			var multiplier = (1 - timeSinceJump) * 3 # Longer jump = more gravity
			velocity.y += gravity * (lowJumpMultiplier * multiplier) * delta

func handle_buffers():
	if isOnFloor or (state == State.CLIMBING and isOnWall):
		if jumpBuffered:
			jump()
	if isOnFloor:
		if dashBuffered:
			dash()

func handle_dash(delta):
	if isDashing:
		var currentTime = Time.get_ticks_msec()
		var dashElapTime = (currentTime - dashStartTime) / 1000.0
		
		if dashElapTime < 0.15:
			var vel = dashDir.normalized() * Vector2(dashDistance, dashDistance / 1.8)
			vel /= 10
			velocity = vel
		else:
			isDashing = false
			ghostTimer.stop()
		return
	
	if isOnFloor:
		dashAvailable = true
	
	if abilities.has(Ability.DASH) and Input.is_action_just_pressed("dash"):
		if dashAvailable:
			dash()
		else:
			dashBuffered = true
			get_tree().create_timer(jumpBufferTime).timeout.connect(reset_dash_buffer)

func dash():
	ghostTimer.start()
	instance_ghost()
	dashDir = Vector2(Input.get_axis("move_left", "move_right"),Input.get_axis("move_up", "move_down"))
	dashAvailable = false
	isDashing = true
	dashStartTime = Time.get_ticks_msec()

func instance_ghost():
	var ghost: Sprite2D = ghost_scene.instantiate()
	get_tree().root.add_child(ghost)
	
	#ghost.position = sprite.position
	ghost.global_position = global_position + sprite.position
	ghost.texture = sprite.texture
	ghost.flip_h = sprite.flip_h
	ghost.scale = sprite.scale
	ghost.hframes = sprite.hframes
	ghost.vframes = sprite.vframes
	ghost.frame = sprite.frame

# Ran multiple times throughout dash
func on_ghost_timer_timeout():
	instance_ghost()

func reset_dash_buffer():
	dashBuffered = false

# Jumps if on ground or has coyote time
# Wall jumps if on wall or has coyote time
# Starts jump buffer if neither apply

# Buffer will jump automatically if player touches ground soon after
func handle_jump(delta):
	if Input.is_action_just_pressed("jump"):
		if isOnFloor or coyoteTimer.time_left > 0.0:
			jump()
			return
		
		if abilities.has(Ability.WALL_JUMP) and wallJumpTimer.time_left == 0.0:
			if wallJumpsPushAway:
				if isOnWall:
					wallJumpDir = -wallDir
					facingDir = wallJumpDir
					velocity.x = facingDir * speed * delta
					state = State.WALL_JUMPING
					wallJumpPauseTimer.start()
					wall_bounce_jump()
					return
				elif wallCoyoteTimer.time_left > 0.0:
					wallJumpDir = -coyoteWallDir
					facingDir = wallJumpDir
					velocity.x = facingDir * speed * delta
					state = State.WALL_JUMPING
					wallJumpPauseTimer.start()
					wall_bounce_jump()
					return
			else:
				attach_to_wall()
				wall_jump()
				return
		
		jumpBuffered = true
		get_tree().create_timer(jumpBufferTime).timeout.connect(reset_jump_buffer)

func active_wall_jump_decline():
	state = State.WALL_JUMP_DECLINE
	wallJumpDeclineTimer.start()

func switch_to_normal_state():
	state = State.NORMAL

func jump():
	state = State.JUMPING
	play_animation("jump")
	jumpStartTime = Time.get_ticks_msec()
	velocity.y = jumpVelocity

func wall_jump():
	if wallJumpTimer.time_left == 0.0:
		wallJumpTimer.wait_time = wallJumpCooldown
		wallJumpTimer.start()
		jump()

func wall_bounce_jump():
	if wallJumpTimer.time_left == 0.0:
		wallJumpTimer.wait_time = wallJumpCooldown
		wallJumpTimer.start()
		
		jumpStartTime = Time.get_ticks_msec()
		velocity.y = jumpVelocity

func handle_wall_jump():
	if Input.is_action_just_pressed("jump"):
		wall_jump()

func reset_jump_buffer():
	jumpBuffered = false
#endregion

func update_sprite():
	if facingDir == 1:
		sprite.flip_h = false
	else:
		sprite.flip_h = true

func handle_movement(delta):
	var hor_dir = Input.get_axis("move_left", "move_right")
	
	# Stop movement going back towards wall
	if state == State.WALL_JUMPING and hor_dir != wallJumpDir:
		return
	
	if hor_dir:
		if state != State.WALL_JUMP_DECLINE:
			velocity.x = hor_dir * speed * delta
		else:
			# Limit movement while State.WALL_JUMP_DECLINE
			velocity.x = velocity.lerp(Vector2(hor_dir * speed * delta, velocity.y), 0.1).x
		
		facingDir = hor_dir
		if state != State.JUMPING:
			play_animation("walk")
	else:
		if state != State.JUMPING:
			play_animation("idle")
		
		if state == State.WALL_JUMPING and hor_dir != wallJumpDir:
			return
		
		# Slows down player, only noticable when additional forces are applied
		velocity.x = move_toward(velocity.x, 0, speed * delta)

func handle_wall_movement(delta):
	if wallJumpTimer.time_left > 0.0:
		return
	
	var ver_dir = Input.get_axis("move_up", "move_down")
	if ver_dir:
		play_animation("walk")
		velocity.y = ver_dir * speed * delta
	else:
		play_animation("idle")
		# Slows down player, only relevant when additional forces are applied
		velocity.y = move_toward(velocity.y, 0, speed * delta)

func update_coyote_data():
	# Check if just left floor after move_and_slide()
	var oldWallDir = wallDir
	if wasOnFloor and not is_on_floor() and velocity.y >= 0:
		coyoteTimer.start()
	if wasOnWall and not is_near_wall() and velocity.y >= 0:
		wallCoyoteTimer.start()
		coyoteWallDir = oldWallDir

func nudge_onto_edge():
	if velocity.y > 0.0:
		return
	
	var collision_count = get_slide_collision_count()
	if collision_count < 1:
		return
	
	var collision = get_slide_collision(collision_count - 1)
	if not collision:
		return
	
	var dir = collision.get_normal() * -1
	if dir == Vector2(1, 0):
		if bottomRightCast.is_colliding() and not topRightCast.is_colliding():
			var yDist = topRightCast.global_position.y - bottomRightCast.global_position.y
			global_position += Vector2(1, yDist)
	elif dir == Vector2(-1, 0):
		pass
		if bottomLeftCast.is_colliding() and not topLeftCast.is_colliding():
			var yDist = topLeftCast.global_position.y - bottomLeftCast.global_position.y
			global_position += Vector2(-1, yDist)

func attach_to_wall():
	isAttachedToWall = is_on_wall()
	if not isAttachedToWall:
		velocity.x = facingDir * speed
	else:
		velocity.x = 0

func on_enter():
	# Position for kill system. Assigned when entering new room (see Game.gd).
	resetPosition = position

func _on_spike_entered(body):
	print("Spike kill player")

#region Damage
func on_health_changed() -> void:
	# player takes no damage if damageIntervalTimer is running
	if !hurtboxComponent.has_overlapping_areas() || !damageIntervalTimer.is_stopped():
		return
	
	damageIntervalTimer.start()

func on_damage_interval_timer_timeout() -> void:
	on_health_changed()
#endregion

func handle_attack():
	if Input.is_action_just_pressed("left_click"):
		if attackAvailable:
			var shape = hitboxComponent.get_node("CollisionShape2D")
			shape.global_position.x = global_position.x + ((shape.shape.size.x / 2) * facingDir)
			shape.disabled = false
			attackAvailable = false
			get_tree().create_timer(0.1).timeout.connect(reset_attack_shape)
			attackTimer.start()

func reset_attack_shape():
	var shape = hitboxComponent.get_node("CollisionShape2D")
	shape.disabled = true

func reset_attack():
	attackAvailable = true

func update_abilities():
	abilities = parasiteComponent.abilities

func play_animation(animName: String):
	var animPlayer = animation
	var enemyPlayer = get_node_or_null("EnemyPlayer")
	if enemyPlayer:
		animPlayer = enemyPlayer
	
	animPlayer.play(animName)
