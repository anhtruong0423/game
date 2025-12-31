extends Node3D


class_name Interactable

@export var prompt_message: String = "Nhặt đồ" # Chữ hiện lên màn hình

@export var value: int = 1

func _ready():
	print("[DEBUG] Interactable ready: ", name, " - value: ", value)

func interact(player):
	print("[DEBUG] interact() called on: ", name)
	player.add_coin(value) # Gọi hàm bên Player
	queue_free()           # Xóa vật phẩm sau khi nhặt
