@tool
extends Node3D

## Tick checkbox "Run" trong Inspector để thêm collision cho tất cả mesh.
## Sau khi chạy xong, nhớ Save scene (Ctrl+S) rồi gỡ script này ra.
@export var run: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			var count = 0
			count = _add_trimesh_collision_recursive(self, count)
			print("=== DONE! Added trimesh collision to ", count, " MeshInstance3D nodes. ===")
		run = false

func _add_trimesh_collision_recursive(node: Node, count: int) -> int:
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var has_static_body = false
			for sub in child.get_children():
				if sub is StaticBody3D:
					has_static_body = true
					break
			if not has_static_body:
				child.create_trimesh_collision()
				count += 1
				if count % 50 == 0:
					print("Progress: ", count, " meshes processed...")
		count = _add_trimesh_collision_recursive(child, count)
	return count
