extends Control

## Main Menu script
## Xử lý navigation giữa các màn hình và panels

@onready var play_button: Button = $MenuContainer/PlayButton
@onready var settings_button: Button = $MenuContainer/SettingsButton
@onready var tutorial_button: Button = $MenuContainer/TutorialButton
@onready var quit_button: Button = $MenuContainer/QuitButton
@onready var reset_button: Button = $MenuContainer/ResetButton

@onready var settings_panel: Control = $SettingsPanel
@onready var settings_save_btn: Button = $SettingsPanel/Panel/ButtonsContainer/SaveButton
@onready var settings_reset_btn: Button = $SettingsPanel/Panel/ButtonsContainer/ResetSettingsButton
@onready var settings_close_btn: Button = $SettingsPanel/Panel/ButtonsContainer/CloseButton

## Settings UI elements
@onready var brightness_slider: HSlider = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/BrightnessContainer/BrightnessSlider
@onready var brightness_value: Label = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/BrightnessContainer/BrightnessValue
@onready var fullscreen_check: CheckBox = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/FullscreenContainer/FullscreenCheck
@onready var vsync_check: CheckBox = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/VsyncContainer/VsyncCheck
@onready var master_slider: HSlider = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/MasterContainer/MasterSlider
@onready var master_value: Label = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/MasterContainer/MasterValue
@onready var music_slider: HSlider = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/MusicContainer/MusicSlider
@onready var music_value: Label = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/MusicContainer/MusicValue
@onready var sfx_slider: HSlider = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/SfxContainer/SfxSlider
@onready var sfx_value: Label = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/SfxContainer/SfxValue
@onready var sensitivity_slider: HSlider = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/SensitivityContainer/SensitivitySlider
@onready var sensitivity_value: Label = $SettingsPanel/Panel/ScrollContainer/VBoxContainer/SensitivityContainer/SensitivityValue

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
	reset_button.pressed.connect(_on_reset_pressed)
	
	# Kết nối signals cho settings panel buttons
	settings_save_btn.pressed.connect(_on_settings_save_pressed)
	settings_reset_btn.pressed.connect(_on_settings_reset_pressed)
	settings_close_btn.pressed.connect(_on_settings_close_pressed)
	
	# Kết nối signals cho settings sliders
	brightness_slider.value_changed.connect(_on_brightness_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	vsync_check.toggled.connect(_on_vsync_toggled)
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	sensitivity_slider.value_changed.connect(_on_sensitivity_changed)
	
	# Kết nối signals cho tutorial panel
	tutorial_close_btn.pressed.connect(_on_tutorial_close_pressed)
	
	# Đảm bảo panels ẩn ban đầu
	settings_panel.visible = false
	tutorial_panel.visible = false
	
	# Load settings vào UI
	load_settings_to_ui()


func _on_play_pressed() -> void:
	# Luôn mở Character Select trước
	get_tree().change_scene_to_file("res://scene/character_select.tscn")


func _on_settings_pressed() -> void:
	show_panel(settings_panel)


func _on_tutorial_pressed() -> void:
	show_panel(tutorial_panel)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_reset_pressed() -> void:
	Global.reset_all_data()
	# Reload main menu để cập nhật
	get_tree().reload_current_scene()


func _on_settings_close_pressed() -> void:
	hide_panel(settings_panel)


func _on_settings_save_pressed() -> void:
	Global.save_data()
	hide_panel(settings_panel)


func _on_settings_reset_pressed() -> void:
	Global.reset_settings()
	load_settings_to_ui()


func _on_tutorial_close_pressed() -> void:
	hide_panel(tutorial_panel)


## ==================== SETTINGS HANDLERS ====================

## Load settings từ Global vào UI
func load_settings_to_ui() -> void:
	# Brightness: 0.5-1.5 -> 50-150
	brightness_slider.value = Global.settings["brightness"] * 100
	brightness_value.text = str(int(brightness_slider.value)) + "%"
	
	# Fullscreen & VSync
	fullscreen_check.button_pressed = Global.settings["fullscreen"]
	vsync_check.button_pressed = Global.settings["vsync"]
	
	# Audio: 0.0-1.0 -> 0-100
	master_slider.value = Global.settings["master_volume"] * 100
	master_value.text = str(int(master_slider.value)) + "%"
	
	music_slider.value = Global.settings["music_volume"] * 100
	music_value.text = str(int(music_slider.value)) + "%"
	
	sfx_slider.value = Global.settings["sfx_volume"] * 100
	sfx_value.text = str(int(sfx_slider.value)) + "%"
	
	# Sensitivity: 0.001-0.005 -> 10-100
	# Formula: (sensitivity - 0.001) / 0.004 * 90 + 10
	var sens = Global.settings["mouse_sensitivity"]
	sensitivity_slider.value = (sens - 0.001) / 0.004 * 90 + 10
	sensitivity_value.text = str(int(sensitivity_slider.value)) + "%"


func _on_brightness_changed(value: float) -> void:
	brightness_value.text = str(int(value)) + "%"
	# Convert 50-150 -> 0.5-1.5
	Global.set_setting("brightness", value / 100.0)


func _on_fullscreen_toggled(pressed: bool) -> void:
	Global.set_setting("fullscreen", pressed)


func _on_vsync_toggled(pressed: bool) -> void:
	Global.set_setting("vsync", pressed)


func _on_master_changed(value: float) -> void:
	master_value.text = str(int(value)) + "%"
	Global.set_setting("master_volume", value / 100.0)


func _on_music_changed(value: float) -> void:
	music_value.text = str(int(value)) + "%"
	Global.set_setting("music_volume", value / 100.0)


func _on_sfx_changed(value: float) -> void:
	sfx_value.text = str(int(value)) + "%"
	Global.set_setting("sfx_volume", value / 100.0)


func _on_sensitivity_changed(value: float) -> void:
	sensitivity_value.text = str(int(value)) + "%"
	# Convert 10-100 -> 0.001-0.005
	# Formula: (value - 10) / 90 * 0.004 + 0.001
	var sens = (value - 10) / 90.0 * 0.004 + 0.001
	Global.set_setting("mouse_sensitivity", sens)


## ==================== UI HELPERS ====================

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
