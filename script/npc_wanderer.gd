extends Node3D

## NPC đi lại ngẫu nhiên trong bán kính quanh vị trí ban đầu

@export var wander_radius: float = 8.0
@export var move_speed: float = 1.5
@export var rotation_speed: float = 4.0
@export var min_wait_time: float = 2.0
@export var max_wait_time: float = 5.0

var home_position: Vector3
var target_position: Vector3
var is_moving: bool = false
var wait_timer: float = 0.0


func _ready():
	home_position = global_position
	_pick_new_target()
	wait_timer = randf_range(0.0, max_wait_time)


func _physics_process(delta):
	if not is_moving:
		wait_timer -= delta
		if wait_timer <= 0.0:
			is_moving = true
			_pick_new_target()
		return

	var diff := target_position - global_position
	diff.y = 0.0
	var dist_sq := diff.x * diff.x + diff.z * diff.z

	if dist_sq < 0.5:
		# Đến nơi, dừng lại chờ
		is_moving = false
		wait_timer = randf_range(min_wait_time, max_wait_time)
		return

	var dist := sqrt(dist_sq)
	var dir_x := diff.x / dist
	var dir_z := diff.z / dist

	global_position.x += dir_x * move_speed * delta
	global_position.z += dir_z * move_speed * delta

	# Quay mặt theo hướng di chuyển
	var target_angle := atan2(dir_x, dir_z)
	rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)


func _pick_new_target():
	var angle := randf() * TAU
	var radius := randf_range(2.0, wander_radius)
	target_position = Vector3(
		home_position.x + cos(angle) * radius,
		home_position.y,
		home_position.z + sin(angle) * radius
	)
