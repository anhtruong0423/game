extends Node3D


class_name Interactable

@export var prompt_message: String = "Nhặt đồ" # Chữ hiện lên màn hình

@export var value: int = 1

func interact(player):
	player.add_coin(value) # Gọi hàm bên Player
	queue_free()           # Xóa vật phẩm sau khi nhặt
