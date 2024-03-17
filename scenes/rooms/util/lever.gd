extends Area2D

@export var pulled: bool = false
@export var oneTimeOnly: bool = true
@export var tile: int = 0
@export var tilemap: TileMap

@onready var button: Button = $Button
@onready var sprite: Sprite2D = $Button/Sprite2D
@onready var leverSprite: Sprite2D = $Sprite2D
@onready var player = get_tree().root.get_node("Game").get_node("Player")
@onready var doors = $"../Doors".get_children()

var hovered = false
var hasPlayer = false
var usedOneTimeOnly = false

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_entered)
	button.mouse_entered.connect(on_enter_hover)
	button.mouse_exited.connect(on_exit_hover)
	if !pulled:
		lock_doors()
	else:
		leverSprite.frame = 1

func _process(_delta):
	handle_input()

func on_enter_hover():
	hovered = true
	
	if !hasPlayer:
		return
	
	sprite.visible = true

func on_exit_hover():
	hovered = false
	sprite.visible = false

func _on_body_entered(body):
	hasPlayer = get_overlapping_bodies().has(player)
	if hovered and hasPlayer:
		sprite.visible = true
	else:
		sprite.visible = false

func handle_input():
	if Input.is_action_just_pressed("interact"):
		if sprite.visible:
			if pulled and not usedOneTimeOnly:
				pulled = false
				leverSprite.frame = 0
				lock_doors()
			else:
				pulled = true
				leverSprite.frame = 1
				open_doors()
				
				if oneTimeOnly:
					usedOneTimeOnly = true

func fill_collision_shape(shape: CollisionShape2D, erase: bool):
	var rect = shape.shape.get_rect()
	var startPos = tilemap.local_to_map(shape.global_position + rect.position)
	var endPos = tilemap.local_to_map(shape.global_position + rect.end)
	
	for x in range(startPos.x, endPos.x + 1):
		for y in range(startPos.y, endPos.y + 1):
			var tilePos = Vector2i(x,y)
			if erase:
				tilemap.erase_cell(0, tilePos)
			else:
				tilemap.set_cells_terrain_connect(0, [tilePos], 0, 0)

func open_doors():
	for door in doors:
		fill_collision_shape(door as CollisionShape2D, true)

func lock_doors():
	for door in doors:
		fill_collision_shape(door as CollisionShape2D, false)
