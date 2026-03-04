extends Control

## Game Over screen script
## Hiển thị score, best score và các nút điều hướng

@onready var background: ColorRect = $Background
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var best_score_label: Label = $VBoxContainer/BestScoreLabel
@onready var restart_button: Button = $VBoxContainer/RestartButton
@onready var main_menu_button: Button = $VBoxContainer/MainMenuButton
@onready var quit_button: Button = $VBoxContainer/QuitButton


func _ready() -> void:
	# Hiển thị con chuột để người chơi có thể click buttons
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Hiển thị score từ Global
	score_label.text = "Score: " + str(Global.last_score)
	best_score_label.text = "Best Score: " + str(Global.best_score)
	
	# Kết nối signals cho buttons
	restart_button.pressed.connect(_on_restart_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# === STYLE ===
	# Background nâu
	background.color = Color(0.72, 0.55, 0.40, 1.0)
	
	# Title style (font mặc định)
	title_label.add_theme_color_override("font_color", Color(0.3, 0.18, 0.06))  # Dark brown
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)
	
	# Score labels style (font mặc định)
	score_label.add_theme_color_override("font_color", Color(1, 1, 1))
	best_score_label.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	
	# Style buttons (font mặc định)
	_style_brown_button(restart_button, "CHƠI LẠI")
	_style_brown_button(main_menu_button, "MENU CHÍNH")
	_style_brown_button(quit_button, "THOÁT")
	
	# Bắt đầu animation fade in
	play_fade_in_animation()
	
	# Phát SFX game over và dừng nhạc nền
	AudioManager.stop_music()
	AudioManager.play_gameover_sfx()


func play_fade_in_animation() -> void:
	# Ẩn tất cả UI ban đầu
	background.color.a = 0
	title_label.modulate.a = 0
	score_label.modulate.a = 0
	best_score_label.modulate.a = 0
	restart_button.modulate.a = 0
	main_menu_button.modulate.a = 0
	quit_button.modulate.a = 0
	
	# Tạo tween cho fade in
	var tween = create_tween()
	tween.set_parallel(false)
	
	# Fade in background (0.5s)
	tween.tween_property(background, "color:a", 1.0, 0.5)
	
	# Fade in title (0.3s)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.3)
	
	# Fade in scores (0.3s mỗi cái)
	tween.tween_property(score_label, "modulate:a", 1.0, 0.3)
	tween.tween_property(best_score_label, "modulate:a", 1.0, 0.3)
	
	# Fade in buttons cùng lúc (0.3s)
	tween.set_parallel(true)
	tween.tween_property(restart_button, "modulate:a", 1.0, 0.3)
	tween.tween_property(main_menu_button, "modulate:a", 1.0, 0.3)
	tween.tween_property(quit_button, "modulate:a", 1.0, 0.3)


func _on_restart_pressed() -> void:
	AudioManager.stop_gameover_sfx()
	AudioManager.play_music()
	Global.go_to_scene("res://scene/main.tscn")


func _on_main_menu_pressed() -> void:
	AudioManager.stop_gameover_sfx()
	AudioManager.play_music()
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _style_brown_button(btn: Button, text: String):
	btn.text = text
	btn.custom_minimum_size = Vector2(220, 55)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	
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
	normal.border_color = Color(0.25, 0.15, 0.05)
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 10
	normal.content_margin_bottom = 10
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(0.65, 0.42, 0.18)
	hover.border_color = Color(0.3, 0.18, 0.06)
	btn.add_theme_stylebox_override("hover", hover)
	
	var pressed = normal.duplicate()
	pressed.bg_color = Color(0.40, 0.25, 0.10)
	pressed.border_color = Color(0.20, 0.12, 0.04)
	btn.add_theme_stylebox_override("pressed", pressed)
