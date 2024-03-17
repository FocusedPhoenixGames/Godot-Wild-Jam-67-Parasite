extends Node2D

@export var doorsLocked: bool = false
@export var tile: int = 0
@export var tilemap: TileMap

@onready var doors = $Doors.get_children()


func _ready():
	var area2D = $Area2D as Area2D
	if not doorsLocked:
		area2D.body_entered.connect(_on_room_entered)
	else:
		lock_doors()

func _on_room_entered(body):
	lock_doors()

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
