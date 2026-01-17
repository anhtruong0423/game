extends Node

const SAVE_PATH = "user://save_data.cfg"

var coin := 0
var best_score := 0
var last_score := 0


func _ready():
	load_data()


func save_game_result(score: int):
	last_score = score
	if score > best_score:
		best_score = score
		save_data()  # Lưu khi có best score mới


## Lưu dữ liệu vào file
func save_data():
	var config = ConfigFile.new()
	config.set_value("game", "best_score", best_score)
	config.save(SAVE_PATH)


## Load dữ liệu từ file
func load_data():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		best_score = config.get_value("game", "best_score", 0)
