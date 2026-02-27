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
	bg.color = Color(0.05, 0.08, 0.15, 1.0)
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
	title.add_theme_color_override("font_color", Color(1.0, 0.9, 0.3))
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
	main_vbox.add_child(menu_btn)


func _create_level_button(level: int) -> Button:
	var btn = Button.new()
	btn.name = "Level%dButton" % level
	btn.custom_minimum_size = Vector2(180, 120)

	var unlocked = _is_level_unlocked(level)
	var stars = Global.level_stars.get(level, 0)
	var level_name = LEVEL_NAMES.get(level, "Level %d" % level)

	# Nội dung nút
	var star_text = ""
	for s in range(3):
		if s < stars:
			star_text += "★"
		else:
			star_text += "☆"

	if unlocked:
		btn.text = "Level %d\n%s\n%s" % [level, level_name, star_text]
		btn.add_theme_font_size_override("font_size", 16)
		btn.pressed.connect(_on_level_selected.bind(level))
	else:
		btn.text = "Level %d\n🔒\nChưa mở khóa" % level
		btn.add_theme_font_size_override("font_size", 16)
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)

	return btn


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
