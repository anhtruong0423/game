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
	
	# Áp dụng style premium
	_style_premium_menu()
	
	# Scale background sprites vừa màn hình
	var vp_size = get_viewport_rect().size
	for bg_sprite in _find_bg_sprites(self):
		if bg_sprite.texture:
			var tex_size = bg_sprite.texture.get_size()
			if tex_size.x > 0 and tex_size.y > 0:
				var s = max(vp_size.x / tex_size.x, vp_size.y / tex_size.y)
				bg_sprite.scale = Vector2(s, s)
				bg_sprite.position = vp_size / 2.0
	
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
	
	# Animation entrance
	_animate_entrance()


## ==================== PREMIUM STYLING ====================

var _title_label: Label
var _bg_timer: float = 0.0
var _bg_rect: ColorRect
var _overlay_rect: ColorRect
var _fruit_labels: Array = []
var _particle_dots: Array = []
var _menu_buttons: Array = []
var _button_base_scales: Dictionary = {}

# Floating fruit config
const FRUIT_EMOJIS = ["🍎", "🍊", "🍇", "🍋", "🍓", "🍌", "🍒", "🍈", "🥭"]
const FRUIT_COUNT = 12
const PARTICLE_DOT_COUNT = 25


func _find_bg_sprites(node: Node) -> Array:
	var result := []
	for child in node.get_children():
		if child is Sprite2D and child.name.begins_with("Background"):
			result.append(child)
		result.append_array(_find_bg_sprites(child))
	return result


func _style_premium_menu():
	# === Deep dark gradient background ===
	_bg_rect = get_node_or_null("Background")
	if not _bg_rect:
		_bg_rect = ColorRect.new()
		_bg_rect.name = "Background"
		_bg_rect.anchors_preset = Control.PRESET_FULL_RECT
		_bg_rect.anchor_right = 1.0
		_bg_rect.anchor_bottom = 1.0
		add_child(_bg_rect)
		move_child(_bg_rect, 0)
	_bg_rect.color = Color(0.02, 0.03, 0.08, 0.45)  # Dark overlay
	
	_overlay_rect = get_node_or_null("GradientOverlay")
	if not _overlay_rect:
		_overlay_rect = ColorRect.new()
		_overlay_rect.name = "GradientOverlay"
		_overlay_rect.anchors_preset = Control.PRESET_FULL_RECT
		_overlay_rect.anchor_right = 1.0
		_overlay_rect.anchor_bottom = 1.0
		add_child(_overlay_rect)
		move_child(_overlay_rect, 1)
	_overlay_rect.color = Color(0.02, 0.08, 0.05, 0.3)
	
	# Thêm vignette overlay tối hơn ở viền
	var vignette = ColorRect.new()
	vignette.name = "Vignette"
	vignette.layout_mode = 1
	vignette.anchors_preset = Control.PRESET_FULL_RECT
	vignette.anchor_right = 1.0
	vignette.anchor_bottom = 1.0
	vignette.color = Color(0, 0, 0, 0.2)
	add_child(vignette)
	move_child(vignette, 2)
	
	# === Floating Particle Dots (ambient sparkles) ===
	_create_particle_dots()
	
	# === Floating Fruit Emojis ===
	_create_floating_fruits()
	
	# === Style Title ===
	_title_label = $MenuContainer/TitleLabel
	_title_label.text = "🌿 PickMiUp 🌿"
	_title_label.add_theme_font_size_override("font_size", 86)
	_title_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.45, 1))
	_title_label.add_theme_color_override("font_shadow_color", Color(0.0, 0.6, 0.2, 0.7))
	_title_label.add_theme_constant_override("shadow_offset_x", 4)
	_title_label.add_theme_constant_override("shadow_offset_y", 4)
	_title_label.add_theme_color_override("font_outline_color", Color(0.1, 0.3, 0.15, 0.5))
	_title_label.add_theme_constant_override("outline_size", 3)
	
	# === Style Subtitle ===
	var subtitle = $MenuContainer/Subtitle
	subtitle.text = "✨ Thu thập trái cây • Giao hàng • Khám phá thế giới ✨"
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color(0.65, 0.85, 0.7, 0.95))
	
	# === Separator line dưới subtitle ===
	var sep = ColorRect.new()
	sep.name = "Separator"
	sep.custom_minimum_size = Vector2(200, 2)
	sep.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	sep.color = Color(0.3, 0.8, 0.4, 0.4)
	$MenuContainer.add_child(sep)
	$MenuContainer.move_child(sep, 2)
	
	# === Thêm thông tin bổ sung ===
	var info_label = Label.new()
	info_label.name = "InfoLabel"
	info_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info_label.add_theme_font_size_override("font_size", 15)
	info_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.85, 0.8))
	if Global.best_score > 0:
		info_label.text = "🏆 Điểm cao nhất: " + str(Global.best_score) + "  •  Level: " + str(Global.current_level)
	else:
		info_label.text = "🎮 Chào mừng người chơi mới!"
	$MenuContainer.add_child(info_label)
	$MenuContainer.move_child(info_label, 3)
	
	# === Style tất cả buttons (cùng kích thước) ===
	var btn_size = Vector2(320, 55)
	_style_menu_button(play_button, Color(0.1, 0.6, 0.25), Color(0.15, 0.75, 0.35), "▶  Bắt Đầu Chơi", 26, btn_size)
	_style_menu_button(settings_button, Color(0.2, 0.3, 0.55), Color(0.25, 0.4, 0.7), "⚙️  Cài Đặt", 22, btn_size)
	_style_menu_button(tutorial_button, Color(0.18, 0.4, 0.48), Color(0.22, 0.52, 0.6), "📖  Hướng Dẫn", 22, btn_size)
	_style_menu_button(quit_button, Color(0.5, 0.15, 0.15), Color(0.6, 0.2, 0.2), "✖  Thoát", 22, btn_size)
	
	# Lưu danh sách buttons để animate hover
	_menu_buttons = [play_button, settings_button, tutorial_button, quit_button]
	for btn in _menu_buttons:
		# Set pivot_offset để scale từ giữa button
		btn.pivot_offset = btn.size / 2.0
		btn.mouse_entered.connect(_on_button_hover.bind(btn))
		btn.mouse_exited.connect(_on_button_unhover.bind(btn))
		_button_base_scales[btn] = btn.scale
	
	# Reset button nhỏ gọn, trong suốt hơn
	reset_button.custom_minimum_size = Vector2(140, 32)
	reset_button.add_theme_font_size_override("font_size", 12)
	reset_button.add_theme_color_override("font_color", Color(0.55, 0.35, 0.35, 0.5))
	var reset_style = StyleBoxFlat.new()
	reset_style.bg_color = Color(0.12, 0.08, 0.08, 0.25)
	reset_style.corner_radius_top_left = 6
	reset_style.corner_radius_top_right = 6
	reset_style.corner_radius_bottom_left = 6
	reset_style.corner_radius_bottom_right = 6
	reset_style.border_width_bottom = 1
	reset_style.border_color = Color(0.4, 0.2, 0.2, 0.3)
	reset_button.add_theme_stylebox_override("normal", reset_style)
	
	var reset_hover = StyleBoxFlat.new()
	reset_hover.bg_color = Color(0.2, 0.1, 0.1, 0.4)
	reset_hover.corner_radius_top_left = 6
	reset_hover.corner_radius_top_right = 6
	reset_hover.corner_radius_bottom_left = 6
	reset_hover.corner_radius_bottom_right = 6
	reset_hover.border_width_bottom = 1
	reset_hover.border_color = Color(0.5, 0.25, 0.25, 0.5)
	reset_button.add_theme_stylebox_override("hover", reset_hover)
	
	# === Version label ===
	var version = Label.new()
	version.text = "v1.0  •  PickMiUp © 2026"
	version.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	version.add_theme_font_size_override("font_size", 12)
	version.add_theme_color_override("font_color", Color(0.35, 0.35, 0.45, 0.45))
	version.anchors_preset = Control.PRESET_BOTTOM_RIGHT
	version.anchor_left = 1.0
	version.anchor_top = 1.0
	version.offset_left = -200
	version.offset_top = -30
	add_child(version)
	
	# === Cảnh báo chơi game ===
	var warning = Label.new()
	warning.text = "⚠️ Cảnh báo: Không chơi game quá 180 phút!"
	warning.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	warning.add_theme_font_size_override("font_size", 12)
	warning.add_theme_color_override("font_color", Color(1.0, 0.55, 0.3, 0.6))
	warning.anchors_preset = Control.PRESET_BOTTOM_LEFT
	warning.anchor_top = 1.0
	warning.offset_left = 10
	warning.offset_top = -30
	warning.size = Vector2(350, 25)
	add_child(warning)


## Tạo floating fruit emojis bay trên background
func _create_floating_fruits():
	for i in range(FRUIT_COUNT):
		var fruit = Label.new()
		fruit.text = FRUIT_EMOJIS[randi() % FRUIT_EMOJIS.size()]
		fruit.add_theme_font_size_override("font_size", randi_range(18, 36))
		fruit.modulate.a = randf_range(0.15, 0.35)
		fruit.position = Vector2(randf_range(0, 1200), randf_range(0, 700))
		fruit.z_index = -1
		# Lưu metadata vào meta
		fruit.set_meta("speed_x", randf_range(-15, 15))
		fruit.set_meta("speed_y", randf_range(-25, -8))
		fruit.set_meta("rotation_speed", randf_range(-0.5, 0.5))
		fruit.set_meta("wave_offset", randf_range(0, TAU))
		fruit.set_meta("wave_amplitude", randf_range(10, 30))
		add_child(fruit)
		move_child(fruit, 4)
		_fruit_labels.append(fruit)


## Tạo particle dots (chấm sáng nhỏ) bay trên background
func _create_particle_dots():
	for i in range(PARTICLE_DOT_COUNT):
		var dot = ColorRect.new()
		var dot_size = randf_range(1, 4)
		dot.size = Vector2(dot_size, dot_size)
		dot.color = Color(
			randf_range(0.3, 0.7),
			randf_range(0.6, 1.0),
			randf_range(0.3, 0.6),
			randf_range(0.1, 0.3)
		)
		dot.position = Vector2(randf_range(0, 1200), randf_range(0, 700))
		dot.z_index = -1
		dot.set_meta("speed_y", randf_range(-20, -5))
		dot.set_meta("speed_x", randf_range(-8, 8))
		dot.set_meta("wave_offset", randf_range(0, TAU))
		add_child(dot)
		move_child(dot, 3)
		_particle_dots.append(dot)


func _style_menu_button(btn: Button, base_color: Color, accent_color: Color, text: String, font_size: int, btn_size: Vector2 = Vector2(300, 55)):
	btn.text = text
	btn.custom_minimum_size = btn_size
	btn.add_theme_font_size_override("font_size", font_size)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	
	# Normal state - gradient-like effect
	var normal = StyleBoxFlat.new()
	normal.bg_color = base_color
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.border_width_bottom = 3
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.border_color = base_color.darkened(0.25)
	normal.content_margin_left = 24
	normal.content_margin_right = 24
	normal.content_margin_top = 12
	normal.content_margin_bottom = 12
	normal.shadow_color = Color(base_color.r, base_color.g, base_color.b, 0.25)
	normal.shadow_size = 6
	normal.shadow_offset = Vector2(0, 3)
	normal.anti_aliasing = true
	btn.add_theme_stylebox_override("normal", normal)
	
	# Hover state - brighter with glow border
	var hover = StyleBoxFlat.new()
	hover.bg_color = accent_color
	hover.corner_radius_top_left = 14
	hover.corner_radius_top_right = 14
	hover.corner_radius_bottom_left = 14
	hover.corner_radius_bottom_right = 14
	hover.border_width_bottom = 3
	hover.border_width_top = 1
	hover.border_width_left = 1
	hover.border_width_right = 1
	hover.border_color = accent_color.lightened(0.35)
	hover.content_margin_left = 24
	hover.content_margin_right = 24
	hover.content_margin_top = 12
	hover.content_margin_bottom = 12
	hover.shadow_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.45)
	hover.shadow_size = 10
	hover.shadow_offset = Vector2(0, 4)
	hover.anti_aliasing = true
	btn.add_theme_stylebox_override("hover", hover)
	
	# Pressed state - sunken dark
	var pressed = StyleBoxFlat.new()
	pressed.bg_color = base_color.darkened(0.15)
	pressed.corner_radius_top_left = 14
	pressed.corner_radius_top_right = 14
	pressed.corner_radius_bottom_left = 14
	pressed.corner_radius_bottom_right = 14
	pressed.border_width_top = 3
	pressed.border_width_left = 1
	pressed.border_width_right = 1
	pressed.border_color = base_color.darkened(0.4)
	pressed.content_margin_left = 24
	pressed.content_margin_right = 24
	pressed.content_margin_top = 14
	pressed.content_margin_bottom = 10
	pressed.shadow_color = Color(0, 0, 0, 0.15)
	pressed.shadow_size = 2
	pressed.shadow_offset = Vector2(0, 1)
	pressed.anti_aliasing = true
	btn.add_theme_stylebox_override("pressed", pressed)
	
	# Focus state
	var focus = StyleBoxFlat.new()
	focus.bg_color = accent_color.lightened(0.05)
	focus.corner_radius_top_left = 14
	focus.corner_radius_top_right = 14
	focus.corner_radius_bottom_left = 14
	focus.corner_radius_bottom_right = 14
	focus.border_width_bottom = 2
	focus.border_width_top = 2
	focus.border_width_left = 2
	focus.border_width_right = 2
	focus.border_color = Color(0.4, 1.0, 0.5, 0.7)
	focus.content_margin_left = 24
	focus.content_margin_right = 24
	focus.content_margin_top = 12
	focus.content_margin_bottom = 12
	focus.shadow_color = Color(0.2, 0.8, 0.3, 0.3)
	focus.shadow_size = 8
	focus.shadow_offset = Vector2(0, 2)
	focus.anti_aliasing = true
	btn.add_theme_stylebox_override("focus", focus)


## Button hover animation - scale up
func _on_button_hover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.06, 1.06), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


## Button unhover animation - scale back
func _on_button_unhover(btn: Button):
	var tween = create_tween()
	tween.tween_property(btn, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)


func _animate_entrance():
	# Fade in toàn bộ
	modulate.a = 0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.6).set_ease(Tween.EASE_OUT)
	
	# Title bounce từ trên xuống
	_title_label.modulate.a = 0
	_title_label.position.y -= 40
	var original_pos = _title_label.position.y + 40
	tween.parallel().tween_property(_title_label, "modulate:a", 1.0, 0.6).set_delay(0.1)
	tween.parallel().tween_property(_title_label, "position:y", original_pos, 0.7).set_delay(0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Subtitle fade in
	var subtitle = $MenuContainer/Subtitle
	subtitle.modulate.a = 0
	tween.parallel().tween_property(subtitle, "modulate:a", 1.0, 0.5).set_delay(0.3)
	
	# Buttons stagger fade in (không dịch chuyển position để giữ layout)
	var buttons = [play_button, settings_button, tutorial_button, quit_button]
	for i in range(buttons.size()):
		var btn = buttons[i]
		btn.modulate.a = 0
		var delay = 0.3 + i * 0.1
		tween.parallel().tween_property(btn, "modulate:a", 1.0, 0.4).set_delay(delay)
	
	# Reset button fade in cuối
	reset_button.modulate.a = 0
	tween.parallel().tween_property(reset_button, "modulate:a", 1.0, 0.3).set_delay(0.8)


func _process(delta):
	_bg_timer += delta
	
	# === Title shimmer/glow animation ===
	if _title_label:
		var t = _bg_timer * 2.0
		var glow = (sin(t) + 1.0) / 2.0
		var shimmer = (sin(t * 1.7 + 1.0) + 1.0) / 2.0
		_title_label.add_theme_color_override("font_color", Color(
			0.15 + shimmer * 0.15,
			0.8 + glow * 0.2,
			0.35 + shimmer * 0.15,
			1.0
		))
		_title_label.add_theme_color_override("font_shadow_color", Color(
			0.0, 0.4 + glow * 0.3, 0.15, 0.6 + glow * 0.2
		))
	
	# === Animated background breathing ===
	var bg_pulse = (sin(_bg_timer * 0.5) + 1.0) / 2.0
	if _bg_rect:
		_bg_rect.color = Color(
			0.02 + bg_pulse * 0.01,
			0.03 + bg_pulse * 0.01,
			0.08 + bg_pulse * 0.02,
			0.45
		)
	if _overlay_rect:
		_overlay_rect.color = Color(
			0.02 + bg_pulse * 0.02,
			0.08 + bg_pulse * 0.02,
			0.05 + bg_pulse * 0.01,
			0.25 + bg_pulse * 0.05
		)
	
	# === Float fruit emojis ===
	var viewport_size = get_viewport_rect().size
	for fruit in _fruit_labels:
		if not is_instance_valid(fruit):
			continue
		var sy: float = fruit.get_meta("speed_y")
		var sx: float = fruit.get_meta("speed_x")
		var wave_off: float = fruit.get_meta("wave_offset")
		var wave_amp: float = fruit.get_meta("wave_amplitude")
		
		fruit.position.y += sy * delta
		fruit.position.x += sx * delta + sin(_bg_timer * 0.8 + wave_off) * wave_amp * delta
		
		# Fade effect - trong suốt hơn gần viền
		var dist_from_center = abs(fruit.position.y - viewport_size.y / 2) / (viewport_size.y / 2)
		fruit.modulate.a = lerp(0.3, 0.08, clamp(dist_from_center, 0, 1))
		
		# Reset khi bay ra ngoài
		if fruit.position.y < -50:
			fruit.position.y = viewport_size.y + 50
			fruit.position.x = randf_range(0, viewport_size.x)
			fruit.text = FRUIT_EMOJIS[randi() % FRUIT_EMOJIS.size()]
		elif fruit.position.y > viewport_size.y + 50:
			fruit.position.y = -50
			fruit.position.x = randf_range(0, viewport_size.x)
	
	# === Float particle dots ===
	for dot in _particle_dots:
		if not is_instance_valid(dot):
			continue
		var dsy: float = dot.get_meta("speed_y")
		var dsx: float = dot.get_meta("speed_x")
		var dwave: float = dot.get_meta("wave_offset")
		
		dot.position.y += dsy * delta
		dot.position.x += dsx * delta + sin(_bg_timer + dwave) * 5.0 * delta
		
		# Twinkle effect
		dot.color.a = 0.1 + (sin(_bg_timer * 3.0 + dwave) + 1.0) / 2.0 * 0.25
		
		# Reset khi bay ra ngoài
		if dot.position.y < -10:
			dot.position.y = viewport_size.y + 10
			dot.position.x = randf_range(0, viewport_size.x)


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
