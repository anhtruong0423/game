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
	
	# Bắt đầu animation fade in
	play_fade_in_animation()


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
	tween.tween_property(background, "color:a", 0.8, 0.5)
	
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
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_main_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
