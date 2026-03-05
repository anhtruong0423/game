extends Node3D

## Tự động tạo convex collision cho MeshInstance3D trong scene
## Dùng convex thay trimesh để giảm lag ~10x, đủ chính xác cho shop

const MAX_MESHES_PER_FRAME := 1  ## Chỉ xử lý 1 mesh mỗi frame để tránh giật

func _ready():
	call_deferred("_add_collision_batch")


## Thu thập mesh cần collision, xử lý 1 mesh/frame
func _add_collision_batch():
	var meshes: Array = []
	_collect_meshes(self, meshes)
	
	for i in range(meshes.size()):
		# Dùng convex collision (nhẹ hơn trimesh rất nhiều)
		meshes[i].create_convex_collision()
		# Nhường 1 frame sau mỗi mesh
		await get_tree().process_frame


## Đệ quy thu thập MeshInstance3D chưa có StaticBody3D
func _collect_meshes(node: Node, result: Array):
	for child in node.get_children():
		if child is MeshInstance3D and child.mesh:
			var has_body = false
			for sub in child.get_children():
				if sub is StaticBody3D:
					has_body = true
					break
			if not has_body:
				result.append(child)
		_collect_meshes(child, result)
