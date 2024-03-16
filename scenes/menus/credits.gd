extends CanvasLayer

signal back_pressed

@onready var backButton: Button = $%BackButton


func _ready():
	backButton.pressed.connect(on_back_button_pressed)
	backButton.grab_focus()


func on_back_button_pressed():
	back_pressed.emit()
