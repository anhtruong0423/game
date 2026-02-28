extends Node

## Tutorial In-Game cho Level 1
## Bác Nông Dân popup hướng dẫn từng bước khi người chơi hoàn thành hành động

## Tutorial steps
enum Step {
	WELCOME,           ## 0 - Vào màn chơi
	FIRST_FRUIT,       ## 1 - Nhặt trái cây đầu tiên
	SECOND_FRUIT,      ## 2 - Nhặt trái cây thứ hai
	DELIVER_TO_BASKET, ## 3 - Giao hàng vào rổ
	ENERGY_LOW,        ## 4 - Năng lượng thấp
	MILK_PICKED,       ## 5 - Nhặt sữa
	DONE,              ## 6 - Hoàn thành tutorial
}

const TUTORIAL_MESSAGES = {
	Step.WELCOME: "Chào cháu! Trái cây nhiệm vụ đang nhấp nháy trên minimap. Hãy đi đến gần và nhấn E để nhặt!",
	Step.FIRST_FRUIT: "Giỏi lắm cháu! Cháu đã nhặt được trái cây đầu tiên. Tiếp tục tìm trái cây tiếp theo nhé!",
	Step.SECOND_FRUIT: "Tuyệt vời! Bây giờ hãy mang trái cây về rổ giao hàng. Đến gần rổ rồi nhấn E để bỏ vào!",
	Step.DELIVER_TO_BASKET: "Xuất sắc! Cháu đã giao hàng thành công! Cứ tiếp tục nhặt và giao là được.",
	Step.ENERGY_LOW: "Cẩn thận! Năng lượng đang thấp. Tìm hộp sữa Frumi gần đây và nhấn Q để uống hồi sức!",
	Step.MILK_PICKED: "Tốt lắm! Sữa Frumi giúp hồi năng lượng. Nhớ uống thường xuyên khi chạy nhiều nhé!",
}

var current_step: int = Step.WELCOME
var player: Node = null
var fruits_picked: int = 0
var has_delivered: bool = false
var energy_warned: bool = false
var milk_picked_notified: bool = false

## UI references
var popup_panel: PanelContainer = null
var popup_label: Label = null
var popup_avatar: TextureRect = null
var popup_name: Label = null
var popup_visible: bool = false
var popup_timer: float = 0.0
const POPUP_DURATION := 6.0
const ENERGY_LOW_THRESHOLD := 0.4  ## 40% năng lượng

## Cooldown cho popup túi đầy (tránh spam)
var _inventory_full_cooldown: float = 0.0
const INVENTORY_FULL_COOLDOWN := 15.0


func setup(p_player: Node):
	player = p_player
	_create_popup_ui()
	# Kết nối signals từ player
	if player.has_signal("fruit_picked_up"):
		player.fruit_picked_up.connect(_on_fruit_picked)
	if player.has_signal("milk_picked_up"):
		player.milk_picked_up.connect(_on_milk_picked)
	if player.has_signal("inventory_full_attempted"):
		player.inventory_full_attempted.connect(_on_inventory_full)
	# Welcome message sau 2.5 giây
	await get_tree().create_timer(2.5).timeout
	_show_step(Step.WELCOME)


func _process(delta):
	if not popup_visible:
		# Kiểm tra năng lượng thấp (chỉ 1 lần)
		if not energy_warned and player and is_instance_valid(player):
			var ratio = player.energy / player.max_energy
			if ratio <= ENERGY_LOW_THRESHOLD:
				energy_warned = true
				_show_step(Step.ENERGY_LOW)
		return

	# Auto ẩn popup sau thời gian
	popup_timer += delta
	if popup_timer >= POPUP_DURATION:
		_hide_popup()

	# Giảm cooldown túi đầy
	if _inventory_full_cooldown > 0:
		_inventory_full_cooldown -= delta


func _unhandled_input(event):
	# Click để ẩn popup nhanh
	if popup_visible:
		if (event is InputEventMouseButton and event.pressed) or \
		   (event is InputEventKey and event.pressed and event.keycode == KEY_SPACE):
			_hide_popup()


func _on_fruit_picked(_item_type: String):
	fruits_picked += 1
	if fruits_picked == 1 and current_step <= Step.FIRST_FRUIT:
		_show_step(Step.FIRST_FRUIT)
	elif fruits_picked >= 2 and current_step <= Step.SECOND_FRUIT and not has_delivered:
		_show_step(Step.SECOND_FRUIT)


func on_items_delivered():
	if has_delivered:
		return
	has_delivered = true
	if current_step <= Step.DELIVER_TO_BASKET:
		_show_step(Step.DELIVER_TO_BASKET)


func _on_milk_picked():
	if milk_picked_notified:
		return
	milk_picked_notified = true
	_show_step(Step.MILK_PICKED)


func _on_inventory_full():
	# Hiện mỗi lần túi đầy, nhưng có cooldown 15s tránh spam
	if _inventory_full_cooldown > 0:
		return
	_inventory_full_cooldown = INVENTORY_FULL_COOLDOWN
	_show_popup("Túi đồ đã đầy rồi cháu ơi! Hãy mang trái cây về rổ giao hàng (nhấn E) rồi quay lại nhặt tiếp. Hoặc nhấn Tab để nâng cấp túi đồ!")


func _show_step(step: int):
	current_step = step
	var msg = TUTORIAL_MESSAGES.get(step, "")
	if msg == "":
		return
	_show_popup(msg)


func _show_popup(text: String):
	if not popup_panel:
		return
	popup_label.text = text
	popup_panel.visible = true
	popup_visible = true
	popup_timer = 0.0


func _hide_popup():
	if popup_panel:
		popup_panel.visible = false
	popup_visible = false
	popup_timer = 0.0


func _create_popup_ui():
	if not player:
		return
	var hud = player.get_node_or_null("HUD")
	if not hud:
		return

	## === Main Panel ===
	popup_panel = PanelContainer.new()
	popup_panel.name = "TutorialPopup"
	popup_panel.anchors_preset = Control.PRESET_CENTER_BOTTOM
	popup_panel.anchor_left = 0.5
	popup_panel.anchor_right = 0.5
	popup_panel.anchor_top = 1.0
	popup_panel.anchor_bottom = 1.0
	popup_panel.offset_left = -380
	popup_panel.offset_right = 380
	popup_panel.offset_top = -230
	popup_panel.offset_bottom = -50
	popup_panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	popup_panel.grow_vertical = Control.GROW_DIRECTION_BEGIN

	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.08, 0.15, 0.92)
	style.corner_radius_top_left = 14
	style.corner_radius_top_right = 14
	style.corner_radius_bottom_left = 14
	style.corner_radius_bottom_right = 14
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_color = Color(0.9, 0.7, 0.2, 0.8)
	style.content_margin_left = 22
	style.content_margin_right = 22
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	popup_panel.add_theme_stylebox_override("panel", style)
	popup_panel.visible = false
	hud.add_child(popup_panel)

	## === HBox: Avatar + Text ===
	var hbox = HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 18)
	popup_panel.add_child(hbox)

	## Avatar bác nông dân
	popup_avatar = TextureRect.new()
	popup_avatar.custom_minimum_size = Vector2(96, 96)
	popup_avatar.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	popup_avatar.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	var farmer_tex = load("res://assets/background/farmer.png")
	if farmer_tex:
		popup_avatar.texture = farmer_tex
	hbox.add_child(popup_avatar)

	## VBox: Tên + Nội dung
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(vbox)

	## Tên nhân vật
	popup_name = Label.new()
	popup_name.text = "🧑‍🌾 Bác Nông Dân"
	popup_name.add_theme_font_size_override("font_size", 22)
	popup_name.add_theme_color_override("font_color", Color(0.9, 0.7, 0.2))
	vbox.add_child(popup_name)

	## Nội dung hướng dẫn
	popup_label = Label.new()
	popup_label.name = "TutorialText"
	popup_label.text = ""
	popup_label.add_theme_font_size_override("font_size", 20)
	popup_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	popup_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	popup_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(popup_label)

	## Gợi ý click để bỏ qua
	var hint = Label.new()
	hint.text = "Click hoặc Space để đóng"
	hint.add_theme_font_size_override("font_size", 14)
	hint.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6, 0.7))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vbox.add_child(hint)
