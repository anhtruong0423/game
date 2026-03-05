extends Control

## Loading screen - preload scene chính + tất cả sub-scene nặng để tránh giật lag

var progress: Array = []
var target_path: String = ""
var loading_started := false

var progress_bar: ProgressBar
var percent_label: Label
var dots_label: Label
var dot_timer := 0.0
var dot_count := 0

var display_progress := 1.0
var real_progress := 1.0
const PROGRESS_LERP_SPEED := 30.0

var _bar_fill_style: StyleBoxFlat

## Preload sub-scene nặng (items, pets, milk, dog, shop...)
const PRELOAD_SCENES: Array = [
	"res://scene/items/chainhua.tscn",
	"res://scene/items/chaisua.tscn",
	"res://scene/items/giaybaocu.tscn",
	"res://scene/items/hopsuacu.tscn",
	"res://scene/items/lonnuocngot.tscn",
	"res://scene/items/thungcarton.tscn",
	"res://scene/items/tuigiay.tscn",
	"res://scene/items/tuinilong.tscn",
	"res://scene/items/voxecu.tscn",
	"res://scene/milk_grape.tscn",
	"res://scene/milk_melon.tscn",
	"res://scene/milk_strawberry.tscn",
	"res://scene/dog.tscn",
	"res://scene/fox.tscn",
	"res://scene/turtle.tscn",
	"res://scene/basket.tscn",
	"res://scene/frumishop.tscn",
]

## Trạng thái loading
enum LoadPhase { MAIN_SCENE, SUB_SCENES, DONE }
var _phase: int = LoadPhase.MAIN_SCENE
var _sub_index: int = 0
var _cached_scenes: Array = []  ## Giữ reference để không bị GC


func _ready():
	target_path = Global.next_scene_path
	if target_path == "":
		target_path = "res://scene/main.tscn"

	_build_ui()
	ResourceLoader.load_threaded_request(target_path, "", true)
	loading_started = true
	_phase = LoadPhase.MAIN_SCENE


func _build_ui():
	var bg = ColorRect.new()
	bg.color = Color(0.72, 0.55, 0.40, 1.0)  # Pastel brown
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	
	# Load font Melon Pop
	var melon_font = load("res://assets/font/Melon Pop.ttf")

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
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.3, 0.18, 0.06))  # Dark brown
	if melon_font:
		title.add_theme_font_override("font", melon_font)
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
	dots_label.add_theme_font_size_override("font_size", 20)
	dots_label.add_theme_color_override("font_color", Color(0.3, 0.18, 0.06))  # Dark brown
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
	_bar_fill_style.bg_color = Color(0.55, 0.35, 0.12)  # Brown
	_bar_fill_style.corner_radius_top_left = 6
	_bar_fill_style.corner_radius_top_right = 6
	_bar_fill_style.corner_radius_bottom_left = 6
	_bar_fill_style.corner_radius_bottom_right = 6
	progress_bar.add_theme_stylebox_override("fill", _bar_fill_style)

	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.85, 0.72, 0.58, 0.6)  # Pastel brown nhạt
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.corner_radius_bottom_right = 6
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_color = Color(0.25, 0.15, 0.05)  # Dark brown border
	progress_bar.add_theme_stylebox_override("background", bg_style)

	percent_label = Label.new()
	percent_label.text = "1%"
	percent_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	percent_label.add_theme_font_size_override("font_size", 14)
	percent_label.add_theme_color_override("font_color", Color(0.35, 0.22, 0.1))
	bar_box.add_child(percent_label)

	var spacer_tip = Control.new()
	spacer_tip.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer_tip)

	var tip = Label.new()
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tip.add_theme_font_size_override("font_size", 13)
	tip.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	var tips = [
		"Giữ Shift để chạy nhanh, nhưng tốn gấp đôi năng lượng!",
		"Uống sữa FRUMI để hồi phục năng lượng.",
		"Mang rác về thùng tái chế để hoàn thành nhiệm vụ.",
		"Nhặt đủ rác nhanh để đạt 3 sao!",
		"Chọn thú cưng Cáo để nhặt xa hơn!",
		"Rùa hồi năng lượng khi bạn đứng yên bên cạnh!",
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

	match _phase:
		LoadPhase.MAIN_SCENE:
			_process_main_scene()
		LoadPhase.SUB_SCENES:
			_process_sub_scenes()
		LoadPhase.DONE:
			return

	display_progress = move_toward(display_progress, real_progress, PROGRESS_LERP_SPEED * delta)
	progress_bar.value = display_progress
	percent_label.text = "%d%%" % int(display_progress)


## Giai đoạn 1: Load scene chính (0% - 60%)
func _process_main_scene():
	var status = ResourceLoader.load_threaded_get_status(target_path, progress)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var p = progress[0] if progress.size() > 0 else 0.0
			real_progress = max(1.0, p * 60.0)  # 0-60%

		ResourceLoader.THREAD_LOAD_LOADED:
			real_progress = 60.0
			_phase = LoadPhase.SUB_SCENES
			_sub_index = 0

		ResourceLoader.THREAD_LOAD_FAILED:
			loading_started = false
			dots_label.text = "Lỗi! Đang thử lại..."
			get_tree().change_scene_to_file(target_path)


## Giai đoạn 2: Preload sub-scenes (60% - 100%), 1-2 scene mỗi frame
func _process_sub_scenes():
	# Load 2 scene mỗi frame để không block quá lâu
	var loaded_this_frame := 0
	while _sub_index < PRELOAD_SCENES.size() and loaded_this_frame < 2:
		var path = PRELOAD_SCENES[_sub_index]
		if ResourceLoader.exists(path):
			var res = load(path)
			if res:
				_cached_scenes.append(res)
		_sub_index += 1
		loaded_this_frame += 1

	# Cập nhật progress: 60% + (sub_progress * 40%)
	var sub_progress = float(_sub_index) / max(1, PRELOAD_SCENES.size())
	real_progress = 60.0 + sub_progress * 40.0

	# Hoàn thành tất cả sub-scenes → chuyển scene
	if _sub_index >= PRELOAD_SCENES.size():
		real_progress = 100.0
		_phase = LoadPhase.DONE
		loading_started = false
		var scene = ResourceLoader.load_threaded_get(target_path)
		get_tree().change_scene_to_packed(scene)

