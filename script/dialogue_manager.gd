extends Control

## Dialogue Manager - Visual Novel style
## Chỉ có 2 nhân vật: Linh và Bác Nông Dân

signal dialogue_finished

@onready var avatar_texture: TextureRect = $DialogueBox/HBoxContainer/Avatar
@onready var name_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/NameLabel
@onready var text_label: Label = $DialogueBox/HBoxContainer/VBoxContainer/TextLabel
@onready var continue_hint: Label = $DialogueBox/ContinueHint
@onready var skip_button: Button = $SkipButton
@onready var scene_label: Label = $SceneImage/SceneLabel

## Avatar textures
var avatar_linh: Texture2D = null
var avatar_farmer: Texture2D = null
var bg_lan: Texture2D = null
var bg_farmer: Texture2D = null

## Hình nền riêng theo level {level: {"linh": Texture2D, "farmer": Texture2D}}
var level_backgrounds: Dictionary = {}

const LEVEL_DIALOGUES: Dictionary = {
	## ===== Level 1: Sự khởi đầu bình yên =====
	1: {
		"scene_text": "🌿 Sân vườn yên bình...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Chào cháu gái! Mới đó mà đã nghỉ hè rồi, mừng cháu về thăm nông trại.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv1_1.png"},
			{"speaker": "Linh", "text": "Dạ, cháu cũng nhớ nông trại lắm, ở thành phố ồn ào quá. Nhưng sao cháu thấy quang cảnh quanh đây bừa bộn rác thế bác?", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv1_2.png"},
			{"speaker": "Bác Nông Dân", "text": "Dạo này khu sinh thái gần đây thu hút đông đúc, có một số lượng khách du lịch xả rác bừa bãi nên rác kẹt lại, chưa kịp dọn dẹp.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv1_3.png"},
			{"speaker": "Linh", "text": "Để cháu phụ bác một tay nhé! Cháu sẽ thu dọn đống rác đó vào thùng tái chế.", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv1_4.png"},
			{"speaker": "Bác Nông Dân", "text": "Tốt quá! Cháu thử bắt đầu nhặt 1 Chai nhựa và 1 Túi giấy đi. Cứ nhấn phím [E] để lấy rác và bỏ vào thùng tái chế gần đó nhé.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/LV1_5.png"},
			{"speaker": "Bác Nông Dân", "text": "Nhớ để ý bản đồ mini góc phải (hoặc nhấn [M] để phóng to), rác cần tìm sẽ được tô sáng. À, nếu mệt thì cháu hãy nhặt những hộp sữa Frumi trên đường (nhấn [Q]) để hồi lại năng lượng nhé!", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/LV1_5.png"},
			{"speaker": "Linh", "text": "Cháu hiểu rồi! Có sữa xịn thế này thì lo gì mệt. Cháu đi dọn ngay đây!", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/LV1_5.png"}		]
	},
	## ===== Level 2: Dấu hiệu lan rộng =====
	2: {
		"scene_text": "🏘️ Khu phố cần dọn dẹp...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Rác ở nông trại đã dọn gần xong, nhưng cháu nhìn ngoài khu vườn phố kìa, tình hình có vẻ tệ hơn. Cần dọn 4 loại rác lận!", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv2_1.png"},
			{"speaker": "Linh", "text": "Nhiều quá! Mà cháu nghe thấy tiếng chó sủa ầm ĩ quanh đó, có sao không bác?", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv2_2.png"},
			{"speaker": "Bác Nông Dân", "text": "Rác sinh hoạt bốc mùi thu hút lũ chó hoang tập trung lại đấy. Cháu phải thật cẩn thận, đừng đến gần. Nếu chúng đuổi, hãy nhấn giữ [Shift] để chạy nhanh nhé!", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv2_3.png"},
			{"speaker": "Linh", "text": "Cháu sẽ cố gắng tránh xa chúng. Nhưng chạy nhanh thì mệt lắm!", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv2_4.png"},
			{"speaker": "Bác Nông Dân", "text": "Đúng rồi, chạy nhanh tốn năng lượng gấp đôi, nếu để thanh thể lực cạn kiệt cháu sẽ kiệt sức mà ngất luôn đó! Nhớ uống sữa bổ sung năng lượng dọc đường nhé.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv2_5.png"},
			{"speaker": "Linh", "text": "Cháu nhớ rồi. Nhặt đủ 2 loại rác là hoàn thành, nhưng cháu sẽ cố gắng dọn sạch cả 4 loại thật nhanh để được 3 sao!", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv2_5.png"}
		]
	},
	## ===== Level 3: Màn đêm buông xuống =====
	3: {
		"scene_text": "🌅 Hoàng hôn buông xuống thị trấn...",
		"data": [
			{"speaker": "Linh", "text": "Bác ơi, cháu dọn mỏi nhừ tay rồi. Mới chốc lát mà trời chuẩn bị tối luôn rồi bác ạ.", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv3_1.png"},
			{"speaker": "Bác Nông Dân", "text": "Đúng rồi cháu. Rác nhiều làm xe thu gom không vào được, nay khu phố bị cắt điện tạm thời. Khi trời tối hẳn, cháu sẽ rất khó tuần tra đấy.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv3_2.png"},
			{"speaker": "Linh", "text": "Trời tối đen thì làm sao cháu thấy được để dọn dẹp 5 loại rác đây bác?", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv3_3.png"},
			{"speaker": "Bác Nông Dân", "text": "Đừng lo, bác đã để sẵn một chiếc đèn pin ngoài kia. Lúc bóng đêm buông xuống, cháu tìm vị trí và nhấn [P] nhặt lấy, sau đó xài [P] bật/tắt để soi sáng đường nhé.", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv3_4.png"},
			{"speaker": "Bác Nông Dân", "text": "Hoàn thành 3/5 loại rác là về nhà nghỉ ngơi được rồi. Nếu dọn đủ 5 loại trong 3 phút, bác sẽ ráng xin cho cháu huy hiệu 3 sao xuất sắc nhất thị trấn!", "color": Color(0.8, 0.6, 0.2), "bg_img": "res://assets/đối thoại/lv3_5.png"},
			{"speaker": "Linh", "text": "Có ánh sáng soi chiếu hy vọng rồi. Cháu không sơ bóng tối vì có chiếc đèn pin thân yêu!", "color": Color(0.9, 0.5, 0.7), "bg_img": "res://assets/đối thoại/lv3_6.png"}
		]
	},
	## ===== Level 4: Thu gom quy mô lớn =====
	4: {
		"scene_text": "🏪 Mùa thu gom lớn...",
		"data": [
			{"speaker": "Linh", "text": "Khu công viên này dơ quá bác ơi. Hơn nữa, hôm qua cháu xách túi rác đi xa thật là mệt mỏi.", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Bữa nay không dễ ăn đâu. Mỗi loại rác có một trọng lượng riêng, mang theo quá tải là cháu di chuyển ì ạch như rùa đổ dốc đấy.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Nhưng may là mình sẽ có nguồn quỹ tài trợ thêm! Bác đã liên hệ với mấy cô bán phế liệu để lấy thêm tiền hoàn thành dọn rác.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Kinh phí đấy cháu sẽ dùng để làm gì ạ?", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Cháu hãy nhấn phím [Tab] nhé. Cháu có thể trích quỹ mua những thiết bị tân tiến hơn: túi rác khổng lồ, giày thể thao siêu tốc hoặc nước uống siêu năng lượng để tăng sức bền.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Cơ chế giống thể thao chuyên nghiệp rồi đây! Để cháu tính toán xem cần nâng cấp chỉ số gì trước để làm nhanh 4/4 loại trước 3 phút lấy 3 sao nha bác!", "color": Color(0.9, 0.5, 0.7)}
		]
	},
	## ===== Level 5: Chuyên gia phân loại =====
	5: {
		"scene_text": "🌙 Đêm trăng trên nông trại...",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Đèo nông trại nay bốc mùi ghê thật. 5 loại rác mới tinh, mà trạm xử lý chỉ cho cháu 3 phút rưỡi thôi sấp nhỏ ạ.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Thời gian eo hẹp quá! Có lẽ sức người làm không kịp rồi bác ơi.", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Nghe lời bác, cháu cần sự trợ giúp từ mấy bé thú cưng nhà ta. Pé Cáo lém lỉnh sẽ phụ cháu vừa chạy nhanh, vừa mang thêm rác. Pé rùa chậm nhưng đem lại sức khỏe vô hình hồi năng lượng kỳ diệu, miễn là cháu đứng yên kế nó.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Gì đỉnh thế bác! Các bé ấy dễ thương vô cùng.", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Và cháu đừng quên dùng la bàn nhỏ, nhấn phím [M] để lên chiến lược nhặt rác hợp lý. Tránh chạy vòng vòng tốn hơi.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Quyết tâm gom đủ 5 loại rác trong 3 phút lấy 3 sao luôn. Cháu cùng hai bạn Cáo và Rùa sẽ quét sạch khu này!", "color": Color(0.9, 0.5, 0.7)}
		]
	},
	## ===== Level 6: Trận chiến cuối cùng =====
	6: {
		"scene_text": "🏆 Thử thách siêu dọn dẹp cuối cùng!",
		"data": [
			{"speaker": "Bác Nông Dân", "text": "Tuyệt vời Linh ơi! Lời đồn về 'siêu nhân dọn rác' lan xa rồi, thị trưởng thành phố vừa giao phó bãi phế liệu lớn nhất hành tinh này cho cháu.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Trời đất, nó rộng thênh thang và còn có tận... 7 LOẠI RÁC cần dọn!", "color": Color(0.9, 0.5, 0.7)},
			{"speaker": "Bác Nông Dân", "text": "Đúng thế! Bãi phế liệu hỗn mang này là bài thi cuối cùng. Tránh chó hung dữ trong bóng đêm, soi đèn dò đường, quản lý nâng cấp, uống sữa hồi sức và cùng thú cưng đồng hành.", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Bác Nông Dân", "text": "Dọn 4 loại sẽ cứu vãn tình hình. Nhưng nếu làm cỏ sạch cả 7 loại rác chỉ trong chưa đầy 2 phút rưỡi, bằng khen Thị trưởng và 3 sao vàng sẽ thuộc về cháu!", "color": Color(0.8, 0.6, 0.2)},
			{"speaker": "Linh", "text": "Làm thôi bác ơi! Cháu không muốn mùa hè của mình là một bãi rác khổng lồ đâu. Cống hiến kỹ năng cuối cùng, xuất phát!", "color": Color(0.9, 0.5, 0.7)}
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
	avatar_linh = load("res://assets/background/Linh.png")
	avatar_farmer = load("res://assets/background/farmer.png")
	## Hình nền mặc định (Level 1, 4, 5, 6)
	bg_lan = load("res://assets/background/farm_girl.png")
	bg_farmer = load("res://assets/background/farm_farmer.png")
	## Hình nền riêng cho Level 2 (chó canh giữ)
	var bg_lan_lv2 = load("res://assets/background/girl_dog.png")
	var bg_farmer_lv2 = load("res://assets/background/famer_girl.png")
	if bg_lan_lv2 and bg_farmer_lv2:
		level_backgrounds[2] = {"linh": bg_lan_lv2, "farmer": bg_farmer_lv2}
	## Hình nền riêng cho Level 3 (ngày/đêm + đèn pin)
	var bg_lan_lv3 = load("res://assets/background/girl_pin.png")
	var bg_farmer_lv3 = load("res://assets/background/farmer_girl_pin.png")
	if bg_lan_lv3 and bg_farmer_lv3:
		level_backgrounds[3] = {"linh": bg_lan_lv3, "farmer": bg_farmer_lv3}


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

	## Đổi avatar theo speaker - hiện avatar cho cả Linh và Bác Nông Dân
	if avatar_texture:
		if entry.speaker == "Linh" and avatar_linh:
			avatar_texture.texture = avatar_linh
			avatar_texture.visible = true
		elif entry.speaker == "Bác Nông Dân" and avatar_farmer:
			avatar_texture.texture = avatar_farmer
			avatar_texture.visible = true
		else:
			avatar_texture.visible = false

	## Đổi background theo speaker và level
	var scene_image = get_node_or_null("SceneImage")
	if scene_image and scene_image is TextureRect:
		if entry.has("bg_img") and entry.bg_img != "":
			var custom_bg = load(entry.bg_img)
			if custom_bg:
				scene_image.texture = custom_bg
		else:
			var level = Global.current_level
			var lvl_bg = level_backgrounds.get(level, null)
			if entry.speaker == "Linh":
				if lvl_bg and lvl_bg.get("linh"):
					scene_image.texture = lvl_bg["linh"]
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
