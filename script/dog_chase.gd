extends Node3D

## Con chó bảo vệ - đuổi theo player khi player đến gần
## Dùng distance check thay vì Area3D để tránh lag physics server

@export var chase_radius: float = 5.0
@export var move_speed: float = 3.0
@export var rotation_speed: float = 8.0
@export var energy_drain_per_second: float = 15.0
@export var bite_range: float = 1.2

var player: CharacterBody3D = null
var is_chasing := false
var anim_player: AnimationPlayer = null
var anim_name := "metarigAction"
var chase_radius_sq: float
var bite_range_sq: float
var home_position: Vector3

## Throttle cho distance check khi không chase (giảm lag)
var _idle_check_timer: float = 0.0
const IDLE_CHECK_INTERVAL: float = 0.2


func _ready():
	chase_radius_sq = chase_radius * chase_radius
	bite_range_sq = bite_range * bite_range
	home_position = global_position
	_find_animation_player(self)
	_find_player.call_deferred()


func _find_player():
	var bodies = get_tree().get_nodes_in_group("player")
	if bodies.size() > 0:
		player = bodies[0] as CharacterBody3D
	else:
		for node in get_tree().get_nodes_in_group(""):
			if node is CharacterBody3D:
				player = node
				break


func _find_animation_player(node: Node):
	for child in node.get_children():
		if child is AnimationPlayer:
			anim_player = child
			return
		_find_animation_player(child)


func _physics_process(delta):
	if not is_instance_valid(player):
		return

	var diff := player.global_position - global_position
	diff.y = 0.0
	var dist_sq := diff.x * diff.x + diff.z * diff.z

	if not is_chasing:
		# Throttle: chỉ check khoảng cách mỗi 0.2s khi không chase
		_idle_check_timer += delta
		if _idle_check_timer < IDLE_CHECK_INTERVAL:
			return
		_idle_check_timer = 0.0
		if dist_sq <= chase_radius_sq:
			is_chasing = true
			_play_chase_animation()
			AudioManager.play_dog_bark()
		return

	if dist_sq > chase_radius_sq:
		is_chasing = false
		_stop_animation()
		AudioManager.stop_dog_bark()
		return

	if dist_sq <= bite_range_sq:
		player.drain_energy(energy_drain_per_second * delta)
	elif dist_sq > 0.01:
		var inv_dist := 1.0 / sqrt(dist_sq)
		var dir_x := diff.x * inv_dist
		var dir_z := diff.z * inv_dist
		global_position.x += dir_x * move_speed * delta
		global_position.z += dir_z * move_speed * delta

	if dist_sq > 0.01:
		var inv_dist := 1.0 / sqrt(dist_sq)
		var target_angle := atan2(diff.x * inv_dist, diff.z * inv_dist)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)


func _play_chase_animation():
	if not anim_player:
		return
	if anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play(anim_name)


func _stop_animation():
	if anim_player and anim_player.is_playing():
		anim_player.stop()
