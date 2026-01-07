extends Node3D

class_name DeliveryPoint

@export var prompt_message: String = "Nhấn E để trả hàng"

func interact(player):
	if player.has_method("deliver_items"):
		player.deliver_items()

