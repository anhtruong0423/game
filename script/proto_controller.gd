# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

## Can we move around?
@export var can_move : bool = true
## Are we affected by gravity?
@export var has_gravity : bool = true
## Can we press to jump?
@export var can_jump : bool = true
## Can we hold to run?
@export var can_sprint : bool = false
## Can we press to enter freefly mode (noclip)?
@export var can_freefly : bool = false

@export_group("Speeds")
## Look around rotation speed.
@export var look_speed : float = 0.002
## Normal speed.
@export var base_speed : float = 3.0
## Speed of jump.
@export var jump_velocity : float = 4.5
## How fast do we run?
@export var sprint_speed : float = 10.0
## How fast do we freefly?
@export var freefly_speed : float = 25.0

@export_group("Input Actions")
## Name of Input Action to move Left.
@export var input_left : String = "ui_left"
## Name of Input Action to move Right.
@export var input_right : String = "ui_right"
## Name of Input Action to move Forward.
@export var input_forward : String = "ui_up"
## Name of Input Action to move Backward.
@export var input_back : String = "ui_down"
## Name of Input Action to Jump.
@export var input_jump : String = "ui_accept"
## Name of Input Action to Sprint.
@export var input_sprint : String = "sprint"
## Name of Input Action to toggle freefly mode.
@export var input_freefly : String = "freefly"
## Name of Input Action to interact with objects.
@export var input_interact : String = "interact"
## Name of Input Action to pick up milk.
@export var input_pickup_milk : String = "pickup_milk"

var mouse_captured : bool = false
var look_rotation : Vector2
var move_speed : float = 0.0
var freeflying : bool = false
var score : int = 0
var current_interactable : Node = null
var current_milk : Node = null  ## Milk gần nhất có thể nhặt bằng Q

## Inventory system
var inventory : Array = []
var max_capacity : int = 2

## Energy system
var energy : float = 100.0
var max_energy : float = 100.0
var energy_drain_rate : float = 5.0  ## Năng lượng mất mỗi giây khi di chuyển

## Upgrade system
var upgrade_levels : Dictionary = {"inventory": 0, "speed": 0, "energy": 0}
var coin_value_multiplier : float = 1.0  ## Dự phòng cho tương lai
var upgrade_menu_open : bool = false
const UPGRADE_PRICES : Dictionary = {"inventory": 100, "speed": 50, "energy": 200}
const BASE_INVENTORY_CAPACITY : int = 2
const BASE_SPEED : float = 7.0
const BASE_ENERGY_DRAIN : float = 5.0

## IMPORTANT REFERENCES
@onready var head: Node3D = $Head
@onready var collider: CollisionShape3D = $Collider
@onready var interact_ray: RayCast3D = $Head/InteractRay
@onready var score_label: Label = $HUD/ScoreLabel
@onready var interact_prompt: Label = $HUD/InteractPrompt
@onready var inventory_label: Label = $HUD/InventoryLabel
@onready var energy_bar: ProgressBar = $HUD/EnergyBar
@onready var milk_prompt: Label = $HUD/MilkPrompt
@onready var upgrade_indicator: Label = $HUD/UpgradeIndicator
@onready var upgrade_menu: Control = $HUD/UpgradeMenu
@onready var inventory_upgrade_btn: Button = $HUD/UpgradeMenu/VBoxContainer/InventoryUpgrade
@onready var speed_upgrade_btn: Button = $HUD/UpgradeMenu/VBoxContainer/SpeedUpgrade
@onready var energy_upgrade_btn: Button = $HUD/UpgradeMenu/VBoxContainer/EnergyUpgrade

func _ready() -> void:
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x
	
	# Khởi tạo upgrade system
	apply_upgrades()
	if upgrade_menu:
		upgrade_menu.visible = false
	
	# Kết nối signals cho upgrade buttons
	if inventory_upgrade_btn:
		inventory_upgrade_btn.pressed.connect(_on_inventory_upgrade_pressed)
	if speed_upgrade_btn:
		speed_upgrade_btn.pressed.connect(_on_speed_upgrade_pressed)
	if energy_upgrade_btn:
		energy_upgrade_btn.pressed.connect(_on_energy_upgrade_pressed)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		capture_mouse()
	if Input.is_key_pressed(KEY_ESCAPE):
		if upgrade_menu_open:
			toggle_upgrade_menu()
		else:
			release_mouse()
	
	# Look around
	if mouse_captured and event is InputEventMouseMotion:
		rotate_look(event.relative)
	
	# Toggle freefly mode
	if can_freefly and Input.is_action_just_pressed(input_freefly):
		if not freeflying:
			enable_freefly()
		else:
			disable_freefly()
	
	# Interact with objects (press E)
	if Input.is_action_just_pressed(input_interact):
		try_interact()
	
	# Pick up milk (press Q)
	if Input.is_action_just_pressed(input_pickup_milk):
		try_pickup_milk()
	
	# Open upgrade menu (press Tab) - chỉ mở, không đóng
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if not upgrade_menu_open:
			toggle_upgrade_menu()

func _physics_process(delta: float) -> void:
	# If freeflying, handle freefly and nothing else
	if can_freefly and freeflying:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var motion := (head.global_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		motion *= freefly_speed * delta
		move_and_collide(motion)
		return
	
	# Apply gravity to velocity
	if has_gravity:
		if not is_on_floor():
			velocity += get_gravity() * delta

	# Apply jumping
	if can_jump:
		if Input.is_action_just_pressed(input_jump) and is_on_floor():
			velocity.y = jump_velocity

	# Modify speed based on sprinting and upgrades
	var upgraded_speed = calculate_speed()
	if can_sprint and Input.is_action_pressed(input_sprint):
			move_speed = sprint_speed * (1.0 + 0.1 * upgrade_levels["speed"])
	else:
		move_speed = upgraded_speed

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
			# Tiêu hao năng lượng khi di chuyển (dựa trên upgrade)
			drain_energy(calculate_energy_drain() * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.y = 0
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	# 1. Tính toán góc xoay mới
	look_rotation.x -= rot_input.y * look_speed
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * look_speed
	
	# 2. Xoay thân người (chỉ xoay quanh trục Y)
	# Thay vì reset Basis, chúng ta set trực tiếp góc xoay để bảo toàn vị trí
	self.rotation.y = look_rotation.y
	
	# 3. Xoay đầu (chỉ xoay quanh trục X)
	# Đảm bảo head chỉ thay đổi rotation, không chạm vào position
	head.rotation.x = look_rotation.x

func enable_freefly():
	collider.disabled = true
	freeflying = true
	velocity = Vector3.ZERO

func disable_freefly():
	collider.disabled = false
	freeflying = false


func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func release_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false


## Checks if some Input Actions haven't been created.
## Disables functionality accordingly.
func check_input_mappings():
	if can_move and not InputMap.has_action(input_left):
		push_error("Movement disabled. No InputAction found for input_left: " + input_left)
		can_move = false
	if can_move and not InputMap.has_action(input_right):
		push_error("Movement disabled. No InputAction found for input_right: " + input_right)
		can_move = false
	if can_move and not InputMap.has_action(input_forward):
		push_error("Movement disabled. No InputAction found for input_forward: " + input_forward)
		can_move = false
	if can_move and not InputMap.has_action(input_back):
		push_error("Movement disabled. No InputAction found for input_back: " + input_back)
		can_move = false
	if can_jump and not InputMap.has_action(input_jump):
		push_error("Jumping disabled. No InputAction found for input_jump: " + input_jump)
		can_jump = false
	if can_sprint and not InputMap.has_action(input_sprint):
		push_error("Sprinting disabled. No InputAction found for input_sprint: " + input_sprint)
		can_sprint = false
	if can_freefly and not InputMap.has_action(input_freefly):
		push_error("Freefly disabled. No InputAction found for input_freefly: " + input_freefly)
		can_freefly = false


## Check for interactable objects every frame
func _process(_delta: float) -> void:
	check_interactable()
	check_milk()
	update_energy_ui()


## Check if raycast is hitting an interactable object
func check_interactable():
	if not interact_ray:
		return
	
	if interact_ray.is_colliding():
		var collider_obj = interact_ray.get_collider()
		if collider_obj:
			# First check if the collider itself has interact method (e.g. DeliveryArea)
			var interactable = null
			if collider_obj.has_method("interact"):
				interactable = collider_obj
			else:
				# Otherwise check parent (e.g. coin's Area3D -> coin)
				var parent = collider_obj.get_parent()
				if parent and parent.has_method("interact"):
					interactable = parent
			
			if interactable:
				current_interactable = interactable
				# Show interact prompt
				if interact_prompt:
					var prompt_text = "Nhấn E"
					if interactable.get("prompt_message"):
						prompt_text = interactable.prompt_message
					interact_prompt.text = prompt_text
				return
	
	current_interactable = null
	# Hide interact prompt (chỉ ẩn nếu không có milk)
	if interact_prompt and not current_milk:
		interact_prompt.text = ""


## Try to interact with the current interactable object
func try_interact():
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact(self)


## Add item to inventory (returns true if successful)
func add_to_inventory(item_value: int) -> bool:
	if inventory.size() >= max_capacity:
		return false
	# Áp dụng coin_value_multiplier (dự phòng cho tương lai)
	var final_value = int(item_value * coin_value_multiplier)
	inventory.append(final_value)
	update_inventory_ui()
	return true


## Deliver all items in inventory to score
func deliver_items():
	if inventory.size() == 0:
		return
	
	var total = 0
	for item in inventory:
		total += item
	score += total
	inventory.clear()
	
	update_score_ui()
	update_inventory_ui()


## Check if inventory is full
func is_inventory_full() -> bool:
	return inventory.size() >= max_capacity


## Update the score display on screen
func update_score_ui():
	if score_label:
		score_label.text = "Score: " + str(score)


## Update the inventory display on screen
func update_inventory_ui():
	if inventory_label:
		inventory_label.text = "Túi: " + str(inventory.size()) + "/" + str(max_capacity)


## Tiêu hao năng lượng
func drain_energy(amount: float):
	energy = max(0, energy - amount)


## Thêm năng lượng (từ milk)
func add_energy(amount: float):
	energy = min(max_energy, energy + amount)


## Cập nhật UI thanh năng lượng
func update_energy_ui():
	if energy_bar:
		energy_bar.value = energy


## Kiểm tra milk gần nhất có thể nhặt
func check_milk():
	if not interact_ray:
		current_milk = null
		return
	
	if interact_ray.is_colliding():
		var collider_obj = interact_ray.get_collider()
		if collider_obj:
			var milk = null
			# Kiểm tra xem collider có phải là milk không
			if collider_obj.has_method("pickup_milk"):
				milk = collider_obj
			else:
				# Kiểm tra parent (Area3D -> Milk node)
				var parent = collider_obj.get_parent()
				if parent:
					if parent.has_method("pickup_milk"):
						milk = parent
					else:
						# Kiểm tra thêm 1 level nữa cho trường hợp nested
						var grandparent = parent.get_parent()
						if grandparent and grandparent.has_method("pickup_milk"):
							milk = grandparent
			
			if milk:
				current_milk = milk
				if milk_prompt:
					milk_prompt.text = "Ấn Q để nhặt milk"
				return
	
	current_milk = null
	if milk_prompt:
		milk_prompt.text = ""


## Nhặt milk khi nhấn Q
func try_pickup_milk():
	if current_milk and current_milk.has_method("pickup_milk"):
		current_milk.pickup_milk(self)


## ==================== UPGRADE SYSTEM ====================

## Tính tốc độ di chuyển dựa trên upgrade level
func calculate_speed() -> float:
	return BASE_SPEED * (1.0 + 0.1 * upgrade_levels["speed"])


## Tính tốc độ tiêu hao năng lượng dựa trên upgrade level
func calculate_energy_drain() -> float:
	var drain = BASE_ENERGY_DRAIN * (1.0 - 0.1 * upgrade_levels["energy"])
	return max(0.1, drain)  ## Tối thiểu 0.1


## Tính dung lượng túi dựa trên upgrade level
func calculate_inventory_capacity() -> int:
	return BASE_INVENTORY_CAPACITY + upgrade_levels["inventory"]


## Lấy giá nâng cấp tiếp theo
func get_upgrade_price(upgrade_type: String) -> int:
	return UPGRADE_PRICES.get(upgrade_type, 0)


## Mua nâng cấp
func buy_upgrade(upgrade_type: String) -> bool:
	var price = get_upgrade_price(upgrade_type)
	if score < price:
		return false
	
	score -= price
	upgrade_levels[upgrade_type] += 1
	
	# Áp dụng hiệu ứng ngay lập tức
	apply_upgrades()
	
	# Cập nhật UI
	update_score_ui()
	update_upgrade_ui()
	update_inventory_ui()
	
	return true


## Áp dụng tất cả upgrades
func apply_upgrades():
	# Cập nhật dung lượng túi
	max_capacity = calculate_inventory_capacity()
	# Tốc độ và năng lượng được tính động trong _physics_process


## Toggle upgrade menu
func toggle_upgrade_menu():
	upgrade_menu_open = not upgrade_menu_open
	if upgrade_menu:
		upgrade_menu.visible = upgrade_menu_open
	if upgrade_menu_open:
		release_mouse()
		update_upgrade_ui()
	else:
		capture_mouse()


## Cập nhật UI upgrade menu
func update_upgrade_ui():
	if not upgrade_menu:
		return
	
	# Cập nhật nút Inventory
	if inventory_upgrade_btn:
		var inv_level = upgrade_levels["inventory"]
		var inv_price = get_upgrade_price("inventory")
		inventory_upgrade_btn.text = "Túi đồ Lv.%d → Lv.%d\n(%d slot → %d slot)\nGiá: %d điểm" % [
			inv_level, inv_level + 1,
			BASE_INVENTORY_CAPACITY + inv_level,
			BASE_INVENTORY_CAPACITY + inv_level + 1,
			inv_price
		]
		inventory_upgrade_btn.disabled = score < inv_price
	
	# Cập nhật nút Speed
	if speed_upgrade_btn:
		var speed_level = upgrade_levels["speed"]
		var speed_price = get_upgrade_price("speed")
		var current_bonus = speed_level * 10
		var next_bonus = (speed_level + 1) * 10
		speed_upgrade_btn.text = "Tốc độ Lv.%d → Lv.%d\n(+%d%% → +%d%%)\nGiá: %d điểm" % [
			speed_level, speed_level + 1,
			current_bonus, next_bonus,
			speed_price
		]
		speed_upgrade_btn.disabled = score < speed_price
	
	# Cập nhật nút Energy
	if energy_upgrade_btn:
		var energy_level = upgrade_levels["energy"]
		var energy_price = get_upgrade_price("energy")
		var current_reduction = energy_level * 10
		var next_reduction = (energy_level + 1) * 10
		energy_upgrade_btn.text = "Năng lượng Lv.%d → Lv.%d\n(-%d%% → -%d%% tiêu hao)\nGiá: %d điểm" % [
			energy_level, energy_level + 1,
			current_reduction, next_reduction,
			energy_price
		]
		energy_upgrade_btn.disabled = score < energy_price


## Callback khi nhấn nút nâng cấp Inventory
func _on_inventory_upgrade_pressed():
	buy_upgrade("inventory")


## Callback khi nhấn nút nâng cấp Speed
func _on_speed_upgrade_pressed():
	buy_upgrade("speed")


## Callback khi nhấn nút nâng cấp Energy
func _on_energy_upgrade_pressed():
	buy_upgrade("energy")
