extends Node3D

## Spawn trái cây và sữa ngẫu nhiên khắp map

const FRUIT_SCENES = [
	"res://scene/items/apple.tscn",
	"res://scene/items/banana.tscn",
	"res://scene/items/cherry.tscn",
	"res://scene/items/grape.tscn",
	"res://scene/items/lemon.tscn",
	"res://scene/items/mango.tscn",
	"res://scene/items/melon.tscn",
	"res://scene/items/orange.tscn",
	"res://scene/items/strawberry.tscn",
]

const MILK_SCENES = [
	"res://scene/milk_grape.tscn",
	"res://scene/milk_melon.tscn",
	"res://scene/milk_strawberry.tscn",
]

## Số lượng spawn
@export var fruit_count: int = 50
@export var milk_count: int = 80

## Vùng spawn cho TRÁI CÂY (đường đi chính)
const SPAWN_ZONES = [
	{"x_min": -20.0, "x_max": 20.0, "z_min": 30.0, "z_max": 90.0},     # Khu trung tâm
	{"x_min": 20.0, "x_max": 130.0, "z_min": 30.0, "z_max": 85.0},      # Khu phải (gần shop)
	{"x_min": -150.0, "x_max": -20.0, "z_min": 40.0, "z_max": 85.0},    # Khu trái
	{"x_min": -300.0, "x_max": -150.0, "z_min": 50.0, "z_max": 85.0},   # Khu xa trái
	{"x_min": 130.0, "x_max": 300.0, "z_min": 50.0, "z_max": 85.0},     # Khu xa phải
	{"x_min": -500.0, "x_max": -300.0, "z_min": 60.0, "z_max": 85.0},   # Ngoại ô trái
	{"x_min": 300.0, "x_max": 500.0, "z_min": 60.0, "z_max": 85.0},     # Ngoại ô phải
	{"x_min": -100.0, "x_max": 100.0, "z_min": 90.0, "z_max": 120.0},   # Phía sau
]

## Vùng spawn cho SỮA (mở rộng: đồi, trong nhà, khắp nơi)
const MILK_SPAWN_ZONES = [
	# === Đường đi chính ===
	{"x_min": -20.0, "x_max": 20.0, "z_min": 30.0, "z_max": 90.0, "y": -133.5},
	{"x_min": -150.0, "x_max": 150.0, "z_min": 85.0, "z_max": 95.0, "y": -133.5},

	# === Trong/gần nhà cửa ===
	{"x_min": -25.0, "x_max": -5.0, "z_min": 15.0, "z_max": 25.0, "y": -133.5},   # Nhà 1
	{"x_min": -5.0, "x_max": 10.0, "z_min": 15.0, "z_max": 25.0, "y": -133.5},    # Nhà 2
	{"x_min": 125.0, "x_max": 140.0, "z_min": 25.0, "z_max": 40.0, "y": -133.5},  # Nhà 3
	{"x_min": 145.0, "x_max": 160.0, "z_min": 32.0, "z_max": 42.0, "y": -133.5},  # Nhà 4
	{"x_min": -155.0, "x_max": -140.0, "z_min": 42.0, "z_max": 55.0, "y": -133.5},# Nhà 5
	{"x_min": -55.0, "x_max": -40.0, "z_min": 18.0, "z_max": 28.0, "y": -133.5},  # Nhà 6
	{"x_min": 100.0, "x_max": 115.0, "z_min": 38.0, "z_max": 50.0, "y": -133.5},  # Nhà 7
	{"x_min": -190.0, "x_max": -175.0, "z_min": 45.0, "z_max": 55.0, "y": -133.5},# Nhà 8
	{"x_min": -170.0, "x_max": -158.0, "z_min": 58.0, "z_max": 68.0, "y": -133.5},# Nhà 9
	{"x_min": 55.0, "x_max": 70.0, "z_min": 120.0, "z_max": 135.0, "y": -133.5},  # Nhà xa
	{"x_min": 230.0, "x_max": 245.0, "z_min": 95.0, "z_max": 108.0, "y": -133.5}, # Nhà xa 2
	{"x_min": -95.0, "x_max": -80.0, "z_min": 95.0, "z_max": 108.0, "y": -133.5}, # Nhà xa 3

	# === Trên đồi ===
	{"x_min": -80.0, "x_max": -20.0, "z_min": 20.0, "z_max": 50.0, "y": -133.5},
	{"x_min": 20.0, "x_max": 80.0, "z_min": 20.0, "z_max": 50.0, "y": -133.5},
	{"x_min": -200.0, "x_max": -100.0, "z_min": 30.0, "z_max": 60.0, "y": -133.5},
	{"x_min": 150.0, "x_max": 250.0, "z_min": 40.0, "z_max": 70.0, "y": -133.5},
	{"x_min": -50.0, "x_max": 50.0, "z_min": 100.0, "z_max": 130.0, "y": -133.5},
	{"x_min": -300.0, "x_max": -200.0, "z_min": 40.0, "z_max": 70.0, "y": -133.5},
	{"x_min": 250.0, "x_max": 350.0, "z_min": 50.0, "z_max": 75.0, "y": -133.5},

	# === Khu vực xa / ngoại ô ===
	{"x_min": -500.0, "x_max": -300.0, "z_min": 50.0, "z_max": 85.0, "y": -133.5},
	{"x_min": 300.0, "x_max": 550.0, "z_min": 50.0, "z_max": 85.0, "y": -133.5},
	{"x_min": -600.0, "x_max": -500.0, "z_min": 60.0, "z_max": 85.0, "y": -133.5},
	{"x_min": 550.0, "x_max": 600.0, "z_min": 60.0, "z_max": 85.0, "y": -133.5},

	# === Khu farm rộng ===
	{"x_min": -100.0, "x_max": 0.0, "z_min": 60.0, "z_max": 80.0, "y": -133.5},
	{"x_min": 60.0, "x_max": 100.0, "z_min": 55.0, "z_max": 75.0, "y": -133.5},
	{"x_min": 130.0, "x_max": 180.0, "z_min": 100.0, "z_max": 120.0, "y": -133.5},
	{"x_min": -130.0, "x_max": -80.0, "z_min": 100.0, "z_max": 115.0, "y": -133.5},
]


func _ready():
	call_deferred("_spawn_all")


func _spawn_all():
	_spawn_fruits()
	_spawn_milks()


func _spawn_fruits():
	var loaded_scenes = []
	for path in FRUIT_SCENES:
		var scene = load(path)
		if scene:
			loaded_scenes.append(scene)
		else:
			push_warning("[FruitSpawner] Không load được: " + path)

	if loaded_scenes.is_empty():
		push_error("[FruitSpawner] Không có scene trái cây nào!")
		return

	var fruits_node = get_parent().get_node_or_null("scattered_fruits")
	if not fruits_node:
		fruits_node = Node3D.new()
		fruits_node.name = "scattered_fruits"
		get_parent().add_child(fruits_node)

	for i in range(fruit_count):
		var zone = SPAWN_ZONES[randi() % SPAWN_ZONES.size()]
		var x = randf_range(zone["x_min"], zone["x_max"])
		var z = randf_range(zone["z_min"], zone["z_max"])
		var pos = Vector3(x, -133.5, z)

		var scene = loaded_scenes[randi() % loaded_scenes.size()]
		var fruit = scene.instantiate()
		fruit.position = pos
		fruit.rotation.y = randf() * TAU
		fruits_node.add_child(fruit)

	print("[FruitSpawner] Đã spawn %d trái cây khắp map!" % fruit_count)


func _spawn_milks():
	var loaded_scenes = []
	for path in MILK_SCENES:
		var scene = load(path)
		if scene:
			loaded_scenes.append(scene)
		else:
			push_warning("[FruitSpawner] Không load được sữa: " + path)

	if loaded_scenes.is_empty():
		push_error("[FruitSpawner] Không có scene sữa nào!")
		return

	var milks_node = get_parent().get_node_or_null("scattered_milks")
	if not milks_node:
		milks_node = Node3D.new()
		milks_node.name = "scattered_milks"
		get_parent().add_child(milks_node)

	for i in range(milk_count):
		var zone = MILK_SPAWN_ZONES[randi() % MILK_SPAWN_ZONES.size()]
		var x = randf_range(zone["x_min"], zone["x_max"])
		var z = randf_range(zone["z_min"], zone["z_max"])
		var y = zone["y"]
		var pos = Vector3(x, y, z)

		var scene = loaded_scenes[randi() % loaded_scenes.size()]
		var milk = scene.instantiate()
		milk.position = pos
		milk.rotation.y = randf() * TAU
		milks_node.add_child(milk)

	print("[FruitSpawner] Đã spawn %d sữa các loại khắp map!" % milk_count)
