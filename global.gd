extends Node

const SAVE_PATH = "user://save_data.cfg"

var coin := 0
var best_score := 0
var last_score := 0

## Tutorial và Character Selection
var tutorial_completed := false
var selected_character := ""  ## "minh", "lan", "hung"

## Character bonuses
const CHARACTER_BONUSES = {
	"minh": {"speed_bonus": 0.1, "energy_bonus": 0.0, "inventory_bonus": 0},
	"lan": {"speed_bonus": 0.0, "energy_bonus": 0.1, "inventory_bonus": 0},
	"hung": {"speed_bonus": 0.0, "energy_bonus": 0.0, "inventory_bonus": 1}
}

## Settings
var settings := {
	"brightness": 1.0,          # 0.5 - 1.5
	"master_volume": 1.0,       # 0.0 - 1.0
	"music_volume": 0.8,        # 0.0 - 1.0
	"sfx_volume": 1.0,          # 0.0 - 1.0
	"mouse_sensitivity": 0.002, # 0.001 - 0.005
	"fullscreen": false,
	"vsync": true
}

## Default settings để reset
const DEFAULT_SETTINGS := {
	"brightness": 1.0,
	"master_volume": 1.0,
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"mouse_sensitivity": 0.002,
	"fullscreen": false,
	"vsync": true
}


func _ready():
	load_data()
	apply_all_settings()


func save_game_result(score: int):
	last_score = score
	if score > best_score:
		best_score = score
		save_data()  # Lưu khi có best score mới


## Đánh dấu tutorial đã hoàn thành
func complete_tutorial():
	tutorial_completed = true
	save_data()


## Chọn nhân vật
func select_character(character_name: String):
	selected_character = character_name
	save_data()


## Lấy bonus của nhân vật hiện tại
func get_character_bonus(bonus_type: String) -> float:
	if selected_character in CHARACTER_BONUSES:
		return CHARACTER_BONUSES[selected_character].get(bonus_type, 0.0)
	return 0.0


## Lưu dữ liệu vào file
func save_data():
	var config = ConfigFile.new()
	config.set_value("game", "best_score", best_score)
	config.set_value("game", "tutorial_completed", tutorial_completed)
	config.set_value("game", "selected_character", selected_character)
	# Save settings
	for key in settings:
		config.set_value("settings", key, settings[key])
	config.save(SAVE_PATH)


## Load dữ liệu từ file
func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		best_score = config.get_value("game", "best_score", 0)
		tutorial_completed = config.get_value("game", "tutorial_completed", false)
		selected_character = config.get_value("game", "selected_character", "")
		# Load settings
		for key in settings:
			settings[key] = config.get_value("settings", key, DEFAULT_SETTINGS[key])
	print("[Global] Loaded: tutorial_completed=", tutorial_completed, ", selected_character=", selected_character)


## Reset tất cả dữ liệu (dùng để test)
func reset_all_data():
	best_score = 0
	tutorial_completed = false
	selected_character = ""
	settings = DEFAULT_SETTINGS.duplicate()
	save_data()
	apply_all_settings()
	print("[Global] Data reset!")


## ==================== SETTINGS FUNCTIONS ====================

## Cập nhật một setting
func set_setting(key: String, value) -> void:
	if key in settings:
		settings[key] = value
		apply_setting(key)


## Áp dụng một setting cụ thể
func apply_setting(key: String) -> void:
	match key:
		"brightness":
			apply_brightness()
		"master_volume":
			apply_master_volume()
		"music_volume":
			apply_music_volume()
		"sfx_volume":
			apply_sfx_volume()
		"fullscreen":
			apply_fullscreen()
		"vsync":
			apply_vsync()
		# mouse_sensitivity được áp dụng trực tiếp trong player controller


## Áp dụng tất cả settings
func apply_all_settings() -> void:
	apply_brightness()
	apply_master_volume()
	apply_music_volume()
	apply_sfx_volume()
	apply_fullscreen()
	apply_vsync()


## Áp dụng độ sáng
func apply_brightness() -> void:
	# Tìm WorldEnvironment trong scene hiện tại
	var root = get_tree().root
	if root.get_child_count() > 0:
		var current_scene = root.get_child(root.get_child_count() - 1)
		var world_env = find_world_environment(current_scene)
		if world_env and world_env.environment:
			world_env.environment.adjustment_enabled = true
			world_env.environment.adjustment_brightness = settings["brightness"]


## Tìm WorldEnvironment trong scene
func find_world_environment(node: Node) -> WorldEnvironment:
	if node is WorldEnvironment:
		return node
	for child in node.get_children():
		var result = find_world_environment(child)
		if result:
			return result
	return null


## Áp dụng âm lượng master
func apply_master_volume() -> void:
	var bus_idx = AudioServer.get_bus_index("Master")
	if bus_idx >= 0:
		var volume_db = linear_to_db(settings["master_volume"])
		AudioServer.set_bus_volume_db(bus_idx, volume_db)


## Áp dụng âm lượng music
func apply_music_volume() -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx >= 0:
		var volume_db = linear_to_db(settings["music_volume"])
		AudioServer.set_bus_volume_db(bus_idx, volume_db)


## Áp dụng âm lượng SFX
func apply_sfx_volume() -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx >= 0:
		var volume_db = linear_to_db(settings["sfx_volume"])
		AudioServer.set_bus_volume_db(bus_idx, volume_db)


## Áp dụng fullscreen
func apply_fullscreen() -> void:
	if settings["fullscreen"]:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


## Áp dụng VSync
func apply_vsync() -> void:
	if settings["vsync"]:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)


## Reset settings về mặc định
func reset_settings() -> void:
	settings = DEFAULT_SETTINGS.duplicate()
	apply_all_settings()
	save_data()
