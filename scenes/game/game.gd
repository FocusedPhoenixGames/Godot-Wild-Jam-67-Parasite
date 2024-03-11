extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SAVE_MANAGER = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://save_data.sav"

# MetSys refers to rooms as strings
@export var startingMap: String

var pauseScreen = preload("res://scenes/menus/pause_screen.tscn")
var generated_rooms: Array[Vector3i]


func _ready() -> void:
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)
	# Make sure MetSys is in initial state.
	# Does not matter in this project, but normally this ensures that the game works correctly when you exit to menu and start again.
	MetSys.reset_state()
	# Assign player for MetSysGame.
	set_player($Player)
	
	if FileAccess.file_exists(SAVE_PATH):
		# If save data exists, load it using MetSys SaveManager.
		var saveManager := SAVE_MANAGER.new()
		saveManager.load_from_text(SAVE_PATH)
		# Assign loaded values.
		#collectibles = saveManager.get_value("collectible_count")
		generated_rooms.assign(saveManager.get_value("generated_rooms"))
		#events.assign(saveManager.get_value("events"))
		#player.abilities.assign(saveManager.get_value("abilities"))
		
		var loadedStartingMap: String = saveManager.get_value("current_room")
		if not loadedStartingMap.is_empty(): # Some compatibility problem.
			startingMap = loadedStartingMap
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
	
	# Initialize room when it changes.
	room_loaded.connect(init_room, CONNECT_DEFERRED)
	# Load the starting room.
	load_room(startingMap)
	
	# Find the save point and teleport the player to it, to start at the save point.
	var start := map.get_node_or_null(^"SavePoint")
	if start:
		player.position = start.position
	
	# Add module for room transitions.
	add_module("RoomTransitions.gd")


func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		add_child(pauseScreen.instantiate())
		get_tree().root.set_input_as_handled()


# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game


# Save game using MetSys SaveManager.
func save_game():
	var saveManager := SAVE_MANAGER.new()
	#saveManager.set_value("collectible_count", collectibles)
	saveManager.set_value("generated_rooms", generated_rooms)
	#saveManager.set_value("events", events)
	saveManager.set_value("current_room", MetSys.get_current_room_name())
	#saveManager.set_value("abilities", player.abilities)
	saveManager.save_as_text(SAVE_PATH)


func reset_map_starting_coords():
	$UI/MarginContainer/MapWindow.reset_starting_coords()


func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	player.on_enter()
