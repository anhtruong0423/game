extends Control

## Character Selection Screen
## Cho phép chọn 1 trong 3 nhân vật với bonus khác nhau

@onready var minh_btn: Button = $VBoxContainer/CharactersContainer/MinhContainer/SelectButton
@onready var lan_btn: Button = $VBoxContainer/CharactersContainer/LanContainer/SelectButton
@onready var hung_btn: Button = $VBoxContainer/CharactersContainer/HungContainer/SelectButton

@onready var minh_container: VBoxContainer = $VBoxContainer/CharactersContainer/MinhContainer
@onready var lan_container: VBoxContainer = $VBoxContainer/CharactersContainer/LanContainer
@onready var hung_container: VBoxContainer = $VBoxContainer/CharactersContainer/HungContainer

var selected_character := ""


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	minh_btn.pressed.connect(_on_minh_selected)
	lan_btn.pressed.connect(_on_lan_selected)
	hung_btn.pressed.connect(_on_hung_selected)
	
	# Nếu đã chọn nhân vật trước đó, highlight nó
	if Global.selected_character != "":
		selected_character = Global.selected_character
		update_selection_ui()


func _on_minh_selected():
	selected_character = "minh"
	update_selection_ui()
	start_game()


func _on_lan_selected():
	selected_character = "lan"
	update_selection_ui()
	start_game()


func _on_hung_selected():
	selected_character = "hung"
	update_selection_ui()
	start_game()


func update_selection_ui():
	# Reset all
	minh_container.modulate = Color(1, 1, 1, 0.7)
	lan_container.modulate = Color(1, 1, 1, 0.7)
	hung_container.modulate = Color(1, 1, 1, 0.7)
	
	# Highlight selected
	match selected_character:
		"minh":
			minh_container.modulate = Color(1, 1, 1, 1)
		"lan":
			lan_container.modulate = Color(1, 1, 1, 1)
		"hung":
			hung_container.modulate = Color(1, 1, 1, 1)


func start_game():
	if selected_character == "":
		return
	
	# Lưu nhân vật đã chọn
	Global.select_character(selected_character)
	Global.complete_tutorial()
	
	# Chuyển sang game
	get_tree().change_scene_to_file("res://scene/main.tscn")

