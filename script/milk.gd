extends Node3D

## Script cho vật phẩm Milk - nhặt bằng phím Q để tăng năng lượng

@export var energy_value: int = 10  ## Năng lượng tăng khi nhặt (1 milk = 10 năng lượng)
@export var prompt_message: String = "Nhấn Q để nhặt sữa"

func _ready():
	add_to_group("milk")

func pickup_milk(player):
	if player.has_method("add_energy"):
		# Kiểm tra xem năng lượng đã đầy chưa
		if player.energy >= player.max_energy:
			return  # Không nhặt nếu năng lượng đã đầy
		
		player.add_energy(energy_value)
		queue_free()  # Xóa milk sau khi nhặt

