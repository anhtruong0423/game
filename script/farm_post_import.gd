@tool
extends EditorScenePostImport

func _post_import(scene):
	_add_collision_recursive(scene)
	return scene

func _add_collision_recursive(node):
	for child in node.get_children():
		_add_collision_recursive(child)
		if child is MeshInstance3D and child.mesh:
			child.create_trimesh_collision()
