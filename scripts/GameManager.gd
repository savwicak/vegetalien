extends Node2D

enum GameState {
	TUTORIAL,
	STORY,
	PLAYING
}

var current_state = GameState.TUTORIAL

@export var tutorial_timeline: String = "tutorial"
@export var after_tutorial_timeline: String = "after_tutorial"

# ===== COUNTER SIGNAL =====
@export var required_tutorial_done: int = 2  # Jumlah signal yang dibutuhkan
var tutorial_done_count: int = 0             # Counter saat ini

func _ready():
	# Hubungkan signal dari EventBus
	if EventBus and not EventBus.tutorial_done.is_connected(_on_tutorial_done):
		EventBus.tutorial_done.connect(_on_tutorial_done)
		print("GameManager terhubung ke EventBus.")

	# Mulai tutorial hanya jika berada di scene main
	if get_tree().current_scene and \
		get_tree().current_scene.scene_file_path.ends_with("main.tscn"):
		start_tutorial()

func start_tutorial():
	print("Memulai tutorial...")
	current_state = GameState.TUTORIAL
	if Dialogic:
		Dialogic.start(tutorial_timeline)
	else:
		push_warning("Dialogic tidak ditemukan!")

# ===== MENERIMA SIGNAL =====
func _on_tutorial_done():
	tutorial_done_count += 1
	print("tutorial_done diterima:", tutorial_done_count, "/", required_tutorial_done)

	# Jalankan dialog hanya jika jumlah signal sudah mencukupi
	if tutorial_done_count >= required_tutorial_done:
		start_after_tutorial_dialog()

func start_after_tutorial_dialog():
	# Hindari pemanggilan berulang
	if current_state != GameState.TUTORIAL:
		return

	print("Semua syarat terpenuhi! Memulai dialog lanjutan...")
	current_state = GameState.STORY

	if Dialogic:
		Dialogic.start(after_tutorial_timeline)

		# Tunggu sampai dialog selesai sebelum masuk ke state PLAYING
		if Dialogic.has_signal("timeline_ended") and \
			not Dialogic.timeline_ended.is_connected(_on_after_timeline_finished):
			Dialogic.timeline_ended.connect(_on_after_timeline_finished)
	else:
		push_warning("Dialogic tidak ditemukan!")
		start_game()

func _on_after_timeline_finished():
	if Dialogic.timeline_ended.is_connected(_on_after_timeline_finished):
		Dialogic.timeline_ended.disconnect(_on_after_timeline_finished)

	current_state = GameState.PLAYING
	start_game()

func start_game():
	print("Game dimulai! Enemy sekarang bisa aktif.")
