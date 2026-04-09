extends Area2D

@export var speed := 600
var direction := Vector2.ZERO

func _process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.apply_knockback(global_position, 60)
		queue_free()

	if body.is_in_group("border"):
		queue_free()
