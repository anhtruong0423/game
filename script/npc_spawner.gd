extends Node3D

## Tự động spawn NPC (dog) khắp map khi game bắt đầu
## NPC dùng model DOG.glb + dog_chase.gd để tấn công player khi đến gần

const DOG_MODEL_PATH = "res://assets/dog/DOG.glb"
const NPC_SCRIPT_PATH = "res://script/dog_chase.gd"

## Vị trí spawn NPC phân bố khắp map
## Y = -133.5 (mặt đất)
const SPAWN_POSITIONS = [
	# === Khu vực cổng StartGate (Z ~85-91) ===
	Vector3(5, -133.5, 88),
	Vector3(-8, -133.5, 86),

	# === Đường chính (Z ~89, X trải dài) ===
	Vector3(-40, -133.5, 87),
	Vector3(-80, -133.5, 88),
	Vector3(-150, -133.5, 86),
	Vector3(-250, -133.5, 88),
	Vector3(-350, -133.5, 87),
	Vector3(-450, -133.5, 89),
	Vector3(40, -133.5, 87),
	Vector3(160, -133.5, 88),
	Vector3(250, -133.5, 87),
	Vector3(350, -133.5, 89),
	Vector3(450, -133.5, 88),
	Vector3(550, -133.5, 87),

	# === Khu farm / đồng (Z ~40-80) ===
	Vector3(-50, -133.5, 55),
	Vector3(50, -133.5, 50),
	Vector3(-100, -133.5, 65),
	Vector3(175, -133.5, 60),
	Vector3(-200, -133.5, 58),
	Vector3(0, -133.5, 45),

	# === Khu shop (gần cửa hàng FrumiShop) ===
	Vector3(105, -133.5, 72),

	# === Khu nhà cửa ===
	Vector3(-16, -133.5, 22),
	Vector3(130, -133.5, 35),
	Vector3(-145, -133.5, 52),

	# === Khu xa (ngoại ô) ===
	Vector3(-500, -133.5, 75),
	Vector3(500, -133.5, 75),
]

## Các thông số chase khác nhau cho mỗi NPC (tạo sự đa dạng)
const CHASE_CONFIGS = [
	{"chase_radius": 8.0, "speed": 2.5, "energy_drain": 12.0, "bite_range": 1.2},
	{"chase_radius": 6.0, "speed": 3.0, "energy_drain": 15.0, "bite_range": 1.0},
	{"chase_radius": 10.0, "speed": 2.0, "energy_drain": 10.0, "bite_range": 1.5},
	{"chase_radius": 7.0, "speed": 3.5, "energy_drain": 18.0, "bite_range": 1.2},
	{"chase_radius": 5.0, "speed": 2.8, "energy_drain": 14.0, "bite_range": 1.0},
]


func _ready():
	call_deferred("_spawn_all_npcs")


func _spawn_all_npcs():
	var dog_model_scene = load(DOG_MODEL_PATH)
	var npc_script = load(NPC_SCRIPT_PATH)

	if not dog_model_scene:
		push_error("[NPCSpawner] Không tìm thấy model: " + DOG_MODEL_PATH)
		return
	if not npc_script:
		push_error("[NPCSpawner] Không tìm thấy script: " + NPC_SCRIPT_PATH)
		return

	for i in range(SPAWN_POSITIONS.size()):
		var pos = SPAWN_POSITIONS[i]
		var config = CHASE_CONFIGS[i % CHASE_CONFIGS.size()]

		# Tạo NPC root node
		var npc = Node3D.new()
		npc.name = "NPC_Dog_%d" % i
		npc.set_script(npc_script)

		# Gán thông số chase
		npc.set("chase_radius", config["chase_radius"])
		npc.set("move_speed", config["speed"])
		npc.set("energy_drain_per_second", config["energy_drain"])
		npc.set("bite_range", config["bite_range"])

		# Thêm model con chó
		var model = dog_model_scene.instantiate()
		model.transform = Transform3D(Basis(), Vector3(0.2, 0, 0.1))
		npc.add_child(model)

		# Thêm vào scene tree trước khi set global_position
		add_child(npc)

		# Đặt vị trí (phải sau add_child để có global transform)
		npc.global_position = pos

		# Quay mặt ngẫu nhiên ban đầu
		npc.rotation.y = randf() * TAU

	print("[NPCSpawner] Đã spawn %d NPC dog khắp map!" % SPAWN_POSITIONS.size())
