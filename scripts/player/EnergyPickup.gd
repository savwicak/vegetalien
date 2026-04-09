extends Area2D

@export var stamina_amount: int = 1

func _ready():
	add_to_group("energy")
	z_index = 100
	print("Energy muncul di:", global_position)
	
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("add_stamina"):
		body.add_stamina(stamina_amount)
		queue_free()
