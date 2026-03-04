extends Control

@onready var background: ColorRect = $Background
@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var stars_label: Label = $VBoxContainer/StarsLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var score_label: Label = $VBoxContainer/ScoreLabel
@onready var next_level_btn: Button = $VBoxContainer/ButtonsContainer/NextLevelButton
@onready var replay_btn: Button = $VBoxContainer/ButtonsContainer/ReplayButton
@onready var level_select_btn: Button = $VBoxContainer/ButtonsContainer/LevelSelectButton
@onready var menu_btn: Button = $VBoxContainer/ButtonsContainer/MenuButton


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Nền pastel brown
	background.color = Color(0.72, 0.55, 0.40, 1.0)

	var level = Global.current_level
	var stars = Global.last_stars

	title_label.text = "Level %d Hoàn Thành!" % level

	var star_text = ""
	for i in range(3):
		if i < stars:
			star_text += "★ "
		else:
			star_text += "☆ "
	stars_label.text = star_text.strip_edges()
	stars_label.add_theme_color_override("font_color", Color(1.0, 0.84, 0.0))

	var elapsed = Global.last_elapsed_time
	var minutes = int(elapsed) / 60
	var seconds = int(elapsed) % 60
	time_label.text = "Thời gian: %02d:%02d" % [minutes, seconds]

	score_label.text = "Điểm: " + str(Global.last_score)

	# Hiển thị bonus xu theo sao
	var bonus = Global.last_star_bonus
	if bonus > 0:
		score_label.text += "\n Thưởng sao: +" + str(bonus) + " xu"
	score_label.text += "\nTổng xu: " + str(Global.total_coins)

	var is_last_level = level >= 6
	if is_last_level:
		next_level_btn.text = "Hoàn thành game!"
		next_level_btn.pressed.connect(_on_finish_game)
	elif stars == 1:
		# Đạt 1 sao: vẫn giữ nút Level tiếp theo + thêm thông báo khuyến khích
		next_level_btn.text = "Level tiếp theo"
		next_level_btn.pressed.connect(_on_next_level)
		# Thêm thông báo khuyến khích chơi lại
		var encourage = Label.new()
		encourage.name = "EncourageLabel"
		encourage.text = " Bạn chỉ đạt 1 sao!\nChơi lại để đạt thêm sao nhé!"
		encourage.add_theme_font_size_override("font_size", 18)
		encourage.add_theme_color_override("font_color", Color(1.0, 0.6, 0.2))
		encourage.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		$VBoxContainer.add_child(encourage)
		$VBoxContainer.move_child(encourage, $VBoxContainer.get_child_count() - 2)
	else:
		next_level_btn.text = "Level tiếp theo"
		next_level_btn.pressed.connect(_on_next_level)

	replay_btn.pressed.connect(_on_replay)
	level_select_btn.pressed.connect(_on_level_select)
	menu_btn.pressed.connect(_on_menu)

	# Style brown cho tất cả buttons
	_style_brown_button(next_level_btn)
	_style_brown_button(replay_btn)
	_style_brown_button(level_select_btn)
	_style_brown_button(menu_btn)

	# Title style
	title_label.add_theme_color_override("font_color", Color(0.3, 0.18, 0.06))
	title_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.3))
	title_label.add_theme_constant_override("shadow_offset_x", 2)
	title_label.add_theme_constant_override("shadow_offset_y", 2)

	play_fade_in()
	
	# Phát SFX hoàn thành level
	AudioManager.play_levelup_sfx()


func play_fade_in():
	background.color.a = 0
	title_label.modulate.a = 0
	stars_label.modulate.a = 0
	time_label.modulate.a = 0
	score_label.modulate.a = 0
	next_level_btn.modulate.a = 0
	replay_btn.modulate.a = 0
	level_select_btn.modulate.a = 0
	menu_btn.modulate.a = 0

	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_property(background, "color:a", 1.0, 0.4)
	tween.tween_property(title_label, "modulate:a", 1.0, 0.3)
	tween.tween_property(stars_label, "modulate:a", 1.0, 0.4)
	tween.tween_property(time_label, "modulate:a", 1.0, 0.2)
	tween.tween_property(score_label, "modulate:a", 1.0, 0.2)
	tween.set_parallel(true)
	tween.tween_property(next_level_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(replay_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(level_select_btn, "modulate:a", 1.0, 0.3)
	tween.tween_property(menu_btn, "modulate:a", 1.0, 0.3)


func _on_next_level():
	Global.advance_level()
	Global.dialogue_mode = "level"
	get_tree().change_scene_to_file("res://scene/dialogue.tscn")


func _on_finish_game():
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")


func _on_replay():
	Global.dialogue_mode = "level"
	get_tree().change_scene_to_file("res://scene/dialogue.tscn")


func _on_level_select():
	get_tree().change_scene_to_file("res://scene/level_select.tscn")


func _on_menu():
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")
