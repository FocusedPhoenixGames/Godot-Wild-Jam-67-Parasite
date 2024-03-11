extends Resource
class_name MasterAnimalData

enum AnimalType{Monkey, Cat, Dog}


@export_category("Animal")
@export var type: AnimalType
@export var sprite: Texture2D
@export_range(3, 50) var health: int
@export_range(1, 10) var power: int
