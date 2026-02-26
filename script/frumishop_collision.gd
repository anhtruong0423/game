extends Node3D

## Tự động tạo trimesh collision cho tất cả MeshInstance3D trong scene

func _ready():
	_add_trimesh_collision_recursive(self)


func _add_trimesh_collision_recursive(node: Node):
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var has_body = false
			for sub in child.get_children():
				if sub is StaticBody3D:
					has_body = true
					break
			if not has_body:
				child.create_trimesh_collision()
		_add_trimesh_collision_recursive(child)
