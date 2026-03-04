extends Node3D

## Thú cưng đi theo player với tốc độ tùy loại
## Fox: nhanh x2, phát hiện rác
## Turtle: chậm x0.5, hồi NL khi player đứng yên

var player: CharacterBody3D = null
var anim_player: AnimationPlayer = null
var anim_name := ""

var follow_speed: float = 7.0
var rotation_speed: float = 6.0
var follow_distance: float = 2.0
var is_moving := false

var pet_type := ""
var fruit_detect_radius_sq: float = 100.0  # 10m squared

## Throttle cho fox fruit scan (giảm lag)
var _fox_scan_timer: float = 0.0
const FOX_SCAN_INTERVAL: float = 0.3  ## Chỉ quét mỗi 0.3 giây


func _ready():
	pet_type = Global.selected_pet

	match pet_type:
		"fox":
			anim_name = "rigAction"
		"turtle":
			anim_name = "Armature.004Action"

	var base_speed: float = 7.0
	var mult: float = Global.get_pet_bonus("follow_speed_mult")
	if mult > 0.0:
		follow_speed = base_speed * mult

	_find_animation_player(self)
	_find_player.call_deferred()


func _find_player():
	var bodies = get_tree().get_nodes_in_group("player")
	if bodies.size() > 0:
		player = bodies[0] as CharacterBody3D


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
	var follow_dist_sq := follow_distance * follow_distance

	if dist_sq > follow_dist_sq:
		var dist := sqrt(dist_sq)
		var dir_x := diff.x / dist
		var dir_z := diff.z / dist

		var step: float = follow_speed * delta
		if dist - follow_distance < step:
			step = dist - follow_distance

		global_position.x += dir_x * step
		global_position.z += dir_z * step

		var target_angle := atan2(dir_x, dir_z)
		rotation.y = lerp_angle(rotation.y, target_angle, rotation_speed * delta)

		if not is_moving:
			is_moving = true
	else:
		if is_moving:
			is_moving = false

		if pet_type == "fox":
			_fox_scan_timer += delta
			if _fox_scan_timer >= FOX_SCAN_INTERVAL:
				_fox_scan_timer = 0.0
				_fox_look_at_fruit(delta)

	if anim_player and not anim_player.is_playing():
		_play_animation()


func _fox_look_at_fruit(delta: float):
	var fruits := get_tree().get_nodes_in_group("interactable")
	if fruits.is_empty():
		return

	var nearest_dist_sq := fruit_detect_radius_sq
	var nearest_pos := Vector3.ZERO
	var found := false

	for fruit in fruits:
		if not is_instance_valid(fruit):
			continue
		var d: Vector3 = fruit.global_position - global_position
		d.y = 0.0
		var dsq := d.x * d.x + d.z * d.z
		if dsq < nearest_dist_sq:
			nearest_dist_sq = dsq
			nearest_pos = fruit.global_position
			found = true

	if found:
		var look_dir := nearest_pos - global_position
		look_dir.y = 0.0
		if look_dir.length_squared() > 0.01:
			var target_angle := atan2(look_dir.x, look_dir.z)
			rotation.y = lerp_angle(rotation.y, target_angle, 3.0 * delta)


func _play_animation():
	if not anim_player or anim_name == "":
		return
	if anim_player.has_animation(anim_name):
		var anim = anim_player.get_animation(anim_name)
		anim.loop_mode = Animation.LOOP_LINEAR
		anim_player.play(anim_name)


func _stop_animation():
	if anim_player and anim_player.is_playing():
		anim_player.stop()
