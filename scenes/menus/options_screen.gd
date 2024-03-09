extends CanvasLayer

signal back_pressed

@onready var windowButton: Button = $%WindowButton
@onready var backButton: Button = $%BackButton
@onready var masterSlider: HSlider = $%MasterSlider
@onready var sfxSlider: HSlider = $%SfxSlider
@onready var musicSlider: HSlider = $%MusicSlider


func _ready():
	windowButton.pressed.connect(on_window_button_pressed)
	backButton.pressed.connect(on_back_button_pressed)
	masterSlider.value_changed.connect(on_audio_slider_changed.bind("Master"))
	sfxSlider.value_changed.connect(on_audio_slider_changed.bind("sfx"))
	musicSlider.value_changed.connect(on_audio_slider_changed.bind("music"))
	masterSlider.grab_focus()
	update_display()


func update_display():
	windowButton.text = "Windowed"
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		windowButton.text = "Fullscreen"
	
	masterSlider.value = get_bus_volume_percent("Master")
	sfxSlider.value = get_bus_volume_percent("sfx")
	musicSlider.value = get_bus_volume_percent("music")


func get_bus_volume_percent(busName: String):
	var busIndex = AudioServer.get_bus_index(busName)
	var volumeDB = AudioServer.get_bus_volume_db(busIndex)
	return db_to_linear(volumeDB)


func set_bus_volume_percent(busName: String, percent: float):
	var busIndex = AudioServer.get_bus_index(busName)
	var volumeDB = linear_to_db(percent)
	AudioServer.set_bus_volume_db(busIndex, volumeDB)


func on_window_button_pressed():
	var mode = DisplayServer.window_get_mode()
	if mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	update_display()


func on_back_button_pressed():
	back_pressed.emit()


func on_audio_slider_changed(value: float, busName: String):
	set_bus_volume_percent(busName, value)
