extends Node

## Waypoint Arrow - Mũi tên HUD dẫn đường đến mục tiêu nhiệm vụ
## Hiển thị mũi tên ở cạnh màn hình chỉ hướng đến rác cần nhặt hoặc thùng rác

var player: CharacterBody3D = null
var arrow_control: Control = null
var target_label: Label = null
var distance_label: Label = null
var _update_timer: float = 0.0
const UPDATE_INTERVAL := 0.2  ## Cập nhật mỗi 0.2 giây

## Trạng thái
var current_target: Node3D = null
var target_position: Vector3 = Vector3.ZERO
var target_name: String = ""
var _pointing_to_basket := false

## Cấu hình hiển thị
const ARROW_SIZE := 28.0
const ARROW_MARGIN := 60.0  ## Khoảng cách từ cạnh màn hình
const MIN_DISTANCE_TO_SHOW := 8.0  ## Không hiện mũi tên khi quá gần


func setup(player_node: CharacterBody3D, hud: CanvasLayer) -> void:
	player = player_node
	_create_arrow_ui(hud)


func _process(delta: float) -> void:
	if not player or not arrow_control:
		return

	_update_timer += delta
	if _update_timer >= UPDATE_INTERVAL:
		_update_timer = 0.0
		_find_target()

	# Cập nhật vị trí mũi tên mỗi frame
	_update_arrow_position()


func _create_arrow_ui(hud: CanvasLayer) -> void:
	# Container chính cho mũi tên
	arrow_control = WaypointArrowDraw.new()
	arrow_control.name = "WaypointArrow"
	arrow_control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	arrow_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	arrow_control.waypoint_ref = self
	hud.add_child(arrow_control)

	# Label tên mục tiêu - đặt ở dưới giữa màn hình
	var info_container = HBoxContainer.new()
	info_container.name = "WaypointInfo"
	info_container.anchor_left = 0.5
	info_container.anchor_right = 0.5
	info_container.anchor_top = 1.0
	info_container.anchor_bottom = 1.0
	info_container.offset_left = -140
	info_container.offset_right = 140
	info_container.offset_top = -100
	info_container.offset_bottom = -75
	info_container.alignment = BoxContainer.ALIGNMENT_CENTER
	info_container.add_theme_constant_override("separation", 8)
	info_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(info_container)

	target_label = Label.new()
	target_label.name = "WaypointTargetName"
	target_label.text = ""
	target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	target_label.add_theme_font_size_override("font_size", 14)
	target_label.add_theme_color_override("font_color", Color(1.0, 0.9, 0.4))
	target_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	target_label.add_theme_constant_override("shadow_offset_x", 1)
	target_label.add_theme_constant_override("shadow_offset_y", 1)
	info_container.add_child(target_label)

	distance_label = Label.new()
	distance_label.name = "WaypointDistance"
	distance_label.text = ""
	distance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	distance_label.add_theme_font_size_override("font_size", 13)
	distance_label.add_theme_color_override("font_color", Color(0.7, 0.8, 1.0, 0.8))
	distance_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	distance_label.add_theme_constant_override("shadow_offset_x", 1)
	distance_label.add_theme_constant_override("shadow_offset_y", 1)
	info_container.add_child(distance_label)


func _find_target() -> void:
	if not player:
		return

	var tree = player.get_tree()
	if not tree:
		return

	# Lấy level manager để biết rác nào đã nhặt
	var level_mgr = tree.get_first_node_in_group("level_manager")

	# Bước 1: Nếu player có rác trong túi → chỉ đến thùng rác
	var controller = player as CharacterBody3D
	if controller.get("inventory") and controller.inventory.size() > 0:
		var nearest_basket: Node3D = null
		var nearest_dist := 99999.0
		for node in tree.get_nodes_in_group("basket"):
			if not is_instance_valid(node):
				continue
			var dist = player.global_position.distance_to(node.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_basket = node
		if nearest_basket:
			current_target = nearest_basket
			target_position = nearest_basket.global_position
			target_name = "🗑️ Thùng rác"
			_pointing_to_basket = true
			return

	# Bước 2: Tìm rác nhiệm vụ gần nhất chưa nhặt
	_pointing_to_basket = false
	var nearest_fruit: Node3D = null
	var nearest_dist := 99999.0

	for node in tree.get_nodes_in_group("interactable"):
		if not is_instance_valid(node):
			continue
		# Kiểm tra xem rác này đã được giao chưa (nếu có level manager)
		var dist = player.global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest_fruit = node

	if nearest_fruit:
		current_target = nearest_fruit
		target_position = nearest_fruit.global_position
		target_name = " Rác nhiệm vụ"
		return

	# Bước 3: Không có mục tiêu
	current_target = null
	target_name = ""


func _update_arrow_position() -> void:
	if not arrow_control:
		return

	if not current_target or not is_instance_valid(current_target) or target_name == "":
		arrow_control.visible = false
		if target_label:
			target_label.text = ""
		if distance_label:
			distance_label.text = ""
		return

	var dist = player.global_position.distance_to(target_position)

	# Ẩn khi quá gần
	if dist < MIN_DISTANCE_TO_SHOW:
		arrow_control.visible = false
		if target_label:
			target_label.text = ""
		if distance_label:
			distance_label.text = ""
		return

	arrow_control.visible = true
	arrow_control.queue_redraw()

	# Cập nhật info labels
	if target_label:
		target_label.text = target_name
	if distance_label:
		distance_label.text = "%dm" % int(dist)


## Tính hướng từ player đến mục tiêu (trả về Vector2 trên XZ plane)
func get_direction_to_target() -> Vector2:
	if not player or not current_target:
		return Vector2.ZERO

	var dx = target_position.x - player.global_position.x
	var dz = target_position.z - player.global_position.z
	return Vector2(dx, dz).normalized()


## Tính góc giữa hướng nhìn của player và hướng đến mục tiêu
func get_angle_to_target() -> float:
	if not player or not current_target:
		return 0.0

	var to_target = get_direction_to_target()
	var forward = -player.transform.basis.z
	var forward_2d = Vector2(forward.x, forward.z).normalized()

	return forward_2d.angle_to(to_target)


## ===================== ARROW DRAW CLASS =====================

class WaypointArrowDraw extends Control:
	var waypoint_ref: Node = null

	func _draw() -> void:
		if not waypoint_ref or not waypoint_ref.current_target:
			return
		if not is_instance_valid(waypoint_ref.current_target):
			return

		var angle = waypoint_ref.get_angle_to_target()
		var screen_size = get_viewport_rect().size
		var center = screen_size / 2.0

		# Vị trí mũi tên trên cạnh màn hình
		var arrow_dir = Vector2(sin(angle), -cos(angle))  # Chuyển sang screen space
		var radius = min(screen_size.x, screen_size.y) / 2.0 - waypoint_ref.ARROW_MARGIN

		var arrow_pos = center + arrow_dir * radius

		# Clamp vào trong màn hình
		arrow_pos.x = clamp(arrow_pos.x, waypoint_ref.ARROW_MARGIN, screen_size.x - waypoint_ref.ARROW_MARGIN)
		arrow_pos.y = clamp(arrow_pos.y, waypoint_ref.ARROW_MARGIN, screen_size.y - waypoint_ref.ARROW_MARGIN)

		var arrow_size = waypoint_ref.ARROW_SIZE

		# Màu theo loại mục tiêu
		var arrow_color: Color
		if waypoint_ref._pointing_to_basket:
			arrow_color = Color(1.0, 0.85, 0.1, 0.9)  # Vàng cho thùng rác
		else:
			arrow_color = Color(0.3, 0.9, 1.0, 0.9)  # Xanh lam cho rác

		# Vẽ viền glow
		var glow_color = Color(arrow_color.r, arrow_color.g, arrow_color.b, 0.3)
		_draw_arrow_shape(arrow_pos, angle, arrow_size * 1.4, glow_color)

		# Vẽ viền trắng
		_draw_arrow_shape(arrow_pos, angle, arrow_size * 1.1, Color(1, 1, 1, 0.6))

		# Vẽ mũi tên chính
		_draw_arrow_shape(arrow_pos, angle, arrow_size, arrow_color)

		# Vẽ chấm tròn ở giữa
		draw_circle(arrow_pos, 3.0, Color(1, 1, 1, 0.9))


	func _draw_arrow_shape(pos: Vector2, angle: float, size: float, color: Color) -> void:
		# Tạo mũi tên tam giác (hướng lên = angle 0)
		var points = PackedVector2Array()
		var half = size / 2.0

		# 3 đỉnh tam giác
		var tip = Vector2(0, -half)         # Đỉnh
		var left = Vector2(-half * 0.6, half * 0.4)   # Trái dưới
		var right = Vector2(half * 0.6, half * 0.4)   # Phải dưới

		# Xoay theo angle
		var cos_a = cos(angle)
		var sin_a = sin(angle)

		var rotated_tip = Vector2(tip.x * cos_a - tip.y * sin_a, tip.x * sin_a + tip.y * cos_a)
		var rotated_left = Vector2(left.x * cos_a - left.y * sin_a, left.x * sin_a + left.y * cos_a)
		var rotated_right = Vector2(right.x * cos_a - right.y * sin_a, right.x * sin_a + right.y * cos_a)

		points.append(pos + rotated_tip)
		points.append(pos + rotated_left)
		points.append(pos + rotated_right)

		draw_polygon(points, PackedColorArray([color, color, color]))
