extends Control

## Level Select Screen - Bảng chọn level
## Hiển thị 6 level dạng grid, có khóa/mở khóa và hiển thị sao đã đạt

const LEVEL_COUNT := 6

const LEVEL_NAMES := {
	1: "Vườn trái cây",
	2: "Khu cam chanh",
	3: "Mùa hè rực rỡ",
	4: "Thu hoạch lớn",
	5: "Thử thách trái cây",
	6: "Siêu thu hoạch",
}

var level_buttons: Array[Button] = []


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	_build_ui()


func _build_ui():
	# Background
	var bg = ColorRect.new()
	bg.name = "Background"
	bg.anchors_preset = Control.PRESET_FULL_RECT
	bg.anchor_right = 1.0
	bg.anchor_bottom = 1.0
	bg.color = Color(0.72, 0.55, 0.40, 1.0)  # Pastel brown
	add_child(bg)

	# Main container
	var main_vbox = VBoxContainer.new()
	main_vbox.name = "MainVBox"
	main_vbox.anchors_preset = Control.PRESET_CENTER
	main_vbox.anchor_left = 0.5
	main_vbox.anchor_top = 0.5
	main_vbox.anchor_right = 0.5
	main_vbox.anchor_bottom = 0.5
	main_vbox.offset_left = -300
	main_vbox.offset_top = -250
	main_vbox.offset_right = 300
	main_vbox.offset_bottom = 250
	main_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	main_vbox.add_theme_constant_override("separation", 30)
	main_vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(main_vbox)

	# Title
	var title = Label.new()
	title.name = "TitleLabel"
	title.text = "CHỌN LEVEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 42)
	title.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	main_vbox.add_child(title)

	# Grid container cho các level buttons (3 cột x 2 hàng)
	var grid = GridContainer.new()
	grid.name = "LevelGrid"
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 20)
	grid.add_theme_constant_override("v_separation", 20)
	grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	main_vbox.add_child(grid)

	# Tạo 6 nút level
	for i in range(1, LEVEL_COUNT + 1):
		var btn = _create_level_button(i)
		grid.add_child(btn)
		level_buttons.append(btn)

	# Separator
	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 10)
	main_vbox.add_child(sep)

	# Nút quay về menu
	var menu_btn = Button.new()
	menu_btn.name = "BackMenuButton"
	menu_btn.text = "← Quay về Menu"
	menu_btn.custom_minimum_size = Vector2(200, 50)
	menu_btn.add_theme_font_size_override("font_size", 18)
	menu_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	menu_btn.pressed.connect(_on_menu_pressed)
	_style_brown_button(menu_btn)
	main_vbox.add_child(menu_btn)


func _create_level_button(level: int) -> Button:
	var btn = Button.new()
	btn.name = "Level%dButton" % level
	btn.custom_minimum_size = Vector2(180, 120)

	var unlocked = _is_level_unlocked(level)
	var stars = Global.level_stars.get(level, 0)
	var level_name = LEVEL_NAMES.get(level, "Level %d" % level)

	# Nội dung nút - tạo star text với màu vàng cho sao đã đạt
	var star_text = ""
	for s in range(3):
		if s < stars:
			star_text += "[color=#FFD700]★[/color]"
		else:
			star_text += "[color=#888888]☆[/color]"

	if unlocked:
		btn.text = "Level %d\n%s" % [level, level_name]
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_level_selected.bind(level))
		# Thêm RichTextLabel cho ngôi sao màu vàng
		var star_label = RichTextLabel.new()
		star_label.bbcode_enabled = true
		star_label.text = star_text
		star_label.fit_content = true
		star_label.scroll_active = false
		star_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		star_label.anchors_preset = Control.PRESET_BOTTOM_WIDE
		star_label.anchor_top = 1.0
		star_label.anchor_bottom = 1.0
		star_label.offset_top = -30.0
		star_label.offset_bottom = -5.0
		star_label.add_theme_font_size_override("normal_font_size", 22)
		# Căn giữa text
		star_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		btn.add_child(star_label)
	else:
		btn.text = "Level %d\n🔒\nChưa mở khóa" % level
		btn.add_theme_font_size_override("font_size", 16)
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)

	_style_brown_button(btn)
	return btn


func _style_brown_button(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.55, 0.35, 0.12)
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.border_width_top = 3
	normal.border_width_bottom = 3
	normal.border_width_left = 3
	normal.border_width_right = 3
	normal.border_color = Color(0.25, 0.15, 0.05)  # Dark brown
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	normal.anti_aliasing = true
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.65, 0.42, 0.18)
	hover.corner_radius_top_left = 14
	hover.corner_radius_top_right = 14
	hover.corner_radius_bottom_left = 14
	hover.corner_radius_bottom_right = 14
	hover.border_width_top = 3
	hover.border_width_bottom = 3
	hover.border_width_left = 3
	hover.border_width_right = 3
	hover.border_color = Color(0.3, 0.18, 0.06)
	hover.content_margin_left = 10
	hover.content_margin_right = 10
	hover.content_margin_top = 8
	hover.content_margin_bottom = 8
	hover.anti_aliasing = true
	btn.add_theme_stylebox_override("hover", hover)
	
	var disabled_style = StyleBoxFlat.new()
	disabled_style.bg_color = Color(0.4, 0.3, 0.2, 0.5)
	disabled_style.corner_radius_top_left = 14
	disabled_style.corner_radius_top_right = 14
	disabled_style.corner_radius_bottom_left = 14
	disabled_style.corner_radius_bottom_right = 14
	disabled_style.border_width_top = 2
	disabled_style.border_width_bottom = 2
	disabled_style.border_width_left = 2
	disabled_style.border_width_right = 2
	disabled_style.border_color = Color(0.25, 0.15, 0.05, 0.4)
	disabled_style.content_margin_left = 10
	disabled_style.content_margin_right = 10
	disabled_style.content_margin_top = 8
	disabled_style.content_margin_bottom = 8
	disabled_style.anti_aliasing = true
	btn.add_theme_stylebox_override("disabled", disabled_style)
	
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))


func _is_level_unlocked(level: int) -> bool:
	if level == 1:
		return true
	return Global.level_stars.get(level - 1, 0) >= 1


func _on_level_selected(level: int):
	Global.current_level = level
	Global.dialogue_mode = "level"
	get_tree().change_scene_to_file("res://scene/dialogue.tscn")


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")
