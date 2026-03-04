extends Node3D

## Script cho thùng rác - nơi player mang rác đến bỏ vào
## Khi rác được bỏ vào, hiển thị đúng hình dạng 3D model của rác trong thùng
## Tối ưu: preload tất cả scene 1 lần thay vì load mỗi khi nhặt

@export var prompt_message: String = "Nhấn E để bỏ rác vào thùng"

var delivered_fruits: Array = []
var fruit_visuals: Node3D = null

## Preloaded fruit scene cache
var _scene_cache: Dictionary = {}

const FRUIT_SCENE_PATHS = {
	"chai_nhua": "res://scene/items/chainhua.tscn",
	"tui_giay": "res://scene/items/tuigiay.tscn",
	"tui_nilong": "res://scene/items/tuinilong.tscn",
	"lon_nuoc_ngot": "res://scene/items/lonnuocngot.tscn",
	"giay_bao_cu": "res://scene/items/giaybaocu.tscn",
	"vo_xe_cu": "res://scene/items/voxecu.tscn",
	"hop_sua_cu": "res://scene/items/hopsuacu.tscn",
	"chai_sua": "res://scene/items/chaisua.tscn",
	"thung_carton": "res://scene/items/thungcarton.tscn",
}

## Vị trí đặt rác bên trong thùng (local space của nhanvat, scale ~0.0146)
## Offset lớn vì parent node có scale rất nhỏ
const FRUIT_POSITIONS = [
	Vector3(0, 3.0, 0),
	Vector3(2.5, 3.0, 1.5),
	Vector3(-2.5, 3.0, 1.5),
	Vector3(1.5, 3.0, -2.5),
	Vector3(-1.5, 3.0, -2.5),
	Vector3(2.5, 3.0, -1.5),
	Vector3(-2.5, 3.0, -1.5),
	Vector3(0, 5.5, 0),
	Vector3(2.0, 5.5, 2.0),
]

## Scale lớn để bù cho parent nhanvat có scale ~0.0146
const FRUIT_VISUAL_SCALE = Vector3(20.0, 20.0, 20.0)

func _ready():
	add_to_group("basket")
	fruit_visuals = Node3D.new()
	fruit_visuals.name = "FruitVisuals"
	add_child(fruit_visuals)
	# Preload tất cả trash scenes để tránh lag khi nhặt
	_preload_scenes()


func _preload_scenes():
	for fruit_type in FRUIT_SCENE_PATHS:
		var scene = load(FRUIT_SCENE_PATHS[fruit_type])
		if scene:
			_scene_cache[fruit_type] = scene


func interact(player):
	if not player.has_method("deliver_items"):
		return
	if player.inventory.size() == 0:
		return

	var delivered_types = player.deliver_items()
	if delivered_types.size() > 0:
		for fruit_type in delivered_types:
			_add_fruit_visual(fruit_type)

		var level_mgr = get_tree().get_first_node_in_group("level_manager")
		if level_mgr:
			level_mgr.on_items_delivered(delivered_types)


func _add_fruit_visual(fruit_type: String):
	delivered_fruits.append(fruit_type)

	# Dùng scene từ cache thay vì load mỗi lần
	var scene = _scene_cache.get(fruit_type, null)
	if not scene:
		return

	var instance = scene.instantiate()

	instance.set_script(null)

	_remove_interactive_children(instance)

	instance.scale = FRUIT_VISUAL_SCALE

	var index = delivered_fruits.size() - 1
	if index < FRUIT_POSITIONS.size():
		instance.position = FRUIT_POSITIONS[index]
	else:
		var base_index = index % FRUIT_POSITIONS.size()
		var layer = index / FRUIT_POSITIONS.size()
		instance.position = FRUIT_POSITIONS[base_index] + Vector3(0, 3.0 * layer, 0)

	fruit_visuals.add_child(instance)


func _remove_interactive_children(node: Node):
	var to_remove: Array = []
	for child in node.get_children():
		if child is Area3D or child is StaticBody3D or child is CollisionShape3D:
			to_remove.append(child)
	for child in to_remove:
		child.queue_free()
