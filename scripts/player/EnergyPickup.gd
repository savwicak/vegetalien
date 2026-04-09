extends Area2D

@export var stamina_amount := 1

func _ready():
	add_to_group("player")
	connect("body_entered", _on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.add_stamina(stamina_amount)
		queue_free()
