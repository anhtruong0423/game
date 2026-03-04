extends Node

## Zone Indicator - Hiển thị tên khu vực trên HUD khi player di chuyển
## Chia bản đồ thành các vùng, khi player vào vùng mới sẽ hiện tên với hiệu ứng fade

## Định nghĩa các khu vực bằng AABB (min_x, max_x, min_z, max_z)
## Dựa trên MILK_SPAWN_POSITIONS trong level_manager.gd
const ZONES = [
	{
		"name": "Khu Trung Tâm",
		"subtitle": "FrumiShop & Thùng rác",
		"color": Color(0.3, 0.9, 0.4),
		"min_x": 95.0, "max_x": 130.0,
		"min_z": 60.0, "max_z": 90.0,
	},
	{
		"name": "Đường Chính",
		"subtitle": "Con đường lớn xuyên nông trại",
		"color": Color(0.9, 0.8, 0.3),
		"min_x": -130.0, "max_x": 170.0,
		"min_z": 82.0, "max_z": 95.0,
	},
	{
		"name": "Cánh Đồng",
		"subtitle": "Khu vực canh tác",
		"color": Color(0.4, 0.8, 0.3),
		"min_x": -110.0, "max_x": 60.0,
		"min_z": 40.0, "max_z": 70.0,
	},
	{
		"name": "Khu Nhà Cửa",
		"subtitle": "Khu dân cư yên tĩnh",
		"color": Color(0.7, 0.5, 0.3),
		"min_x": -30.0, "max_x": 140.0,
		"min_z": 15.0, "max_z": 40.0,
	},
	{
		"name": "Vùng Tây",
		"subtitle": "Vùng hoang dã phía tây",
		"color": Color(0.3, 0.6, 0.8),
		"min_x": -220.0, "max_x": -110.0,
		"min_z": 55.0, "max_z": 95.0,
	},
	{
		"name": "Vùng Đông",
		"subtitle": "Phía đông nông trại",
		"color": Color(0.3, 0.6, 0.8),
		"min_x": 140.0, "max_x": 270.0,
		"min_z": 55.0, "max_z": 95.0,
	},
]

var player: CharacterBody3D = null
var current_zone_name: String = ""
var zone_label: Label = null
var subtitle_label: Label = null
var zone_panel: PanelContainer = null
var _check_timer: float = 0.0
const CHECK_INTERVAL := 0.5  ## Kiểm tra mỗi 0.5 giây

## Animation
var _fade_tween: Tween = null
var _is_showing := false
var _display_timer := 0.0
const DISPLAY_DURATION := 3.0  ## Hiển thị 3 giây


func setup(player_node: CharacterBody3D, hud: CanvasLayer) -> void:
	player = player_node
	_create_zone_ui(hud)


func _process(delta: float) -> void:
	if not player:
		return

	# Throttle zone check
	_check_timer += delta
	if _check_timer >= CHECK_INTERVAL:
		_check_timer = 0.0
		_check_zone()

	# Auto-hide sau thời gian hiển thị
	if _is_showing:
		_display_timer += delta
		if _display_timer >= DISPLAY_DURATION:
			_hide_zone_name()


func _create_zone_ui(hud: CanvasLayer) -> void:
	# Container chính - giữa trên màn hình
	zone_panel = PanelContainer.new()
	zone_panel.name = "ZoneIndicator"
	zone_panel.anchor_left = 0.5
	zone_panel.anchor_right = 0.5
	zone_panel.anchor_top = 0.0
	zone_panel.anchor_bottom = 0.0
	zone_panel.offset_left = -160
	zone_panel.offset_right = 160
	zone_panel.offset_top = 50
	zone_panel.offset_bottom = 110
	zone_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	zone_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	zone_panel.modulate.a = 0.0  # Bắt đầu ẩn

	# Style nền
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.12, 0.75)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_color = Color(0.4, 0.7, 0.9, 0.5)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.content_margin_left = 16
	style.content_margin_right = 16
	style.content_margin_top = 8
	style.content_margin_bottom = 8
	zone_panel.add_theme_stylebox_override("panel", style)
	hud.add_child(zone_panel)

	# VBox cho tên + phụ đề
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 2)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	zone_panel.add_child(vbox)

	# Label tên khu vực
	zone_label = Label.new()
	zone_label.name = "ZoneName"
	zone_label.text = ""
	zone_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	zone_label.add_theme_font_size_override("font_size", 22)
	zone_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	zone_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	zone_label.add_theme_constant_override("shadow_offset_x", 2)
	zone_label.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(zone_label)

	# Label phụ đề
	subtitle_label = Label.new()
	subtitle_label.name = "ZoneSubtitle"
	subtitle_label.text = ""
	subtitle_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_font_size_override("font_size", 13)
	subtitle_label.add_theme_color_override("font_color", Color(0.7, 0.8, 0.9, 0.8))
	vbox.add_child(subtitle_label)


func _check_zone() -> void:
	if not player:
		return

	var px = player.global_position.x
	var pz = player.global_position.z
	var new_zone := ""
	var new_subtitle := ""
	var new_color := Color(1, 1, 1)

	# Ưu tiên zone nhỏ hơn (Khu Trung Tâm) trước
	for zone in ZONES:
		if px >= zone["min_x"] and px <= zone["max_x"] and pz >= zone["min_z"] and pz <= zone["max_z"]:
			new_zone = zone["name"]
			new_subtitle = zone["subtitle"]
			new_color = zone["color"]
			break

	if new_zone == "":
		new_zone = "Ngoại Ô"
		new_subtitle = "Vùng chưa khám phá"
		new_color = Color(0.6, 0.6, 0.6)

	# Chỉ hiện khi đổi vùng
	if new_zone != current_zone_name:
		current_zone_name = new_zone
		_show_zone_name(new_zone, new_subtitle, new_color)


func _show_zone_name(zone_name: String, subtitle: String, color: Color) -> void:
	if not zone_label or not zone_panel:
		return

	zone_label.text = zone_name
	zone_label.add_theme_color_override("font_color", color)
	subtitle_label.text = subtitle

	_is_showing = true
	_display_timer = 0.0

	# Cancel tween cũ
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Fade in
	_fade_tween = player.get_tree().create_tween()
	_fade_tween.tween_property(zone_panel, "modulate:a", 1.0, 0.4).set_ease(Tween.EASE_OUT)


func _hide_zone_name() -> void:
	_is_showing = false

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	# Fade out
	_fade_tween = player.get_tree().create_tween()
	_fade_tween.tween_property(zone_panel, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
