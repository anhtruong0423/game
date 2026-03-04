extends Control

## Pet Selection Screen - Chọn thú cưng đi cùng

@onready var background: ColorRect = $Background

@onready var fox_btn: Button = $VBoxContainer/PetsContainer/FoxContainer/SelectButton
@onready var turtle_btn: Button = $VBoxContainer/PetsContainer/TurtleContainer/SelectButton

@onready var fox_container: VBoxContainer = $VBoxContainer/PetsContainer/FoxContainer
@onready var turtle_container: VBoxContainer = $VBoxContainer/PetsContainer/TurtleContainer

var selected_pet := ""


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Đổi background sang nâu
	background.color = Color(0.72, 0.55, 0.40, 1)  # Pastel brown
	
	# Style avatar panels - nền pastel nâu, border dark brown, bo tròn
	_style_avatar_panel($VBoxContainer/PetsContainer/FoxContainer/Avatar)
	_style_avatar_panel($VBoxContainer/PetsContainer/TurtleContainer/Avatar)
	
	# Style select buttons - nâu
	_style_select_button(fox_btn)
	_style_select_button(turtle_btn)
	
	# Đổi tất cả chữ sang trắng
	_set_label_white($VBoxContainer/Title)
	_set_label_white($VBoxContainer/Subtitle)
	_set_label_white($VBoxContainer/PetsContainer/FoxContainer/Name)
	_set_label_white($VBoxContainer/PetsContainer/FoxContainer/Trait)
	_set_label_white($VBoxContainer/PetsContainer/FoxContainer/Speed)
	_set_label_white($VBoxContainer/PetsContainer/TurtleContainer/Name)
	_set_label_white($VBoxContainer/PetsContainer/TurtleContainer/Trait)
	_set_label_white($VBoxContainer/PetsContainer/TurtleContainer/Speed)
	
	# Bọc tính năng trong shape + đổi chữ nâu đậm
	_style_pet_features(fox_container)
	_style_pet_features(turtle_container)

	fox_btn.pressed.connect(_on_fox_selected)
	turtle_btn.pressed.connect(_on_turtle_selected)

	if Global.selected_pet != "":
		selected_pet = Global.selected_pet
		update_selection_ui()


func _on_fox_selected():
	selected_pet = "fox"
	update_selection_ui()
	start_game()


func _on_turtle_selected():
	selected_pet = "turtle"
	update_selection_ui()
	start_game()


func update_selection_ui():
	# Mặc định: cả hai nhạt nhẹ
	fox_container.modulate = Color(1, 1, 1, 0.75)
	turtle_container.modulate = Color(1, 1, 1, 0.75)
	fox_container.scale = Vector2(0.95, 0.95)
	turtle_container.scale = Vector2(0.95, 0.95)

	match selected_pet:
		"fox":
			fox_container.modulate = Color(1, 1, 1, 1)
			fox_container.scale = Vector2(1.05, 1.05)
		"turtle":
			turtle_container.modulate = Color(1, 1, 1, 1)
			turtle_container.scale = Vector2(1.05, 1.05)


func start_game():
	if selected_pet == "":
		return

	Global.select_pet(selected_pet)
	
	# Pet select giờ chỉ hiện SAU dialogue (Level 2+)
	# Nên sau khi chọn pet xong → vào game trực tiếp
	Global.go_to_scene("res://scene/main.tscn")


func _style_avatar_panel(panel: Panel):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.75, 0.6, 0.45, 0.6)  # Pastel nâu
	style.corner_radius_top_left = 20
	style.corner_radius_top_right = 20
	style.corner_radius_bottom_left = 20
	style.corner_radius_bottom_right = 20
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_color = Color(0.25, 0.15, 0.05)  # Dark brown
	style.anti_aliasing = true
	panel.add_theme_stylebox_override("panel", style)


func _style_select_button(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.55, 0.35, 0.12)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_color = Color(0.25, 0.15, 0.05)
	normal.anti_aliasing = true
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.65, 0.42, 0.18)
	hover.corner_radius_top_left = 12
	hover.corner_radius_top_right = 12
	hover.corner_radius_bottom_left = 12
	hover.corner_radius_bottom_right = 12
	hover.border_width_top = 2
	hover.border_width_bottom = 2
	hover.border_width_left = 2
	hover.border_width_right = 2
	hover.border_color = Color(0.3, 0.18, 0.06)
	hover.anti_aliasing = true
	btn.add_theme_stylebox_override("hover", hover)
	
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))


func _set_label_white(label: Label):
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))


func _style_pet_features(container: VBoxContainer):
	# Tìm các Bonus labels
	var bonus_labels := []
	for child in container.get_children():
		if child is Label and child.name.begins_with("Bonus"):
			bonus_labels.append(child)
	
	if bonus_labels.is_empty():
		return
	
	# Tạo Panel shape bọc các tính năng
	var features_panel = PanelContainer.new()
	features_panel.name = "FeaturesShape"
	
	# Style shape - nền pastel nâu nhạt, bo tròn, border dark brown
	var shape_style = StyleBoxFlat.new()
	shape_style.bg_color = Color(0.85, 0.72, 0.58, 0.5)  # Pastel nâu nhạt
	shape_style.corner_radius_top_left = 14
	shape_style.corner_radius_top_right = 14
	shape_style.corner_radius_bottom_left = 14
	shape_style.corner_radius_bottom_right = 14
	shape_style.border_width_top = 2
	shape_style.border_width_bottom = 2
	shape_style.border_width_left = 2
	shape_style.border_width_right = 2
	shape_style.border_color = Color(0.25, 0.15, 0.05)  # Dark brown
	shape_style.content_margin_left = 12
	shape_style.content_margin_right = 12
	shape_style.content_margin_top = 8
	shape_style.content_margin_bottom = 8
	shape_style.anti_aliasing = true
	features_panel.add_theme_stylebox_override("panel", shape_style)
	
	# Tạo VBox trong panel
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 4)
	
	# Lấy vị trí insert (trước Bonus1)
	var insert_idx = bonus_labels[0].get_index()
	
	# Di chuyển bonus labels vào vbox
	for label in bonus_labels:
		label.get_parent().remove_child(label)
		# Đổi chữ sang nâu đậm
		label.add_theme_color_override("font_color", Color(0.3, 0.18, 0.06))
		vbox.add_child(label)
	
	features_panel.add_child(vbox)
	container.add_child(features_panel)
	container.move_child(features_panel, insert_idx)
