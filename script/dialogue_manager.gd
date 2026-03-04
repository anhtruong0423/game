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
var bg_lan: Texture2D = null
var bg_farmer: Texture2D = null

## Hình nền riêng theo level {level: {"lan": Texture2D, "farmer": Texture2D}}
var level_backgrounds: Dictionary = {}

const LEVEL_DIALOGUES: Dictionary = {
	## ===== Level 1: Làm quen — nhặt rác + giới thiệu sữa & minimap =====
	1: {
		"scene_text": "🌿 Sân vườn yên bình...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Chào cháu Lan! Chào mừng cháu đến nông trại của bác. Hôm nay bác cần cháu giúp dọn dẹp rác quanh vườn!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Dạ, cháu sẵn sàng rồi bác! Cháu cần làm gì ạ?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhiệm vụ đầu tiên đơn giản thôi. Cháu nhặt 1 Chai nhựa và 1 Túi giấy, rồi mang về thùng tái chế.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhấn E để nhặt rác khi đứng gần. Mang về thùng rồi nhấn E lần nữa để bỏ vào nhé!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "À, cháu thấy có mấy hộp sữa Frumi nữa kìa! Cháu có thể nhặt không bác?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Được chứ! Nhấn Q để nhặt sữa Frumi. Uống sữa sẽ hồi năng lượng, rất cần khi chạy nhiều đấy!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhớ dùng bản đồ nhỏ ở góc màn hình. Rác nhiệm vụ sẽ nhấp nháy để cháu dễ tìm!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Tuyệt vời! Không giới hạn thời gian thì thoải mái rồi. Đi dọn rác thôi nào!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	## ===== Level 2: Thêm thử thách — chó + năng lượng + chạy nhanh =====
	2: {
		"scene_text": "🏘️ Khu phố cần dọn dẹp...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Tốt lắm cháu! Level 2 sẽ khó hơn đấy. Lần này cần nhặt Chai sữa, Giấy báo cũ, Lon nước ngọt và Túi ni-lông.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "4 loại luôn hả bác? Nhiều hơn rồi!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 2 loại là qua màn, nhưng muốn 3 sao thì phải đủ 4 loại trong 4 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Cẩn thận nhé! Trong khu phố có mấy con chó canh giữ. Nếu đến quá gần, chúng sẽ đuổi theo và làm cháu mất năng lượng!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Chó?! Cháu sợ chó lắm! Làm sao tránh được ạ?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Giữ khoảng cách là được. Còn nếu bị đuổi, nhấn Shift để chạy nhanh thoát thân!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhưng nhớ là chạy nhanh sẽ tốn năng lượng gấp đôi. Hết năng lượng là ngã luôn đấy! Uống sữa Frumi để hồi nhé.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Hiểu rồi! Tránh chó, chạy nhanh khi cần, và nhớ uống sữa. Đi dọn rác thôi!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	## ===== Level 3: Ngày/đêm + đèn pin =====
	3: {
		"scene_text": "🌅 Hoàng hôn buông xuống nông trại...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 3 rồi! Lần này cháu cần nhặt Thùng carton, Vỏ xe cũ, Hộp sữa cũ, Chai nhựa và Túi giấy trong 4 phút.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "5 loại rác! Nhưng... sao trời tối dần vậy bác?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đúng rồi! Từ level này trở đi, trời sẽ có chu kỳ ngày và đêm. Khi trời tối, cháu sẽ rất khó nhìn đường!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Trời ơi, vậy làm sao mà nhặt rác trong bóng tối?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đừng lo! Khi trời bắt đầu tối, một cây đèn pin sẽ xuất hiện gần cháu. Nhấn P để nhặt nó!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Sau khi nhặt, nhấn P lần nữa để bật/tắt đèn pin. Đèn sẽ giúp cháu soi đường trong đêm tối.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 3 loại rác là qua màn. Muốn 3 sao thì đủ 5 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Ngày đêm, đèn pin... thú vị quá! Cháu sẽ chinh phục bóng tối!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	## ===== Level 4: Trọng lượng + nâng cấp =====
	4: {
		"scene_text": "🏪 Mùa thu gom lớn...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 4 - Thu gom lớn! Cần nhặt Chai nhựa, Túi ni-lông, Chai sữa và Vỏ xe cũ trong 4 phút.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Cháu thấy túi đồ hơi nặng khi mang nhiều rác quá bác ơi...", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đúng rồi! Mỗi loại rác đều có trọng lượng. Mang càng nặng, cháu sẽ đi càng chậm!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Mẹo nhé: bỏ rác vào thùng thường xuyên để giảm tải. Đừng ôm hết rồi mới mang về!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "À, cháu thấy có bảng nâng cấp nữa kìa! Ấn phím gì vậy bác?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhấn Tab để mở menu nâng cấp! Dùng xu thu được để nâng cấp 3 thứ:", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Túi đồ: mang được nhiều rác hơn. Tốc độ: chạy nhanh hơn. Năng lượng: bền bỉ hơn!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 3 loại là qua màn. Muốn 3 sao thì phải đủ 4 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Nâng cấp rồi sẽ mạnh hơn! Cháu phải đầu tư thông minh!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	## ===== Level 5: Mẹo chuyên nghiệp =====
	5: {
		"scene_text": "🌙 Đêm trăng trên nông trại...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Level 5! Cần nhặt Túi giấy, Giấy báo cũ, Lon nước ngọt, Thùng carton và Hộp sữa cũ trong 3 phút rưỡi.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "5 loại rác, thời gian ít hơn... Bác có mẹo gì không ạ?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Có chứ! Đầu tiên, nhấn M để mở bản đồ lớn. Xem vị trí rác rồi lên kế hoạch đường đi!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Thứ hai, nhớ uống sữa Frumi trước khi chạy nhanh. Sữa rải khắp nơi, kể cả trong nhà và trên đồi!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Thứ ba, thú cưng của cháu rất hữu ích! Cáo giúp chạy nhanh hơn, còn rùa giúp hồi năng lượng khi đứng yên gần nó.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Ồ, cháu chưa biết thú cưng có nhiều khả năng vậy!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 3 loại là qua màn. Muốn 3 sao thì đủ 5 loại trong 3 phút!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Lên kế hoạch, tận dụng thú cưng, uống sữa đều đặn. Cháu tự tin lắm!", "color": Color(0.9, 0.5, 0.7)},
		]
	},
	## ===== Level 6: Thử thách cuối cùng =====
	6: {
		"scene_text": "🏆 Thử thách siêu dọn dẹp cuối cùng!",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Cháu Lan, đây là thử thách cuối cùng! Siêu dọn dẹp — bác rất tự hào về cháu!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Cháu đã đi một chặng đường dài! Thử thách cuối cùng gì vậy bác?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Thu gom TẤT CẢ 7 loại rác: Chai nhựa, Túi ni-lông, Chai sữa, Vỏ xe cũ, Lon nước ngọt, Hộp sữa cũ và Thùng carton!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "7 loại trong 3 phút?! Đó là tất cả rác cần dọn luôn!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đúng vậy! Cháu sẽ cần dùng mọi kỹ năng đã học: tránh chó, dùng đèn pin, uống sữa, nâng cấp thiết bị...", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhặt 4 loại là qua màn. Muốn 3 sao thì đủ cả 7 loại trong 2 phút rưỡi!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Hoàn thành thử thách này, cháu sẽ trở thành chiến binh bảo vệ môi trường số 1!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Lan", "text": "Tất cả những gì cháu đã học, hôm nay sẽ phát huy. Đi thôi, lần cuối cùng!", "color": Color(0.9, 0.5, 0.7)},
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
	## Hình nền mặc định (Level 1, 4, 5, 6)
	bg_lan = load("res://assets/background/farm_girl.png")
	bg_farmer = load("res://assets/background/farm_farmer.png")
	## Hình nền riêng cho Level 2 (chó canh giữ)
	var bg_lan_lv2 = load("res://assets/background/girl_dog.png")
	var bg_farmer_lv2 = load("res://assets/background/famer_girl.png")
	if bg_lan_lv2 and bg_farmer_lv2:
		level_backgrounds[2] = {"lan": bg_lan_lv2, "farmer": bg_farmer_lv2}
	## Hình nền riêng cho Level 3 (ngày/đêm + đèn pin)
	var bg_lan_lv3 = load("res://assets/background/girl_pin.png")
	var bg_farmer_lv3 = load("res://assets/background/farmer_girl_pin.png")
	if bg_lan_lv3 and bg_farmer_lv3:
		level_backgrounds[3] = {"lan": bg_lan_lv3, "farmer": bg_farmer_lv3}


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

	## Đổi background theo speaker và level
	var scene_image = get_node_or_null("SceneImage")
	if scene_image and scene_image is TextureRect:
		var level = Global.current_level
		var lvl_bg = level_backgrounds.get(level, null)
		if entry.speaker == "Lan":
			if lvl_bg and lvl_bg.get("lan"):
				scene_image.texture = lvl_bg["lan"]
			elif bg_lan:
				scene_image.texture = bg_lan
		else:
			if lvl_bg and lvl_bg.get("farmer"):
				scene_image.texture = lvl_bg["farmer"]
			elif bg_farmer:
				scene_image.texture = bg_farmer

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
	# Level 2+ → chọn thú cưng trước khi vào game
	# Level 1 → vào game trực tiếp (không cần chọn pet)
	if Global.current_level >= 2:
		get_tree().change_scene_to_file("res://scene/character_select.tscn")
	else:
		Global.go_to_scene("res://scene/main.tscn")


func _on_skip_pressed():
	finish_dialogue()
