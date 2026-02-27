extends Node

signal mission_updated(delivered_items: Dictionary)
signal level_can_pass()
signal level_completed(stars: int)

const ITEM_DISPLAY_NAMES = {
	"apple": "Táo",
	"banana": "Chuối",
	"cherry": "Cherry",
	"grape": "Nho",
	"lemon": "Chanh",
	"mango": "Xoài",
	"melon": "Dưa lưới",
	"orange": "Cam",
	"strawberry": "Dâu",
}

const LEVEL_DATA = {
	1: {
		"required_items": ["apple", "banana"],
		"min_to_pass": 1,
		"time_limit": 0,
		"star_conditions": {
			1: {"items": 1, "time": 0},
			2: {"items": 2, "time": 0},
			3: {"items": 2, "time": 0}
		},
		"spawn_items": [
			{"type": "apple", "position": Vector3(108, -133.5, 68)},
			{"type": "banana", "position": Vector3(116, -133.5, 73)},
		]
	},
	2: {
		"required_items": ["orange", "lemon", "grape"],
		"min_to_pass": 2,
		"time_limit": 300,
		"star_conditions": {
			1: {"items": 2, "time": 0},
			2: {"items": 3, "time": 0},
			3: {"items": 3, "time": 300}
		},
		"spawn_items": [
			{"type": "orange", "position": Vector3(105, -133.5, 66)},
			{"type": "lemon", "position": Vector3(118, -133.5, 72)},
			{"type": "grape", "position": Vector3(110, -133.5, 78)},
		]
	},
	3: {
		"required_items": ["strawberry", "mango", "melon"],
		"min_to_pass": 2,
		"time_limit": 240,
		"star_conditions": {
			1: {"items": 2, "time": 0},
			2: {"items": 3, "time": 0},
			3: {"items": 3, "time": 180}
		},
		"spawn_items": [
			{"type": "strawberry", "position": Vector3(106, -133.5, 74)},
			{"type": "mango", "position": Vector3(119, -133.5, 67)},
			{"type": "melon", "position": Vector3(112, -133.5, 80)},
		]
	},
	4: {
		"required_items": ["apple", "cherry", "orange", "mango"],
		"min_to_pass": 3,
		"time_limit": 240,
		"star_conditions": {
			1: {"items": 3, "time": 0},
			2: {"items": 4, "time": 0},
			3: {"items": 4, "time": 180}
		},
		"spawn_items": [
			{"type": "apple", "position": Vector3(104, -133.5, 70)},
			{"type": "cherry", "position": Vector3(120, -133.5, 74)},
			{"type": "orange", "position": Vector3(108, -133.5, 64)},
			{"type": "mango", "position": Vector3(117, -133.5, 80)},
		]
	},
	5: {
		"required_items": ["banana", "lemon", "grape", "strawberry", "melon"],
		"min_to_pass": 3,
		"time_limit": 210,
		"star_conditions": {
			1: {"items": 3, "time": 0},
			2: {"items": 4, "time": 0},
			3: {"items": 5, "time": 180}
		},
		"spawn_items": [
			{"type": "banana", "position": Vector3(103, -133.5, 67)},
			{"type": "lemon", "position": Vector3(121, -133.5, 71)},
			{"type": "grape", "position": Vector3(106, -133.5, 78)},
			{"type": "strawberry", "position": Vector3(118, -133.5, 64)},
			{"type": "melon", "position": Vector3(110, -133.5, 82)},
		]
	},
	6: {
		"required_items": ["apple", "cherry", "orange", "mango", "grape", "melon", "strawberry"],
		"min_to_pass": 4,
		"time_limit": 180,
		"star_conditions": {
			1: {"items": 4, "time": 0},
			2: {"items": 6, "time": 0},
			3: {"items": 7, "time": 150}
		},
		"spawn_items": [
			{"type": "apple", "position": Vector3(104, -133.5, 66)},
			{"type": "cherry", "position": Vector3(121, -133.5, 68)},
			{"type": "orange", "position": Vector3(106, -133.5, 75)},
			{"type": "mango", "position": Vector3(119, -133.5, 78)},
			{"type": "grape", "position": Vector3(110, -133.5, 82)},
			{"type": "melon", "position": Vector3(115, -133.5, 63)},
			{"type": "strawberry", "position": Vector3(108, -133.5, 71)},
		]
	},
}

const MILK_SCENES = [
	"res://scene/milk_grape.tscn",
	"res://scene/milk_melon.tscn",
	"res://scene/milk_strawberry.tscn",
]

const MILK_SPAWN_POSITIONS = [
	Vector3(110.5, -133.5, 70),
	Vector3(114, -133.5, 74),
	Vector3(107, -133.5, 68),
]

var current_level: int = 1
var delivered_items: Dictionary = {}
var elapsed_time: float = 0.0
var level_active: bool = true
var can_pass: bool = false
var time_expired: bool = false

## HUD references (created dynamically)
var timer_label: Label = null
var mission_container: VBoxContainer = null
var mission_items_ui: Dictionary = {}
var pass_notification: Label = null
var choice_panel: PanelContainer = null
var choice_shown: bool = false
var play_warning_label: Label = null
var play_warning_shown: bool = false
var total_play_time: float = 0.0


func _ready():
	add_to_group("level_manager")
	current_level = Global.current_level
	call_deferred("_setup_level")


func _process(delta):
	if not level_active:
		return

	elapsed_time += delta
	total_play_time += delta

	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return

	update_timer_display(data)

	# Cảnh báo chơi quá 180 phút (10800 giây)
	if total_play_time >= 10800.0 and not play_warning_shown:
		play_warning_shown = true
		show_play_time_warning()


func _setup_level():
	clear_existing_items()
	spawn_level_items()
	spawn_milk_items()
	setup_basket()
	setup_hud()
	update_mission_hud()


func clear_existing_items():
	var coins_node = get_parent().get_node_or_null("coins")
	if coins_node:
		for child in coins_node.get_children():
			child.queue_free()

	var milks_node = get_parent().get_node_or_null("milks")
	if milks_node:
		for child in milks_node.get_children():
			child.queue_free()


func spawn_level_items():
	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return

	var coins_node = get_parent().get_node_or_null("coins")
	if not coins_node:
		coins_node = Node3D.new()
		coins_node.name = "coins"
		get_parent().add_child(coins_node)

	for item_info in data["spawn_items"]:
		var scene_path = "res://scene/items/" + item_info["type"] + ".tscn"
		var scene = load(scene_path)
		if scene:
			var instance = scene.instantiate()
			instance.position = item_info["position"]
			coins_node.add_child(instance)


func spawn_milk_items():
	var milks_node = get_parent().get_node_or_null("milks")
	if milks_node:
		for child in milks_node.get_children():
			child.queue_free()
	else:
		milks_node = Node3D.new()
		milks_node.name = "milks"
		get_parent().add_child(milks_node)

	for i in range(MILK_SPAWN_POSITIONS.size()):
		var scene_path = MILK_SCENES[i % MILK_SCENES.size()]
		var scene = load(scene_path)
		if scene:
			var instance = scene.instantiate()
			instance.position = MILK_SPAWN_POSITIONS[i]
			milks_node.add_child(instance)


func setup_basket():
	var basket_node = get_parent().get_node_or_null("nhanvat")
	if not basket_node:
		return

	var existing = basket_node.get_node_or_null("BasketDelivery")
	if existing:
		existing.queue_free()

	var delivery = Node3D.new()
	delivery.name = "BasketDelivery"
	delivery.set_script(load("res://script/basket_delivery.gd"))
	basket_node.add_child(delivery)


func setup_hud():
	var player = _find_player()
	if not player:
		return

	var hud = player.get_node_or_null("HUD")
	if not hud:
		return

	_create_timer_label(hud)
	_create_mission_panel(hud)
	_create_pass_notification(hud)


func _create_timer_label(hud: CanvasLayer):
	timer_label = Label.new()
	timer_label.name = "TimerLabel"
	timer_label.text = ""
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.anchors_preset = Control.PRESET_TOP_LEFT
	timer_label.position = Vector2(15, 10)
	timer_label.size = Vector2(200, 40)
	hud.add_child(timer_label)

	var data = LEVEL_DATA.get(current_level, null)
	if data and data["time_limit"] == 0:
		timer_label.visible = false

	# Tạo label cảnh báo thời gian chơi
	_create_play_warning(hud)


func _create_play_warning(hud: CanvasLayer):
	var panel = PanelContainer.new()
	panel.name = "PlayWarningPanel"
	panel.anchors_preset = Control.PRESET_CENTER_TOP
	panel.anchor_left = 0.5
	panel.anchor_right = 0.5
	panel.offset_left = -200
	panel.offset_right = 200
	panel.offset_top = 5
	panel.offset_bottom = 40

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.6, 0.0, 0.0, 0.85)
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_left = 8
	style.corner_radius_bottom_right = 8
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(1.0, 0.2, 0.2, 1.0)
	style.content_margin_left = 10
	style.content_margin_right = 10
	style.content_margin_top = 5
	style.content_margin_bottom = 5
	panel.add_theme_stylebox_override("panel", style)
	hud.add_child(panel)

	play_warning_label = Label.new()
	play_warning_label.text = "⚠️ Cảnh báo: Không chơi game quá 180 phút!"
	play_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	play_warning_label.add_theme_font_size_override("font_size", 15)
	play_warning_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	panel.add_child(play_warning_label)


func _create_mission_panel(hud: CanvasLayer):
	var panel = PanelContainer.new()
	panel.name = "MissionPanel"
	panel.anchors_preset = Control.PRESET_TOP_RIGHT
	panel.anchor_left = 1.0
	panel.anchor_right = 1.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = -220
	panel.offset_right = -10
	panel.offset_top = 60
	panel.offset_bottom = 250
	panel.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	hud.add_child(panel)

	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 8)
	panel.add_child(margin)

	var vbox = VBoxContainer.new()
	margin.add_child(vbox)

	var title = Label.new()
	title.text = "Nhiệm vụ - Level " + str(current_level)
	title.add_theme_font_size_override("font_size", 18)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep = HSeparator.new()
	vbox.add_child(sep)

	mission_container = VBoxContainer.new()
	mission_container.name = "MissionItems"
	vbox.add_child(mission_container)


func _create_pass_notification(hud: CanvasLayer):
	pass_notification = Label.new()
	pass_notification.name = "PassNotification"
	pass_notification.text = ""
	pass_notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pass_notification.add_theme_font_size_override("font_size", 20)
	pass_notification.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
	pass_notification.anchors_preset = Control.PRESET_CENTER_BOTTOM
	pass_notification.position = Vector2(-200, -80)
	pass_notification.size = Vector2(400, 40)
	pass_notification.visible = false
	hud.add_child(pass_notification)


func update_timer_display(data: Dictionary):
	if not timer_label:
		return

	if data["time_limit"] == 0:
		return

	var remaining = max(0, data["time_limit"] - elapsed_time)
	var minutes = int(remaining) / 60
	var seconds = int(remaining) % 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

	if remaining <= 30:
		timer_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	elif remaining <= 60:
		timer_label.add_theme_color_override("font_color", Color(1, 0.8, 0.2))
	else:
		timer_label.remove_theme_color_override("font_color")

	if remaining <= 0 and not time_expired:
		time_expired = true


func update_mission_hud():
	if not mission_container:
		return

	for child in mission_container.get_children():
		child.queue_free()
	mission_items_ui.clear()

	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return

	for item_type in data["required_items"]:
		var hbox = HBoxContainer.new()

		var check = Label.new()
		check.custom_minimum_size = Vector2(24, 0)
		check.add_theme_font_size_override("font_size", 16)
		if delivered_items.has(item_type):
			check.text = "[v]"
			check.add_theme_color_override("font_color", Color(0.2, 1.0, 0.2))
		else:
			check.text = "[ ]"
			check.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		hbox.add_child(check)

		var name_label = Label.new()
		name_label.text = ITEM_DISPLAY_NAMES.get(item_type, item_type)
		name_label.add_theme_font_size_override("font_size", 16)
		if delivered_items.has(item_type):
			name_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		hbox.add_child(name_label)

		mission_container.add_child(hbox)
		mission_items_ui[item_type] = hbox


func on_items_delivered(types: Array):
	for t in types:
		if t != "":
			delivered_items[t] = true

	update_mission_hud()
	check_mission_progress()
	mission_updated.emit(delivered_items)


func check_mission_progress():
	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return

	var count = get_delivered_count()

	if count >= data["min_to_pass"] and not can_pass:
		can_pass = true
		show_pass_notification()
		show_choice_panel()
		level_can_pass.emit()

	var all_done = count >= data["required_items"].size()
	if all_done and not choice_shown:
		# Nếu hoàn thành tất cả mà chưa hiện panel thì auto complete
		complete_level()


func get_delivered_count() -> int:
	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return 0
	var count = 0
	for item_type in data["required_items"]:
		if delivered_items.has(item_type):
			count += 1
	return count


func calculate_stars() -> int:
	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return 0

	var count = get_delivered_count()
	var stars = 0

	for star_level in [3, 2, 1]:
		var cond = data["star_conditions"][star_level]
		var items_ok = count >= cond["items"]
		var time_ok = cond["time"] == 0 or elapsed_time <= cond["time"]
		if items_ok and time_ok:
			stars = star_level
			break

	return stars


func show_pass_notification():
	if not pass_notification:
		return

	var stars = calculate_stars()
	pass_notification.text = "Đạt %d sao! Tiếp tục nhặt để đạt 3 sao." % stars
	pass_notification.visible = true


func show_choice_panel():
	if choice_shown:
		return
	choice_shown = true

	var player = _find_player()
	if not player:
		return
	var hud = player.get_node_or_null("HUD")
	if not hud:
		return

	# Tạo panel chọn
	choice_panel = PanelContainer.new()
	choice_panel.name = "ChoicePanel"
	choice_panel.anchors_preset = Control.PRESET_CENTER
	choice_panel.anchor_left = 0.5
	choice_panel.anchor_right = 0.5
	choice_panel.anchor_top = 0.5
	choice_panel.anchor_bottom = 0.5
	choice_panel.offset_left = -180
	choice_panel.offset_right = 180
	choice_panel.offset_top = -80
	choice_panel.offset_bottom = 80

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.15, 0.92)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_color = Color(0.3, 0.8, 0.4, 0.8)
	choice_panel.add_theme_stylebox_override("panel", style)
	hud.add_child(choice_panel)

	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	choice_panel.add_child(vbox)

	var stars = calculate_stars()
	var title = Label.new()
	title.text = "⭐ Đạt %d sao! Bạn muốn..." % stars
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 22)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.3))
	vbox.add_child(title)

	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 16)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)

	# Nút "Màn tiếp theo"
	var btn_next = Button.new()
	btn_next.text = "Màn tiếp theo ▶"
	btn_next.custom_minimum_size = Vector2(150, 40)
	btn_next.add_theme_font_size_override("font_size", 16)
	btn_next.pressed.connect(_on_next_level_pressed)
	hbox.add_child(btn_next)

	# Nút "Ở lại chơi tiếp"
	var btn_stay = Button.new()
	btn_stay.text = "Ở lại đạt 3 sao ⭐"
	btn_stay.custom_minimum_size = Vector2(150, 40)
	btn_stay.add_theme_font_size_override("font_size", 16)
	btn_stay.pressed.connect(_on_stay_pressed)
	hbox.add_child(btn_stay)

	# Unlock chuột để bấm nút
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_next_level_pressed():
	# Chuyển sang màn tiếp theo
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	complete_level()


func _on_stay_pressed():
	# Ẩn panel, tiếp tục chơi
	if choice_panel:
		choice_panel.queue_free()
		choice_panel = null
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if pass_notification:
		pass_notification.text = "Tiếp tục nhặt để đạt 3 sao!"


func complete_level():
	level_active = false
	var stars = calculate_stars()

	if choice_panel:
		choice_panel.queue_free()
		choice_panel = null

	var player = _find_player()
	if player:
		Global.save_game_result(player.score)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	Global.last_elapsed_time = elapsed_time
	Global.save_level_result(current_level, stars)
	level_completed.emit(stars)

	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scene/level_complete.tscn")


func _find_player() -> Node:
	var proto = get_parent().get_node_or_null("ProtoController")
	if proto:
		return proto
	for child in get_parent().get_children():
		if child.has_method("deliver_items"):
			return child
	return null


## Hiển thị cảnh báo khi chơi quá 180 phút
func show_play_time_warning():
	if play_warning_label:
		play_warning_label.text = "⚠️ Cảnh báo: Bạn đã chơi quá 180 phút!\nHãy nghỉ ngơi để bảo vệ sức khỏe!"
		play_warning_label.visible = true
		# Tự ẩn sau 10 giây
		await get_tree().create_timer(10.0).timeout
		if is_instance_valid(play_warning_label):
			play_warning_label.visible = false
