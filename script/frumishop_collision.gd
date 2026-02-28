extends Node3D

## Tự động tạo trimesh collision cho tất cả MeshInstance3D trong scene
## Dùng call_deferred + batch processing để tránh lag spike khi load

const BATCH_SIZE := 3  ## Chỉ xử lý 3 mesh mỗi frame

func _ready():
	# Dùng call_deferred để tránh freeze khi load scene
	call_deferred("_add_collision_batch")


## Thu thập tất cả mesh cần tạo collision, rồi xử lý từng batch với delay
func _add_collision_batch():
	var meshes: Array = []
	_collect_meshes(self, meshes)
	
	# Tạo collision cho từng batch, chờ 1 frame giữa mỗi batch
	for i in range(meshes.size()):
		meshes[i].create_trimesh_collision()
		if (i + 1) % BATCH_SIZE == 0 and i < meshes.size() - 1:
			await get_tree().process_frame


## Đệ quy thu thập tất cả MeshInstance3D chưa có StaticBody3D
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
