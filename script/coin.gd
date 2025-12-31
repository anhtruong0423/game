extends Node3D


class_name Interactable

@export var prompt_message: String = "Nhấn E để nhặt" # Chữ hiện lên màn hình

@export var value: int = 1

func interact(player):
	# Check if inventory is full
	if player.has_method("is_inventory_full") and player.is_inventory_full():
		return  # Cannot pick up - inventory full
	
	if player.has_method("add_to_inventory"):
		if player.add_to_inventory(value):
			queue_free()  # Only delete if successfully added
