extends Node

## Mini Map - Hiển thị bản đồ thu nhỏ ở góc dưới trái HUD
## Sử dụng SubViewport + Camera3D Orthographic nhìn từ trên xuống

## Kích thước minimap trên HUD (px)
const MINIMAP_SIZE := 180
## Kích thước camera orthographic (bán kính hiển thị xung quanh player)
const CAMERA_ORTHO_SIZE := 80.0
## Độ cao camera nhìn xuống
const CAMERA_HEIGHT := 50.0
## Throttle cập nhật overlay icons (giây)
const OVERLAY_UPDATE_INTERVAL := 0.3
## Kích thước player dot
const PLAYER_DOT_SIZE := 6.0
## Kích thước icon khác
const ICON_SIZE := 4.0

var player: CharacterBody3D = null
var minimap_camera: Camera3D = null
var sub_viewport: SubViewport = null
var sub_viewport_container: SubViewportContainer = null
var minimap_container: Control = null
var overlay: Control = null
var is_visible := true
var _overlay_timer := 0.0
var blink_fruits := false
var _blink_timer := 0.0

## Các vị trí cần vẽ overlay
var _basket_positions: Array = []
var _fruit_positions: Array = []
var _milk_positions: Array = []
var _dog_positions: Array = []
var _pet_position: Vector3 = Vector3.ZERO
var _has_pet := false
var _shop_position := Vector3(109.6, -134.1, 69.3)  ## Vị trí FrumiShop từ main.tscn


func setup(player_node: CharacterBody3D, hud: CanvasLayer) -> void:
	player = player_node
	_create_minimap_ui(hud)
	_create_sub_viewport()
	_update_overlay_data()


func _process(delta: float) -> void:
	if not is_visible or not player or not minimap_camera:
		return

	# Camera follow player mỗi frame (nhẹ)
	minimap_camera.global_position = Vector3(
		player.global_position.x,
		player.global_position.y + CAMERA_HEIGHT,
		player.global_position.z
	)

	# Cập nhật blink timer
	_blink_timer += delta

	# Throttle overlay data update
	_overlay_timer += delta
	if _overlay_timer >= OVERLAY_UPDATE_INTERVAL:
		_overlay_timer = 0.0
		_update_overlay_data()

	# Redraw overlay mỗi frame (đơn giản, chỉ vẽ dots)
	if overlay:
		overlay.queue_redraw()


func toggle() -> void:
	is_visible = not is_visible
	if minimap_container:
		minimap_container.visible = is_visible


func _create_minimap_ui(hud: CanvasLayer) -> void:
	# Container chính - góc trên phải
	minimap_container = Control.new()
	minimap_container.name = "MinimapContainer"
	minimap_container.anchor_left = 1.0
	minimap_container.anchor_top = 0.0
	minimap_container.anchor_right = 1.0
	minimap_container.anchor_bottom = 0.0
	minimap_container.offset_left = -(MINIMAP_SIZE + 15.0)
	minimap_container.offset_top = 15.0
	minimap_container.offset_right = -15.0
	minimap_container.offset_bottom = MINIMAP_SIZE + 15.0
	minimap_container.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	minimap_container.grow_vertical = Control.GROW_DIRECTION_END
	minimap_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(minimap_container)

	# Nền minimap (tròn, bán trong suốt)
	var bg = Panel.new()
	bg.name = "MinimapBg"
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.05, 0.08, 0.12, 0.75)
	bg_style.corner_radius_top_left = MINIMAP_SIZE / 2
	bg_style.corner_radius_top_right = MINIMAP_SIZE / 2
	bg_style.corner_radius_bottom_left = MINIMAP_SIZE / 2
	bg_style.corner_radius_bottom_right = MINIMAP_SIZE / 2
	bg_style.border_color = Color(0.3, 0.6, 0.9, 0.6)
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg.add_theme_stylebox_override("panel", bg_style)
	minimap_container.add_child(bg)

	# SubViewportContainer
	sub_viewport_container = SubViewportContainer.new()
	sub_viewport_container.name = "MinimapViewportContainer"
	sub_viewport_container.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	sub_viewport_container.offset_left = 4.0
	sub_viewport_container.offset_top = 4.0
	sub_viewport_container.offset_right = -4.0
	sub_viewport_container.offset_bottom = -4.0
	sub_viewport_container.stretch = true
	sub_viewport_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_container.add_child(sub_viewport_container)

	# Overlay (vẽ dots lên trên minimap)
	overlay = MinimapOverlay.new()
	overlay.name = "MinimapOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.minimap_ref = self
	minimap_container.add_child(overlay)

	# Label "MINIMAP" phía trên
	var title_label = Label.new()
	title_label.name = "MinimapTitle"
	title_label.text = "MAP"
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 11)
	title_label.add_theme_color_override("font_color", Color(0.6, 0.8, 1.0, 0.8))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	title_label.add_theme_constant_override("shadow_offset_x", 1)
	title_label.add_theme_constant_override("shadow_offset_y", 1)
	title_label.anchors_preset = Control.PRESET_TOP_WIDE
	title_label.offset_top = -18.0
	title_label.offset_bottom = 0.0
	minimap_container.add_child(title_label)

	# Hint phím tắt
	var hint_label = Label.new()
	hint_label.name = "MinimapHint"
	hint_label.text = "[M] Ẩn/Hiện"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 10)
	hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.6))
	hint_label.anchors_preset = Control.PRESET_BOTTOM_WIDE
	hint_label.offset_top = 0.0
	hint_label.offset_bottom = 16.0
	minimap_container.add_child(hint_label)


func _create_sub_viewport() -> void:
	# SubViewport
	sub_viewport = SubViewport.new()
	sub_viewport.name = "MinimapSubViewport"
	sub_viewport.size = Vector2i(200, 200)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = false
	sub_viewport.world_3d = player.get_viewport().find_world_3d()
	sub_viewport_container.add_child(sub_viewport)

	# Camera3D - Orthographic, nhìn xuống
	minimap_camera = Camera3D.new()
	minimap_camera.name = "MinimapCamera"
	minimap_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	minimap_camera.size = CAMERA_ORTHO_SIZE
	minimap_camera.near = 0.1
	minimap_camera.far = 200.0
	minimap_camera.current = true
	# Nhìn thẳng xuống: rotate -90 độ trên trục X
	minimap_camera.rotation_degrees = Vector3(-90, 0, 0)
	# Vị trí ban đầu
	minimap_camera.position = Vector3(0, CAMERA_HEIGHT, 0)
	sub_viewport.add_child(minimap_camera)
	# Cập nhật vị trí sau khi vào tree
	if player and player.is_inside_tree():
		minimap_camera.global_position = Vector3(
			player.global_position.x,
			player.global_position.y + CAMERA_HEIGHT,
			player.global_position.z
		)


## Cập nhật dữ liệu vị trí các object trên map (throttled)
func _update_overlay_data() -> void:
	if not player:
		return

	var tree = player.get_tree()
	if not tree:
		return

	# Basket
	_basket_positions.clear()
	for node in tree.get_nodes_in_group("basket"):
		if is_instance_valid(node):
			_basket_positions.append(node.global_position)

	# Fruits (interactable)
	_fruit_positions.clear()
	for node in tree.get_nodes_in_group("interactable"):
		if is_instance_valid(node):
			_fruit_positions.append(node.global_position)

	# Milk
	_milk_positions.clear()
	for node in tree.get_nodes_in_group("milk"):
		if is_instance_valid(node):
			_milk_positions.append(node.global_position)

	# Dogs
	_dog_positions.clear()
	for node in tree.get_nodes_in_group("dog"):
		if is_instance_valid(node):
			_dog_positions.append(node.global_position)

	# Pet
	var controller = player as CharacterBody3D
	if controller.get("pet_instance") and is_instance_valid(controller.pet_instance):
		_pet_position = controller.pet_instance.global_position
		_has_pet = true
	else:
		_has_pet = false


## Chuyển từ vị trí world 3D sang vị trí 2D trên minimap overlay
func world_to_minimap(world_pos: Vector3) -> Vector2:
	if not player:
		return Vector2(-1000, -1000)

	var viewport_size = MINIMAP_SIZE - 8  # Trừ padding
	var half_size = viewport_size / 2.0

	# Khoảng cách từ player (trên XZ plane)
	var dx = world_pos.x - player.global_position.x
	var dz = world_pos.z - player.global_position.z

	# Map vào minimap coordinates
	var mx = half_size + (dx / CAMERA_ORTHO_SIZE) * viewport_size
	var my = half_size + (dz / CAMERA_ORTHO_SIZE) * viewport_size

	return Vector2(mx + 4, my + 4)  # +4 cho padding


## Kiểm tra vị trí có nằm trong minimap không
func is_in_minimap(minimap_pos: Vector2) -> bool:
	var center = Vector2(MINIMAP_SIZE / 2.0, MINIMAP_SIZE / 2.0)
	var radius = (MINIMAP_SIZE - 8) / 2.0
	return minimap_pos.distance_to(center) <= radius


## ===================== OVERLAY DRAW CLASS =====================

class MinimapOverlay extends Control:
	var minimap_ref: Node = null

	func _draw() -> void:
		if not minimap_ref or not minimap_ref.player:
			return

		# === Vẽ Shop icon (hình vuông xanh lục) ===
		var shop_pos = minimap_ref.world_to_minimap(minimap_ref._shop_position)
		if minimap_ref.is_in_minimap(shop_pos):
			draw_rect(Rect2(shop_pos - Vector2(4, 4), Vector2(8, 8)), Color(0.2, 0.9, 0.4, 0.9))
			# Chữ S nhỏ
			# draw_string sẽ phức tạp, dùng rect là đủ

		# === Vẽ Basket icons (vàng) ===
		for pos3d in minimap_ref._basket_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_rect(Rect2(pos2d - Vector2(3.5, 3.5), Vector2(7, 7)),
					Color(1.0, 0.85, 0.1, 0.9))

		# === Vẽ Fruits (nổi bật, có viền phát sáng + nhấp nháy) ===
		var fruit_blink_alpha := 1.0
		var fruit_glow_scale := 1.0
		if minimap_ref.blink_fruits:
			# Hiệu ứng nhấp nháy: alpha dao động 0.4 - 1.0
			fruit_blink_alpha = 0.4 + (sin(minimap_ref._blink_timer * 5.0) + 1.0) / 2.0 * 0.6
			# Kích thước glow dao động 1.6 - 2.2
			fruit_glow_scale = 1.6 + (sin(minimap_ref._blink_timer * 5.0) + 1.0) / 2.0 * 0.6

		for pos3d in minimap_ref._fruit_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				# Viền phát sáng bên ngoài (nhấp nháy)
				draw_circle(pos2d, minimap_ref.ICON_SIZE * fruit_glow_scale,
					Color(1.0, 1.0, 0.2, 0.3 * fruit_blink_alpha))
				# Viền trắng
				draw_circle(pos2d, minimap_ref.ICON_SIZE * 1.2,
					Color(1.0, 1.0, 1.0, 0.7 * fruit_blink_alpha))
				# Lõi cam sáng
				draw_circle(pos2d, minimap_ref.ICON_SIZE,
					Color(1.0, 0.5, 0.0, fruit_blink_alpha))

		# === Vẽ Milk (trắng nhỏ) ===
		for pos3d in minimap_ref._milk_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_circle(pos2d, minimap_ref.ICON_SIZE * 0.5,
					Color(1.0, 1.0, 1.0, 0.5))

		# === Vẽ Dogs (đỏ) ===
		for pos3d in minimap_ref._dog_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_circle(pos2d, minimap_ref.ICON_SIZE,
					Color(1.0, 0.15, 0.15, 0.9))

		# === Vẽ Pet (tím) ===
		if minimap_ref._has_pet:
			var pet_pos = minimap_ref.world_to_minimap(minimap_ref._pet_position)
			if minimap_ref.is_in_minimap(pet_pos):
				draw_circle(pet_pos, minimap_ref.ICON_SIZE * 0.8,
					Color(0.7, 0.3, 1.0, 0.9))

		# === Vẽ Player dot (xanh dương, ở trung tâm) ===
		var player_pos = minimap_ref.world_to_minimap(minimap_ref.player.global_position)
		draw_circle(player_pos, minimap_ref.PLAYER_DOT_SIZE,
			Color(0.2, 0.6, 1.0, 1.0))
		# Viền trắng
		draw_arc(player_pos, minimap_ref.PLAYER_DOT_SIZE + 1, 0, TAU, 24,
			Color(1.0, 1.0, 1.0, 0.8), 1.5)

		# === Vẽ hướng player (mũi tên nhỏ) ===
		var forward_dir = -minimap_ref.player.transform.basis.z
		var arrow_dir = Vector2(forward_dir.x, forward_dir.z).normalized()
		var arrow_start = player_pos + arrow_dir * (minimap_ref.PLAYER_DOT_SIZE + 2)
		var arrow_end = player_pos + arrow_dir * (minimap_ref.PLAYER_DOT_SIZE + 8)
		draw_line(arrow_start, arrow_end, Color(0.4, 0.8, 1.0, 0.9), 2.0)
