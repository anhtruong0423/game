extends Control

## Dialogue Manager - Visual Novel style
## Hiển thị đối thoại với avatar và tự động/click để tiếp tục

signal dialogue_finished

@onready var avatar_texture: TextureRect = $DialogueBox/HBoxContainer/Avatar
@onready var name_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/NameLabel
@onready var text_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/TextLabel
@onready var continue_hint: Label = $DialogueBox/ContinueHint
@onready var skip_button: Button = $SkipButton

## Dialogue data - mỗi entry là {speaker, text, color}
var dialogue_data: Array = [
	{"speaker": "Bác Bảo Vệ", "text": "Chào các cháu! Hôm nay là ngày đầu tiên các cháu làm việc ở đây nhỉ?", "color": Color(0.8, 0.6, 0.2)},
	{"speaker": "Minh", "text": "Dạ vâng ạ! Cháu háo hức quá!", "color": Color(0.2, 0.7, 0.9)},
	{"speaker": "Lan", "text": "Bác ơi, công việc của tụi cháu là gì ạ?", "color": Color(0.9, 0.5, 0.7)},
	{"speaker": "Bác Bảo Vệ", "text": "Đơn giản thôi! Các cháu cần thu thập các món đồ và mang đến điểm giao hàng.", "color": Color(0.8, 0.6, 0.2)},
	{"speaker": "Hùng", "text": "Nghe dễ quá vậy bác!", "color": Color(0.3, 0.8, 0.4)},
	{"speaker": "Bác Bảo Vệ", "text": "Khoan đã! Các cháu cần chú ý năng lượng. Di chuyển sẽ tiêu hao năng lượng đấy.", "color": Color(0.8, 0.6, 0.2)},
	{"speaker": "Lan", "text": "Vậy hết năng lượng thì sao ạ?", "color": Color(0.9, 0.5, 0.7)},
	{"speaker": "Bác Bảo Vệ", "text": "Thì... Game Over! Nhưng đừng lo, uống sữa sẽ hồi phục năng lượng.", "color": Color(0.8, 0.6, 0.2)},
	{"speaker": "Minh", "text": "Cháu hiểu rồi! WASD để di chuyển, E để nhặt đồ, Q để uống sữa!", "color": Color(0.2, 0.7, 0.9)},
	{"speaker": "Bác Bảo Vệ", "text": "Đúng rồi! Còn nhấn Tab để mở menu nâng cấp. Chúc các cháu làm việc vui vẻ!", "color": Color(0.8, 0.6, 0.2)},
	{"speaker": "Hùng", "text": "Cảm ơn bác! Để cháu xem ai làm giỏi nhất nào!", "color": Color(0.3, 0.8, 0.4)},
]

var current_index := 0
var is_typing := false
var full_text := ""
var displayed_text := ""
var char_index := 0

const TYPING_SPEED := 0.03  ## Giây giữa mỗi ký tự
const AUTO_ADVANCE_DELAY := 2.0  ## Giây chờ trước khi tự động chuyển

var typing_timer := 0.0
var auto_timer := 0.0
var waiting_for_advance := false


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	skip_button.pressed.connect(_on_skip_pressed)
	show_dialogue(current_index)


func _process(delta):
	# Typing effect
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
	
	# Auto advance
	if waiting_for_advance:
		auto_timer += delta
		if auto_timer >= AUTO_ADVANCE_DELAY:
			advance_dialogue()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if is_typing:
			# Skip typing, show full text immediately
			char_index = full_text.length()
			displayed_text = full_text
			text_label.text = displayed_text
			is_typing = false
			waiting_for_advance = true
			continue_hint.text = "Click hoặc đợi để tiếp tục..."
		elif waiting_for_advance:
			advance_dialogue()
	
	# Spacebar cũng có thể dùng để tiếp tục
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
	name_label.text = entry.speaker
	name_label.add_theme_color_override("font_color", entry.color)
	
	full_text = entry.text
	displayed_text = ""
	char_index = 0
	text_label.text = ""
	
	is_typing = true
	waiting_for_advance = false
	typing_timer = 0.0
	auto_timer = 0.0
	continue_hint.text = "..."


func advance_dialogue():
	waiting_for_advance = false
	auto_timer = 0.0
	current_index += 1
	show_dialogue(current_index)


func finish_dialogue():
	dialogue_finished.emit()
	# Chuyển sang màn hình chọn nhân vật
	get_tree().change_scene_to_file("res://scene/character_select.tscn")


func _on_skip_pressed():
	finish_dialogue()

