extends Control

## Pet Selection Screen - Chọn thú cưng đi cùng

@onready var fox_btn: Button = $VBoxContainer/PetsContainer/FoxContainer/SelectButton
@onready var turtle_btn: Button = $VBoxContainer/PetsContainer/TurtleContainer/SelectButton

@onready var fox_container: VBoxContainer = $VBoxContainer/PetsContainer/FoxContainer
@onready var turtle_container: VBoxContainer = $VBoxContainer/PetsContainer/TurtleContainer

var selected_pet := ""


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	fox_btn.pressed.connect(_on_fox_selected)
	turtle_btn.pressed.connect(_on_turtle_selected)

	if Global.selected_pet != "":
		selected_pet = Global.selected_pet
		update_selection_ui()


func _on_fox_selected():
	selected_pet = "fox"
	update_selection_ui()
	start_game()


func _on_turtle_selected():
	selected_pet = "turtle"
	update_selection_ui()
	start_game()


func update_selection_ui():
	fox_container.modulate = Color(1, 1, 1, 0.7)
	turtle_container.modulate = Color(1, 1, 1, 0.7)

	match selected_pet:
		"fox":
			fox_container.modulate = Color(1, 1, 1, 1)
		"turtle":
			turtle_container.modulate = Color(1, 1, 1, 1)


func start_game():
	if selected_pet == "":
		return

	Global.select_pet(selected_pet)
	
	# Mới chơi lần đầu (chưa có sao nào) → vào thẳng Level 1, bỏ qua level select
	var has_any_stars := false
	for level in Global.level_stars:
		if Global.level_stars[level] > 0:
			has_any_stars = true
			break
	
	if not has_any_stars:
		Global.current_level = 1
		Global.dialogue_mode = "level"
		get_tree().change_scene_to_file("res://scene/dialogue.tscn")
	else:
		get_tree().change_scene_to_file("res://scene/level_select.tscn")
