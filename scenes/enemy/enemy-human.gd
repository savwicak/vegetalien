extends CharacterBody2D

@onready var target = $"../Player"

@export var speed := 100

@onready var sprite = $Sprite2D

# ===== KNOCKBACK =====
var knockback_velocity = Vector2.ZERO
@export var knockback_friction := 80

func _ready():
	add_to_group("enemies")
	
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2) # merah
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1) # balik normal
func _physics_process(delta):
	if target == null:
		return

	var direction = (target.global_position - global_position).normalized()

	# ===== CEK KNOCKBACK =====
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	# 🔥 WAJIB DI LUAR IF
	move_and_slide()

	# ===== REDUCE KNOCKBACK =====
	knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, knockback_friction * delta)


func apply_knockback(from_position: Vector2, power: float):
	print("KENA KNOCKBACK 💥")

	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power * 0.3

	flash_red() # 🔥 TAMBAH INI
