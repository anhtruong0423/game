extends Node3D


class_name Interactable

@export var prompt_message: String = "Nhấn E để nhặt"
@export var item_type: String = ""
@export var value: int = 1000
@export var weight: float = 1.0

func _ready():
	add_to_group("interactable")

func interact(player):
	if player.has_method("is_inventory_full") and player.is_inventory_full():
		return

	if player.has_method("add_to_inventory_typed"):
		if player.add_to_inventory_typed(item_type, value, weight):
			_cleanup_and_free()
	elif player.has_method("add_to_inventory_with_weight"):
		if player.add_to_inventory_with_weight(value, weight):
			_cleanup_and_free()
	elif player.has_method("add_to_inventory"):
		if player.add_to_inventory(value):
			_cleanup_and_free()


## Ẩn ngay + xóa khỏi group trước khi queue_free để giảm lag
func _cleanup_and_free():
	visible = false
	set_process(false)
	set_physics_process(false)
	remove_from_group("interactable")
	# Tắt collision nếu có
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
		elif child is StaticBody3D or child is Area3D:
			for sub in child.get_children():
				if sub is CollisionShape3D:
					sub.disabled = true
	queue_free()
