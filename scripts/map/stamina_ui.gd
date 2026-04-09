extends Control

@export var max_stamina := 5
@export var full_texture: Texture2D
@export var empty_texture: Texture2D

@onready var stamina_container = $StaminaContainer
var bars: Array[TextureRect] = []

func _ready():
	# Ambil semua bar dari container
	for child in stamina_container.get_children():
		if child is TextureRect:
			bars.append(child)
	
	update_stamina(0)

func update_stamina(current_stamina: int):
	for i in range(bars.size()):
		if i < current_stamina:
			bars[i].texture = full_texture
		else:
			bars[i].texture = empty_texture
