extends Node3D

## Script cho vật phẩm Milk - nhặt bằng phím Q để tăng năng lượng

@export var energy_value: int = 10  ## Năng lượng tăng khi nhặt (1 milk = 10 năng lượng)
@export var milk_flavor: String = ""  ## Vị sữa: "Nho", "Dưa Lưới", "Dâu"
var prompt_message: String = "Nhấn Q để nhặt sữa"

## Map tên node → vị sữa (tự detect nếu không set export)
const FLAVOR_MAP = {
	"MilkGrape": "Nho",
	"MilkMelon": "Dưa Lưới",
	"MilkStrawberry": "Dâu",
	"Milk": "",
}

func _ready():
	add_to_group("milk")
	# Tự detect vị sữa từ tên node nếu chưa được set
	if milk_flavor == "":
		milk_flavor = FLAVOR_MAP.get(name, "")
	# Cập nhật prompt theo vị
	if milk_flavor != "":
		prompt_message = "Nhấn Q để nhặt sữa Frumi vị " + milk_flavor
	else:
		prompt_message = "Nhấn Q để nhặt sữa Frumi"

func pickup_milk(player):
	if player.has_method("add_energy"):
		# Kiểm tra xem năng lượng đã đầy chưa
		if player.energy >= player.max_energy:
			return  # Không nhặt nếu năng lượng đã đầy
		
		player.add_energy(energy_value)
		_cleanup_and_free()


## Ẩn ngay + xóa khỏi group trước khi queue_free để giảm lag
func _cleanup_and_free():
	visible = false
	set_process(false)
	set_physics_process(false)
	remove_from_group("milk")
	for child in get_children():
		if child is CollisionShape3D:
			child.disabled = true
		elif child is StaticBody3D or child is Area3D:
			for sub in child.get_children():
				if sub is CollisionShape3D:
					sub.disabled = true
	queue_free()


