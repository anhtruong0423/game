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
const PROXIMITY_CHECK_INTERVAL : float = 0.15  ## Chỉ check mỗi 0.15 giây thay vì mỗi frame

## Energy system
var energy : float = 100.0
var max_energy : float = 100.0
var energy_drain_rate : float = 5.0  ## Năng lượng mất mỗi giây khi di chuyển
var is_exhausted : bool = false
var is_sprinting : bool = false
var energy_blink_timer : float = 0.0

## Upgrade system
var upgrade_levels : Dictionary = {"inventory": 0, "speed": 0, "energy": 0}
var coin_value_multiplier : float = 1.0  ## Dự phòng cho tương lai
var upgrade_menu_open : bool = false
var pause_menu_open : bool = false
const UPGRADE_PRICES : Dictionary = {"inventory": 100, "speed": 50, "energy": 200}
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

func _ready() -> void:
	add_to_group("player")
	check_input_mappings()
	look_rotation.y = rotation.y
	look_rotation.x = head.rotation.x

	if score_label:
		score_label.visible = false

	_setup_energy_bar_style()
	_setup_transparent_buttons()
	_setup_turtle_hint()
	_spawn_pet.call_deferred()

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
			# Nếu đang mở settings trong pause, đóng settings
			if pause_settings_panel and pause_settings_panel.visible:
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
	
	# Open upgrade menu (press Tab) - chỉ mở, không đóng, không cho mở khi pause
	if event is InputEventKey and event.pressed and event.keycode == KEY_TAB:
		if not upgrade_menu_open and not pause_menu_open:
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
		velocity.y = 0
	
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
	update_energy_ui()
	_pet_passive_heal(_delta)


## Check for nearby interactable objects (fruits, basket) using proximity
func check_interactable():
	# Check for nearby fruits first
	var nearest_fruit = null
	var nearest_fruit_dist = INTERACT_RANGE

	for node in get_tree().get_nodes_in_group("interactable"):
		if not is_instance_valid(node):
			continue
		var dist = global_position.distance_to(node.global_position)
		if dist < nearest_fruit_dist:
			nearest_fruit_dist = dist
			nearest_fruit = node

	if nearest_fruit:
		current_interactable = nearest_fruit
		if interact_prompt:
			interact_prompt.text = nearest_fruit.prompt_message if nearest_fruit.get("prompt_message") else "Nhấn E để nhặt"
		return

	# No fruit nearby → check basket (only if player has items)
	if inventory.size() > 0:
		var nearest_basket = null
		var nearest_basket_dist = INTERACT_RANGE

		for node in get_tree().get_nodes_in_group("basket"):
			if not is_instance_valid(node):
				continue
			var dist = global_position.distance_to(node.global_position)
			if dist < nearest_basket_dist:
				nearest_basket_dist = dist
				nearest_basket = node

		if nearest_basket:
			current_interactable = nearest_basket
			if interact_prompt:
				interact_prompt.text = nearest_basket.prompt_message if nearest_basket.get("prompt_message") else "Nhấn E để bỏ trái cây vào rổ"
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
		return false
	var final_value = int(item_value * coin_value_multiplier)
	inventory.append({"type": item_type, "value": final_value, "weight": item_weight})
	total_weight += item_weight
	update_inventory_ui()
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


## Tiêu hao năng lượng
func drain_energy(amount: float):
	var reduction := Global.get_pet_bonus("dog_damage_reduction")
	var final_amount := amount * (1.0 - reduction)
	energy = max(0, energy - final_amount)
	if energy <= 0 and not is_exhausted:
		is_exhausted = true
		trigger_game_over()


## Rùa hồi NL khi player đứng yên (chỉ hồi tới 30% max)
func _pet_passive_heal(delta: float):
	var heal_rate := Global.get_pet_bonus("passive_heal")
	if heal_rate <= 0.0 or is_exhausted:
		return
	var heal_cap := max_energy * 0.3
	if energy >= heal_cap:
		return
	if velocity.length_squared() < 0.1:
		energy = min(heal_cap, energy + heal_rate * delta)


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
	pet_instance.global_position = global_position + Vector3(-2, 0, -2)
	get_parent().add_child(pet_instance)
	pet_instance.global_position = global_position + Vector3(-2, 0, -2)


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

	energy_bar.anchor_left = 1.0
	energy_bar.anchor_right = 1.0
	energy_bar.offset_left = -220.0
	energy_bar.offset_top = 20.0
	energy_bar.offset_right = -20.0
	energy_bar.offset_bottom = 50.0
	energy_bar.grow_horizontal = Control.GROW_DIRECTION_BEGIN

	_energy_fill_style = StyleBoxFlat.new()
	_energy_fill_style.bg_color = Color(0.2, 0.8, 0.2)
	_energy_fill_style.corner_radius_top_left = 3
	_energy_fill_style.corner_radius_top_right = 3
	_energy_fill_style.corner_radius_bottom_left = 3
	_energy_fill_style.corner_radius_bottom_right = 3
	energy_bar.add_theme_stylebox_override("fill", _energy_fill_style)

	_energy_bg_style = StyleBoxFlat.new()
	_energy_bg_style.bg_color = Color(0.15, 0.15, 0.15, 0.8)
	_energy_bg_style.corner_radius_top_left = 3
	_energy_bg_style.corner_radius_top_right = 3
	_energy_bg_style.corner_radius_bottom_left = 3
	_energy_bg_style.corner_radius_bottom_right = 3
	energy_bar.add_theme_stylebox_override("background", _energy_bg_style)


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
func check_milk():
	var nearest = null
	var nearest_dist = INTERACT_RANGE

	for node in get_tree().get_nodes_in_group("milk"):
		if not is_instance_valid(node):
			continue
		var dist = global_position.distance_to(node.global_position)
		if dist < nearest_dist:
			nearest_dist = dist
			nearest = node

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


## Lấy giá nâng cấp tiếp theo
func get_upgrade_price(upgrade_type: String) -> int:
	return UPGRADE_PRICES.get(upgrade_type, 0)


## Mua nâng cấp
func buy_upgrade(upgrade_type: String) -> bool:
	var price = get_upgrade_price(upgrade_type)

	if upgrade_type == "inventory":
		if Global.total_coins < price:
			return false
		Global.total_coins -= price
		Global.save_data()
	else:
		if score < price:
			return false
		score -= price

	upgrade_levels[upgrade_type] += 1

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
	
	# Cập nhật nút Inventory (dùng total_coins từ qua màn)
	if inventory_upgrade_btn:
		var inv_level = upgrade_levels["inventory"]
		var inv_price = get_upgrade_price("inventory")
		inventory_upgrade_btn.text = "Túi đồ Lv.%d → Lv.%d\n(%d slot → %d slot)\nGiá: %d xu (có: %d xu)" % [
			inv_level, inv_level + 1,
			BASE_INVENTORY_CAPACITY + inv_level,
			BASE_INVENTORY_CAPACITY + inv_level + 1,
			inv_price, Global.total_coins
		]
		inventory_upgrade_btn.disabled = Global.total_coins < inv_price
	
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


## ==================== PAUSE MENU SYSTEM ====================

## Toggle pause menu
func toggle_pause_menu():
	pause_menu_open = not pause_menu_open
	
	if pause_panel:
		pause_panel.visible = pause_menu_open
	
	# Pause/unpause game
	get_tree().paused = pause_menu_open
	
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


## Main Menu button - về menu chính
func _on_pause_mainmenu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/mainmenu.tscn")


## Quit button - thoát game
func _on_pause_quit_pressed():
	get_tree().quit()
