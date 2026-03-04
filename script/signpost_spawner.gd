extends Node

## Signpost Spawner - Tạo biển chỉ đường 3D tại các vị trí quan trọng trên bản đồ
## Mỗi biển gồm: cột gỗ + bảng tên khu vực + mũi tên hướng

## Y level mặt đất (dựa trên spawn items trong level_manager.gd)
const GROUND_Y := -133.5

## Dữ liệu biển chỉ đường
## Mỗi biển có: vị trí, và danh sách hướng chỉ (tên + góc xoay)
const SIGNPOST_DATA = [
	{
		"position": Vector3(95, -133.5, 87),  ## Ngã rẽ đường chính vào khu trung tâm
		"signs": [
			{"text": "FrumiShop ->", "color": Color(0.2, 0.8, 0.3), "rotation_y": -30},
			{"text": "<- Canh Dong", "color": Color(0.4, 0.7, 0.2), "rotation_y": 150},
			{"text": "Duong Chinh ->", "color": Color(0.9, 0.8, 0.2), "rotation_y": 90},
		]
	},
	{
		"position": Vector3(0, -133.5, 87),  ## Giữa đường chính
		"signs": [
			{"text": "Khu Trung Tam ->", "color": Color(0.3, 0.9, 0.4), "rotation_y": 90},
			{"text": "<- Vung Tay", "color": Color(0.3, 0.6, 0.8), "rotation_y": -90},
			{"text": "Canh Dong v", "color": Color(0.4, 0.7, 0.2), "rotation_y": 0},
		]
	},
	{
		"position": Vector3(-70, -133.5, 87),  ## Phía tây đường chính
		"signs": [
			{"text": "Trung Tam ->", "color": Color(0.3, 0.9, 0.4), "rotation_y": 90},
			{"text": "<- Vung Hoang Da", "color": Color(0.3, 0.6, 0.8), "rotation_y": -90},
		]
	},
	{
		"position": Vector3(140, -133.5, 87),  ## Phía đông đường chính
		"signs": [
			{"text": "<- FrumiShop", "color": Color(0.3, 0.9, 0.4), "rotation_y": -90},
			{"text": "Vung Dong ->", "color": Color(0.3, 0.6, 0.8), "rotation_y": 90},
		]
	},
	{
		"position": Vector3(109, -133.5, 58),  ## Trước FrumiShop
		"signs": [
			{"text": "FrumiShop ^", "color": Color(0.2, 0.9, 0.4), "rotation_y": 0},
			{"text": "Khu Nha Cua v", "color": Color(0.7, 0.5, 0.3), "rotation_y": 180},
		]
	},
	{
		"position": Vector3(-15, -133.5, 40),  ## Ngã rẽ vào khu nhà cửa
		"signs": [
			{"text": "Khu Nha Cua v", "color": Color(0.7, 0.5, 0.3), "rotation_y": 180},
			{"text": "Canh Dong ->", "color": Color(0.4, 0.7, 0.2), "rotation_y": 90},
			{"text": "Duong Chinh ^", "color": Color(0.9, 0.8, 0.2), "rotation_y": 0},
		]
	},
]

var player: CharacterBody3D = null
var _signposts: Array = []  ## Lưu reference để cleanup


func setup(player_node: CharacterBody3D) -> void:
	player = player_node
	_spawn_all_signposts()


func _spawn_all_signposts() -> void:
	if not player:
		return

	var parent = player.get_parent()
	if not parent:
		return

	# Tạo container cho tất cả biển
	var container = Node3D.new()
	container.name = "Signposts"
	parent.add_child(container)

	for data in SIGNPOST_DATA:
		var signpost = _create_signpost(data)
		container.add_child(signpost)
		_signposts.append(signpost)

	print("[SignpostSpawner] Đã tạo %d biển chỉ đường" % _signposts.size())


func _create_signpost(data: Dictionary) -> Node3D:
	var root = Node3D.new()
	root.name = "Signpost"
	root.global_position = data["position"]

	## === Cột gỗ chính ===
	var pole = MeshInstance3D.new()
	pole.name = "Pole"
	var pole_mesh = CylinderMesh.new()
	pole_mesh.top_radius = 0.06
	pole_mesh.bottom_radius = 0.08
	pole_mesh.height = 3.0
	pole.mesh = pole_mesh

	var pole_mat = StandardMaterial3D.new()
	pole_mat.albedo_color = Color(0.45, 0.3, 0.15)  # Màu gỗ
	pole_mat.roughness = 0.9
	pole.material_override = pole_mat
	pole.position = Vector3(0, 1.5, 0)  # Nửa chiều cao
	root.add_child(pole)

	## === Đỉnh cột (chỏm tròn) ===
	var cap = MeshInstance3D.new()
	cap.name = "Cap"
	var cap_mesh = SphereMesh.new()
	cap_mesh.radius = 0.1
	cap_mesh.height = 0.2
	cap.mesh = cap_mesh
	var cap_mat = StandardMaterial3D.new()
	cap_mat.albedo_color = Color(0.55, 0.35, 0.15)
	cap.material_override = cap_mat
	cap.position = Vector3(0, 3.05, 0)
	root.add_child(cap)

	## === Tạo các bảng chỉ đường ===
	var signs = data.get("signs", [])
	for i in range(signs.size()):
		var sign_data = signs[i]
		var sign_node = _create_sign_board(sign_data, i, signs.size())
		root.add_child(sign_node)

	return root


func _create_sign_board(sign_data: Dictionary, index: int, total: int) -> Node3D:
	var sign_root = Node3D.new()
	sign_root.name = "Sign_%d" % index

	# Vị trí bảng trên cột (phân bố đều từ trên xuống)
	var height = 2.7 - (index * 0.5)
	sign_root.position = Vector3(0, height, 0)

	# Xoay theo hướng chỉ
	sign_root.rotation_degrees.y = sign_data.get("rotation_y", 0)

	## === Bảng gỗ ===
	var board = MeshInstance3D.new()
	board.name = "Board"
	var board_mesh = BoxMesh.new()
	board_mesh.size = Vector3(1.2, 0.35, 0.05)
	board.mesh = board_mesh

	var board_mat = StandardMaterial3D.new()
	board_mat.albedo_color = Color(0.55, 0.4, 0.2)  # Gỗ sáng
	board_mat.roughness = 0.85
	board.material_override = board_mat
	board.position = Vector3(0.65, 0, 0)  # Lệch ra ngoài cột
	sign_root.add_child(board)

	## === Mũi tên nhỏ ở đầu bảng ===
	var arrow_side = 1 if sign_data["text"].ends_with("->") else -1
	if sign_data["text"].ends_with("->") or sign_data["text"].begins_with("<-"):
		var arrow = MeshInstance3D.new()
		arrow.name = "Arrow"
		var arrow_mesh = PrismMesh.new()
		arrow_mesh.size = Vector3(0.15, 0.25, 0.06)
		arrow.mesh = arrow_mesh

		var arrow_mat = StandardMaterial3D.new()
		arrow_mat.albedo_color = sign_data.get("color", Color(1, 1, 1))
		arrow_mat.emission_enabled = true
		arrow_mat.emission = sign_data.get("color", Color(1, 1, 1))
		arrow_mat.emission_energy_multiplier = 0.3
		arrow.material_override = arrow_mat

		if sign_data["text"].ends_with("->"):
			arrow.position = Vector3(1.35, 0, 0)
			arrow.rotation_degrees.z = -90
		else:
			arrow.position = Vector3(-0.05, 0, 0)
			arrow.rotation_degrees.z = 90

		sign_root.add_child(arrow)

	## === Text Label3D ===
	var label = Label3D.new()
	label.name = "Text"
	# Xóa ký hiệu mũi tên khỏi text hiển thị
	var display_text = sign_data["text"]
	display_text = display_text.replace(" ->", "").replace("<- ", "").replace(" ^", "").replace(" v", "")
	label.text = display_text
	label.font_size = 48
	label.pixel_size = 0.005
	label.modulate = sign_data.get("color", Color(1, 1, 1))
	label.outline_modulate = Color(0, 0, 0, 0.9)
	label.outline_size = 8
	label.position = Vector3(0.65, 0, 0.03)  # Hơi nhô ra khỏi bảng
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	sign_root.add_child(label)

	return sign_root
