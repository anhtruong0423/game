extends Node

signal mission_updated(delivered_items: Dictionary)
signal level_can_pass()
signal level_completed(stars: int)

const ITEM_DISPLAY_NAMES = {
	"yellow_bag": "Túi vàng",
	"green_bag": "Túi xanh",
	"red_bag": "Túi đỏ",
	"plastic_bottle": "Chai nhựa",
	"leaf": "Lá cây",
	"grape": "Nho",
	"melon": "Dưa lưới",
	"strawberry": "Dâu",
	"banana": "Chuối",
	"lemon": "Chanh",
	"mango": "Xoài",
	"apple": "Táo",
	"orange": "Cam",
	"watermelon": "Dưa hấu",
	"pineapple": "Thơm"
}

const LEVEL_DATA = {
	1: {
		"required_items": ["yellow_bag", "plastic_bottle"],
		"min_to_pass": 1,
		"time_limit": 0,
		"star_conditions": {
			1: {"items": 1, "time": 0},
			2: {"items": 2, "time": 0},
			3: {"items": 2, "time": 0}
		},
		"spawn_items": [
			{"type": "yellow_bag", "position": Vector3(-11.3, 0.4, 9.0)},
			{"type": "plastic_bottle", "position": Vector3(-6.4, 0.3, 9.1)},
		]
	},
	2: {
		"required_items": ["green_bag", "plastic_bottle", "red_bag"],
		"min_to_pass": 2,
		"time_limit": 300,
		"star_conditions": {
			1: {"items": 2, "time": 0},
			2: {"items": 3, "time": 0},
			3: {"items": 3, "time": 300}
		},
		"spawn_items": [
			{"type": "green_bag", "position": Vector3(-15.8, 0.4, 7.6)},
			{"type": "plastic_bottle", "position": Vector3(-9.1, 0.3, 9.0)},
			{"type": "red_bag", "position": Vector3(-12.5, 0.4, 6.6)},
		]
	},
	3: {
		"required_items": ["leaf", "red_bag", "plastic_bottle"],
		"min_to_pass": 1,
		"time_limit": 180,
		"star_conditions": {
			1: {"items": 1, "time": 180},
			2: {"items": 2, "time": 180},
			3: {"items": 3, "time": 180}
		},
		"spawn_items": [
			{"type": "leaf", "position": Vector3(-11.3, 0.2, 9.0)},
			{"type": "red_bag", "position": Vector3(-15.8, 0.4, 7.6)},
			{"type": "plastic_bottle", "position": Vector3(-6.4, 0.3, 6.6)},
		]
	}
}

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


func _ready():
	add_to_group("level_manager")
	current_level = Global.current_level
	call_deferred("_setup_level")


func _process(delta):
	if not level_active:
		return

	elapsed_time += delta

	var data = LEVEL_DATA.get(current_level, null)
	if not data:
		return

	update_timer_display(data)


func _setup_level():
	clear_existing_items()
	spawn_level_items()
	setup_hud()
	update_mission_hud()


func clear_existing_items():
	var coins_node = get_parent().get_node_or_null("coins")
	if coins_node:
		for child in coins_node.get_children():
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
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_label.add_theme_font_size_override("font_size", 24)
	timer_label.anchors_preset = Control.PRESET_CENTER_TOP
	timer_label.position = Vector2(-60, 10)
	timer_label.size = Vector2(120, 40)
	hud.add_child(timer_label)

	var data = LEVEL_DATA.get(current_level, null)
	if data and data["time_limit"] == 0:
		timer_label.visible = false


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
		level_can_pass.emit()

	var all_done = count >= data["required_items"].size()
	if all_done:
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

	var data = LEVEL_DATA.get(current_level, null)
	var all_done = get_delivered_count() >= data["required_items"].size()

	if all_done:
		pass_notification.text = "Hoàn thành! Đang chuyển màn..."
	else:
		pass_notification.text = "Có thể qua màn! Tiếp tục nhặt để đạt sao cao hơn."
	pass_notification.visible = true


func complete_level():
	level_active = false
	var stars = calculate_stars()

	var player = _find_player()
	if player:
		Global.save_game_result(player.score)

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
