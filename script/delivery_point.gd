extends Node3D

class_name DeliveryPoint

@export var prompt_message: String = "Nhấn E để trả hàng"

func interact(player):
	if player.has_method("deliver_items"):
		var delivered_types = player.deliver_items()
		if delivered_types.size() > 0:
			var level_mgr = get_tree().get_first_node_in_group("level_manager")
			if level_mgr:
				level_mgr.on_items_delivered(delivered_types)
