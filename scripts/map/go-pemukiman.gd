extends Area2D

@export var target_scene: String = "res://pemukiman.tscn"
@export var portal_name: String = "Pemukiman"

@onready var panel = $Panel
@onready var label = $Panel/Label

func _ready():
	panel.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		panel.visible = true
		label.text = "Pergi ke " + portal_name + "?"

func _on_body_exited(body):
	if body.name == "Player":
		panel.visible = false

func _on_button_yes_pressed():
	get_tree().change_scene_to_file(target_scene)

func _on_button_no_pressed():
	panel.visible = false
