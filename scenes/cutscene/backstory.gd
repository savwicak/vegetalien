extends Control

@onready var video = $VideoStreamPlayer

func _ready():
	video.finished.connect(_on_video_finished)
	video.play()

func _on_video_finished():
	go_to_main()

func _on_button_pressed():
	go_to_main()

func go_to_main():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
