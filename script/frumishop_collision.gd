extends Node3D

## Tự động tạo collision cho tất cả MeshInstance3D trong scene
## Sử dụng convex collision (nhẹ hơn trimesh rất nhiều)

func _ready():
	# Dùng call_deferred để tránh freeze khi load scene
	call_deferred("_add_collision_recursive", self)


func _add_collision_recursive(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var has_body = false
			for sub in child.get_children():
				if sub is StaticBody3D:
					has_body = true
					break
			if not has_body:
				# Convex collision nhẹ hơn trimesh collision rất nhiều
				# clean=true: loại bỏ đỉnh trùng, simplify=true: đơn giản hóa shape
				child.create_convex_collision(true, true)
		_add_collision_recursive(child)
