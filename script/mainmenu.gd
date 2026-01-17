extends Control

## Main Menu script
## Xử lý navigation giữa các màn hình và panels

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var settings_button: Button = $MenuContainer/SettingsButton
@onready var tutorial_button: Button = $MenuContainer/TutorialButton
@onready var quit_button: Button = $MenuContainer/QuitButton

@onready var settings_panel: Control = $SettingsPanel
@onready var settings_close_btn: Button = $SettingsPanel/Panel/VBoxContainer/CloseButton

@onready var tutorial_panel: Control = $TutorialPanel
@onready var tutorial_close_btn: Button = $TutorialPanel/Panel/VBoxContainer/CloseButton


func _ready() -> void:
	# Hiển thị con chuột
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Kết nối signals cho menu buttons
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Kết nối signals cho panel close buttons
	settings_close_btn.pressed.connect(_on_settings_close_pressed)
	tutorial_close_btn.pressed.connect(_on_tutorial_close_pressed)
	
	# Đảm bảo panels ẩn ban đầu
	settings_panel.visible = false
	tutorial_panel.visible = false


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scene/main.tscn")


func _on_settings_pressed() -> void:
	show_panel(settings_panel)


func _on_tutorial_pressed() -> void:
	show_panel(tutorial_panel)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_close_pressed() -> void:
	hide_panel(settings_panel)


func _on_tutorial_close_pressed() -> void:
	hide_panel(tutorial_panel)


## Hiển thị panel với animation fade in
func show_panel(panel: Control) -> void:
	panel.visible = true
	panel.modulate.a = 0
	
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.2)


## Ẩn panel với animation fade out
func hide_panel(panel: Control) -> void:
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func(): panel.visible = false)


## Xử lý phím ESC để đóng panels
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if settings_panel.visible:
			hide_panel(settings_panel)
		elif tutorial_panel.visible:
			hide_panel(tutorial_panel)

