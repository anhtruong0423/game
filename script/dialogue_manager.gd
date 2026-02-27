extends Control

## Dialogue Manager - Visual Novel style
## Chỉ có 2 nhân vật: Lan và Bác Nông Dân

signal dialogue_finished

@onready var avatar_texture: TextureRect = $DialogueBox/HBoxContainer/Avatar
@onready var name_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/NameLabel
@onready var text_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/TextLabel
@onready var continue_hint: Label = $DialogueBox/ContinueHint
@onready var skip_button: Button = $SkipButton
@onready var scene_label: Label = $SceneImage/SceneLabel

## Avatar textures
var avatar_lan: Texture2D = null
var avatar_farmer: Texture2D = null

const LEVEL_DIALOGUES: Dictionary = {
	1: {
		"scene_text": "Vườn trái cây...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 1 - Bắt đầu thu hoạch! Nhiệm vụ đầu tiên đơn giản thôi.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cháu cần tìm và nhặt 1 quả Táo và 1 quả Chuối, rồi mang về điểm giao hàng.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Chỉ 2 loại trái cây thôi hả bác? Dễ quá!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đừng chủ quan nhé! Nhớ mang về điểm giao hàng mới tính. Không giới hạn thời gian đâu.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Vậy thì thoải mái rồi! Đi thôi nào!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	2: {
		"scene_text": "Khu vườn cam chanh...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 2 - Vườn trái cây! Lần này khó hơn một chút đấy.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cần thu thập 3 loại: Cam, Chanh và Nho.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "3 loại trái cây! Cháu thích nho lắm!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 2 loại là qua màn, nhưng muốn 3 sao thì phải đủ 3 loại trong 5 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "5 phút thôi sao? Phải nhanh tay lên thôi!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	3: {
		"scene_text": "Vườn trái cây mùa hè...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 3 - Mùa hè rực rỡ! Trái cây mùa hè chín rộ rồi.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cháu cần thu thập Dâu, Xoài và Dưa lưới trong 4 phút.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Dâu và Xoài! Nghe ngon quá bác ơi!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 2 loại là qua màn. Muốn 3 sao phải đủ 3 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Cháu sẽ cố gắng hết sức!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	4: {
		"scene_text": "Thu hoạch lớn...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 4 - Thu hoạch lớn! Bắt đầu thử thách thực sự rồi đây.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cần thu thập 4 loại: Táo, Cherry, Cam và Xoài trong 4 phút.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "4 loại trái cây luôn! Nhiều hơn rồi đó!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 3 loại là qua màn. Muốn 3 sao thì phải đủ 4 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Thử thách lớn nhưng cháu không sợ!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	5: {
		"scene_text": "Thử thách trái cây...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 5 - Thử thách trái cây! Đây là màn khó nhất!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cần thu thập 5 loại: Chuối, Chanh, Nho, Dâu và Dưa lưới trong 3 phút rưỡi.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "5 loại! Phải chạy nhanh lắm mới kịp!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 3 loại là qua màn. Muốn 3 sao thì đủ 5 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Cháu sẽ chinh phục thử thách này!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	6: {
		"scene_text": "Siêu thu hoạch...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level cuối - Siêu thu hoạch! Đây là thử thách cuối cùng!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cần thu thập 7 loại trái cây: Táo, Cherry, Cam, Xoài, Nho, Dưa lưới và Dâu!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "7 loại trong 3 phút?! Căng quá bác ơi!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 4 loại là qua màn. Muốn 3 sao thì đủ cả 7 loại trong 2 phút rưỡi!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Thử thách cuối cùng! Cháu sẽ hoàn thành!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
}

var dialogue_data: Array = []
var current_index := 0
var is_typing := false
var full_text := ""
var displayed_text := ""
var char_index := 0

const TYPING_SPEED := 0.03
const AUTO_ADVANCE_DELAY := 2.0

var typing_timer := 0.0
var auto_timer := 0.0
var waiting_for_advance := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	skip_button.pressed.connect(_on_skip_pressed)
	_set_click_through(self)
	_load_avatars()
	_load_dialogue_data()
	show_dialogue(current_index)


func _load_avatars():
	avatar_lan = load("res://assets/background/character.png")
	avatar_farmer = load("res://assets/background/farmer.png")


func _set_click_through(node: Node):
	if node is Button:
		return
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_click_through(child)


func _load_dialogue_data():
	var level = Global.current_level
	var level_data = LEVEL_DIALOGUES.get(level, null)
	if level_data:
		dialogue_data = level_data["data"].duplicate()
		if scene_label:
			scene_label.text = level_data["scene_text"]
	else:
		dialogue_data = LEVEL_DIALOGUES[1]["data"].duplicate()


func _process(delta):
	if is_typing:
		typing_timer += delta
		if typing_timer >= TYPING_SPEED:
			typing_timer = 0.0
			if char_index < full_text.length():
				char_index += 1
				displayed_text = full_text.substr(0, char_index)
				text_label.text = displayed_text
			else:
				is_typing = false
				waiting_for_advance = true
				continue_hint.text = "Click hoặc đợi để tiếp tục..."

	if waiting_for_advance:
		auto_timer += delta
		if auto_timer >= AUTO_ADVANCE_DELAY:
			advance_dialogue()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			char_index = full_text.length()
			displayed_text = full_text
			text_label.text = displayed_text
			is_typing = false
			waiting_for_advance = true
			continue_hint.text = "Click hoặc đợi để tiếp tục..."
		elif waiting_for_advance:
			advance_dialogue()

	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		if is_typing:
			char_index = full_text.length()
			displayed_text = full_text
			text_label.text = displayed_text
			is_typing = false
			waiting_for_advance = true
		elif waiting_for_advance:
			advance_dialogue()


func show_dialogue(index: int):
	if index >= dialogue_data.size():
		finish_dialogue()
		return

	var entry = dialogue_data[index]
	if not entry:
		finish_dialogue()
		return

	if name_label:
		name_label.text = entry.speaker
		name_label.add_theme_color_override("font_color", entry.color)

	## Đổi avatar theo speaker
	if avatar_texture:
		if entry.speaker == "Lan" and avatar_lan:
			avatar_texture.texture = avatar_lan
		elif avatar_farmer:
			avatar_texture.texture = avatar_farmer

	full_text = entry.text
	displayed_text = ""
	char_index = 0
	if text_label:
		text_label.text = ""

	is_typing = true
	waiting_for_advance = false
	typing_timer = 0.0
	auto_timer = 0.0
	if continue_hint:
		continue_hint.text = "..."


func advance_dialogue():
	waiting_for_advance = false
	auto_timer = 0.0
	current_index += 1
	show_dialogue(current_index)


func finish_dialogue():
	dialogue_finished.emit()
	Global.go_to_scene("res://scene/main.tscn")


func _on_skip_pressed():
	finish_dialogue()
