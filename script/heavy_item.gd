extends Node3D

## Script cho vật nặng - có trọng lượng lớn để test hệ thống weight

@export var prompt_message: String = "Nhấn E để nhặt (Nặng!)"
@export var value: int = 5000  ## Giá trị cao hơn coin thường
@export var weight: float = 10.0  ## Nặng 10kg - sẽ giảm 50% tốc độ

func interact(player):
	# Check if inventory is full
	if player.has_method("is_inventory_full") and player.is_inventory_full():
		return  # Cannot pick up - inventory full
	
	if player.has_method("add_to_inventory_with_weight"):
		if player.add_to_inventory_with_weight(value, weight):
			queue_free()  # Only delete if successfully added

