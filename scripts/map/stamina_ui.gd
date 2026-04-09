extends Control

@export var full_texture: Texture2D
@export var empty_texture: Texture2D
@export var max_stamina: int = 5

@onready var stamina_container = $StaminaContainer
var bars: Array[TextureRect] = []

func _ready():
	for child in stamina_container.get_children():
		if child is TextureRect:
			bars.append(child)
	update_stamina(0)

func update_stamina(current: int):
	for i in range(bars.size()):
		bars[i].texture = full_texture if i < current else empty_texture
