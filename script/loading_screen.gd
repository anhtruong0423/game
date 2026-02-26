extends Control

## Loading screen - hiển thị trong lúc load scene nặng, chuyển ngay khi xong

var progress: Array = []
var target_path: String = ""
var loading_started := false
var loaded_scene: PackedScene = null

var progress_bar: ProgressBar
var percent_label: Label
var dots_label: Label
var dot_timer := 0.0
var dot_count := 0

var display_progress := 1.0
var real_progress := 1.0
const PROGRESS_LERP_SPEED := 30.0

var _bar_fill_style: StyleBoxFlat


func _ready():
	target_path = Global.next_scene_path
	if target_path == "":
		target_path = "res://scene/main.tscn"

	_build_ui()
	ResourceLoader.load_threaded_request(target_path, "", true)
	loading_started = true


func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.05, 0.05, 0.1, 1.0)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)

	var spacer_top = Control.new()
	spacer_top.custom_minimum_size = Vector2(0, 100)
	vbox.add_child(spacer_top)

	var title = Label.new()
	title.text = "PickMiUp"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.add_theme_color_override("font_color", Color(0.3, 0.85, 0.4))
	vbox.add_child(title)

	var spacer_mid = Control.new()
	spacer_mid.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(spacer_mid)

	var bar_center = CenterContainer.new()
	vbox.add_child(bar_center)

	var bar_box = VBoxContainer.new()
	bar_box.custom_minimum_size = Vector2(400, 0)
	bar_center.add_child(bar_box)

	dots_label = Label.new()
	dots_label.text = "Đang tải"
	dots_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots_label.add_theme_font_size_override("font_size", 18)
	dots_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
	bar_box.add_child(dots_label)

	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 8)
	bar_box.add_child(spacer)

	progress_bar = ProgressBar.new()
	progress_bar.custom_minimum_size = Vector2(400, 16)
	progress_bar.max_value = 100
	progress_bar.value = 1
	progress_bar.show_percentage = false
	bar_box.add_child(progress_bar)

	_bar_fill_style = StyleBoxFlat.new()
	_bar_fill_style.bg_color = Color(0.2, 0.75, 0.3)
	_bar_fill_style.corner_radius_top_left = 3
	_bar_fill_style.corner_radius_top_right = 3
	_bar_fill_style.corner_radius_bottom_left = 3
	_bar_fill_style.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("fill", _bar_fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.2, 0.8)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("background", bg_style)

	percent_label = Label.new()
	percent_label.text = "1%"
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_size_override("font_size", 14)
	percent_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	bar_box.add_child(percent_label)

	var spacer_tip = Control.new()
	spacer_tip.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer_tip)

	var tip = Label.new()
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 13)
	tip.add_theme_color_override("font_color", Color(0.45, 0.45, 0.55))
	var tips = [
		"Giữ Shift để chạy nhanh, nhưng tốn gấp đôi năng lượng!",
		"Uống sữa FRUMI để hồi phục năng lượng.",
		"Mang trái cây về rổ để hoàn thành nhiệm vụ.",
		"Nhặt đủ trái cây nhanh để đạt 3 sao!",
	]
	tip.text = tips[randi() % tips.size()]
	vbox.add_child(tip)


func _process(delta):
	if not loading_started:
		return

	dot_timer += delta
	if dot_timer >= 0.35:
		dot_timer = 0.0
		dot_count = (dot_count + 1) % 4
		dots_label.text = "Đang tải" + ".".repeat(dot_count)

	var status = ResourceLoader.load_threaded_get_status(target_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			real_progress = progress[0] * 100.0 if progress.size() > 0 else 1.0
			real_progress = max(1.0, real_progress)

		ResourceLoader.THREAD_LOAD_LOADED:
			real_progress = 100.0
			loading_started = false
			var scene = ResourceLoader.load_threaded_get(target_path)
			get_tree().change_scene_to_packed(scene)
			return

		ResourceLoader.THREAD_LOAD_FAILED:
			loading_started = false
			dots_label.text = "Lỗi! Đang thử lại..."
			get_tree().change_scene_to_file(target_path)
			return

	display_progress = move_toward(display_progress, real_progress, PROGRESS_LERP_SPEED * delta)
	progress_bar.value = display_progress
	percent_label.text = "%d%%" % int(display_progress)
