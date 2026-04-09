extends Node2D

# Scene energy yang akan di-spawn
@export var energy_scene: PackedScene

# Area spawn
@export var spawn_area: Rect2 = Rect2(Vector2(-500, -500), Vector2(1000, 1000))

# Waktu spawn
@export var spawn_interval: float = 5.0
@export var max_energy: int = 10

# Layer yang dianggap sebagai obstacle (sesuaikan dengan collision layer di map)
@export var obstacle_collision_mask: int = 1

# Radius untuk pengecekan tabrakan
@export var check_radius: float = 16.0

var rng = RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	spawn_loop()

func spawn_loop():
	while true:
		await get_tree().create_timer(spawn_interval).timeout
		
		if get_tree().get_nodes_in_group("energy").size() < max_energy:
			spawn_energy()

func spawn_energy():
	var max_attempts := 10
	var position: Vector2
	
	for i in range(max_attempts):
		position = get_random_position()
		if is_position_free(position):
			create_energy(position)
			return
	
	print("Gagal menemukan posisi spawn yang valid.")

func get_random_position() -> Vector2:
	var x = rng.randf_range(spawn_area.position.x, spawn_area.end.x)
	var y = rng.randf_range(spawn_area.position.y, spawn_area.end.y)
	return Vector2(x, y)

func is_position_free(pos: Vector2) -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var shape = CircleShape2D.new()
	shape.radius = check_radius
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = obstacle_collision_mask
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_shape(query, 1)
	return result.is_empty()

func create_energy(pos: Vector2):
	var energy = energy_scene.instantiate()
	energy.global_position = pos
	get_tree().current_scene.add_child(energy)
