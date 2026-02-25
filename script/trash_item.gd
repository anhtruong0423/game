extends Node3D

class_name TrashItem

@export var item_type: String = ""
@export var display_name: String = ""
@export var prompt_message: String = "Nhấn E để nhặt"
@export var value: int = 1000
@export var weight: float = 1.0

func interact(player):
	if player.has_method("is_inventory_full") and player.is_inventory_full():
		return

	if player.has_method("add_to_inventory_typed"):
		if player.add_to_inventory_typed(item_type, value, weight):
			queue_free()
