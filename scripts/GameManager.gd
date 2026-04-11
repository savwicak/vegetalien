extends Node2D

enum GameState {
	TUTORIAL,
	STORY,
	PLAYING,
	TREE_QUEST
}

var current_state = GameState.TUTORIAL

@export var tutorial_timeline: String = "tutorial"
@export var after_tutorial_timeline: String = "after_tutorial"
@export var after_cutscene_timeline: String = "pemukiman_open"
@export var tree_after_timeline: String = "tree_after_quest"

# ===== COUNTER TUTORIAL =====
@export var required_tutorial_done: int = 2
var tutorial_done_count: int = 0

# ===== STATE =====
var game_started := false


func _ready():
	# =========================
	# EVENTBUS CONNECT (SAFE)
	# =========================
	if EventBus:
		connect_signal_safe(EventBus.tutorial_done, _on_tutorial_done)
		connect_signal_safe(EventBus.tree_completed, _on_tree_completed)
		connect_signal_safe(EventBus.spawn_enemy_tutorial, _on_spawn_enemy_tutorial)
		connect_signal_safe(EventBus.spawn_enemy_tree, _on_spawn_enemy_tree)
		connect_signal_safe(EventBus.player_died, _on_player_died)
		connect_signal_safe(EventBus.cutscene_finished, _on_cutscene_finished)

		print("✅ GameManager terhubung ke EventBus.")

	# =========================
	# DIALOGIC CONNECT (SAFE)
	# =========================
	if Dialogic:
		connect_signal_safe(Dialogic.signal_event, _on_dialogic_signal)

	# =========================
	# FLOW BERDASARKAN STATE
	# =========================
	var scene = get_tree().current_scene

	if scene and scene.scene_file_path.ends_with("main.tscn"):
		if EventBus.after_cutscene:
			print("▶️ Masuk dari cutscene - langsung ke dialog setelah cutscene.")
			call_deferred("start_after_cutscene_dialog")
		else:
			print("▶️ Memulai tutorial pertama kali.")
			call_deferred("start_tutorial")
	else:
		print("⛔ BUKAN MAIN SCENE - TUTORIAL DI-SKIP")


# ==========================================================
# ===================== HELPER =============================
# ==========================================================
func connect_signal_safe(signal_ref, callable):
	if signal_ref and not signal_ref.is_connected(callable):
		signal_ref.connect(callable)


# ==========================================================
# ===================== TUTORIAL ===========================
# ==========================================================
func start_tutorial():
	print("📘 Memulai tutorial...")
	current_state = GameState.TUTORIAL

	if Dialogic:
		Dialogic.start(tutorial_timeline)


func _on_tutorial_done():
	tutorial_done_count += 1
	print("tutorial_done:", tutorial_done_count, "/", required_tutorial_done)

	if tutorial_done_count >= required_tutorial_done:
		if EventBus:
			EventBus.mark_tutorial_done()
		start_after_tutorial_dialog()


func start_after_tutorial_dialog():
	if current_state != GameState.TUTORIAL:
		return

	print("📖 Masuk STORY setelah tutorial...")
	current_state = GameState.STORY

	if Dialogic:
		if Dialogic.has_signal("timeline_ended"):
			if not Dialogic.timeline_ended.is_connected(_on_after_timeline_finished):
				Dialogic.timeline_ended.connect(
					_on_after_timeline_finished,
					CONNECT_ONE_SHOT
				)

		Dialogic.start(after_tutorial_timeline)
	else:
		start_game()


func _on_after_timeline_finished():
	start_game()


# ==========================================================
# ===================== CUTSCENE FLOW ======================
# ==========================================================
func _on_cutscene_finished():
	print("🎬 Cutscene selesai - siap menampilkan dialog setelah cutscene.")
	EventBus.after_cutscene = true


func start_after_cutscene_dialog():
	# Reset flag agar tidak ter-trigger lagi
	EventBus.after_cutscene = false

	current_state = GameState.STORY
	print("📖 Memulai dialog setelah cutscene...")
	Dialogic.start("pemukiman")

	if Dialogic:
		if Dialogic.has_signal("timeline_ended"):
			if not Dialogic.timeline_ended.is_connected(_on_after_cutscene_dialog_finished):
				Dialogic.timeline_ended.connect(
					_on_after_cutscene_dialog_finished,
					CONNECT_ONE_SHOT
				)

		Dialogic.start(after_cutscene_timeline)
	else:
		start_game()


func _on_after_cutscene_dialog_finished():
	start_game()


# ==========================================================
# ===================== GAME START =========================
# ==========================================================
func start_game():
	if game_started:
		return

	game_started = true
	current_state = GameState.PLAYING

	print("🎮 Game dimulai!")

	if EventBus:
		EventBus.mark_game_started()
		EventBus.emit_signal("game_started")


# ==========================================================
# ===================== TREE QUEST =========================
# ==========================================================
func _on_tree_completed():
	print("🌳 Quest pohon selesai!")
	current_state = GameState.TREE_QUEST
	start_tree_story()


func start_tree_story():
	print("📖 Mulai story pohon...")

	if Dialogic:
		Dialogic.start(tree_after_timeline)


# 🔥 Dipanggil dari Dialogic Signal Event
func start_tree_quest():
	print("🔥 MASUK QUEST POHON")
	current_state = GameState.TREE_QUEST

	if Dialogic:
		Dialogic.start("tree_intro")


# ==========================================================
# ===================== SPAWN ENEMY ========================
# ==========================================================
func _on_spawn_enemy_tutorial():
	print("👾 Spawn enemy tutorial")


func _on_spawn_enemy_tree():
	print("👾 Spawn enemy pohon")


# ==========================================================
# ===================== 💀 PLAYER MATI =====================
# ==========================================================
func _on_player_died():
	print("💀 Player mati di state:", current_state)

	match current_state:
		GameState.TUTORIAL:
			play_tutorial_death()
		GameState.TREE_QUEST:
			play_tree_death()
		GameState.PLAYING:
			play_tree_death()


func play_tutorial_death():
	if get_tree():
		get_tree().change_scene_to_file("res://scenes/cutscene/gameover.tscn")


func play_tree_death():
	if get_tree():
		get_tree().change_scene_to_file("res://scenes/cutscene/rottenTomato.tscn")


# ==========================================================
# ===================== DIALOGIC SIGNAL ====================
# ==========================================================
func _on_dialogic_signal(argument: String):
	print("📡 Signal dari Dialogic:", argument)

	if argument == "start_pemukiman_mission":
		start_tree_quest()
