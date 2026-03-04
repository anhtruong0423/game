extends Node

## Mini Map - Hiển thị bản đồ thu nhỏ ở góc trên phải HUD
## Click vào minimap để mở rộng bản đồ toàn cảnh với khu vực
## Click lần nữa hoặc nhấn ESC để thu nhỏ

## ==================== CONSTANTS ====================

const MINIMAP_SIZE := 180
const CAMERA_ORTHO_SIZE := 80.0
const CAMERA_ORTHO_SIZE_EXPANDED := 300.0
const CAMERA_HEIGHT := 50.0
const CAMERA_HEIGHT_EXPANDED := 180.0
const OVERLAY_UPDATE_INTERVAL := 0.3
const PLAYER_DOT_SIZE := 6.0
const ICON_SIZE := 4.0
const EXPANDED_WIDTH := 600
const EXPANDED_HEIGHT := 500

## ==================== ZONE DATA ====================
## Tọa độ dựa trên MILK_SPAWN_POSITIONS và spawn_items trong level_manager.gd
## Y = -133.5 cho tất cả vật thể trên mặt đất
## Shop tại (109.6, -134.1, 69.3)

const ZONES = [
	{
		"name": "Khu Trung Tâm",
		"icon": "🏪",
		"color": Color(0.3, 0.9, 0.4, 0.12),
		"border_color": Color(0.3, 0.9, 0.4, 0.6),
		"label_color": Color(0.3, 0.9, 0.4, 0.95),
		"min_x": 95.0, "max_x": 130.0,
		"min_z": 60.0, "max_z": 90.0,
	},
	{
		"name": "Đường Chính",
		"icon": "🛤️",
		"color": Color(0.9, 0.8, 0.3, 0.08),
		"border_color": Color(0.9, 0.8, 0.3, 0.5),
		"label_color": Color(0.9, 0.8, 0.3, 0.95),
		"min_x": -130.0, "max_x": 170.0,
		"min_z": 82.0, "max_z": 95.0,
	},
	{
		"name": "Cánh Đồng",
		"icon": "🌾",
		"color": Color(0.4, 0.8, 0.3, 0.08),
		"border_color": Color(0.4, 0.8, 0.3, 0.5),
		"label_color": Color(0.4, 0.8, 0.3, 0.95),
		"min_x": -110.0, "max_x": 60.0,
		"min_z": 40.0, "max_z": 70.0,
	},
	{
		"name": "Khu Nhà Cửa",
		"icon": "🏠",
		"color": Color(0.7, 0.5, 0.3, 0.08),
		"border_color": Color(0.7, 0.5, 0.3, 0.5),
		"label_color": Color(0.7, 0.5, 0.3, 0.95),
		"min_x": -30.0, "max_x": 140.0,
		"min_z": 15.0, "max_z": 40.0,
	},
	{
		"name": "Vùng Tây",
		"icon": "🌲",
		"color": Color(0.3, 0.6, 0.8, 0.08),
		"border_color": Color(0.3, 0.6, 0.8, 0.5),
		"label_color": Color(0.3, 0.6, 0.8, 0.95),
		"min_x": -220.0, "max_x": -110.0,
		"min_z": 55.0, "max_z": 95.0,
	},
	{
		"name": "Vùng Đông",
		"icon": "🌲",
		"color": Color(0.3, 0.6, 0.8, 0.08),
		"border_color": Color(0.3, 0.6, 0.8, 0.5),
		"label_color": Color(0.3, 0.6, 0.8, 0.95),
		"min_x": 140.0, "max_x": 270.0,
		"min_z": 55.0, "max_z": 95.0,
	},
]

## ==================== VARIABLES ====================

var player: CharacterBody3D = null
var hud_ref: CanvasLayer = null
var minimap_camera: Camera3D = null
var sub_viewport: SubViewport = null
var sub_viewport_container: SubViewportContainer = null
var minimap_container: Control = null
var overlay: Control = null
var bg_panel: Panel = null
var bg_style: StyleBoxFlat = null
var title_label: Label = null
var hint_label: Label = null

var is_visible := true
var is_expanded := false
var _overlay_timer := 0.0
var blink_fruits := false
var _blink_timer := 0.0

var _basket_positions: Array = []
var _fruit_positions: Array = []
var _milk_positions: Array = []
var _dog_positions: Array = []
var _pet_position: Vector3 = Vector3.ZERO
var _has_pet := false
var _shop_position := Vector3(109.6, -134.1, 69.3)

var _expanded_bg: ColorRect = null
var _legend_panel: PanelContainer = null
var _close_btn: Button = null


func setup(player_node: CharacterBody3D, hud: CanvasLayer) -> void:
	player = player_node
	hud_ref = hud
	_create_minimap_ui(hud)
	_create_sub_viewport()
	_create_expanded_bg(hud)
	_update_overlay_data()


func _process(delta: float) -> void:
	if not is_visible or not player or not minimap_camera:
		return

	if is_expanded:
		minimap_camera.global_position = Vector3(
			player.global_position.x,
			player.global_position.y + CAMERA_HEIGHT_EXPANDED,
			player.global_position.z
		)
	else:
		minimap_camera.global_position = Vector3(
			player.global_position.x,
			player.global_position.y + CAMERA_HEIGHT,
			player.global_position.z
		)

	_blink_timer += delta
	_overlay_timer += delta
	if _overlay_timer >= OVERLAY_UPDATE_INTERVAL:
		_overlay_timer = 0.0
		_update_overlay_data()

	if overlay:
		overlay.queue_redraw()





func toggle() -> void:
	is_visible = not is_visible
	if minimap_container:
		minimap_container.visible = is_visible
	if not is_visible and is_expanded:
		_collapse()


func toggle_expand() -> void:
	if is_expanded:
		_collapse()
	else:
		_expand()




func _expand() -> void:
	is_expanded = true
	if not minimap_container:
		return

	# Full screen với margin nhỏ
	minimap_container.anchor_left = 0.0
	minimap_container.anchor_top = 0.0
	minimap_container.anchor_right = 1.0
	minimap_container.anchor_bottom = 1.0
	minimap_container.offset_left = 20.0
	minimap_container.offset_top = 20.0
	minimap_container.offset_right = -20.0
	minimap_container.offset_bottom = -20.0

	if bg_style:
		bg_style.corner_radius_top_left = 16
		bg_style.corner_radius_top_right = 16
		bg_style.corner_radius_bottom_left = 16
		bg_style.corner_radius_bottom_right = 16
		bg_style.bg_color = Color(0.03, 0.05, 0.08, 0.95)
		bg_style.border_color = Color(0.3, 0.6, 0.9, 0.8)

	if minimap_camera:
		minimap_camera.size = CAMERA_ORTHO_SIZE_EXPANDED
	if sub_viewport:
		sub_viewport.size = Vector2i(1200, 800)
	if title_label:
		title_label.text = "❤️ BẢN ĐỒ NÔNG TRẠI"
		title_label.add_theme_font_size_override("font_size", 22)
		title_label.offset_top = -35.0
	if hint_label:
		hint_label.text = "[M] Thu nhỏ"
		hint_label.add_theme_font_size_override("font_size", 13)
	if _expanded_bg:
		_expanded_bg.visible = true

	_show_legend()


func _collapse() -> void:
	is_expanded = false
	if not minimap_container:
		return

	minimap_container.anchor_left = 1.0
	minimap_container.anchor_top = 0.0
	minimap_container.anchor_right = 1.0
	minimap_container.anchor_bottom = 0.0
	minimap_container.offset_left = -(MINIMAP_SIZE + 15.0)
	minimap_container.offset_top = 15.0
	minimap_container.offset_right = -15.0
	minimap_container.offset_bottom = MINIMAP_SIZE + 15.0

	if bg_style:
		bg_style.corner_radius_top_left = MINIMAP_SIZE / 2
		bg_style.corner_radius_top_right = MINIMAP_SIZE / 2
		bg_style.corner_radius_bottom_left = MINIMAP_SIZE / 2
		bg_style.corner_radius_bottom_right = MINIMAP_SIZE / 2
		bg_style.bg_color = Color(0.05, 0.08, 0.12, 0.75)
		bg_style.border_color = Color(0.3, 0.6, 0.9, 0.6)

	if minimap_camera:
		minimap_camera.size = CAMERA_ORTHO_SIZE
	if sub_viewport:
		sub_viewport.size = Vector2i(200, 200)
	if title_label:
		title_label.text = "MAP"
		title_label.add_theme_font_size_override("font_size", 11)
		title_label.offset_top = -18.0
	if hint_label:
		hint_label.text = "[M] Mở rộng"
		hint_label.add_theme_font_size_override("font_size", 10)
	if _expanded_bg:
		_expanded_bg.visible = false
	_hide_legend()


## ==================== UI CREATION ====================

func _create_minimap_ui(hud: CanvasLayer) -> void:
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

	# Nền minimap
	bg_panel = Panel.new()
	bg_panel.name = "MinimapBg"
	bg_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bg_style = StyleBoxFlat.new()
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
	bg_panel.add_theme_stylebox_override("panel", bg_style)
	minimap_container.add_child(bg_panel)

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

	# Overlay
	overlay = MinimapOverlay.new()
	overlay.name = "MinimapOverlay"
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.minimap_ref = self
	minimap_container.add_child(overlay)



	# Title
	title_label = Label.new()
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
	title_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_container.add_child(title_label)

	# Hint
	hint_label = Label.new()
	hint_label.name = "MinimapHint"
	hint_label.text = "Click để mở rộng"
	hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_font_size_override("font_size", 10)
	hint_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.6, 0.6))
	hint_label.anchors_preset = Control.PRESET_BOTTOM_WIDE
	hint_label.offset_top = 0.0
	hint_label.offset_bottom = 16.0
	hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	minimap_container.add_child(hint_label)


func _create_sub_viewport() -> void:
	sub_viewport = SubViewport.new()
	sub_viewport.name = "MinimapSubViewport"
	sub_viewport.size = Vector2i(200, 200)
	sub_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	sub_viewport.transparent_bg = false
	sub_viewport.world_3d = player.get_viewport().find_world_3d()
	sub_viewport_container.add_child(sub_viewport)

	minimap_camera = Camera3D.new()
	minimap_camera.name = "MinimapCamera"
	minimap_camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	minimap_camera.size = CAMERA_ORTHO_SIZE
	minimap_camera.near = 0.1
	minimap_camera.far = 200.0
	minimap_camera.current = true
	minimap_camera.rotation_degrees = Vector3(-90, 0, 0)
	minimap_camera.position = Vector3(0, CAMERA_HEIGHT, 0)
	sub_viewport.add_child(minimap_camera)

	if player and player.is_inside_tree():
		minimap_camera.global_position = Vector3(
			player.global_position.x,
			player.global_position.y + CAMERA_HEIGHT,
			player.global_position.z
		)


func _create_expanded_bg(hud: CanvasLayer) -> void:
	_expanded_bg = ColorRect.new()
	_expanded_bg.name = "MinimapExpandedBg"
	_expanded_bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_expanded_bg.color = Color(0, 0, 0, 0.5)
	_expanded_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_expanded_bg.visible = false
	hud.add_child(_expanded_bg)
	hud.move_child(_expanded_bg, minimap_container.get_index())


## ==================== LEGEND ====================

func _show_legend() -> void:
	if _legend_panel:
		_legend_panel.visible = true
		return
	if not hud_ref:
		return

	_legend_panel = PanelContainer.new()
	_legend_panel.name = "MinimapLegend"
	# Đặt trong minimap container, góc trên phải
	_legend_panel.anchor_left = 1.0
	_legend_panel.anchor_right = 1.0
	_legend_panel.anchor_top = 0.0
	_legend_panel.anchor_bottom = 0.0
	_legend_panel.offset_left = -175
	_legend_panel.offset_right = -10
	_legend_panel.offset_top = 10
	_legend_panel.offset_bottom = 400
	_legend_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.03, 0.05, 0.08, 0.9)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_color = Color(0.3, 0.6, 0.9, 0.6)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	_legend_panel.add_theme_stylebox_override("panel", style)
	minimap_container.add_child(_legend_panel)  # Thêm vào minimap, không phải hud

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	_legend_panel.add_child(vbox)

	var legend_title = Label.new()
	legend_title.text = "📋 Chú Thích"
	legend_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	legend_title.add_theme_font_size_override("font_size", 15)
	legend_title.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(legend_title)

	vbox.add_child(HSeparator.new())

	var icons = [
		{"text": "🔵  Bạn", "color": Color(0.2, 0.6, 1.0)},
		{"text": "🟢  FrumiShop", "color": Color(0.2, 0.9, 0.4)},
		{"text": "🟡  Thùng rác", "color": Color(1.0, 0.85, 0.1)},
		{"text": "🟠  Rác nhiệm vụ", "color": Color(1.0, 0.5, 0.0)},
		{"text": "🔴  Chó", "color": Color(1.0, 0.15, 0.15)},
		{"text": "⚪  Sữa", "color": Color(1.0, 1.0, 1.0)},
		{"text": "🟣  Thú cưng", "color": Color(0.7, 0.3, 1.0)},
	]
	for icon_data in icons:
		var lbl = Label.new()
		lbl.text = icon_data["text"]
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", icon_data["color"])
		vbox.add_child(lbl)

	vbox.add_child(HSeparator.new())

	var zone_title = Label.new()
	zone_title.text = "🗺️ Khu Vực"
	zone_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_title.add_theme_font_size_override("font_size", 14)
	zone_title.add_theme_color_override("font_color", Color(0.8, 0.9, 1.0))
	vbox.add_child(zone_title)

	for zone in ZONES:
		var lbl = Label.new()
		lbl.text = zone["icon"] + " " + zone["name"]
		lbl.add_theme_font_size_override("font_size", 12)
		lbl.add_theme_color_override("font_color", zone["label_color"])
		vbox.add_child(lbl)


func _hide_legend() -> void:
	if _legend_panel:
		_legend_panel.visible = false


## ==================== OVERLAY DATA ====================

func _update_overlay_data() -> void:
	if not player:
		return
	var tree = player.get_tree()
	if not tree:
		return

	_basket_positions.clear()
	for node in tree.get_nodes_in_group("basket"):
		if is_instance_valid(node):
			_basket_positions.append(node.global_position)

	_fruit_positions.clear()
	for node in tree.get_nodes_in_group("interactable"):
		if is_instance_valid(node):
			_fruit_positions.append(node.global_position)

	_milk_positions.clear()
	for node in tree.get_nodes_in_group("milk"):
		if is_instance_valid(node):
			_milk_positions.append(node.global_position)

	_dog_positions.clear()
	for node in tree.get_nodes_in_group("dog"):
		if is_instance_valid(node):
			_dog_positions.append(node.global_position)

	var controller = player as CharacterBody3D
	if controller.get("pet_instance") and is_instance_valid(controller.pet_instance):
		_pet_position = controller.pet_instance.global_position
		_has_pet = true
	else:
		_has_pet = false


## ==================== COORDINATE CONVERSION ====================

func world_to_minimap(world_pos: Vector3) -> Vector2:
	if not player:
		return Vector2(-1000, -1000)

	var current_size: float
	var viewport_w: float
	var viewport_h: float

	if is_expanded and minimap_container:
		current_size = CAMERA_ORTHO_SIZE_EXPANDED
		viewport_w = minimap_container.size.x - 8.0
		viewport_h = minimap_container.size.y - 8.0
	else:
		current_size = CAMERA_ORTHO_SIZE
		viewport_w = MINIMAP_SIZE - 8.0
		viewport_h = MINIMAP_SIZE - 8.0

	var half_w = viewport_w / 2.0
	var half_h = viewport_h / 2.0

	var dx = world_pos.x - player.global_position.x
	var dz = world_pos.z - player.global_position.z

	var mx = half_w + (dx / current_size) * viewport_w
	var my = half_h + (dz / current_size) * viewport_h

	return Vector2(mx + 4, my + 4)


func is_in_minimap(minimap_pos: Vector2) -> bool:
	if is_expanded and minimap_container:
		return minimap_pos.x >= 0 and minimap_pos.x <= minimap_container.size.x \
			and minimap_pos.y >= 0 and minimap_pos.y <= minimap_container.size.y
	else:
		var center = Vector2(MINIMAP_SIZE / 2.0, MINIMAP_SIZE / 2.0)
		var radius = (MINIMAP_SIZE - 8) / 2.0
		return minimap_pos.distance_to(center) <= radius


## ===================== OVERLAY DRAW CLASS =====================

class MinimapOverlay extends Control:
	var minimap_ref: Node = null

	func _draw() -> void:
		if not minimap_ref or not minimap_ref.player:
			return

		# === Vẽ Zone areas (chỉ khi expanded) ===
		if minimap_ref.is_expanded:
			_draw_zones()

		# === Vẽ Shop icon ===
		var shop_pos = minimap_ref.world_to_minimap(minimap_ref._shop_position)
		if minimap_ref.is_in_minimap(shop_pos):
			var ss = 8.0
			draw_rect(Rect2(shop_pos - Vector2(ss/2, ss/2), Vector2(ss, ss)), Color(0.2, 0.9, 0.4, 0.9))

		# === Vẽ Basket icons ===
		for pos3d in minimap_ref._basket_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				var s = 8.0 if minimap_ref.is_expanded else 7.0
				draw_rect(Rect2(pos2d - Vector2(s/2, s/2), Vector2(s, s)), Color(1.0, 0.85, 0.1, 0.9))

		# === Vẽ Fruits ===
		var fruit_blink_alpha := 1.0
		var fruit_glow_scale := 1.0
		if minimap_ref.blink_fruits:
			fruit_blink_alpha = 0.4 + (sin(minimap_ref._blink_timer * 5.0) + 1.0) / 2.0 * 0.6
			fruit_glow_scale = 1.6 + (sin(minimap_ref._blink_timer * 5.0) + 1.0) / 2.0 * 0.6

		var icon_size = minimap_ref.ICON_SIZE * (1.5 if minimap_ref.is_expanded else 1.0)

		for pos3d in minimap_ref._fruit_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_circle(pos2d, icon_size * fruit_glow_scale, Color(1.0, 1.0, 0.2, 0.3 * fruit_blink_alpha))
				draw_circle(pos2d, icon_size * 1.2, Color(1.0, 1.0, 1.0, 0.7 * fruit_blink_alpha))
				draw_circle(pos2d, icon_size, Color(1.0, 0.5, 0.0, fruit_blink_alpha))

		# === Vẽ Milk ===
		for pos3d in minimap_ref._milk_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_circle(pos2d, icon_size * 0.5, Color(1.0, 1.0, 1.0, 0.5))

		# === Vẽ Dogs ===
		for pos3d in minimap_ref._dog_positions:
			var pos2d = minimap_ref.world_to_minimap(pos3d)
			if minimap_ref.is_in_minimap(pos2d):
				draw_circle(pos2d, icon_size, Color(1.0, 0.15, 0.15, 0.9))

		# === Vẽ Pet ===
		if minimap_ref._has_pet:
			var pet_pos = minimap_ref.world_to_minimap(minimap_ref._pet_position)
			if minimap_ref.is_in_minimap(pet_pos):
				draw_circle(pet_pos, icon_size * 0.8, Color(0.7, 0.3, 1.0, 0.9))

		# === Vẽ Player dot ===
		var player_dot_size = minimap_ref.PLAYER_DOT_SIZE * (1.5 if minimap_ref.is_expanded else 1.0)
		var player_pos = minimap_ref.world_to_minimap(minimap_ref.player.global_position)
		draw_circle(player_pos, player_dot_size, Color(0.2, 0.6, 1.0, 1.0))
		draw_arc(player_pos, player_dot_size + 1, 0, TAU, 24, Color(1.0, 1.0, 1.0, 0.8), 1.5)

		# === Vẽ hướng player ===
		var forward_dir = -minimap_ref.player.transform.basis.z
		var arrow_dir = Vector2(forward_dir.x, forward_dir.z).normalized()
		var arrow_start = player_pos + arrow_dir * (player_dot_size + 2)
		var arrow_end = player_pos + arrow_dir * (player_dot_size + 8)
		draw_line(arrow_start, arrow_end, Color(0.4, 0.8, 1.0, 0.9), 2.0)

		# === Vẽ tên khu vực player đang ở (expanded) ===
		if minimap_ref.is_expanded:
			_draw_player_zone_name(player_pos)


	func _draw_zones() -> void:
		for zone in minimap_ref.ZONES:
			# Chuyển 4 góc từ world → minimap coordinates
			var top_left = minimap_ref.world_to_minimap(Vector3(zone["min_x"], 0, zone["min_z"]))
			var bottom_right = minimap_ref.world_to_minimap(Vector3(zone["max_x"], 0, zone["max_z"]))

			var rect_pos = Vector2(min(top_left.x, bottom_right.x), min(top_left.y, bottom_right.y))
			var rect_size = Vector2(abs(bottom_right.x - top_left.x), abs(bottom_right.y - top_left.y))

			if rect_size.x < 2 or rect_size.y < 2:
				continue

			# Nền vùng
			draw_rect(Rect2(rect_pos, rect_size), zone["color"])
			# Viền vùng
			draw_rect(Rect2(rect_pos, rect_size), zone["border_color"], false, 1.5)

			# Tên khu vực
			var center = rect_pos + rect_size / 2.0
			var label_text = zone["icon"] + " " + zone["name"]
			var font = ThemeDB.fallback_font
			if font:
				var font_size = 13
				var text_size = font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
				# Chỉ vẽ nếu vùng đủ lớn
				if rect_size.x > text_size.x * 0.6:
					var text_pos = center - Vector2(text_size.x / 2.0, -text_size.y / 4.0)
					draw_string(font, text_pos + Vector2(1, 1), label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, 0.8))
					draw_string(font, text_pos, label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, zone["label_color"])


	func _draw_player_zone_name(player_pos: Vector2) -> void:
		var px = minimap_ref.player.global_position.x
		var pz = minimap_ref.player.global_position.z
		var zone_name := "🗺️ Ngoại Ô"
		var zone_color := Color(0.6, 0.6, 0.6)

		for zone in minimap_ref.ZONES:
			if px >= zone["min_x"] and px <= zone["max_x"] and pz >= zone["min_z"] and pz <= zone["max_z"]:
				zone_name = zone["icon"] + " " + zone["name"]
				zone_color = zone["label_color"]
				break

		var font = ThemeDB.fallback_font
		if font:
			var font_size = 12
			var text_size = font.get_string_size(zone_name, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
			var text_pos = player_pos + Vector2(-text_size.x / 2.0, 18)
			draw_string(font, text_pos + Vector2(1, 1), zone_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0, 0, 0, 0.8))
			draw_string(font, text_pos, zone_name, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, zone_color)
