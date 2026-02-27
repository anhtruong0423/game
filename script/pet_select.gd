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
	get_tree().change_scene_to_file("res://scene/level_select.tscn")
