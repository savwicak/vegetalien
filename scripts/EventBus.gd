extends Node

# =========================
# SIGNALS
# =========================
signal tutorial_done
signal enemy_died
signal game_started

signal spawn_enemy_tutorial
signal spawn_enemy_tree
signal diamonds_collected
signal tree_completed

signal player_died
signal show_elephant_marker

# 🔥 SIGNAL BARU (CUTSCENE FLOW CONTROLLER)
signal cutscene_finished

# =========================
# GAME STATE MEMORY
# =========================
var after_cutscene: bool = false
var tutorial_completed: bool = false
var game_started_flag: bool = false

# =========================
# HELPERS
# =========================
func mark_cutscene_done():
	after_cutscene = true
	emit_signal("cutscene_finished")


func mark_tutorial_done():
	tutorial_completed = true


func mark_game_started():
	game_started_flag = true
