extends Sprite2D


@onready var healthComponent: HealthComponent = $"../../HealthComponent"

func _ready():
	healthComponent.health_changed.connect(update_sprite)

func update_sprite():
	frame = 10 - healthComponent.currentHealth
