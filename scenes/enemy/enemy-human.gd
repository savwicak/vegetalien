extends CharacterBody2D

@export var speed := 100
@export var stun_duration := 4.0  # Durasi freeze dalam detik

@onready var sprite: Sprite2D = $Sprite2D
@onready var target: Node2D = get_tree().get_first_node_in_group("player")

# ===== STATE =====
var is_stunned: bool = false

# ===== KNOCKBACK =====
var knockback_velocity: Vector2 = Vector2.ZERO
@export var knockback_friction := 80.0

# ===== DAMAGE AREA =====
@onready var damage_area: Area2D = get_node_or_null("DamageArea")

func _ready():
	add_to_group("enemies")

	if damage_area:
		damage_area.body_entered.connect(_on_damage_area_body_entered)
	else:
		push_error("DamageArea tidak ditemukan! Pastikan node bernama 'DamageArea' ada di dalam scene Enemy.")

# ==========================================================
# PHYSICS PROCESS
# ==========================================================
func _physics_process(delta):
	if target == null:
		return

	# Jika sedang stun, enemy berhenti bergerak
	if is_stunned:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Flip sprite berdasarkan arah gerak
	if velocity.x != 0:
		sprite.flip_h = velocity.x > 0

	var direction = (target.global_position - global_position).normalized()

	# Prioritaskan knockback
	if knockback_velocity.length() > 10:
		velocity = knockback_velocity
	else:
		velocity = direction * speed

	move_and_slide()

	# Reduksi knockback secara bertahap
	knockback_velocity = knockback_velocity.move_toward(
		Vector2.ZERO, knockback_friction * delta
	)

# ==========================================================
# DAMAGE KE PLAYER
# ==========================================================
func _on_damage_area_body_entered(body):
	if body.is_in_group("player") and body.has_method("take_damage"):
		print("Player terkena damage!")
		body.take_damage(global_position)

# ==========================================================
# DIPANGGIL SAAT TERKENA PELURU
# ==========================================================
func apply_knockback(from_position: Vector2, power: float):
	var dir = (global_position - from_position).normalized()
	knockback_velocity = dir * power * 2
	flash_red()
	stun()  # Aktifkan efek freeze

# ==========================================================
# STUN / FREEZE MECHANIC
# ==========================================================
func stun():
	if is_stunned:
		return  # Hindari reset timer jika sudah stun

	is_stunned = true
	print("Enemy terkena stun selama", stun_duration, "detik")

	# Opsional: ubah warna untuk indikasi stun
	sprite.modulate = Color(0.5, 0.7, 1.0)  # Biru menandakan freeze

	await get_tree().create_timer(stun_duration).timeout

	is_stunned = false
	sprite.modulate = Color(1, 1, 1)
	print("Enemy kembali bergerak")

# ==========================================================
# VISUAL FEEDBACK SAAT TERKENA DAMAGE
# ==========================================================
func flash_red():
	sprite.modulate = Color(1, 0.2, 0.2)
	await get_tree().create_timer(0.1).timeout

	# Jika masih stun, pertahankan warna biru
	if is_stunned:
		sprite.modulate = Color(0.5, 0.7, 1.0)
	else:
		sprite.modulate = Color(1, 1, 1)
