extends Node

const SAVE_PATH = "user://save_data.cfg"

var coin := 0
var best_score := 0
var last_score := 0

## Level system
var current_level: int = 1
var level_stars: Dictionary = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}
var total_coins: int = 0
var last_stars: int = 0
var last_elapsed_time: float = 0.0
var last_star_bonus: int = 0
var has_flashlight: bool = false  ## Đèn pin giữ từ Level 3+

## Tutorial và Pet Selection
var tutorial_completed := false
var selected_pet := ""  ## "fox" hoặc "turtle"
var dialogue_mode := "tutorial"  ## "tutorial" hoặc "level"

## Loading screen
var next_scene_path := ""

## Pet bonuses
const PET_BONUSES = {
	"fox": {
		"speed_bonus": 0.2,
		"sprint_drain_reduction": 0.3,
		"inventory_bonus": 0,
		"dog_damage_reduction": 0.0,
		"passive_heal": 0.0,
		"follow_speed_mult": 2.0,
		"scene_path": "res://scene/fox.tscn"
	},
	"turtle": {
		"speed_bonus": 0.0,
		"sprint_drain_reduction": 0.0,
		"inventory_bonus": 2,
		"dog_damage_reduction": 0.5,
		"passive_heal": 1.0,
		"follow_speed_mult": 0.5,
		"scene_path": "res://scene/turtle.tscn"
	}
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
	total_coins += score
	if score > best_score:
		best_score = score
	save_data()


func save_level_result(level: int, stars: int):
	last_stars = stars
	if stars > level_stars.get(level, 0):
		level_stars[level] = stars
	save_data()


func advance_level():
	if current_level < 6:
		current_level += 1
		save_data()


## Đánh dấu tutorial đã hoàn thành
func complete_tutorial():
	tutorial_completed = true
	save_data()


## Chọn thú cưng
func select_pet(pet_name: String):
	selected_pet = pet_name
	save_data()


## Chuyển scene qua loading screen
func go_to_scene(scene_path: String):
	next_scene_path = scene_path
	get_tree().change_scene_to_file("res://scene/loading.tscn")


## Lấy bonus của thú cưng hiện tại
func get_pet_bonus(bonus_type: String) -> float:
	if selected_pet in PET_BONUSES:
		return float(PET_BONUSES[selected_pet].get(bonus_type, 0.0))
	return 0.0

func get_pet_string_bonus(bonus_type: String) -> String:
	if selected_pet in PET_BONUSES:
		return str(PET_BONUSES[selected_pet].get(bonus_type, ""))
	return ""


## Lưu dữ liệu vào file
func save_data():
	var config = ConfigFile.new()
	config.set_value("game", "best_score", best_score)
	config.set_value("game", "tutorial_completed", tutorial_completed)
	config.set_value("game", "selected_pet", selected_pet)
	config.set_value("game", "current_level", current_level)
	config.set_value("game", "total_coins", total_coins)
	config.set_value("game", "has_flashlight", has_flashlight)
	for level in level_stars:
		config.set_value("level_stars", str(level), level_stars[level])
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
		selected_pet = config.get_value("game", "selected_pet", config.get_value("game", "selected_character", ""))
		current_level = config.get_value("game", "current_level", 1)
		total_coins = config.get_value("game", "total_coins", 0)
		has_flashlight = config.get_value("game", "has_flashlight", false)
		for level in level_stars:
			level_stars[level] = config.get_value("level_stars", str(level), 0)
		for key in settings:
			settings[key] = config.get_value("settings", key, DEFAULT_SETTINGS[key])
	print("[Global] Loaded: level=", current_level, ", tutorial=", tutorial_completed, ", pet=", selected_pet)


## Reset tất cả dữ liệu (dùng để test)
func reset_all_data():
	best_score = 0
	tutorial_completed = false
	selected_pet = ""
	current_level = 1
	total_coins = 0
	has_flashlight = false
	level_stars = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0}
	settings = DEFAULT_SETTINGS.duplicate()
	save_data()
	apply_all_settings()
	# Đảm bảo game không bị kẹt ở trạng thái pause
	get_tree().paused = false
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
