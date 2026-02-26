extends Node3D

## Con chó bảo vệ - đuổi theo player khi player đến gần

@export var chase_radius: float = 5.0
@export var move_speed: float = 3.0
@export var rotation_speed: float = 8.0
@export var energy_drain_per_second: float = 15.0
@export var bite_range: float = 1.2

var player: Node3D = null
var is_chasing := false
var anim_player: AnimationPlayer = null
var anim_name := "metarigAction"


func _ready():
	_find_animation_player(self)

	var area = $Area3D
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
		var col_shape = area.get_child(0)
		if col_shape is CollisionShape3D and col_shape.shape is SphereShape3D:
			col_shape.shape.radius = chase_radius


func _find_animation_player(node: Node):
	for child in node.get_children():
		if child is AnimationPlayer:
			anim_player = child
			return
		_find_animation_player(child)


func _physics_process(delta):
	if not is_chasing or not is_instance_valid(player):
		return

	var dir = player.global_position - global_position
	dir.y = 0
	var distance = dir.length()

	if distance <= bite_range:
		if player.has_method("drain_energy"):
			player.drain_energy(energy_drain_per_second * delta)
	else:
		dir = dir.normalized()
		global_position += dir * move_speed * delta

	if distance > 0.1:
		var target_angle = atan2(dir.normalized().x, dir.normalized().z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)


func _on_body_entered(body: Node3D):
	if body is CharacterBody3D:
		player = body
		is_chasing = true
		_play_chase_animation()


func _on_body_exited(body: Node3D):
	if body == player:
		is_chasing = false
		player = null
		_stop_animation()


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
