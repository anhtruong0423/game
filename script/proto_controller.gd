# ProtoController v1.0 by Brackeys
# CC0 License
# Intended for rapid prototyping of first-person games.
# Happy prototyping!

extends CharacterBody3D

## Tutorial signals
signal trash_picked_up(item_type: String)
signal milk_picked_up()
signal inventory_full_attempted()

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
var inventory : Array = []  ## Array of {value: int, weight: float}
var max_capacity : int = 2
var total_weight : float = 0.0  ## Tổng trọng lượng đang mang

## Weight system constants
const WEIGHT_SPEED_PENALTY : float = 0.05  ## Giảm 5% tốc độ mỗi kg
const MAX_WEIGHT_PENALTY : float = 0.5  ## Tối đa giảm 50% tốc độ

## Proximity detection range
const INTERACT_RANGE : float = 3.0

## Throttle cho proximity check (giảm lag)
var _proximity_check_timer : float = 0.0
const PROXIMITY_CHECK_INTERVAL : float = 0.25  ## Chỉ check mỗi 0.25 giây thay vì mỗi frame

## Energy system
var energy : float = 100.0
var max_energy : float = 100.0
var energy_drain_rate : float = 5.0  ## Năng lượng mất mỗi giây khi di chuyển
var is_exhausted : bool = false
var is_sprinting : bool = false
var energy_blink_timer : float = 0.0

## Upgrade system
var upgrade_levels : Dictionary
var coin_value_multiplier : float = 1.0  ## Dự phòng cho tương lai
var upgrade_menu_open : bool = false
var pause_menu_open : bool = false
const UPGRADE_BASE_PRICES : Dictionary = {"inventory": 500, "speed": 300, "energy": 800}
const BASE_INVENTORY_CAPACITY : int = 1
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
var coin_display_label: Label = null  ## Hiển thị số xu trên bảng upgrade

## Pause Menu references
@onready var pause_panel: Control = $HUD/PausePanel
@onready var pause_continue_btn: Button = $HUD/PausePanel/VBoxContainer/ContinueButton
@onready var pause_restart_btn: Button = $HUD/PausePanel/VBoxContainer/RestartButton
@onready var pause_settings_btn: Button = $HUD/PausePanel/VBoxContainer/SettingsButton
@onready var pause_mainmenu_btn: Button = $HUD/PausePanel/VBoxContainer/MainMenuButton
@onready var pause_quit_btn: Button = $HUD/PausePanel/VBoxContainer/QuitButton
@onready var pause_settings_panel: Control = $HUD/PausePanel/PauseSettingsPanel

## Pause Settings UI references
@onready var pause_brightness_slider: HSlider = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/BrightnessContainer/PauseBrightnessSlider
@onready var pause_brightness_value: Label = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/BrightnessContainer/PauseBrightnessValue
@onready var pause_master_slider: HSlider = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/MasterContainer/PauseMasterSlider
@onready var pause_master_value: Label = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/MasterContainer/PauseMasterValue
@onready var pause_music_slider: HSlider = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/MusicContainer/PauseMusicSlider
@onready var pause_music_value: Label = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/MusicContainer/PauseMusicValue
@onready var pause_sfx_slider: HSlider = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/SfxContainer/PauseSfxSlider
@onready var pause_sfx_value: Label = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/SfxContainer/PauseSfxValue
@onready var pause_sensitivity_slider: HSlider = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/SensitivityContainer/PauseSensitivitySlider
@onready var pause_sensitivity_value: Label = $HUD/PausePanel/PauseSettingsPanel/Panel/ScrollContainer/VBoxContainer/SensitivityContainer/PauseSensitivityValue
@onready var pause_settings_save_btn: Button = $HUD/PausePanel/PauseSettingsPanel/Panel/ButtonsContainer/SaveButton
@onready var pause_settings_reset_btn: Button = $HUD/PausePanel/PauseSettingsPanel/Panel/ButtonsContainer/ResetButton
@onready var pause_settings_close_btn: Button = $HUD/PausePanel/PauseSettingsPanel/Panel/ButtonsContainer/CloseButton

var pet_instance: Node3D = null
var turtle_hint_label: Label = null
var minimap_instance: Node = null
var zone_indicator_instance: Node = null

## Flashlight system
var has_flashlight := false
var flashlight_on := false
var flashlight_node: SpotLight3D = null
const FLASHLIGHT_PICKUP_RANGE := 3.0

## Dog Bite Effect - Camera shake
var _shake_intensity: float = 0.0
var _shake_timer: float = 0.0
var _original_head_rotation: Vector3 = Vector3.ZERO
var _bite_warning_label: Label = null

func _ready() -> void:
	add_to_group("player")
	# Đảm bảo game không bị kẹt ở trạng thái pause
	get_tree().paused = false
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

	if score_label:
		score_label.visible = false

	upgrade_levels = Global.upgrade_levels

	_setup_energy_bar_style()
	_setup_transparent_buttons()
	_setup_turtle_hint()
	_spawn_pet.call_deferred()
	_setup_minimap.call_deferred()
	_setup_zone_indicator.call_deferred()
	_restore_flashlight.call_deferred()
	_setup_bite_warning.call_deferred()

	apply_upgrades()
	update_inventory_ui()
	print("[Player] Pet=%s, inventory_bonus=%d, max_capacity=%d" % [Global.selected_pet, int(Global.get_pet_bonus("inventory_bonus")), max_capacity])
	if upgrade_menu:
		upgrade_menu.visible = false
	
	# Kết nối signals cho upgrade buttons
	if inventory_upgrade_btn:
		inventory_upgrade_btn.pressed.connect(_on_inventory_upgrade_pressed)
	if speed_upgrade_btn:
		speed_upgrade_btn.pressed.connect(_on_speed_upgrade_pressed)
	if energy_upgrade_btn:
		energy_upgrade_btn.pressed.connect(_on_energy_upgrade_pressed)
	
	# Khởi tạo pause menu
	if pause_panel:
		pause_panel.visible = false
	
	# Kết nối signals cho pause menu buttons
	if pause_continue_btn:
		pause_continue_btn.pressed.connect(_on_pause_continue_pressed)
	if pause_restart_btn:
		pause_restart_btn.pressed.connect(_on_pause_restart_pressed)
	if pause_settings_btn:
		pause_settings_btn.pressed.connect(_on_pause_settings_pressed)
	if pause_mainmenu_btn:
		pause_mainmenu_btn.pressed.connect(_on_pause_mainmenu_pressed)
	if pause_quit_btn:
		pause_quit_btn.pressed.connect(_on_pause_quit_pressed)
	
	# Kết nối signals cho pause settings panel
	if pause_settings_close_btn:
		pause_settings_close_btn.pressed.connect(_on_pause_settings_close_pressed)
	if pause_settings_save_btn:
		pause_settings_save_btn.pressed.connect(_on_pause_settings_save_pressed)
	if pause_settings_reset_btn:
		pause_settings_reset_btn.pressed.connect(_on_pause_settings_reset_pressed)
	
	# Tạo giao diện pause menu kiểu game casual
	_setup_pause_menu_style()
	
	# Kết nối signals cho pause settings sliders
	if pause_brightness_slider:
		pause_brightness_slider.value_changed.connect(_on_pause_brightness_changed)
	if pause_master_slider:
		pause_master_slider.value_changed.connect(_on_pause_master_changed)
	if pause_music_slider:
		pause_music_slider.value_changed.connect(_on_pause_music_changed)
	if pause_sfx_slider:
		pause_sfx_slider.value_changed.connect(_on_pause_sfx_changed)
	if pause_sensitivity_slider:
		pause_sensitivity_slider.value_changed.connect(_on_pause_sensitivity_changed)

func _unhandled_input(event: InputEvent) -> void:
	# Mouse capturing (chỉ khi không pause)
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not pause_menu_open:
		capture_mouse()
	
	# Xử lý ESC
	if Input.is_key_pressed(KEY_ESCAPE):
		if pause_menu_open:
			# Nếu đang mở map overlay, đóng map overlay
			if pause_map_panel and pause_map_panel.visible:
				pause_map_panel.visible = false
			# Nếu đang mở settings trong pause, đóng settings
			elif pause_settings_panel and pause_settings_panel.visible:
				pause_settings_panel.visible = false
			else:
				# Đóng pause menu
				toggle_pause_menu()
		elif upgrade_menu_open:
			toggle_upgrade_menu()
		else:
			# Mở pause menu
			toggle_pause_menu()
	
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
	
	# Toggle upgrade menu (press Tab) - mở/đóng bằng Tab, không cho mở khi pause
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if not pause_menu_open:
			toggle_upgrade_menu()
	
	# Mở rộng minimap (press M)
	if event is InputEventKey and event.pressed and event.keycode == KEY_M:
		if not pause_menu_open and not upgrade_menu_open:
			if minimap_instance and minimap_instance.has_method("toggle_expand"):
				minimap_instance.toggle_expand()

	# Flashlight (press P) - nhặt hoặc bật/tắt đèn pin
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		if not pause_menu_open and not upgrade_menu_open:
			if has_flashlight:
				toggle_flashlight()
			else:
				try_pickup_flashlight()

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

	# Modify speed based on sprinting, upgrades, and exhaustion
	var upgraded_speed = calculate_speed()
	if is_exhausted:
		move_speed = BASE_SPEED * 0.15
		is_sprinting = false
	elif can_sprint and Input.is_action_pressed(input_sprint):
		move_speed = sprint_speed * (1.0 + 0.1 * upgrade_levels["speed"])
		is_sprinting = true
	else:
		move_speed = upgraded_speed
		is_sprinting = false

	# Apply desired movement to velocity
	if can_move:
		var input_dir := Input.get_vector(input_left, input_right, input_forward, input_back)
		var move_dir := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if move_dir:
			velocity.x = move_dir.x * move_speed
			velocity.z = move_dir.z * move_speed
			if not is_exhausted:
				var drain_multiplier = 2.0 if is_sprinting else 1.0
				if is_sprinting:
					drain_multiplier *= (1.0 - Global.get_pet_bonus("sprint_drain_reduction"))
				drain_energy(calculate_energy_drain() * drain_multiplier * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, move_speed)
			velocity.z = move_toward(velocity.z, 0, move_speed)
	else:
		velocity.x = 0
		velocity.z = 0
	
	# Use velocity to actually move
	move_and_slide()


## Rotate us to look around.
## Base of controller rotates around y (left/right). Head rotates around x (up/down).
## Modifies look_rotation based on rot_input, then resets basis and rotates by look_rotation.
func rotate_look(rot_input : Vector2):
	# Lấy mouse sensitivity từ Global settings
	var current_sensitivity = Global.settings.get("mouse_sensitivity", look_speed)
	
	# 1. Tính toán góc xoay mới
	look_rotation.x -= rot_input.y * current_sensitivity
	look_rotation.x = clamp(look_rotation.x, deg_to_rad(-85), deg_to_rad(85))
	look_rotation.y -= rot_input.x * current_sensitivity
	
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


## Check for interactable objects (throttled để giảm lag)
func _process(_delta: float) -> void:
	_proximity_check_timer += _delta
	if _proximity_check_timer >= PROXIMITY_CHECK_INTERVAL:
		_proximity_check_timer = 0.0
		check_interactable()
		check_milk()
		_check_flashlight_proximity()
	update_energy_ui()
	_pet_passive_heal(_delta)
	_process_camera_shake(_delta)
	_process_bite_warning(_delta)


## Check for nearby interactable objects (fruits, basket) using proximity
## Tối ưu: dùng distance_squared_to để tránh sqrt
func check_interactable():
	var effective_range := INTERACT_RANGE + Global.get_pet_bonus("interact_range_bonus")
	var range_sq := effective_range * effective_range
	const EARLY_EXIT_SQ := 2.25  ## 1.5m — đủ gần, không cần tìm thêm

	# Check for nearby fruits first
	var nearest_fruit = null
	var nearest_fruit_dist_sq = range_sq

	for node in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(node):
			continue
		var dist_sq = global_position.distance_squared_to(node.global_position)
		if dist_sq < nearest_fruit_dist_sq:
			nearest_fruit_dist_sq = dist_sq
			nearest_fruit = node
			# Early exit nếu rất gần
			if dist_sq < EARLY_EXIT_SQ:
				break

	if nearest_fruit:
		current_interactable = nearest_fruit
		if interact_prompt:
			interact_prompt.text = nearest_fruit.prompt_message if nearest_fruit.get("prompt_message") else "Nhấn E để nhặt"
		return

	# No fruit nearby → check basket (only if player has items)
	if inventory.size() > 0:
		var nearest_basket = null
		var nearest_basket_dist_sq = range_sq

		for node in get_tree().get_nodes_in_group("basket"):
			if not is_instance_valid(node):
				continue
			var dist_sq = global_position.distance_squared_to(node.global_position)
			if dist_sq < nearest_basket_dist_sq:
				nearest_basket_dist_sq = dist_sq
				nearest_basket = node

		if nearest_basket:
			current_interactable = nearest_basket
			if interact_prompt:
				interact_prompt.text = nearest_basket.prompt_message if nearest_basket.get("prompt_message") else "Nhấn E để bỏ rác vào thùng"
			return

	current_interactable = null
	if interact_prompt:
		interact_prompt.text = ""


## Try to interact with the current interactable object
func try_interact():
	if current_interactable and current_interactable.has_method("interact"):
		current_interactable.interact(self)


## Add item to inventory (returns true if successful) - legacy support
func add_to_inventory(item_value: int) -> bool:
	return add_to_inventory_with_weight(item_value, 1.0)


## Add item to inventory with weight (returns true if successful)
func add_to_inventory_with_weight(item_value: int, item_weight: float) -> bool:
	return add_to_inventory_typed("", item_value, item_weight)


## Add item to inventory with type and weight (returns true if successful)
func add_to_inventory_typed(item_type: String, item_value: int, item_weight: float) -> bool:
	if inventory.size() >= max_capacity:
		inventory_full_attempted.emit()
		return false
	var final_value = int(item_value * coin_value_multiplier)
	inventory.append({"type": item_type, "value": final_value, "weight": item_weight})
	total_weight += item_weight
	update_inventory_ui()
	AudioManager.play_pick_sfx()
	trash_picked_up.emit(item_type)
	return true


## Deliver all items in inventory to score, returns list of delivered item types
func deliver_items() -> Array:
	if inventory.size() == 0:
		return []
	
	var delivered_types: Array = []
	var total = 0
	for item in inventory:
		if item is Dictionary:
			total += item.get("value", 0)
			var t = item.get("type", "")
			if t != "":
				delivered_types.append(t)
		else:
			total += item
	score += total
	inventory.clear()
	total_weight = 0.0
	
	update_score_ui()
	update_inventory_ui()
	return delivered_types


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
		inventory_label.text = "Túi: " + str(inventory.size()) + "/" + str(max_capacity) + " (%.1fkg)" % total_weight


## Tiêu hao năng lượng (from_dog=true khi bị chó cắn)
func drain_energy(amount: float, from_dog: bool = false):
	var reduction := Global.get_pet_bonus("dog_damage_reduction")
	var final_amount := amount * (1.0 - reduction)
	energy = max(0, energy - final_amount)
	
	# Chỉ rung camera + cảnh báo khi bị chó cắn
	if from_dog:
		_trigger_camera_shake(0.02, 0.15)
		_show_bite_warning()
	
	if energy <= 0 and not is_exhausted:
		is_exhausted = true
		trigger_game_over()


## === CAMERA SHAKE khi bị chó cắn ===
func _trigger_camera_shake(intensity: float, duration: float):
	_shake_intensity = intensity
	_shake_timer = duration

func _process_camera_shake(delta: float):
	if _shake_timer <= 0:
		return
	_shake_timer -= delta
	if _shake_timer <= 0:
		_shake_timer = 0
		_shake_intensity = 0
		head.rotation.x = look_rotation.x
		return
	# Rung ngẫu nhiên trổi trái-phải và lên-xuống
	var shake_x = randf_range(-_shake_intensity, _shake_intensity)
	var shake_y = randf_range(-_shake_intensity, _shake_intensity)
	head.rotation.x = look_rotation.x + shake_x
	rotation.y = look_rotation.y + shake_y


## === CẢNH BÁO BỊ CẮN ===
func _setup_bite_warning():
	var hud_node = get_node_or_null("HUD")
	if not hud_node:
		return
	_bite_warning_label = Label.new()
	_bite_warning_label.name = "BiteWarning"
	_bite_warning_label.text = "⚠ Đang bị chó cắn! Năng lượng đang giảm!"
	_bite_warning_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_bite_warning_label.anchor_left = 0.5
	_bite_warning_label.anchor_right = 0.5
	_bite_warning_label.anchor_top = 0.15
	_bite_warning_label.anchor_bottom = 0.15
	_bite_warning_label.offset_left = -200
	_bite_warning_label.offset_right = 200
	_bite_warning_label.offset_top = -15
	_bite_warning_label.offset_bottom = 15
	_bite_warning_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_bite_warning_label.add_theme_font_size_override("font_size", 22)
	_bite_warning_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2, 1.0))
	_bite_warning_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	_bite_warning_label.add_theme_constant_override("shadow_offset_x", 2)
	_bite_warning_label.add_theme_constant_override("shadow_offset_y", 2)
	_bite_warning_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bite_warning_label.visible = false
	hud_node.add_child(_bite_warning_label)

var _bite_warning_timer: float = 0.0

func _show_bite_warning():
	if not _bite_warning_label:
		return
	_bite_warning_label.visible = true
	_bite_warning_timer = 0.5  # Hiển 0.5 giây
	# Nhấp nháy màu đỏ
	_bite_warning_label.modulate = Color(1, 1, 1, 1)

func _process_bite_warning(delta: float):
	if _bite_warning_timer > 0:
		_bite_warning_timer -= delta
		if _bite_warning_timer <= 0:
			if _bite_warning_label:
				_bite_warning_label.visible = false


## Rùa hồi NL khi player ở gần rùa (bán kính 1m) và đứng yên (chỉ hồi tới 30% max)
var _turtle_popup_shown := false
func _pet_passive_heal(delta: float):
	var heal_rate := Global.get_pet_bonus("passive_heal")
	if heal_rate <= 0.0 or is_exhausted:
		return
	var heal_cap := max_energy * 0.3
	if energy >= heal_cap:
		return
	# Phải ở gần rùa (bán kính 1m) VÀ đứng yên
	if not is_instance_valid(pet_instance):
		return
	var dist_sq := global_position.distance_squared_to(pet_instance.global_position)
	if dist_sq > 1.0:  ## 1m bán kính
		# Popup hướng dẫn lần đầu khi NL thấp
		if not _turtle_popup_shown and energy / max_energy <= 0.4:
			_turtle_popup_shown = true
			_show_turtle_tutorial_popup()
		return
	if velocity.length_squared() < 0.1:
		energy = min(heal_cap, energy + heal_rate * delta)


func _show_turtle_tutorial_popup():
	var level_mgr = get_tree().get_first_node_in_group("level_manager")
	if level_mgr and level_mgr.get("tutorial_guide"):
		var guide = level_mgr.tutorial_guide
		if guide and guide.has_method("_show_popup"):
			guide._show_popup("🐢 Năng lượng đang thấp! Hãy chờ rùa đi theo rồi đứng yên bên cạnh nó để hồi năng lượng. Rùa chỉ hồi khi cháu ở gần nó trong bán kính 1 mét!")
			return
	# Fallback: hiện hint label nếu không có tutorial guide
	if turtle_hint_label:
		turtle_hint_label.text = "🐢 Chờ rùa đến gần và đứng yên để hồi năng lượng!"
		turtle_hint_label.visible = true


## Spawn thú cưng vào scene
func _spawn_pet():
	var scene_path := Global.get_pet_string_bonus("scene_path")
	if scene_path == "":
		return
	var pet_scene := load(scene_path) as PackedScene
	if not pet_scene:
		return
	pet_instance = pet_scene.instantiate()
	var pet_script := load("res://script/pet_follow.gd")
	pet_instance.set_script(pet_script)
	get_parent().add_child(pet_instance)
	pet_instance.global_position = global_position + Vector3(-2, 0, -2)


func _setup_minimap():
	var hud = get_node_or_null("HUD")
	if not hud:
		return
	var minimap_script = load("res://script/minimap.gd")
	if not minimap_script:
		push_warning("[Minimap] Không load được minimap.gd")
		return
	minimap_instance = Node.new()
	minimap_instance.set_script(minimap_script)
	minimap_instance.name = "Minimap"
	add_child(minimap_instance)
	minimap_instance.setup(self, hud)


func _setup_zone_indicator():
	var hud = get_node_or_null("HUD")
	if not hud:
		return
	var zone_script = load("res://script/zone_indicator.gd")
	if not zone_script:
		push_warning("[ZoneIndicator] Không load được zone_indicator.gd")
		return
	zone_indicator_instance = Node.new()
	zone_indicator_instance.set_script(zone_script)
	zone_indicator_instance.name = "ZoneIndicator"
	add_child(zone_indicator_instance)
	zone_indicator_instance.setup(self, hud)





## ==================== FLASHLIGHT SYSTEM ====================

## Kiểm tra đèn pin gần và hiện prompt
func _check_flashlight_proximity():
	if has_flashlight:
		return
	var pickups = get_tree().get_nodes_in_group("flashlight_pickup")
	for pickup in pickups:
		if not is_instance_valid(pickup):
			continue
		var dist = global_position.distance_to(pickup.global_position)
		if dist <= FLASHLIGHT_PICKUP_RANGE:
			if interact_prompt:
				interact_prompt.text = "🔦 Nhấn P để nhặt đèn pin"
			return
	# Không có đèn pin gần → xóa prompt (nếu đang hiển thị prompt đèn pin)
	if interact_prompt and interact_prompt.text.begins_with("🔦 Nhấn P"):
		interact_prompt.text = ""


## Thử nhặt đèn pin gần đó
func try_pickup_flashlight():
	if has_flashlight:
		return
	var pickups = get_tree().get_nodes_in_group("flashlight_pickup")
	for pickup in pickups:
		if not is_instance_valid(pickup):
			continue
		var dist = global_position.distance_to(pickup.global_position)
		if dist <= FLASHLIGHT_PICKUP_RANGE:
			pickup_flashlight()
			pickup.queue_free()
			return


## Nhặt đèn pin — tạo SpotLight3D gắn vào Head
func pickup_flashlight():
	has_flashlight = true
	flashlight_on = true
	Global.has_flashlight = true
	Global.save_data()

	flashlight_node = SpotLight3D.new()
	flashlight_node.name = "PlayerFlashlight"
	flashlight_node.light_energy = 3.0
	flashlight_node.light_color = Color(1.0, 0.95, 0.8)
	flashlight_node.spot_range = 20.0
	flashlight_node.spot_angle = 25.0
	flashlight_node.spot_attenuation = 0.8
	flashlight_node.shadow_enabled = true
	flashlight_node.position = Vector3(0.2, -0.1, -0.3)
	head.add_child(flashlight_node)

	# Hiển thị thông báo
	if interact_prompt:
		interact_prompt.text = "🔦 Đã nhặt đèn pin! Nhấn P để bật/tắt"
		# Auto ẩn sau 3 giây
		get_tree().create_timer(3.0).timeout.connect(func():
			if interact_prompt and interact_prompt.text.begins_with("🔦"):
				interact_prompt.text = ""
		)

	print("[Player] Đã nhặt đèn pin!")


## Bật/tắt đèn pin
func toggle_flashlight():
	if not has_flashlight or not flashlight_node:
		return
	flashlight_on = not flashlight_on
	flashlight_node.visible = flashlight_on
	if flashlight_on:
		print("[Player] Đèn pin: BẬT")
	else:
		print("[Player] Đèn pin: TẮT")


## Khôi phục đèn pin nếu đã nhặt từ trước (Global.has_flashlight)
## Chỉ khôi phục ở Level 3+ (đèn pin không xuất hiện ở Level 1, 2)
func _restore_flashlight():
	if not Global.has_flashlight:
		return
	if Global.current_level < 3:
		return  # Đèn pin chỉ hoạt động từ Level 3+
	if has_flashlight:
		return  # Đã có rồi
	# Tạo lại đèn pin
	has_flashlight = true
	flashlight_on = true

	flashlight_node = SpotLight3D.new()
	flashlight_node.name = "PlayerFlashlight"
	flashlight_node.light_energy = 3.0
	flashlight_node.light_color = Color(1.0, 0.95, 0.8)
	flashlight_node.spot_range = 20.0
	flashlight_node.spot_angle = 25.0
	flashlight_node.spot_attenuation = 0.8
	flashlight_node.shadow_enabled = true
	flashlight_node.position = Vector3(0.2, -0.1, -0.3)
	head.add_child(flashlight_node)
	print("[Player] Đèn pin đã được khôi phục từ save!")


## Kích hoạt màn hình Game Over
func trigger_game_over():
	Global.save_game_result(score)
	get_tree().change_scene_to_file("res://scene/gameover.tscn")


## Thêm năng lượng (từ milk)
func add_energy(amount: float):
	energy = min(max_energy, energy + amount)
	if energy > 0:
		is_exhausted = false


var _energy_fill_style: StyleBoxFlat = null
var _energy_bg_style: StyleBoxFlat = null

func _setup_energy_bar_style():
	if not energy_bar:
		return

	# Đặt energy bar ở trên trái, dưới ScoreLabel
	energy_bar.anchor_left = 0.0
	energy_bar.anchor_right = 0.0
	energy_bar.offset_left = 20.0
	energy_bar.offset_top = 52.0
	energy_bar.offset_right = 200.0
	energy_bar.offset_bottom = 74.0
	energy_bar.grow_horizontal = Control.GROW_DIRECTION_END

	_energy_fill_style = StyleBoxFlat.new()
	_energy_fill_style.bg_color = Color(0.2, 0.8, 0.2)
	_energy_fill_style.corner_radius_top_left = 4
	_energy_fill_style.corner_radius_top_right = 4
	_energy_fill_style.corner_radius_bottom_left = 4
	_energy_fill_style.corner_radius_bottom_right = 4
	energy_bar.add_theme_stylebox_override("fill", _energy_fill_style)

	_energy_bg_style = StyleBoxFlat.new()
	_energy_bg_style.bg_color = Color(0.1, 0.1, 0.12, 0.85)
	_energy_bg_style.corner_radius_top_left = 4
	_energy_bg_style.corner_radius_top_right = 4
	_energy_bg_style.corner_radius_bottom_left = 4
	_energy_bg_style.corner_radius_bottom_right = 4
	_energy_bg_style.border_color = Color(0.3, 0.5, 0.3, 0.4)
	_energy_bg_style.border_width_top = 1
	_energy_bg_style.border_width_bottom = 1
	_energy_bg_style.border_width_left = 1
	_energy_bg_style.border_width_right = 1
	energy_bar.add_theme_stylebox_override("background", _energy_bg_style)

	# UpgradeIndicator - nhỏ gọn dưới energy bar
	if upgrade_indicator:
		upgrade_indicator.anchor_left = 0.0
		upgrade_indicator.anchor_right = 0.0
		upgrade_indicator.offset_left = 20.0
		upgrade_indicator.offset_top = 76.0
		upgrade_indicator.offset_right = 200.0
		upgrade_indicator.offset_bottom = 92.0
		upgrade_indicator.grow_horizontal = Control.GROW_DIRECTION_END
		upgrade_indicator.add_theme_font_size_override("font_size", 11)

	# Làm đẹp inventory label (góc dưới trái)
	_setup_inventory_style()


func _setup_inventory_style():
	if not inventory_label:
		return
	# Đặt lại vị trí góc dưới trái đẹp hơn
	inventory_label.anchor_left = 0.0
	inventory_label.anchor_top = 1.0
	inventory_label.anchor_right = 0.0
	inventory_label.anchor_bottom = 1.0
	inventory_label.offset_left = 15.0
	inventory_label.offset_top = -55.0
	inventory_label.offset_right = 210.0
	inventory_label.offset_bottom = -15.0
	inventory_label.grow_vertical = Control.GROW_DIRECTION_BEGIN
	inventory_label.grow_horizontal = Control.GROW_DIRECTION_END
	inventory_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	inventory_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT

	# Style background
	var inv_style = StyleBoxFlat.new()
	inv_style.bg_color = Color(0.08, 0.1, 0.15, 0.8)
	inv_style.corner_radius_top_left = 8
	inv_style.corner_radius_top_right = 8
	inv_style.corner_radius_bottom_left = 8
	inv_style.corner_radius_bottom_right = 8
	inv_style.border_color = Color(0.3, 0.7, 0.9, 0.4)
	inv_style.border_width_top = 1
	inv_style.border_width_bottom = 1
	inv_style.border_width_left = 1
	inv_style.border_width_right = 1
	inv_style.content_margin_left = 12
	inv_style.content_margin_right = 12
	inv_style.content_margin_top = 6
	inv_style.content_margin_bottom = 6
	inventory_label.add_theme_stylebox_override("normal", inv_style)

	# Font đẹp hơn
	inventory_label.add_theme_font_size_override("font_size", 18)
	inventory_label.add_theme_color_override("font_color", Color(0.5, 0.95, 1.0))
	inventory_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.7))
	inventory_label.add_theme_constant_override("shadow_offset_x", 1)
	inventory_label.add_theme_constant_override("shadow_offset_y", 1)

	update_inventory_ui()


func _setup_turtle_hint():
	if Global.selected_pet != "turtle":
		return
	var hud = get_node_or_null("HUD")
	if not hud:
		return
	turtle_hint_label = Label.new()
	turtle_hint_label.name = "TurtleHint"
	turtle_hint_label.text = "🐢 Hãy đi chậm lại chờ rùa của bạn để hồi năng lượng!"
	turtle_hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turtle_hint_label.add_theme_font_size_override("font_size", 16)
	turtle_hint_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
	turtle_hint_label.anchors_preset = Control.PRESET_CENTER_BOTTOM
	turtle_hint_label.position = Vector2(-250, -60)
	turtle_hint_label.size = Vector2(500, 30)
	turtle_hint_label.visible = false
	hud.add_child(turtle_hint_label)


func _setup_transparent_buttons():
	var all_buttons: Array = []

	if inventory_upgrade_btn:
		all_buttons.append(inventory_upgrade_btn)
	if speed_upgrade_btn:
		all_buttons.append(speed_upgrade_btn)
	if energy_upgrade_btn:
		all_buttons.append(energy_upgrade_btn)
	if pause_continue_btn:
		all_buttons.append(pause_continue_btn)
	if pause_restart_btn:
		all_buttons.append(pause_restart_btn)
	if pause_settings_btn:
		all_buttons.append(pause_settings_btn)
	if pause_mainmenu_btn:
		all_buttons.append(pause_mainmenu_btn)
	if pause_quit_btn:
		all_buttons.append(pause_quit_btn)
	if pause_settings_save_btn:
		all_buttons.append(pause_settings_save_btn)
	if pause_settings_reset_btn:
		all_buttons.append(pause_settings_reset_btn)
	if pause_settings_close_btn:
		all_buttons.append(pause_settings_close_btn)

	for btn in all_buttons:
		_apply_transparent_style(btn)


func _apply_transparent_style(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.1, 0.1, 0.1, 0.3)
	normal.border_color = Color(1, 1, 1, 0.3)
	normal.border_width_bottom = 1
	normal.border_width_top = 1
	normal.border_width_left = 1
	normal.border_width_right = 1
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	btn.add_theme_stylebox_override("normal", normal)

	var hover = StyleBoxFlat.new()
	hover.bg_color = Color(0.2, 0.4, 0.8, 0.4)
	hover.border_color = Color(1, 1, 1, 0.5)
	hover.border_width_bottom = 1
	hover.border_width_top = 1
	hover.border_width_left = 1
	hover.border_width_right = 1
	hover.corner_radius_top_left = 6
	hover.corner_radius_top_right = 6
	hover.corner_radius_bottom_left = 6
	hover.corner_radius_bottom_right = 6
	hover.content_margin_left = 10
	hover.content_margin_right = 10
	hover.content_margin_top = 6
	hover.content_margin_bottom = 6
	btn.add_theme_stylebox_override("hover", hover)

	var pressed = StyleBoxFlat.new()
	pressed.bg_color = Color(0.1, 0.3, 0.6, 0.5)
	pressed.border_color = Color(1, 1, 1, 0.6)
	pressed.border_width_bottom = 1
	pressed.border_width_top = 1
	pressed.border_width_left = 1
	pressed.border_width_right = 1
	pressed.corner_radius_top_left = 6
	pressed.corner_radius_top_right = 6
	pressed.corner_radius_bottom_left = 6
	pressed.corner_radius_bottom_right = 6
	pressed.content_margin_left = 10
	pressed.content_margin_right = 10
	pressed.content_margin_top = 6
	pressed.content_margin_bottom = 6
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled = StyleBoxFlat.new()
	disabled.bg_color = Color(0.05, 0.05, 0.05, 0.2)
	disabled.border_color = Color(0.5, 0.5, 0.5, 0.2)
	disabled.border_width_bottom = 1
	disabled.border_width_top = 1
	disabled.border_width_left = 1
	disabled.border_width_right = 1
	disabled.corner_radius_top_left = 6
	disabled.corner_radius_top_right = 6
	disabled.corner_radius_bottom_left = 6
	disabled.corner_radius_bottom_right = 6
	disabled.content_margin_left = 10
	disabled.content_margin_right = 10
	disabled.content_margin_top = 6
	disabled.content_margin_bottom = 6
	btn.add_theme_stylebox_override("disabled", disabled)


## Cập nhật UI thanh năng lượng
func update_energy_ui():
	if not energy_bar:
		return
	energy_bar.value = energy

	if not _energy_fill_style:
		return

	var ratio = energy / max_energy
	if ratio <= 0.2:
		energy_blink_timer += get_process_delta_time()
		var blink = (sin(energy_blink_timer * 10.0) + 1.0) / 2.0
		_energy_fill_style.bg_color = Color(0.9, 0.1, 0.1).lerp(Color(0.5, 0.0, 0.0), blink)
	else:
		_energy_fill_style.bg_color = Color(0.2, 0.8, 0.2)
		energy_blink_timer = 0.0

	# Hiển thị gợi ý rùa khi năng lượng thấp
	if turtle_hint_label:
		if ratio <= 0.25 and Global.selected_pet == "turtle":
			turtle_hint_label.visible = true
		else:
			turtle_hint_label.visible = false


## Kiểm tra milk gần nhất bằng proximity
## Tối ưu: dùng distance_squared_to để tránh sqrt
func check_milk():
	const INTERACT_RANGE_SQ := INTERACT_RANGE * INTERACT_RANGE
	const EARLY_EXIT_SQ := 2.25  ## 1.5m — đủ gần

	var nearest = null
	var nearest_dist_sq = INTERACT_RANGE_SQ

	for node in get_tree().get_nodes_in_group("milk"):
		if not is_instance_valid(node):
			continue
		var dist_sq = global_position.distance_squared_to(node.global_position)
		if dist_sq < nearest_dist_sq:
			nearest_dist_sq = dist_sq
			nearest = node
			# Early exit nếu rất gần
			if dist_sq < EARLY_EXIT_SQ:
				break

	if nearest:
		current_milk = nearest
		if milk_prompt:
			milk_prompt.text = nearest.prompt_message if nearest.get("prompt_message") else "Nhấn Q để nhặt sữa"
	else:
		current_milk = null
		if milk_prompt:
			milk_prompt.text = ""


## Nhặt milk khi nhấn Q
func try_pickup_milk():
	if current_milk and current_milk.has_method("pickup_milk"):
		current_milk.pickup_milk(self)


## ==================== UPGRADE SYSTEM ====================

## Tính tốc độ di chuyển dựa trên upgrade level, bonus nhân vật và trọng lượng
func calculate_speed() -> float:
	var pet_speed_bonus = Global.get_pet_bonus("speed_bonus")
	var base = BASE_SPEED * (1.0 + 0.1 * upgrade_levels["speed"] + pet_speed_bonus)
	# Tính penalty từ trọng lượng
	var weight_penalty = min(total_weight * WEIGHT_SPEED_PENALTY, MAX_WEIGHT_PENALTY)
	return base * (1.0 - weight_penalty)


## Tính tốc độ tiêu hao năng lượng dựa trên upgrade level và bonus nhân vật
func calculate_energy_drain() -> float:
	var drain = BASE_ENERGY_DRAIN * (1.0 - 0.1 * upgrade_levels["energy"])
	return max(0.1, drain)  ## Tối thiểu 0.1


## Tính dung lượng túi dựa trên upgrade level và bonus nhân vật
func calculate_inventory_capacity() -> int:
	var pet_inv_bonus = int(Global.get_pet_bonus("inventory_bonus"))
	return BASE_INVENTORY_CAPACITY + upgrade_levels["inventory"] + pet_inv_bonus


## Lấy giá nâng cấp tiếp theo (tăng theo level hiện tại)
func get_upgrade_price(upgrade_type: String) -> int:
	var base = UPGRADE_BASE_PRICES.get(upgrade_type, 0)
	var level = upgrade_levels.get(upgrade_type, 0)
	return base * (level + 1)


## Mua nâng cấp (tất cả dùng Global.total_coins)
func buy_upgrade(upgrade_type: String) -> bool:
	var price = get_upgrade_price(upgrade_type)

	if Global.total_coins < price:
		return false

	upgrade_levels[upgrade_type] += 1
	Global.total_coins -= price
	Global.save_data()
	AudioManager.play_upgrade_sfx()

	apply_upgrades()

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
	
	# Hiển thị số xu đang có
	if not coin_display_label:
		_create_coin_display()
	if coin_display_label:
		coin_display_label.text = "💰 Xu: %d" % Global.total_coins

	# Cập nhật nút Inventory
	if inventory_upgrade_btn:
		var inv_level = upgrade_levels["inventory"]
		var inv_price = get_upgrade_price("inventory")
		inventory_upgrade_btn.text = "Túi đồ Lv.%d → Lv.%d\n(%d slot → %d slot)\nGiá: %d xu" % [
			inv_level, inv_level + 1,
			BASE_INVENTORY_CAPACITY + inv_level,
			BASE_INVENTORY_CAPACITY + inv_level + 1,
			inv_price
		]
		inventory_upgrade_btn.disabled = Global.total_coins < inv_price
	
	# Cập nhật nút Speed
	if speed_upgrade_btn:
		var speed_level = upgrade_levels["speed"]
		var speed_price = get_upgrade_price("speed")
		var current_bonus = speed_level * 10
		var next_bonus = (speed_level + 1) * 10
		speed_upgrade_btn.text = "Tốc độ Lv.%d → Lv.%d\n(+%d%% → +%d%%)\nGiá: %d xu" % [
			speed_level, speed_level + 1,
			current_bonus, next_bonus,
			speed_price
		]
		speed_upgrade_btn.disabled = Global.total_coins < speed_price
	
	# Cập nhật nút Energy
	if energy_upgrade_btn:
		var energy_level = upgrade_levels["energy"]
		var energy_price = get_upgrade_price("energy")
		var current_reduction = energy_level * 10
		var next_reduction = (energy_level + 1) * 10
		energy_upgrade_btn.text = "Năng lượng Lv.%d → Lv.%d\n(-%d%% → -%d%% tiêu hao)\nGiá: %d xu" % [
			energy_level, energy_level + 1,
			current_reduction, next_reduction,
			energy_price
		]
		energy_upgrade_btn.disabled = Global.total_coins < energy_price


## Tạo label hiển thị số xu ở đầu bảng upgrade
func _create_coin_display():
	var vbox = upgrade_menu.get_node_or_null("VBoxContainer")
	if not vbox:
		return
	coin_display_label = Label.new()
	coin_display_label.name = "CoinDisplay"
	coin_display_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	coin_display_label.add_theme_font_size_override("font_size", 22)
	coin_display_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.1))
	vbox.add_child(coin_display_label)
	vbox.move_child(coin_display_label, 0)  # Đặt lên đầu


## Callback khi nhấn nút nâng cấp Inventory
func _on_inventory_upgrade_pressed():
	buy_upgrade("inventory")


## Callback khi nhấn nút nâng cấp Speed
func _on_speed_upgrade_pressed():
	buy_upgrade("speed")


## Callback khi nhấn nút nâng cấp Energy
func _on_energy_upgrade_pressed():
	buy_upgrade("energy")


## ==================== PAUSE MENU SYSTEM ====================

## Tạo giao diện pause menu kiểu game casual
func _setup_pause_menu_style():
	if not pause_panel:
		return
	
	# === Style cho title ===
	var title_label = pause_panel.get_node_or_null("VBoxContainer/Title")
	if title_label:
		title_label.add_theme_font_size_override("font_size", 52)
		title_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0, 1.0))
		title_label.add_theme_color_override("font_shadow_color", Color(0.2, 0.15, 0.1, 0.8))
		title_label.add_theme_constant_override("shadow_offset_x", 3)
		title_label.add_theme_constant_override("shadow_offset_y", 3)
	
	# === Style cho background overlay ===
	var bg = pause_panel.get_node_or_null("Background")
	if bg:
		bg.color = Color(0.0, 0.0, 0.0, 0.55)
	
	# === VBoxContainer spacing ===
	var vbox = pause_panel.get_node_or_null("VBoxContainer")
	if vbox:
		vbox.add_theme_constant_override("separation", 12)
	
	# === Icon paths ===
	var icon_paths = {
		"continue": "res://assets/GUI/Post/Assets/Menu Buttons/Icons/Arrow.png",
		"restart": "res://assets/GUI/Post/Assets/Menu Buttons/Icons/Return.png",
		"mainmenu": "res://assets/GUI/Post/Assets/Menu Buttons/Icons/House.png",
		"settings": "res://assets/GUI/Post/Assets/Menu Buttons/Icons/Settings.png"
	}
	
	# === Style nút brown cho tất cả các nút ===
	var all_pause_buttons = []
	if pause_continue_btn:
		all_pause_buttons.append({"btn": pause_continue_btn, "icon": icon_paths["continue"], "text": "TIẾP TỤC"})
	if pause_restart_btn:
		all_pause_buttons.append({"btn": pause_restart_btn, "icon": icon_paths["restart"], "text": "CHƠI LẠI"})
	if pause_mainmenu_btn:
		all_pause_buttons.append({"btn": pause_mainmenu_btn, "icon": icon_paths["mainmenu"], "text": "BẢN ĐỒ"})
	if pause_settings_btn:
		all_pause_buttons.append({"btn": pause_settings_btn, "icon": icon_paths["settings"], "text": "CÀI ĐẶT"})
	if pause_quit_btn:
		all_pause_buttons.append({"btn": pause_quit_btn, "icon": "", "text": "THOÁT"})
	
	for data in all_pause_buttons:
		_apply_casual_button_style(
			data["btn"], data["text"], data["icon"], null,
			Color(0.55, 0.35, 0.15, 1.0),  # Brown (nền)
			Color(0.65, 0.42, 0.18, 1.0),  # Brown sáng hơn (hover)
			Color(0.40, 0.25, 0.10, 1.0)   # Brown đậm (pressed)
		)


## Áp dụng style nút kiểu game casual (bo tròn, gradient, icon + text)
func _apply_casual_button_style(btn: Button, text: String, icon_path: String, custom_font, 
		color_normal: Color, color_hover: Color, color_pressed: Color):
	# Kích thước nút
	btn.custom_minimum_size = Vector2(300, 65)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	
	# Text
	btn.text = text
	btn.alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Font
	if custom_font:
		btn.add_theme_font_override("font", custom_font)
	btn.add_theme_font_size_override("font_size", 26)
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(0.95, 0.95, 0.95, 1))
	
	# Font shadow
	btn.add_theme_color_override("font_shadow_color", Color(0.15, 0.1, 0.05, 0.6))
	btn.add_theme_constant_override("shadow_offset_x", 2)
	btn.add_theme_constant_override("shadow_offset_y", 2)
	
	# Normal style
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = color_normal
	style_normal.corner_radius_top_left = 20
	style_normal.corner_radius_top_right = 20
	style_normal.corner_radius_bottom_left = 20
	style_normal.corner_radius_bottom_right = 20
	style_normal.border_color = Color(0.30, 0.18, 0.08, 1.0)  # Dark brown border
	style_normal.border_width_top = 3
	style_normal.border_width_bottom = 3
	style_normal.border_width_left = 3
	style_normal.border_width_right = 3
	style_normal.shadow_color = Color(0, 0, 0, 0.25)
	style_normal.shadow_size = 4
	style_normal.shadow_offset = Vector2(0, 3)
	style_normal.content_margin_left = 20
	style_normal.content_margin_right = 20
	style_normal.content_margin_top = 12
	style_normal.content_margin_bottom = 12
	btn.add_theme_stylebox_override("normal", style_normal)
	
	# Hover style
	var style_hover = style_normal.duplicate()
	style_hover.bg_color = color_hover
	style_hover.border_color = Color(0.25, 0.14, 0.05, 1.0)  # Darker brown border on hover
	style_hover.border_width_top = 4
	style_hover.border_width_bottom = 4
	style_hover.border_width_left = 4
	style_hover.border_width_right = 4
	btn.add_theme_stylebox_override("hover", style_hover)
	
	# Pressed style
	var style_pressed = style_normal.duplicate()
	style_pressed.bg_color = color_pressed
	style_pressed.border_width_top = 3
	style_pressed.border_width_bottom = 3
	style_pressed.border_width_left = 3
	style_pressed.border_width_right = 3
	style_pressed.border_color = Color(0.20, 0.12, 0.04, 1.0)  # Darkest brown border
	style_pressed.shadow_size = 1
	style_pressed.shadow_offset = Vector2(0, 1)
	btn.add_theme_stylebox_override("pressed", style_pressed)
	
	# Focus style (giống normal)
	var style_focus = style_normal.duplicate()
	style_focus.border_color = Color(0.35, 0.22, 0.10, 1.0)  # Dark brown focus border
	style_focus.border_width_top = 3
	style_focus.border_width_bottom = 3
	style_focus.border_width_left = 3
	style_focus.border_width_right = 3
	btn.add_theme_stylebox_override("focus", style_focus)
	
	# Thêm icon bên trái nút
	if icon_path != "":
		var icon_tex = load(icon_path) as Texture2D
		if icon_tex:
			btn.icon = icon_tex
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
			btn.expand_icon = true


## Toggle pause menu
func toggle_pause_menu():
	pause_menu_open = not pause_menu_open
	
	if pause_panel:
		pause_panel.visible = pause_menu_open
	
	# Pause/unpause game
	get_tree().paused = pause_menu_open
	
	# Ẩn/hiện minimap khi pause
	if minimap_instance and minimap_instance.has_method("toggle"):
		if pause_menu_open:
			minimap_instance.minimap_container.visible = false
		else:
			minimap_instance.minimap_container.visible = minimap_instance.is_visible
	
	if pause_menu_open:
		release_mouse()
		# Đóng settings panel nếu đang mở
		if pause_settings_panel:
			pause_settings_panel.visible = false
	else:
		capture_mouse()


## Continue button - tiếp tục chơi
func _on_pause_continue_pressed():
	toggle_pause_menu()


## Restart button - chơi lại từ đầu
func _on_pause_restart_pressed():
	get_tree().paused = false
	Global.go_to_scene("res://scene/main.tscn")


## Settings button - mở settings panel
func _on_pause_settings_pressed():
	if pause_settings_panel:
		pause_settings_panel.visible = true
		load_pause_settings_to_ui()


## Settings close button - đóng settings panel
func _on_pause_settings_close_pressed():
	if pause_settings_panel:
		pause_settings_panel.visible = false


## Settings save button - lưu settings
func _on_pause_settings_save_pressed():
	Global.save_data()
	if pause_settings_panel:
		pause_settings_panel.visible = false


## Settings reset button - đặt lại settings về mặc định
func _on_pause_settings_reset_pressed():
	Global.reset_settings()
	load_pause_settings_to_ui()


## Load settings từ Global vào pause settings UI
func load_pause_settings_to_ui():
	if pause_brightness_slider:
		pause_brightness_slider.value = Global.settings["brightness"] * 100
		pause_brightness_value.text = str(int(pause_brightness_slider.value)) + "%"
	
	if pause_master_slider:
		pause_master_slider.value = Global.settings["master_volume"] * 100
		pause_master_value.text = str(int(pause_master_slider.value)) + "%"
	
	if pause_music_slider:
		pause_music_slider.value = Global.settings["music_volume"] * 100
		pause_music_value.text = str(int(pause_music_slider.value)) + "%"
	
	if pause_sfx_slider:
		pause_sfx_slider.value = Global.settings["sfx_volume"] * 100
		pause_sfx_value.text = str(int(pause_sfx_slider.value)) + "%"
	
	if pause_sensitivity_slider:
		# Sensitivity: 0.001-0.005 -> 10-100
		var sens = Global.settings["mouse_sensitivity"]
		pause_sensitivity_slider.value = (sens - 0.001) / 0.004 * 90 + 10
		pause_sensitivity_value.text = str(int(pause_sensitivity_slider.value)) + "%"


## Callback khi thay đổi độ sáng
func _on_pause_brightness_changed(value: float):
	if pause_brightness_value:
		pause_brightness_value.text = str(int(value)) + "%"
	Global.set_setting("brightness", value / 100.0)


## Callback khi thay đổi master volume
func _on_pause_master_changed(value: float):
	if pause_master_value:
		pause_master_value.text = str(int(value)) + "%"
	Global.set_setting("master_volume", value / 100.0)


## Callback khi thay đổi music volume
func _on_pause_music_changed(value: float):
	if pause_music_value:
		pause_music_value.text = str(int(value)) + "%"
	Global.set_setting("music_volume", value / 100.0)


## Callback khi thay đổi SFX volume
func _on_pause_sfx_changed(value: float):
	if pause_sfx_value:
		pause_sfx_value.text = str(int(value)) + "%"
	Global.set_setting("sfx_volume", value / 100.0)


## Callback khi thay đổi mouse sensitivity
func _on_pause_sensitivity_changed(value: float):
	if pause_sensitivity_value:
		pause_sensitivity_value.text = str(int(value)) + "%"
	# Convert 10-100 -> 0.001-0.005
	var sens = (value - 10) / 90.0 * 0.004 + 0.001
	Global.set_setting("mouse_sensitivity", sens)


## Main Menu button - mở overlay bản đồ trong pause
var pause_map_panel: Control = null

func _on_pause_mainmenu_pressed():
	# Rebuild mỗi khi mở để cập nhật trạng thái mở khóa level
	if pause_map_panel:
		pause_map_panel.queue_free()
		pause_map_panel = null
	_build_pause_map_panel()
	pause_map_panel.visible = true


## Đóng overlay bản đồ, quay về pause menu
func _on_pause_map_close():
	if pause_map_panel:
		pause_map_panel.visible = false


## Tạo overlay bản đồ (level select) trong pause menu
const PAUSE_LEVEL_COUNT := 6
const PAUSE_LEVEL_NAMES := {
	1: "Dọn dẹp sân vườn",
	2: "Khu phố sạch",
	3: "Dọn rác ban đêm",
	4: "Thu gom lớn",
	5: "Thử thách tái chế",
	6: "Siêu dọn dẹp",
}

func _build_pause_map_panel():
	pause_map_panel = Control.new()
	pause_map_panel.name = "PauseMapPanel"
	pause_map_panel.process_mode = Node.PROCESS_MODE_ALWAYS
	pause_map_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_map_panel.visible = false
	pause_panel.add_child(pause_map_panel)
	
	# Overlay tối
	var overlay = ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0, 0, 0, 0.5)
	pause_map_panel.add_child(overlay)
	
	# Panel chính
	var panel = Panel.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.anchor_right = 0.5
	panel.anchor_bottom = 0.5
	panel.offset_left = -340
	panel.offset_top = -280
	panel.offset_right = 340
	panel.offset_bottom = 280
	panel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	panel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.72, 0.55, 0.40, 0.95)
	panel_style.corner_radius_top_left = 16
	panel_style.corner_radius_top_right = 16
	panel_style.corner_radius_bottom_left = 16
	panel_style.corner_radius_bottom_right = 16
	panel_style.border_width_top = 3
	panel_style.border_width_bottom = 3
	panel_style.border_width_left = 3
	panel_style.border_width_right = 3
	panel_style.border_color = Color(0.30, 0.18, 0.08)
	panel.add_theme_stylebox_override("panel", panel_style)
	pause_map_panel.add_child(panel)
	
	# VBox bên trong panel
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 20
	vbox.offset_right = -20
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 20)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)
	
	# Tiêu đề
	var title = Label.new()
	title.text = "BẢN ĐỒ"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(1, 1, 1))
	title.add_theme_color_override("font_shadow_color", Color(0.2, 0.12, 0.05, 0.7))
	title.add_theme_constant_override("shadow_offset_x", 2)
	title.add_theme_constant_override("shadow_offset_y", 2)
	vbox.add_child(title)
	
	# Grid container cho level buttons
	var grid_center = CenterContainer.new()
	vbox.add_child(grid_center)
	
	var grid = GridContainer.new()
	grid.columns = 3
	grid.add_theme_constant_override("h_separation", 15)
	grid.add_theme_constant_override("v_separation", 15)
	grid_center.add_child(grid)
	
	# Tạo 6 nút level
	for i in range(1, PAUSE_LEVEL_COUNT + 1):
		var btn = _create_pause_map_level_btn(i)
		grid.add_child(btn)
	
	# Nút đóng
	var close_btn = Button.new()
	close_btn.text = "← Đóng"
	close_btn.custom_minimum_size = Vector2(180, 45)
	close_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_btn.add_theme_font_size_override("font_size", 18)
	close_btn.add_theme_color_override("font_color", Color(1, 1, 1))
	close_btn.pressed.connect(_on_pause_map_close)
	_style_pause_map_btn(close_btn)
	vbox.add_child(close_btn)


func _create_pause_map_level_btn(level: int) -> Button:
	var btn = Button.new()
	btn.custom_minimum_size = Vector2(160, 100)
	
	var unlocked = level == 1 or Global.level_stars.get(level - 1, 0) >= 1
	var stars = Global.level_stars.get(level, 0)
	var level_name = PAUSE_LEVEL_NAMES.get(level, "Level %d" % level)
	
	if unlocked:
		var star_str = ""
		for s in range(3):
			if s < stars:
				star_str += "★"
			else:
				star_str += "☆"
		btn.text = "Level %d\n%s\n%s" % [level, level_name, star_str]
		btn.add_theme_font_size_override("font_size", 14)
		btn.pressed.connect(_on_pause_map_level_selected.bind(level))
	else:
		btn.text = "Level %d\n🔒\nChưa mở khóa" % level
		btn.add_theme_font_size_override("font_size", 14)
		btn.disabled = true
		btn.modulate = Color(1, 1, 1, 0.5)
	
	btn.add_theme_color_override("font_color", Color(1, 1, 1, 0.95))
	_style_pause_map_btn(btn)
	return btn


func _style_pause_map_btn(btn: Button):
	var normal = StyleBoxFlat.new()
	normal.bg_color = Color(0.55, 0.35, 0.12)
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_color = Color(0.25, 0.15, 0.05)
	normal.content_margin_left = 8
	normal.content_margin_right = 8
	normal.content_margin_top = 6
	normal.content_margin_bottom = 6
	btn.add_theme_stylebox_override("normal", normal)
	
	var hover = normal.duplicate()
	hover.bg_color = Color(0.65, 0.42, 0.18)
	hover.border_color = Color(0.3, 0.18, 0.06)
	btn.add_theme_stylebox_override("hover", hover)
	
	var pressed_style = normal.duplicate()
	pressed_style.bg_color = Color(0.40, 0.25, 0.10)
	btn.add_theme_stylebox_override("pressed", pressed_style)
	
	var disabled_style = normal.duplicate()
	disabled_style.bg_color = Color(0.4, 0.3, 0.2, 0.5)
	disabled_style.border_color = Color(0.25, 0.15, 0.05, 0.4)
	btn.add_theme_stylebox_override("disabled", disabled_style)


func _on_pause_map_level_selected(level: int):
	get_tree().paused = false
	Global.current_level = level
	Global.dialogue_mode = "level"
	get_tree().change_scene_to_file("res://scene/dialogue.tscn")


## Quit button - thoát game
func _on_pause_quit_pressed():
	get_tree().quit()
